from pytest_terraform import terraform


@terraform("software", scope="session", replay=False)
def test_null(software):
    pass


def test_software(software):
    packages = software.outputs["packages"]
    runcmds = software.outputs["runcmds"]
    assert len(packages) > 0
    assert len(runcmds) > 0


def test_software_test(software):
    # Verify ordering
    runcmds = software.outputs["runcmds_test"]
    assert runcmds["value"] == ["z1", "y2", "x3", "w4", "v5"]


# TODO generate cloud init file?
