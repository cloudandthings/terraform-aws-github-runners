# terraform-aws-github-runners

Deploy GitHub Action runners in your AWS Account. Uses AWS CodeBuild to manage ephemeral runners, so you don't have to.

[![GitHub repo link](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/icon.gif )](https://github.com/cloudandthings/terraform-aws-github-runners)

---

[![Maintenance](https://img.shields.io/badge/Maintained-yes-green.svg)](https://github.com/cloudandthings/terraform-aws-github-runners/graphs/commit-activity)
[![Test Status](https://github.com/cloudandthings/terraform-aws-github-runners/actions/workflows/main.yml/badge.svg)](https://github.com/cloudandthings/terraform-aws-github-runners/actions/workflows/main.yml)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.13.0-blue)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

# Previous version notice

Previously, this module used EC2 spot instances with configurable AutoScaling.

Should you wish to continue to use this older approach, the code has been moved to (terraform-aws-github-runners-ec2)[https://github.com/cloudandthings/terraform-aws-github-runners-ec2].

# Features

- Simple! See the provided examples for a quick-start.
- Serverless. No EC2 instances that need to be maintained
- Cost-effective. Only billed for when CodeBuild project is running as projects are billed per build minute.
- Scalable. By default one runner process and 20GB storage is provided per vCPU per EC2 instance.

A full list of created resources is shown below.

# Why?

Deploying self-hosted GitHub runner should be simple.
It shouldn't need a long setup process or a lot of infrastructure.

This module additionally does not require public inbound traffic, and can be easily customised if needed.

# Known limitations

1. Additional config needed if using custom ECR image

If a custom ECR image is used then additional install and config is needed when building the Docker image.
This is because some of the GitHub `uses` actions do not work by default.

# How it works

<!-- TODO update diagram -->

[![Infrastructure diagram](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/runner.svg)](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/runner.svg)

An AWS CodeBuild Project and a webhook is created in a specific GitHub repo. The webhook is used to trigger the build project when a Github Action is triggered. The CodeBuild project run will self-configure as a GitHub runner, and run the job commands in the repo's workflow file.

Steps execute arbitrary commands, defined by your repo workflows.

For example:
 - Perform a linting check.
 - Connect to another AWS Account using an IAM credential and operate on some AWS infrastructure.
 - Anything else...

# How to use it

## 1. Decide on how to authenticate to GitHub

Here we focus on setting up a personal access token to authenticate to GitHub.
OAuth is also supported but not implemented / documented here.

<!-- TODO OAuth -->

### GitHub access token

Note that CodeBuild only supports 1 GitHub token to be configured for all CodeBuild projects in the same AWS Account and Region.

Therefore, when using multiple CodeBuild projects, you can configure the token once per region (not once per project).

There are a few approaches that you could take, choose one from the below.

#### 2. Create your GitHub token

Create a [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
Make sure that the fine grained token has [these](https://docs.aws.amazon.com/codebuild/latest/userguide/access-tokens-github.html#access-tokens-github-prereqs) permissions.


#### 2a. Add the token to CodeBuild separately.

You would add the token as [documented here](https://docs.aws.amazon.com/codebuild/latest/userguide/access-tokens-github.html)
This is recommended if you do not want to maintain the token in Terraform.

#### 2b. Provide the token as an input Terraform variable

Note that although the variable is sensitive, the value will still be stored in Terraform state.

#### 2c. Use AWS Parameter Store

<!-- TODO there seems to be a SecretsManager option in the link above - worth investigating -->

Add the token to AWS Systems Manager Parameter Store, and configure this module to read it.
The module will add the token to Codebuild for you.

This is recommended if you have only a single project.

### Adding your token to Parameter Store (Optional)

Add it to AWS Systems Manager Parameter Store with the `SecureString` type.

[![Parameter Store configuration](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/ssm.png)](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/ssm.png )


## 2. Configure this module

Configure and deploy this module using Terraform. See examples below.

# More info

- Found an issue? Want to help? [Contribute](https://github.com/cloudandthings/terraform-aws-github-runners/.github/contribute.md).

<!-- TODO cost estimate

- Review a [cost estimate](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/cost_estimate.md).

-->

<!-- BEGIN_TF_DOCS -->
## Module Docs

### Basic Example
```hcl
module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  # Naming for all created resources
  name = "github-runner-codebuild-test"
  source_location              = "https://github.com/my-org/my-repo.git"

  # Optional parameters
  ############################
  github_personal_access_token = "example"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]
}
```
### Advanced Example
```hcl
locals {
  naming_prefix = "test-github-runner"
  vpc_id        = "vpc-0ffaabbcc1122"
}

# Create a custom security-group to allow SSH to all EC2 instances
resource "aws_security_group" "this" {
  name        = "${local.naming_prefix}-sg"
  description = "GitHub runner ${local.naming_prefix}-sg"

  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    description = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = local.vpc_id
  #checkov:skip=CKV2_AWS_5:The SG is attached by the module.
  #checkov:skip=CKV_AWS_382:Egress to GitHub Actions is required for the runner to work.
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group_rule" "ssh_ingress" {
  description       = "Allow SSH ingress to EC2 instance"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.this.id
}

module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  source_location                            = "https://github.com/my-org/my-repo.git"
  github_personal_access_token_ssm_parameter = "example"

  # Naming for all created resources
  name = "github-runner-codebuild-test"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]
  # Optional parameters
  ################################

  security_group_ids         = [aws_security_group.this.id]
  use_ecr_image              = true
  cloudwatch_logs_group_name = "/some/log/group"
}
```

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | Number of minutes, from 5 to 2160 (36 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed. | `number` | `5` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `14` | no |
| <a name="input_cloudwatch_logs_group_name"></a> [cloudwatch\_logs\_group\_name](#input\_cloudwatch\_logs\_group\_name) | Name of the log group used by the codebuild project. If blank then a default is used. | `string` | `null` | no |
| <a name="input_cloudwatch_logs_stream_name"></a> [cloudwatch\_logs\_stream\_name](#input\_cloudwatch\_logs\_stream\_name) | Name of the log stream used by the codebuild project. If blank then a default is used. | `string` | `null` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Short description of the project. | `string` | `null` | no |
| <a name="input_environment_compute_type"></a> [environment\_compute\_type](#input\_environment\_compute\_type) | Information about the compute resources the build project will use. Valid values: BUILD\_GENERAL1\_SMALL, BUILD\_GENERAL1\_MEDIUM, BUILD\_GENERAL1\_LARGE, BUILD\_GENERAL1\_2XLARGE, BUILD\_LAMBDA\_1GB, BUILD\_LAMBDA\_2GB, BUILD\_LAMBDA\_4GB, BUILD\_LAMBDA\_8GB, BUILD\_LAMBDA\_10GB. BUILD\_GENERAL1\_SMALL is only valid if type is set to LINUX\_CONTAINER. When type is set to LINUX\_GPU\_CONTAINER, compute\_type must be BUILD\_GENERAL1\_LARGE. When type is set to LINUX\_LAMBDA\_CONTAINER or ARM\_LAMBDA\_CONTAINER, compute\_type must be BUILD\_LAMBDA\_XGB | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_environment_image"></a> [environment\_image](#input\_environment\_image) | Docker image to use for this build project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/amazonlinux2-x86\_64-standard:4.0), Docker Hub images (e.g., hashicorp/terraform:latest). If use\_ecr\_image is set to true, this value will be ignored and the ECR image location will be used. | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Type of build environment to use for related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER, LINUX\_LAMBDA\_CONTAINER, ARM\_LAMBDA\_CONTAINER | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_github_personal_access_token"></a> [github\_personal\_access\_token](#input\_github\_personal\_access\_token) | The GitHub personal access token to use for accessing the repository | `string` | `null` | no |
| <a name="input_github_personal_access_token_ssm_parameter"></a> [github\_personal\_access\_token\_ssm\_parameter](#input\_github\_personal\_access\_token\_ssm\_parameter) | The GitHub personal access token to use for accessing the repository | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role to be used, if one is not given a role will be created | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM service role | `string` | `null` | no |
| <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies) | Map of IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The AWS KMS key to be used | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Created resources will be named with this. | `string` | n/a | yes |
| <a name="input_s3_logs_bucket_name"></a> [s3\_logs\_bucket\_name](#input\_s3\_logs\_bucket\_name) | Name of the S3 bucket to store logs in. If null then logging to S3 will be disabled. | `string` | `null` | no |
| <a name="input_s3_logs_bucket_prefix"></a> [s3\_logs\_bucket\_prefix](#input\_s3\_logs\_bucket\_prefix) | Prefix to use for the logs in the S3 bucket | `string` | `""` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The list of Security Group IDs for AWS Codebuild to launch ephemeral EC2 instances in. | `list(string)` | `[]` | no |
| <a name="input_source_location"></a> [source\_location](#input\_source\_location) | Your source code repo location, for example https://github.com/my/repo.git | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of Subnet IDs for AWS Codebuild to launch ephemeral EC2 instances in. | `list(string)` | `[]` | no |
| <a name="input_use_ecr_image"></a> [use\_ecr\_image](#input\_use\_ecr\_image) | Determines whether the build image will be pulled from ECR, if set to true an ECR repository will be created and an image needs to be pushed to it before running the build project | `string` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID for AWS Codebuild to launch ephemeral instances in. | `string` | `null` | no |

----
### Modules

No modules.

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_project"></a> [codebuild\_project](#output\_codebuild\_project) | Name and ARN of codebuild project, to be used when running GitHub Actions |
| <a name="output_codebuild_role"></a> [codebuild\_role](#output\_codebuild\_role) | Name and ARN of codebuild role, to be used when running GitHub Actions |
| <a name="output_ecr_repository"></a> [ecr\_repository](#output\_ecr\_repository) | Name and ARN of ECR repository, to be used when to push custom docker images for the codebuiild project |

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |

----
### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_source_credential.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_source_credential.string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_webhook.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook) | resource |
| [aws_ecr_lifecycle_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecr_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.networking_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.s3_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudwatch_log_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.networking_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.github_personal_access_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

----

```
<!-- END_TF_DOCS -->
