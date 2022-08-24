import pytest
from pytest_terraform import terraform

import yaml
import subprocess


@terraform("user_data", scope="session", replay=False)
def test_null(user_data):
    pass


@pytest.mark.parametrize("version", range(1, 2))
def test_user_data_is_valid_yaml(user_data, version):
    out = user_data.outputs[f"user_data_{version}"]
    yaml.safe_load(out["value"])


@pytest.mark.parametrize("version", range(1, 2))
def test_user_data_is_valid_cloud_init(user_data, version, tmp_path):
    out = user_data.outputs[f"user_data_{version}"]
    tmp_file = tmp_path / "hello.txt"
    tmp_file.write_text(out["value"])
    result = subprocess.run(
        ["cloud-init", "schema", "--config-file", tmp_file],
        capture_output=True,
        text=True,
        check=True,
    )
    assert result.returncode == 0
