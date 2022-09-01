import os
import string
import random
import time
import pytest
from mock import patch
import logging
from botocore.config import Config
import boto3
from pytest import mark

from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
from fabric.connection import Connection
from pytest_terraform import terraform

REGION = "eu-west-1"
SOFTWARE_PACK_TEST_CMDS = {
    "docker-engine": "docker version",
    "node": "node --version",
    "pre-commit": "pre-commit --version",
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

os.environ["TF_VAR_public_key"] = pem_public_key.decode()
os.environ["TF_VAR_region"] = REGION

config = Config(region_name=REGION)
ec2 = boto3.client("ec2", config=config)

# Resorting to global vars because pytest_terraform doesn't play nice with Classes.
public_ip = None
instance_id = None


@mark.slow
@terraform("main", scope="session", replay=False)
def test_1_terraform(main):
    logging.info(main.outputs)
    global instance_id
    instance_id = main.outputs["instance_id"]["value"]
    if len(instance_id) == 0:
        raise Exception("instance_id is invalid")

    global public_ip
    public_ip = main.outputs["public_ip"]["value"]
    if len(public_ip) == 0:
        raise Exception("public_ip is invalid")


@mark.slow
@pytest.mark.depends(on=["test_1_terraform"])
@terraform("main", scope="session", replay=False)
def test_2_ec2_starts(main):
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
        if not still_starting or attempt_count >= 6 * 5:
            break
        time.sleep(10)
    assert not still_starting


@mark.slow
@pytest.mark.depends(on=["test_2_ec2_starts"])
@terraform("main", scope="session", replay=False)
def test_3_ec2_tagged(main):
    done = False
    attempt_count = 0
    while not done:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        instances = response["Instances"]
        if len(instances) == 0:
            raise Exception("Instance not found")
        if len(instances) == 1:
            tags = instances[0]["Tags"]
            for tag in tags:
                if tag["Key"] == "terraform-aws-github-runner:setup":
                    done = True
        else:
            raise Exception("Found more than one instance")
        attempt_count = attempt_count + 1
        if done or attempt_count > 6 * 20:
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
        "timeout": 30,
    }
    return Connection(host=host, user=user, connect_kwargs=connect_kwargs)


@mark.slow
@patch("sys.stdin", new=open("/dev/null"))
@pytest.mark.depends(on=["test_3_ec2_starts"])
@terraform("main", scope="session", replay=False)
def test_4_ec2_connection(main):
    connected = False
    attempt_count = 1
    result = None
    while not connected:
        with connection() as c:
            result = c.run("uname -a")
            if result.ok:
                connected = True
        attempt_count = attempt_count + 1
        if connected or attempt_count > 5:
            break
        logging.info(f"{attempt_count=}")
        time.sleep(1)

    logging.info(f"{result=}")
    assert connected


@mark.slow
@pytest.mark.depends(on=["test_4_ec2_connection"])
@patch("sys.stdin", new=open("/dev/null"))
@terraform("main", scope="session", replay=False)
def test_5_ec2_completed(main):
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
        if completed or attempt_count > 6:
            break
        logging.info(f"{attempt_count=}")
        time.sleep(1)

    logging.info(f"{result=}")
    assert completed


@mark.slow
@pytest.mark.depends(on=["test_5_ec2_completed"])
@patch("sys.stdin", new=open("/dev/null"))
@terraform("main", scope="session", replay=False)
def test_6_installed_software(main):
    software_packs = main.outputs["software_packs"]["value"]
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
@pytest.mark.depends(on=['test_6_installed_software'])
@patch("sys.stdin", new=open("/dev/null"))
@terraform("main", scope="session", replay=False)
def test_7_cloud_init_get_logs(main):
    with connection() as c:
        assert c.run("cloud-init collect-logs").ok
        c.get("cloud-init.tar.gz")
        # TODO Add sudo get for user data....
"""

# TODO stack overflow
# env.hosts = [public_ip_address]
# env.user = 'ubuntu'
# env.key_filename = 'test-rsa.pem'

# Use an invalid token...

# Parse cloud-init log for errors
