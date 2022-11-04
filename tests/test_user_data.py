import pytest

import yaml
import subprocess

from tests.conftest import terraform_apply_and_output


@pytest.fixture(scope="session")
def output(terraform_config):
    yield from terraform_apply_and_output(__name__, terraform_config)


def test_it(output):
    pass


@pytest.mark.parametrize("version", range(1, 2))
def test_user_data_is_valid_yaml(output, version):
    out = output[f"user_data_{version}"]
    yaml.safe_load(out)


@pytest.mark.parametrize("version", range(1, 2))
def test_user_data_is_valid_cloud_init(output, version, tmp_path):
    out = output[f"user_data_{version}"]
    tmp_file = tmp_path / "hello.txt"
    tmp_file.write_text(out)
    result = subprocess.run(
        ["cloud-init", "schema", "--config-file", tmp_file],
        capture_output=True,
        text=True,
        check=True,
    )
    assert result.returncode == 0
