<!-- BEGIN_TF_DOCS -->
----
## main.tf
```hcl
module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  # Naming for all created resources
  name            = "github-runner-codebuild-test"
  source_location = "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"
  source_organization = "cloudandthings"

  # Environment image is not specified so it will default to:
  # "aws/codebuild/amazonlinux2-x86_64-standard:5.0"

  # Optional parameters
  ############################
  description = "Created by my-org/my-runner-repo.git"

  github_personal_access_token = "example"

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.0.1 |

----
### Resources

No resources.

----
<!-- END_TF_DOCS -->
