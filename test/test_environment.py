import subprocess


def test_cloud_init():
    result = subprocess.run(
        ["cloud-init", "--version"], capture_output=True, text=True, check=True
    )
    assert result.returncode == 0
