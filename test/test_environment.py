import subprocess
from pytest import mark


def test_cloud_init():
    result = subprocess.run(
        ["cloud-init", "--version"], capture_output=True, text=True, check=True
    )
    assert result.returncode == 0


@mark.slow
def test_inputs(inputs):
    assert inputs["run_id"] is not None
