# terraform-aws-github-runners

Deploy GitHub Action runners in your AWS Account using serverless AWS CodeBuild.

---

[![Maintenance](https://img.shields.io/badge/Maintained-yes-green.svg)](https://github.com/cloudandthings/terraform-aws-github-runners/graphs/commit-activity)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.13.0-blue)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Pre-commit](https://github.com/cloudandthings/terraform-aws-github-runners/actions/workflows/pre-commit-and-tests.yml/badge.svg)](https://github.com/cloudandthings/terraform-aws-github-runners/actions/workflows/pre-commit-and-tests.yml)
[![Trivy Security Scan](https://github.com/cloudandthings/terraform-aws-github-runners/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/cloudandthings/terraform-aws-github-runners/actions/workflows/trivy-scan.yml)

## Overview

This Terraform module simplifies deployment of self-hosted GitHub Action runners using AWS CodeBuild. Unlike traditional approaches that require managing EC2 instances, this solution is serverless.

### Key Benefits

- **Simple** - Quick setup with minimal configuration (see examples)
- **Serverless** - No EC2 instances to maintain; CodeBuild spins up ephemeral runners on-demand
- **Cost-effective** - Pay only for build minutes when workflows run; zero cost when idle
- **Scalable** - Automatically scales within [AWS CodeBuild quotas](https://docs.aws.amazon.com/codebuild/latest/userguide/limits.html)
- **Secure** - No public inbound traffic required

### Ideal Use Cases

This module is best for projects with infrequent CI/CD runs or long idle periods. For many projects, CI/CD runs sporadically, making the pay-per-minute model of CodeBuild more economical than continuously running EC2 instances.

## How It Works

When a GitHub Action is triggered in your repository:

1. A webhook notifies the AWS CodeBuild project
2. CodeBuild spins up an ephemeral runner environment (optionally, within your VPC)
3. The runner self-configures and connects to GitHub
4. Your workflow jobs execute in the CodeBuild environment
5. The runner terminates after job completion

## Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- GitHub repository with appropriate permissions
- Terraform >= 0.13.0


### Step 1: Setup GitHub Authentication

Configure authentication between AWS and GitHub to enable secure communication.

Follow the detailed setup guide: [GitHub Authentication Setup](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/GITHUB-AUTH-SETUP.md)


### Step 2: Deploy the Module

Configure and deploy this module using Terraform. Check the examples directory for quick-start templates.

```hcl
module "github_runner" {
  source = "cloudandthings/github-runners/aws"

  # Your configuration here
}
```

### Step 3: Update Your Workflow

Modify your GitHub workflow file to use the CodeBuild runner:

```yaml
jobs:
  my-job:
    # The runner label below will trigger CodeBuild to run this job
    runs-on: codebuild-${{ RUNNER_NAME }}-${{ github.run_id }}-${{ github.run_attempt }}
    steps:
      - uses: actions/checkout@v3
      - name: Run your commands
        run: echo "Running on CodeBuild!"
```

Replace `RUNNER_NAME` with the name you configured for your runner.

The runner label is also added as a description on the CodeBuild project.

## Docker Image Configuration

### Default Images

The module automatically selects an appropriate default Docker image:

- **Default**: `aws/codebuild/amazonlinux2-x86_64-standard:5.0` (when not using ECR)
- **ECR**: Assumes an image tagged `latest` exists in your ECR repository

### Using Custom Images

Specify a custom Docker image via the `environment_image` variable:

**CodeBuild images:**
```hcl
environment_image = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
```

**Docker Hub images:**
```hcl
environment_image = "hashicorp/terraform:latest"
```

**Amazon ECR images:**
```hcl
environment_image = "137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest"
```


### Amazon ECR Setup

To use Amazon ECR:

1. Provide an existing ECR repository name, or let the module create one
2. Ensure an image with the `latest` tag exists, or specify a different tag in `environment_image`
3. The final image URI is available as an output variable for verification

**Note**: If using a custom ECR image, you may need additional configuration in your Dockerfile since some GitHub `uses` actions may not work by default.

## Known Limitations

### 1. Custom ECR Images Require Additional Setup

When using custom ECR images, some GitHub `uses` actions may not work out of the box. Additional installation and configuration steps may be needed in your Dockerfile to ensure compatibility with GitHub Actions.

### 2. Cost Considerations for High-Volume Projects

CodeBuild charges per build minute. While this module is highly cost-effective for projects with infrequent builds, it may not be economical for repositories with:
- Frequent commits and builds
- Very long-running workflows
- Numerous parallel jobs

Use the [AWS Pricing Calculator](https://calculator.aws.amazon.com/) to estimate costs for your specific use case.

## Migration from EC2 Version

This module previously used EC2 spot instances with configurable AutoScaling. If you wish to continue using the EC2-based approach, the code has been moved to a separate repository:

**[terraform-aws-github-runners-ec2](https://github.com/cloudandthings/terraform-aws-github-runners-ec2)**


## Troubleshooting

Having issues? Check out our [Troubleshooting Guide](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/TROUBLESHOOTING.md) for common problems and solutions.

## Contributing

Found an issue or want to contribute? See [CONTRIBUTING.md](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/CONTRIBUTING.md) for guidelines.

Please note that this project has a [Code of Conduct](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Security

For security concerns, please review our [Security Policy](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/SECURITY.md). To report a vulnerability, please use [GitHub Security Advisories](https://github.com/cloudandthings/terraform-aws-github-runners/security/advisories/new).

## Resources

- [GitHub Authentication Setup Guide](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/GITHUB-AUTH-SETUP.md)
- [Troubleshooting Guide](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/TROUBLESHOOTING.md)
- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**License**: [View License](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/LICENSE)

<!-- BEGIN_TF_DOCS -->
## Module Docs

### Basic Example
```hcl
module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  # Naming for all created resources
  name            = "github-runner-codebuild-test"
  source_location = "https://github.com/my-org/my-repo.git"

  # Environment image is not specified so it will default to:
  # "aws/codebuild/amazonlinux2-x86_64-standard:5.0"

  # Optional parameters
  ############################
  description = "Created by my-org/my-runner-repo.git"

  # testing purposes only
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
  vpc_cidr      = "10.0.0.0/16"
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

# Create a baseline CodeBuild credential that all GitHub projects will use by default
resource "aws_codebuild_source_credential" "github" {
  auth_type   = "SECRETS_MANAGER"
  server_type = "GITHUB"
  token       = "arn:aws:secretsmanager:region:account-id:secret:name"
}

module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  source_location = "https://github.com/my-org/my-repo.git"

  # Naming for all created resources
  name = "github-runner-codebuild-test"

  # Environment image is not specified so it will default to:
  # "${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/${local.ecr_repository_name}:latest"
  # Because an ECR repo is used

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]

  # Optional parameters
  ################################
  description = "Created by my-org/my-runner-repo.git"

  create_ecr_repository = true

  # Override the baseline CodeBuild credential
  source_auth = {
    type     = "SECRETS_MANAGER"
    resource = "arn:aws:secretsmanager:af-south-1:123456789012:secret:my-github-oauth-token-secret-nwYBWW"
  }

  security_group_ids         = [aws_security_group.this.id]
  cloudwatch_logs_group_name = "/some/log/group"
}

# Example: Using the default security group with custom ingress rules for Packer
module "github_runner_with_packer" {
  source = "../../"

  # Required parameters
  source_location = "https://github.com/my-org/my-repo.git"
  name            = "github-runner-packer"

  # VPC configuration
  vpc_id     = local.vpc_id
  subnet_ids = ["subnet-0123", "subnet-0456"]

  # Custom ingress rules added to the default security group
  # This is useful when running Packer which requires ephemeral ports for WinRM/SSH
  ingress_with_cidr_blocks = [
    {
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      description = "Ephemeral ports required for Packer WinRM/SSH communication"
      cidr_blocks = [local.vpc_cidr]
    },
    {
      from_port   = 5985
      to_port     = 5986
      protocol    = "tcp"
      description = "WinRM ports for Packer"
      cidr_blocks = [local.vpc_cidr]
    }
  ]
}
```

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | Number of minutes, from 5 to 2160 (36 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed. | `number` | `5` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `14` | no |
| <a name="input_cloudwatch_logs_group_name"></a> [cloudwatch\_logs\_group\_name](#input\_cloudwatch\_logs\_group\_name) | Name of the log group used by the CodeBuild project. If not specified then a default is used. | `string` | `null` | no |
| <a name="input_cloudwatch_logs_stream_name"></a> [cloudwatch\_logs\_stream\_name](#input\_cloudwatch\_logs\_stream\_name) | Name of the log stream used by the CodeBuild project. If not specified then a default is used. | `string` | `null` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_create_ecr_repository"></a> [create\_ecr\_repository](#input\_create\_ecr\_repository) | If set to true then an ECR repository will be created, and an image needs to be pushed to it before running the build project | `string` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Short description of the project. | `string` | `null` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | Name of the ECR repository to create or use. If not specified and `create_ecr_repository` is true, then a default is used. | `string` | `null` | no |
| <a name="input_environment_compute_type"></a> [environment\_compute\_type](#input\_environment\_compute\_type) | Information about the compute resources the build project will use. Valid values: `BUILD_GENERAL1_SMALL`, `BUILD_GENERAL1_MEDIUM`, `BUILD_GENERAL1_LARGE`, `BUILD_GENERAL1_2XLARGE`, `BUILD_LAMBDA_1GB`, `BUILD_LAMBDA_2GB`, `BUILD_LAMBDA_4GB`, `BUILD_LAMBDA_8GB`, `BUILD_LAMBDA_10GB`. `BUILD_GENERAL1_SMALL` is only valid if type is set to `LINUX_CONTAINER`. When type is set to `LINUX_GPU_CONTAINER`, compute\_type must be `BUILD_GENERAL1_LARGE`. When type is set to `LINUX_LAMBDA_CONTAINER` or `ARM_LAMBDA_CONTAINER`, compute\_type must be `BUILD_LAMBDA_XGB` | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_environment_image"></a> [environment\_image](#input\_environment\_image) | Docker image to use for this build project. Valid values include Docker images provided by CodeBuild (e.g `aws/codebuild/amazonlinux2-x86_64-standard:4.0`), Docker Hub images (e.g., `hashicorp/terraform:latest`) and full Docker repository URIs such as those for ECR (e.g., `137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest`). If not specified and not using ECR, then a default CodeBuild image is used, or if using ECR then an ECR image with a `latest` tag is used. | `string` | `null` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Type of build environment to use for related builds. Valid values: `LINUX_CONTAINER`, `LINUX_GPU_CONTAINER`, `WINDOWS_CONTAINER` (deprecated), `WINDOWS_SERVER_2019_CONTAINER`, `ARM_CONTAINER`, `LINUX_LAMBDA_CONTAINER`, `ARM_LAMBDA_CONTAINER` | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_github_codeconnection_arn"></a> [github\_codeconnection\_arn](#input\_github\_codeconnection\_arn) | ARN of an active GitHub app CodeConnection to use for the region-wide CodeBuild Source Credential. See `docs/GITHUB-AUTH-SETUP.md` for more information. | `string` | `null` | no |
| <a name="input_github_personal_access_token"></a> [github\_personal\_access\_token](#input\_github\_personal\_access\_token) | The GitHub personal access token for the region-wide CodeBuild Source Credential. See `docs/GITHUB-AUTH-SETUP.md` for more information. | `string` | `null` | no |
| <a name="input_github_personal_access_token_ssm_parameter"></a> [github\_personal\_access\_token\_ssm\_parameter](#input\_github\_personal\_access\_token\_ssm\_parameter) | SSM parameter containing the GitHub personal access token to use for the region-wide CodeBuild Source Credential. See `docs/GITHUB-AUTH-SETUP.md` for more information. | `string` | `null` | no |
| <a name="input_github_secretsmanager_secret_arn"></a> [github\_secretsmanager\_secret\_arn](#input\_github\_secretsmanager\_secret\_arn) | The Secret ARN containing the credentials to use for the region-wide CodeBuild Source Credential. See `docs/GITHUB-AUTH-SETUP.md` for more information. | `string` | `null` | no |
| <a name="input_iam_role_assume_role_policy"></a> [iam\_role\_assume\_role\_policy](#input\_iam\_role\_assume\_role\_policy) | The IAM role assume role policy document to use. If not specified then a default is used. | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role to be used. If not specified then a role will be created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of the IAM role. If not specified then the default of '/' is used. | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM service role | `string` | `null` | no |
| <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies) | Map of IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_ingress_with_cidr_blocks"></a> [ingress\_with\_cidr\_blocks](#input\_ingress\_with\_cidr\_blocks) | List of ingress rules to add to the default security group with CIDR blocks | <pre>list(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    description = string<br/>    cidr_blocks = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_ingress_with_source_security_group_id"></a> [ingress\_with\_source\_security\_group\_id](#input\_ingress\_with\_source\_security\_group\_id) | List of ingress rules to add to the default security group with source security group IDs | <pre>list(object({<br/>    from_port                = number<br/>    to_port                  = number<br/>    protocol                 = string<br/>    description              = string<br/>    source_security_group_id = string<br/>  }))</pre> | `[]` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The AWS KMS key to be used | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Created resources will be named with this. | `string` | n/a | yes |
| <a name="input_privileged_mode"></a> [privileged\_mode](#input\_privileged\_mode) | Whether to enable running the Docker daemon inside a Docker container. Set to true if the build project needs to build Docker images or run Docker containers (e.g., via docker-compose, Testcontainers, or LocalStack). | `bool` | `false` | no |
| <a name="input_s3_logs_bucket_name"></a> [s3\_logs\_bucket\_name](#input\_s3\_logs\_bucket\_name) | Name of the S3 bucket to store logs in. If not specified then logging to S3 will be disabled. | `string` | `null` | no |
| <a name="input_s3_logs_bucket_prefix"></a> [s3\_logs\_bucket\_prefix](#input\_s3\_logs\_bucket\_prefix) | Prefix to use for the logs in the S3 bucket | `string` | `""` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The list of Security Group IDs for AWS CodeBuild to launch ephemeral EC2 instances in. | `list(string)` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on created Security Group. Defaults to `name` | `string` | `null` | no |
| <a name="input_source_auth"></a> [source\_auth](#input\_source\_auth) | Override the default CodeBuild source credential for this project. This allows using project-specific authentication instead of the account/region baseline credential. See docs/GITHUB-AUTH-SETUP.md for usage details. | <pre>object({<br/>    type     = string<br/>    resource = string<br/>  })</pre> | `null` | no |
| <a name="input_source_location"></a> [source\_location](#input\_source\_location) | Your source code repo location, for example https://github.com/my/repo.git, or `CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION` for org-level webhooks. | `string` | n/a | yes |
| <a name="input_source_organization"></a> [source\_organization](#input\_source\_organization) | Your GitHub organization name for organization-level webhook creation. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of Subnet IDs for AWS CodeBuild to launch ephemeral EC2 instances in. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources created by this module. If configured with a provider `default_tags` configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID for AWS CodeBuild to launch ephemeral instances in. | `string` | `null` | no |

----
### Modules

No modules.

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_security_group_id"></a> [aws\_security\_group\_id](#output\_aws\_security\_group\_id) | ID of the security group created for the CodeBuild project |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch log group for the CodeBuild project |
| <a name="output_codebuild_project_arn"></a> [codebuild\_project\_arn](#output\_codebuild\_project\_arn) | ARN of the CodeBuild project, to be used when running GitHub Actions |
| <a name="output_codebuild_project_name"></a> [codebuild\_project\_name](#output\_codebuild\_project\_name) | Name of the CodeBuild project, to be used when running GitHub Actions |
| <a name="output_codebuild_role_name"></a> [codebuild\_role\_name](#output\_codebuild\_role\_name) | Name of the CodeBuild role, to be used when running GitHub Actions |
| <a name="output_ecr_repository_name"></a> [ecr\_repository\_name](#output\_ecr\_repository\_name) | Name of the ECR repository, to be used when to push custom docker images for the CodeBuild project |
| <a name="output_environment_image"></a> [environment\_image](#output\_environment\_image) | Docker image used for this CodeBuild project |

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5, < 7 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5, < 7 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |

----
### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_source_credential.codeconnection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_source_credential.secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_source_credential.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_source_credential.string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_webhook.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook) | resource |
| [aws_ecr_lifecycle_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.codeconnection_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecr_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.networking_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.s3_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ingress_with_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_with_source_security_group_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_security_group_egress_rule.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudwatch_log_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codeconnection_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.networking_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.github_personal_access_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

----

```
<!-- END_TF_DOCS -->
