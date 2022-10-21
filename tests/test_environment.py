import subprocess


def test_cloud_init():
    result = subprocess.run(
        ["cloud-init", "--version"], capture_output=True, text=True, check=True
    )
    assert result.returncode == 0


def test_variables(terraform_default_variables):
    assert terraform_default_variables["run_id"] is not None
