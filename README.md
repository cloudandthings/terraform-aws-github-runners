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
  name = "${local.naming_prefix}-sg"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = local.vpc_id
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
    "docker-engine",
    "node",
    "pre-commit",
    "python2",
    "python3",
    "terraform",
    "terraform-docs",
    "tflint",
  ]
}
```

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | AWS AMI name filter for launching instances. <br> GitHub supports specific operating systems and architectures, including Ubuntu 22.04 amd64 which is the default. <br> Note: The included software packs are not tested with other AMIs. | `string` | `"ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609"` | no |
| <a name="input_autoscaling_desired_size"></a> [autoscaling\_desired\_size](#input\_autoscaling\_desired\_size) | The number of Amazon EC2 instances that should be running.<br>*When `scaling_mode="autoscaling-group"`* | `number` | `1` | no |
| <a name="input_autoscaling_max_instance_lifetime"></a> [autoscaling\_max\_instance\_lifetime](#input\_autoscaling\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service. Values must be either equal to `0` or between `86400` and `31536000` seconds.<br>*When `scaling_mode="autoscaling-group"`* | `string` | `0` | no |
| <a name="input_autoscaling_max_size"></a> [autoscaling\_max\_size](#input\_autoscaling\_max\_size) | The maximum size of the Auto Scaling Group.<br>*When `scaling_mode="autoscaling-group"`* | `number` | `3` | no |
| <a name="input_autoscaling_min_size"></a> [autoscaling\_min\_size](#input\_autoscaling\_min\_size) | The minimum size of the Auto Scaling Group.<br>*When `scaling_mode="autoscaling-group"`* | `number` | `1` | no |
| <a name="input_autoscaling_schedule_off_recurrences"></a> [autoscaling\_schedule\_off\_recurrences](#input\_autoscaling\_schedule\_off\_recurrences) | A list of schedule cron expressions, specifying when the Auto Scaling Group will terminate all instances.<br>Example: `["0 18 * * *"]`<br>*When `scaling_mode="autoscaling-group"`* | `list(string)` | `[]` | no |
| <a name="input_autoscaling_schedule_on_recurrences"></a> [autoscaling\_schedule\_on\_recurrences](#input\_autoscaling\_schedule\_on\_recurrences) | A list of schedule cron expressions, specifying when the Auto Scaling Group will launch instances.<br>Example: `["0 07 * * MON-FRI"]`<br>*When `scaling_mode="autoscaling-group"`* | `list(string)` | `[]` | no |
| <a name="input_autoscaling_schedule_time_zone"></a> [autoscaling\_schedule\_time\_zone](#input\_autoscaling\_schedule\_time\_zone) | The timezone for schedule cron expressions.<br>https://www.joda.org/joda-time/timezones.html<br>*When `scaling_mode="autoscaling-group"`* | `string` | `""` | no |
| <a name="input_cloud_init_extra_other"></a> [cloud\_init\_extra\_other](#input\_cloud\_init\_extra\_other) | Arbitrary text to append to the `cloudinit` script. | `string` | `""` | no |
| <a name="input_cloud_init_extra_packages"></a> [cloud\_init\_extra\_packages](#input\_cloud\_init\_extra\_packages) | A list of strings to append beneath the `packages:` section of the `cloudinit` script.<br>https://cloudinit.readthedocs.io/en/latest/topics/modules.html#package-update-upgrade-install | `list(string)` | `[]` | no |
| <a name="input_cloud_init_extra_runcmds"></a> [cloud\_init\_extra\_runcmds](#input\_cloud\_init\_extra\_runcmds) | A list of strings to append beneath the `runcmd:` section of the `cloudinit` script.<br>https://cloudinit.readthedocs.io/en/latest/topics/modules.html#runcmd | `list(string)` | `[]` | no |
| <a name="input_cloud_init_extra_write_files"></a> [cloud\_init\_extra\_write\_files](#input\_cloud\_init\_extra\_write\_files) | A list of strings to append beneath the `write_files:` section of the `cloudinit` script.<br>https://cloudinit.readthedocs.io/en/latest/topics/modules.html#write-files | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#input\_cloudwatch\_log\_group) | CloudWatch log group name prefix. Runner logs from /var/log/syslog are sent here. <br>Example: `github_runner`, with this value logs will be written to `github_runner/var/log/syslog/<instance_id>`.<br>If left unspecified then logging is disabled. | `string` | `""` | no |
| <a name="input_ec2_associate_public_ip_address"></a> [ec2\_associate\_public\_ip\_address](#input\_ec2\_associate\_public\_ip\_address) | Whether to associate a public IP address with EC2 instances in a VPC. | `bool` | `false` | no |
| <a name="input_ec2_ebs_volume_size"></a> [ec2\_ebs\_volume\_size](#input\_ec2\_ebs\_volume\_size) | Size in GB of instance-attached EBS storage. By default this is set to number of vCPUs per instance * 20 GB. | `number` | `-1` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | Instance type for EC2 instances. | `string` | n/a | yes |
| <a name="input_ec2_key_pair_name"></a> [ec2\_key\_pair\_name](#input\_ec2\_key\_pair\_name) | EC2 Key Pair name to allow SSH to EC2 instances. | `string` | `""` | no |
| <a name="input_github_organisation_name"></a> [github\_organisation\_name](#input\_github\_organisation\_name) | GitHub orgnisation name. Derived from `github_url` by default. | `string` | `""` | no |
| <a name="input_github_runner_group"></a> [github\_runner\_group](#input\_github\_runner\_group) | Custom GitHub runner group. | `string` | `""` | no |
| <a name="input_github_runner_labels"></a> [github\_runner\_labels](#input\_github\_runner\_labels) | Custom GitHub runner labels. <br>Example: `"gpu,x64,linux"`. | `list(string)` | `[]` | no |
| <a name="input_github_url"></a> [github\_url](#input\_github\_url) | GitHub organisation URL.<br>Example: "https://github.com/cloudandthings/". | `string` | n/a | yes |
| <a name="input_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#input\_iam\_instance\_profile\_arn) | IAM Instance Profile to launch EC2 instances with. Must allow permissions to read the SSM Parameter. Will be created by default. | `string` | `""` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Created resources will be prefixed with this. | `string` | `"github-runner"` | no |
| <a name="input_per_instance_runner_count"></a> [per\_instance\_runner\_count](#input\_per\_instance\_runner\_count) | Number of runners per instance. By default this is set equal to the number of vCPUs per instance. May be set to 0 to never create runners. | `number` | `-1` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_scaling_mode"></a> [scaling\_mode](#input\_scaling\_mode) | How instances are managed. <br> Can be either `"autoscaling-group"` or `"single-instance"`. | `string` | `"autoscaling-group"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security groups to assign to EC2 instances.<br>Note: If none are provided, a new security group will be used which will deny inbound traffic **including SSH**. | `list(string)` | `[]` | no |
| <a name="input_software_packs"></a> [software\_packs](#input\_software\_packs) | A list of pre-defined software packs to install.<br>Valid options are: `"ALL"`, `"docker-engine"`, `"node"`, `"python2"`, `"python3"`, `"terraform"`, `"terraform-docs"`, `"tflint"`.<br>An empty list will mean none are installed. | `list(string)` | <pre>[<br>  "ALL"<br>]</pre> | no |
| <a name="input_ssm_parameter_name"></a> [ssm\_parameter\_name](#input\_ssm\_parameter\_name) | SSM parameter name for the GitHub Runner token.<br>Example: "/github/runner/token". | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of Subnet IDs to launch EC2 instances in. <br> If `scaling_mode="single-instance"` then the first Subnet ID from this list will be used. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID to launch instances in. | `string` | n/a | yes |

----
### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_software_packs"></a> [software\_packs](#module\_software\_packs) | ./modules/software | n/a |
| <a name="module_user_data"></a> [user\_data](#module\_user\_data) | ./modules/user_data | n/a |

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_instance_id"></a> [aws\_instance\_id](#output\_aws\_instance\_id) | Instance ID (when `scaled_mode=single-instance`) |
| <a name="output_aws_instance_public_ip"></a> [aws\_instance\_public\_ip](#output\_aws\_instance\_public\_ip) | Instance public IP (when `scaled_mode=single-instance`) |
| <a name="output_per_instance_runner_count"></a> [per\_instance\_runner\_count](#output\_per\_instance\_runner\_count) | Effective per instance runner count. |
| <a name="output_software_packs"></a> [software\_packs](#output\_software\_packs) | List of software packs that were installed. |

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.38.0 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.0.1 |

----
### Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_schedule.off](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_autoscaling_schedule.on](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_cloudwatch_metric_alarm.scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ec2_instance_type.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

----

```
<!-- END_TF_DOCS -->
