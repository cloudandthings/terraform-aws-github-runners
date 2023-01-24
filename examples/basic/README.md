<!-- BEGIN_TF_DOCS -->
----
## main.tf
```hcl
module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  region     = "af-south-1"
  github_url = "https://github.com/my-org"

  # Naming for all created resources
  naming_prefix = "test-github-runner"

  ssm_parameter_name = "/github/runner/token"

  # 2 cores, so 2 ephemeral runners will start in parallel.
  ec2_instance_type = "t3.micro"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]
}
```
----

## Documentation

----
### Inputs

No inputs.

----
### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_runner"></a> [github\_runner](#module\_github\_runner) | ../../ | n/a |

----
### Outputs

No outputs.

----
### Providers

No providers.

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.0.1 |

----
### Resources

No resources.

----
<!-- END_TF_DOCS -->
