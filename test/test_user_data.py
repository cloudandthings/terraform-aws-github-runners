import pytest
from pytest_terraform import terraform

import yaml
import subprocess


@terraform("terraform_user_data", scope="session", replay=False)
def test_null(terraform_user_data):
    pass


@pytest.mark.parametrize("version", range(1, 2))
def test_user_data_is_valid_yaml(terraform_user_data, version):
    user_data = terraform_user_data.outputs[f"user_data_{version}"]
    yaml.safe_load(user_data["value"])


@pytest.mark.parametrize("version", range(1, 2))
def test_user_data_is_valid_cloud_init(terraform_user_data, version, tmp_path):
    user_data = terraform_user_data.outputs[f"user_data_{version}"]
    tmp_file = tmp_path / "hello.txt"
    tmp_file.write_text(user_data["value"])
    result = subprocess.run(
        ["cloud-init", "schema", "--config-file", tmp_file],
        capture_output=True,
        text=True,
        check=True,
    )
    assert result.returncode == 0
