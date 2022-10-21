import pytest

from tests.conftest import terraform_apply_and_output


@pytest.fixture(scope="session")
def output(terraform_config):
    yield from terraform_apply_and_output(__name__, terraform_config)


def test_it(output):
    pass


def test_software(output):
    packages = output["test_packages"]
    runcmds = output["test_runcmds"]
    assert len(packages) > 0
    assert len(runcmds) > 0


def test_software_order(output):
    runcmds = output["test_order_runcmds"]
    assert ["z1", "y2", "x3", "w4", "v5"] == runcmds


def test_software_all(output):
    software_packs = output["test_all_software_packs"]
    assert "node" in software_packs
    assert "python3" in software_packs
    assert "python2" in software_packs

    packages = output["test_all_packages"]
    assert "nodejs" in packages
    assert "python3" in packages
    assert "python3-venv" in packages
