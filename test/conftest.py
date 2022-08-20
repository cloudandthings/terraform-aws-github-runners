import pytest


def pytest_addoption(parser):
    parser.addoption("--run-id", action="store")
    parser.addoption("--ec2-key-pair-name", action="store", default="")


@pytest.fixture
def inputs(request):
    inputs = {
        "run_id": request.config.getoption("--run-id"),
        "ec2_key_pair_name": request.config.getoption("--ec2-key-pair-name"),
    }
    if inputs["run_id"] is None:
        raise Exception("run_id must be specified.")
    return inputs
