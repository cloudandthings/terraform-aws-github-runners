# terraform-aws-github-runners

Simple to use, self-hosted GitHub Action runners. Uses EC2 spot instances with configurable AutoScaling.

[![GitHub repo link](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/icon.gif )](https://github.com/cloudandthings/terraform-aws-github-runners)

---

[![Maintenance](https://img.shields.io/badge/Maintained-yes-green.svg)](https://github.com/cloudandthings/terraform-aws-github-runners/graphs/commit-activity)
[![Test Status](https://github.com/cloudandthings/terraform-aws-github-runners/actions/workflows/main.yml/badge.svg)](https://github.com/cloudandthings/terraform-aws-github-runners/actions/workflows/main.yml)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.13.0-blue)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

## Features

- Simple! See the provided examples for a quick-start.
- Cost-effective. Uses EC2 Spot pricing and AutoScaling to keep costs low. Runs multiple runners per EC2 instance depending on the number of vCPU available.
- Customisable using [cloudinit](https://cloudinit.readthedocs.io/).
- Scalable. By default one runner process and 20GB storage is provided per vCPU per EC2 instance.

## Why?

Deploying a self-hosted github runner should be simple.
It shouldn't need a long setup process or a lot of infrastructure.

This module additionally does not require public inbound traffic, and can be easily customised if needed.

### Known limitations

1. Needs a VPC.

Currently this module requires a VPC and Subnets for deployment. In future a non-VPC deployment could perhaps be added.

2. Changes may affect the shared EC2 environment.

Parallel runners are ephemeral and their work environment is destroyed after each job is done.
However, they still run on the same underlying EC2 instance.
This means they can make changes which impact each other, for example if the EBS storage gets full.

A possible workaround could be to [run jobs in a container](https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container).

## How it works

[![Infrastructure diagram](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/runner.svg)](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/runner.svg)

An AutoScaling group is created to spin up Spot EC2 instances on a schedule. The instances retrieve a pre-configured GitHub access token from AWS SSM Parameter Store, and start one (or more) ephemeral actions runner processes. These authenticate with GitHub and wait for work.

Steps execute arbitrary commands, defined by your repo workflows.

For example:
 - Perform a linting check.
 - Connect to another AWS Account using an IAM credential and operate on some EC2 or RDS infrastructure.
 - Anything else...


A full list of created resources is shown below.

## How to use it

### 1. Store your GitHub token
Create a [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
Add it to AWS Systems Manager Parameter Store with the `SecureString` type.

[![Parameter Store configuration](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/ssm.png)](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/ssm.png )


### 2. Configure module
Configure and deploy the module using Terraform. See examples below.

## More info

- Found an issue? Want to help? [Contribute](https://github.com/cloudandthings/terraform-aws-github-runners/.github/contribute.md).
- Review a [cost estimate](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/cost_estimate.md).

<!-- BEGIN_TF_DOCS -->
## Module Docs

### Basic Example
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
  region     = "af-south-1"
  github_url = "https://github.com/my-org"

  naming_prefix = local.naming_prefix

  ssm_parameter_name = "/github/runner/token"

  ec2_instance_type = "t3.micro"

  vpc_id     = local.vpc_id
  subnet_ids = ["subnet-0123", "subnet-0456"]

  # Optional parameters
  ################################

  # If for some reason you dont want to install everything.
  software_packs = [
    "BASE_PACKAGES", # Extra utility packages like curl, zip, etc
    "docker-engine",
    "node",
    "python2" # Required for cloudwatch logging
  ]

  ec2_associate_public_ip_address = true
  ec2_key_pair_name               = "my_key_pair"
  security_groups                 = [aws_security_group.this.id]

  autoscaling_max_instance_lifetime = 86400
  autoscaling_min_size              = 2
  autoscaling_desired_size          = 2
  autoscaling_max_size              = 5

  autoscaling_schedule_time_zone = "Africa/Johannesburg"
  # Scale up to desired capacity during work hours
  autoscaling_schedule_on_recurrences = ["0 07 * * MON-FRI"]
  # Scale down to zero after hours
  autoscaling_schedule_off_recurrences = ["0 18 * * *"]

  cloud_init_extra_packages = ["neofetch"]
  cloud_init_extra_runcmds = [
    "echo \"hello world\" > ~/test_file"
  ]

  cloudwatch_log_group = "/some/log/group"
}
```
### Software packs
```hcl
locals {
  # All available software packs
  all = [
    # Contains base packages eg curl, zip, etc
    "BASE_PACKAGES",

    "docker-engine",
    "node",
    "pre-commit",
    "python2",
    "python3",
    "terraform",
    "terraform-docs",
    "tflint",
    "tfsec"
  ]
}
```

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | ----------------------------------------------------- Optional variables ----------------------------------------------------- | `number` | `5` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_environment_compute_type"></a> [environment\_compute\_type](#input\_environment\_compute\_type) | n/a | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_environment_image"></a> [environment\_image](#input\_environment\_image) | n/a | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | n/a | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_logs_config"></a> [logs\_config](#input\_logs\_config) | n/a | <pre>object({<br>    cloudwatch_logs_group_name  = optional(string)<br>    cloudwatch_logs_stream_name = optional(string)<br>    s3_logs_location            = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Created resources will be named with this. | `string` | `"github-runner"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The list of Security Group IDs for AWS Codebuild to launch ephemeral EC2 instances in. | `list(string)` | `[]` | no |
| <a name="input_source_config"></a> [source\_config](#input\_source\_config) | n/a | <pre>list(<br>    object({<br>      location = string<br>      type     = optional(string, "GITHUB")<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of Subnet IDs for AWS Codebuild to launch ephemeral EC2 instances in. | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID for AWS Codebuild to launch ephemeral instances in. | `string` | `null` | no |

----
### Modules

No modules.

----
### Outputs

No outputs.

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.9 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.9 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |

----
### Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_webhook.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

----

```
<!-- END_TF_DOCS -->
