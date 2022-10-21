import pytest

from tests.conftest import terraform_plan


@pytest.fixture(scope="session")
def plan(terraform_config):
    yield from terraform_plan(__name__, terraform_config)


@pytest.mark.slow
def test_it(plan):
    pass
