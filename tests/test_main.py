import string
import random
import time
import pytest
from mock import patch
import logging
from botocore.config import Config
import boto3

from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
from fabric.connection import Connection

from tests.conftest import terraform_apply_and_output


REGION = "eu-west-1"


@pytest.fixture(scope="session")
def output(terraform_config):
    variables = {"public_key": pem_public_key.decode(), "region": REGION}
    yield from terraform_apply_and_output(
        __name__, terraform_config, variables=variables
    )


SOFTWARE_PACK_TEST_CMDS = {
    "docker-engine": "docker version",
    "node": "node --version",
    "pre-commit": "pre-commit --version",
    "python": "python --version",
    "python2": "python2 --version",
    "python3": "python3 --version",
    "terraform": "terraform --version",
    "terraform-docs": "terraform-docs --version",
    "tflint": "tflint --version",
}

letters = string.ascii_lowercase
private_key_pass = "".join(random.choice(letters) for i in range(10))

# Thanks https://dev.to/aaronktberry/generating-encrypted-key-pairs-in-python-69b
private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
alg = serialization.BestAvailableEncryption(private_key_pass.encode())

encrypted_pem_private_key = private_key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.OpenSSH,
    encryption_algorithm=alg,
)

pem_public_key = private_key.public_key().public_bytes(
    encoding=serialization.Encoding.OpenSSH,
    format=serialization.PublicFormat.OpenSSH,
)

private_key_file = open("test-rsa.pem", "w")
private_key_file.write(encrypted_pem_private_key.decode())
private_key_file.close()

public_key_file = open("test-rsa.pub", "w")
public_key_file.write(pem_public_key.decode())
public_key_file.close()

config = Config(region_name=REGION)
ec2 = boto3.client("ec2", config=config)

public_ip = None
instance_id = None


@pytest.mark.slow
@pytest.mark.dependency()
def test_1_terraform(output):
    logging.info(output)
    global instance_id
    instance_id = output["instance_id"]
    if len(instance_id) == 0:
        raise Exception("instance_id is invalid")

    global public_ip
    public_ip = output["public_ip"]
    if len(public_ip) == 0:
        raise Exception("public_ip is invalid")


@pytest.mark.slow
@pytest.mark.dependency(depends=["test_1_terraform"])
def test_2_ec2_starts(output):
    if instance_id is None:
        raise Exception
    # Wait for instance to be running...
    still_starting = True
    attempt_count = 0
    while still_starting:
        response = ec2.describe_instance_status(
            InstanceIds=[instance_id], IncludeAllInstances=True
        )
        logging.info(f"{response=}")
        x = response["InstanceStatuses"][0]
        instance_state = x["InstanceState"]["Name"]
        instance_status = x["InstanceStatus"]["Status"]
        system_status = x["SystemStatus"]["Status"]

        if instance_state not in ("pending", "running"):
            raise Exception(f"instance_state={instance_state}")
        if instance_status not in ("ok", "initializing"):
            raise Exception(f"instance_status={instance_status}")
        if system_status not in ("ok", "initializing"):
            raise Exception(f"system_status={system_status}")
        if (
            instance_state == "running"
            and instance_status == "ok"
            and system_status == "ok"
        ):
            still_starting = False
        attempt_count = attempt_count + 1
        logging.info(f"{attempt_count=}")
        # Wait up to 5min
        if not still_starting or attempt_count >= 6 * 5:
            break
        time.sleep(10)
    assert not still_starting


@pytest.mark.slow
@pytest.mark.dependency(depends=["test_2_ec2_starts"])
def test_3_ec2_tagged(output):
    done = False
    attempt_count = 0
    while not done:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        logging.info(f"{response=}")
        reservations = response["Reservations"]
        if len(reservations) != 1:
            raise Exception("Reservation for instance not found")
        instances = reservations[0]["Instances"]
        if len(instances) != 1:
            raise Exception("Instance not found")
        tags = instances[0]["Tags"]
        for tag in tags:
            if tag["Key"] == "terraform-aws-github-runner:setup":
                done = True
        attempt_count = attempt_count + 1
        # Wait up to 15 min
        if done or attempt_count > 6 * 15:
            break
        time.sleep(10)
    assert done


def connection():
    if public_ip is None:
        raise Exception
    # Configure SSH connection
    host = public_ip
    user = "ubuntu"
    connect_kwargs = {
        "key_filename": "test-rsa.pem",
        "passphrase": private_key_pass,
        "timeout": 20,
    }
    return Connection(host=host, user=user, connect_kwargs=connect_kwargs)


@pytest.mark.slow
@patch("sys.stdin", new=open("/dev/null"))
@pytest.mark.dependency(depends=["test_3_ec2_tagged"])
def test_4_ec2_connection(output):
    connected = False
    attempt_count = 1
    result = None
    while not connected:
        with connection() as c:
            result = c.run("uname -a")
            if result.ok:
                connected = True
        attempt_count = attempt_count + 1
        # Wait up to 2 min
        if connected or attempt_count > 4:
            break
        logging.info(f"{attempt_count=}")
        time.sleep(1)

    logging.info(f"{result=}")
    assert connected


@pytest.mark.slow
@pytest.mark.dependency(depends=["test_4_ec2_connection"])
@patch("sys.stdin", new=open("/dev/null"))
def test_5_ec2_completed(output):
    completed = False
    attempt_count = 1
    result = None
    while not completed:
        with connection() as c:
            result = c.run("cloud-init status")
            if result.ok:
                logging.info(f"stdout={result.stdout=} {result.stderr=}")
                if "status:" in result.stdout and "done" in result.stdout:
                    completed = True
        attempt_count = attempt_count + 1
        # Wait up to 2 min
        if completed or attempt_count > 4:
            break
        logging.info(f"{attempt_count=}")
        time.sleep(1)

    logging.info(f"{result=}")
    assert completed


@pytest.mark.slow
@pytest.mark.dependency(depends=["test_5_ec2_completed"])
@patch("sys.stdin", new=open("/dev/null"))
def test_6_installed_software(output):
    software_packs = output["software_packs"]
    with connection() as c:
        for software_pack in software_packs:
            logging.info(f"Testing {software_pack=}")
            result = c.run(SOFTWARE_PACK_TEST_CMDS[software_pack])
            logging.info(f"{result.stdout=} {result.stderr=}")
            assert result.ok


"""
# Download cloud-init logs.
# Useful for local debugging.
@mark.slow
@pytest.mark.dependency(depends=['test_6_installed_software'])
@patch("sys.stdin", new=open("/dev/null"))
def test_7_cloud_init_get_logs(output):
    with connection() as c:
        assert c.run("cloud-init collect-logs").ok
        c.get("cloud-init.tar.gz")
        # TODO Add sudo get for user data....
"""
