from pytest_terraform import terraform


@terraform("software", scope="session", replay=False)
def test_software_supported(software):
    packages = software.outputs["packages"]
    runcmds = software.outputs["runcmds"]
    assert len(packages) > 0
    assert len(runcmds) > 0
    # TODO generate cloud init file?
