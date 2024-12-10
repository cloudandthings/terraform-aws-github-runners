<!-- BEGIN_TF_DOCS -->
----
## main.tf
```hcl
module "runners" {
  source = "../../"

  name            = "${var.name}-github-runner"
  source_location = var.source_location

  github_personal_access_token_ssm_parameter = var.github_personal_access_token_ssm_parameter

  # Environment image is not specified so it will default to:
  # "aws/codebuild/amazonlinux2-x86_64-standard:5.0"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  iam_role_policies = {
    "allow_secrets_manager" = aws_iam_policy.secrets_manager.arn,
    "s3_managed_policy"     = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  }
}
```
----

## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_personal_access_token_ssm_parameter"></a> [github\_personal\_access\_token\_ssm\_parameter](#input\_github\_personal\_access\_token\_ssm\_parameter) | The GitHub personal access token to use for accessing the repository | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name used as a prefix for all resources in this module | `string` | n/a | yes |
| <a name="input_source_location"></a> [source\_location](#input\_source\_location) | Your source code repo location, for example https://github.com/my/repo.git | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of Subnet IDs for AWS Codebuild to launch ephemeral EC2 instances in. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID for AWS Codebuild to launch ephemeral instances in. | `string` | n/a | yes |

----
### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_runners"></a> [runners](#module\_runners) | ../../ | n/a |

----
### Outputs

No outputs.

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.0.1 |

----
### Resources

| Name | Type |
|------|------|
| [aws_iam_policy.secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

----
<!-- END_TF_DOCS -->
