<!-- BEGIN_TF_DOCS -->
----
## main.tf
```hcl
module "runners" {
  for_each = var.source_locations

  source = "../../"

  name            = "${each.value.source_name}-github-runner"
  source_location = each.value.source_location

  github_personal_access_token_ssm_parameter = var.github_personal_access_token_ssm_parameter

  # Environment image is not specified so it will default to:
  # "aws/codebuild/amazonlinux2-x86_64-standard:5.0"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
}
```
----

## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_personal_access_token_ssm_parameter"></a> [github\_personal\_access\_token\_ssm\_parameter](#input\_github\_personal\_access\_token\_ssm\_parameter) | The GitHub personal access token to use for accessing the repository | `string` | n/a | yes |
| <a name="input_source_locations"></a> [source\_locations](#input\_source\_locations) | Map of source locations to use when creating runners | <pre>map(object({<br>    source_location = string<br>    source_name     = string<br>  }))</pre> | <pre>{<br>  "example-1": {<br>    "source_location": "https://github.com/my-org/example-1.git",<br>    "source_name": "example-1"<br>  },<br>  "example-2": {<br>    "source_location": "https://github.com/my-org/example-2.git",<br>    "source_name": "example-2"<br>  }<br>}</pre> | no |
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
