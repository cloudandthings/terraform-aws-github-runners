from pytest_terraform import terraform


@terraform("software", scope="session", replay=False)
def test_null(software):
    pass


def test_software(software):
    packages = software.outputs["test_packages"]
    runcmds = software.outputs["test_runcmds"]
    assert len(packages) > 0
    assert len(runcmds) > 0


def test_software_order(software):
    runcmds = software.outputs["test_order_runcmds"]
    assert runcmds["value"] == ["z1", "y2", "x3", "w4", "v5"]


def test_software_default(software):
    runcmds = software.outputs["test_default_packages"]
    assert "nodejs" in runcmds["value"]
    assert "python3" in runcmds["value"]
    assert "python3-venv" in runcmds["value"]


# TODO generate cloud init file?
