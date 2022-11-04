# Running tests

```sh
pytest -m 'not slow'
```
or

```sh
pytest -m 'slow'
```

While the tests are running, CTRL-C can be used to kill the tests and automatically destroy all created infrastructure.

# Testing interactively

These tests can easily be run interactively as follows:

- Configure `terraform.tfvars` in a test folder

- Configure AWS credentials

- Create SSM Parameter (optional)

- Configure AWS region: `export AWS_DEFAULT_REGION=x`

- Run `terraform apply` in a test folder
