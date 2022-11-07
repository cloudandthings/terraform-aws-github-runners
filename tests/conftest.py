# flake8: noqa
import pytest
import tftest
import os
import logging
import json
import yaml

DEFAULT_CONFIG_FILE = ".pytest_config.yaml"


# Monkeypatch
def cleanup_github_rubbish(in_):
    out = in_
    if in_.find("{"):
        out = in_[in_.find("{") : in_.rfind("}")]
        if out.find("::debug"):
            out = out[: out.find("::debug")]
        if out.find("::set-output"):
            out = out[: out.find("::set-output")]
    return out


def pytest_addoption(parser):
    parser.addoption("--config-file", action="store", default=DEFAULT_CONFIG_FILE)
    parser.addoption("--terraform-binary", action="store", default="terraform")


@pytest.fixture(scope="session")
def config_file(request):
    return request.config.getoption("--config-file")


@pytest.fixture(scope="session")
def config(config_file) -> dict:
    if config_file is None:
        return {}
    if os.path.isfile(config_file):
        with open(config_file, "r") as f:
            return yaml.safe_load(f)
    elif config_file == DEFAULT_CONFIG_FILE:
        return {}
    else:
        raise FileNotFoundError(config_file)


@pytest.fixture(scope="session")
def terraform_default_variables(request, config):
    """Return default Terraform variables."""
    variables = {}
    for name, value in config.get("variables", {}).items():
        variables[name] = value
    return variables


def terraform_examples_dir():
    return os.path.join(os.getcwd(), "examples")


def terraform_tests_dir():
    return os.path.join(os.getcwd(), "tests", "terraform")


@pytest.fixture(scope="session")
def terraform_binary(request):
    """Return path to Terraform binary."""
    return request.config.getoption("--terraform-binary")


@pytest.fixture(scope="session")
def terraform_tests():
    """Return a list of tests, i.e subdirectories in `tests/terraform/`."""
    directory = terraform_tests_dir()
    return [f.name for f in os.scandir(directory) if f.is_dir()]


@pytest.fixture(scope="session")
def terraform_examples():
    """Return a list of examples, i.e subdirectories in `examples/`."""
    directory = terraform_examples_dir()
    return [f.name for f in os.scandir(directory) if f.is_dir()]


@pytest.fixture(scope="session")
def terraform_config(
    terraform_binary, terraform_tests, terraform_examples, terraform_default_variables
):
    """Convenience fixture for passing around config."""
    config = {
        "terraform_binary": terraform_binary,
        "terraform_tests": terraform_tests,
        "terraform_examples": terraform_examples,
        "terraform_default_variables": terraform_default_variables,
    }
    logging.info(config)
    return config


def get_tf(test_name, terraform_config, variables=None):
    """Construct and return `tftest.TerraformTest`, for executing Terraform commands."""
    basedir = None
    if "." in test_name:  # Called with __name__, eg tests.test_examples_basic
        test_name = test_name.split(".")[-1]
        if test_name.startswith("test_"):
            test_name = test_name[len("test_") :]
    if test_name.startswith("examples_"):
        basedir = terraform_examples_dir()
        test_name = test_name[len("examples_") :].replace("_", "-")
    elif test_name in terraform_config["terraform_tests"]:
        basedir = terraform_tests_dir()
    logging.info(f"{basedir=} {test_name=}")

    tf = tftest.TerraformTest(
        tfdir=test_name, basedir=basedir, binary=terraform_config["terraform_binary"]
    )
    tf._plan_formatter = lambda out: tftest.TerraformPlanOutput(
        json.loads(cleanup_github_rubbish(out))
    )
    tf._output_formatter = lambda out: tftest.TerraformValueDict(
        json.loads(cleanup_github_rubbish(out))
    )
    # Populate test.auto.tfvars.json with the specified variables
    variables = variables or {}
    variables = {**terraform_config["terraform_default_variables"], **variables}
    with open(os.path.join(basedir, test_name, "test.auto.tfvars.json"), "w") as f:
        json.dump(variables, f)
    tf.setup()
    return tf


def terraform_plan(test_name, terraform_config, variables=None):
    """Run `terraform plan -out`, returning the plan output."""
    tf = get_tf(test_name, terraform_config, variables=variables)
    yield tf.plan(output=True)


def terraform_apply_and_output(test_name, terraform_config, variables=None):
    """Run `terraform_apply` and then `terraform output`, returning the output."""
    tf = get_tf(test_name, terraform_config, variables=variables)
    try:
        tf.apply()
        yield tf.output()
    # Shorten the default exception message.
    except tftest.TerraformTestError as e:
        tf.destroy(**{"auto_approve": True})
        raise tftest.TerraformTestError(e.cmd_error) from e
    finally:
        tf.destroy(**{"auto_approve": True})
