# terraform-aws-github-runers

![alt text](docs/icon.gif "Title" )

Simple, self-hosted github runners deployed via Terraform.

## Features

- Simple to use. There are examples and pre-defined software packs for easy install.
- Runs on EC2. By default, one runner process per vCPU.
- Cost-effective (Using Spot pricing with AutoScaling).
- Customisable using [cloudinit](https://cloudinit.readthedocs.io/).

## How to use

### 1. Store your GitHub token
Add your GitHub personal access token to AWS SSM Parameter Store.

### 2. Configure module
Configure and deploy the module. Examples below.

## Cost Estimate

Assumptions: 
- A single `t3.micro` instance type, which has 2 vCPUs.
- Region is `af-south-1` 
- Autoscaling scehduling is configured as `9 hours` from Mon-Fri (`195.54` instance hours per month)
- EBS Storage: Type is `gp2`, `10GB`, No snapshots

**EC2 monthly cost**

- t3.micro On-Demand hourly cost: `$0.0136`
- Historical average discount for `t3.micro`: 70%
- `195.54` On-Demand instances hours x `0.0136 USD` = `2.66 USD`
- Less 70% Spot discount: `2.66 USD - (2.66 USD x 0.7) = 0.797786 USD`

EC2 monthly subtotal = `0.80 USD`

**EBS monthly cost**

- `195.54 total EC2 hours / 730 hours in a month = 0.27 instance months`
- `10 GB x 0.27 instance months x 0.1309 USD = 0.35 USD (EBS Storage Cost)`

EBS monthly subotal = `0.35 USD`

**Total monthly cost**
 - EC2 monthly subtotal + EBS monthly subtotal
 - `0.80 USD + 0.35 USD = 1.15 USD`

Total monthly cost = `1.15 USD`

<!-- BEGIN_TF_DOCS -->
## Module Docs

### Examples
#### Basic Usage
```hcl
module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
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
#### Advanced Usage
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
    "python3",
  ]

  ec2_associate_public_ip_address = true
  ec2_key_pair_name               = "my_key_pair"
  security_groups                 = [aws_security_group.this.id]

  autoscaling_schedule_time_zone = "Africa/Johannesburg"

  autoscaling_max_instance_lifetime = 86400
  autoscaling_min_size              = 2
  autoscaling_desired_size          = 2
  autoscaling_max_size              = 5
  # Scale up to desired capacity during work hours
  autoscaling_schedule_on_recurrences = ["0 08 * 1-5 *"]
  # Scale down to zero after hours
  autoscaling_schedule_off_recurrences = ["0 18 * * *"]

  cloud_init_extra_packages = ["neofetch"]
  cloud_init_extra_runcmds = [
    "echo \"hello world\" > ~/test_file"
  ]
}
```
----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | AWS AMI name filter for launching instances. GitHub supports specific operating systems and architectures, including Ubuntu 22.04 amd64 which is the default. The included software packs are not tested with other AMIs. | `string` | `"ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609"` | no |
| <a name="input_autoscaling_desired_size"></a> [autoscaling\_desired\_size](#input\_autoscaling\_desired\_size) | The number of Amazon EC2 instances that should be running (when `scaling_mode=autoscaling-group`). | `number` | `1` | no |
| <a name="input_autoscaling_max_instance_lifetime"></a> [autoscaling\_max\_instance\_lifetime](#input\_autoscaling\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service. Values must be either equal to 0 or between 86400 and 31536000 seconds (when `scaling_mode=autoscaling-group`). | `string` | `0` | no |
| <a name="input_autoscaling_max_size"></a> [autoscaling\_max\_size](#input\_autoscaling\_max\_size) | The maximum size of the Auto Scaling Group (when `scaling_mode=autoscaling-group`). | `number` | `3` | no |
| <a name="input_autoscaling_min_size"></a> [autoscaling\_min\_size](#input\_autoscaling\_min\_size) | The minimum size of the Auto Scaling Group (when `scaling_mode=autoscaling-group`). | `number` | `1` | no |
| <a name="input_autoscaling_schedule_off_recurrences"></a> [autoscaling\_schedule\_off\_recurrences](#input\_autoscaling\_schedule\_off\_recurrences) | A list of schedule cron expressions, specifying when the Auto Scaling Group will terminate all instances. Example: ["0 20 * * *"] (when `scaling_mode=autoscaling-group`). | `list(string)` | `[]` | no |
| <a name="input_autoscaling_schedule_on_recurrences"></a> [autoscaling\_schedule\_on\_recurrences](#input\_autoscaling\_schedule\_on\_recurrences) | A list of schedule cron expressions, specifying when the Auto Scaling Group will launch instances. Example: ["0 6 * * *"] (when `scaling_mode=autoscaling-group`). | `list(string)` | `[]` | no |
| <a name="input_autoscaling_schedule_time_zone"></a> [autoscaling\_schedule\_time\_zone](#input\_autoscaling\_schedule\_time\_zone) | The timezone for schedule cron expressions. See https://www.joda.org/joda-time/timezones.html (when `scaling_mode=autoscaling-group`). | `string` | `""` | no |
| <a name="input_cloud_init_extra_other"></a> [cloud\_init\_extra\_other](#input\_cloud\_init\_extra\_other) | Any other text to append to the cloudinit script. | `string` | `""` | no |
| <a name="input_cloud_init_extra_packages"></a> [cloud\_init\_extra\_packages](#input\_cloud\_init\_extra\_packages) | A list of strings to append beneath the `packages:` section of the cloudinit script. See https://cloudinit.readthedocs.io/en/latest/topics/modules.html#package-update-upgrade-install . | `list(string)` | `[]` | no |
| <a name="input_cloud_init_extra_runcmds"></a> [cloud\_init\_extra\_runcmds](#input\_cloud\_init\_extra\_runcmds) | A list of strings to append beneath the `runcmd:` section of the cloudinit script. See https://cloudinit.readthedocs.io/en/latest/topics/modules.html#runcmd . | `list(string)` | `[]` | no |
| <a name="input_cloud_init_extra_write_files"></a> [cloud\_init\_extra\_write\_files](#input\_cloud\_init\_extra\_write\_files) | A list of strings to append beneath the `write_files:` section of the cloudinit script. See https://cloudinit.readthedocs.io/en/latest/topics/modules.html#write-files . | `list(string)` | `[]` | no |
| <a name="input_ec2_associate_public_ip_address"></a> [ec2\_associate\_public\_ip\_address](#input\_ec2\_associate\_public\_ip\_address) | Whether to associate a public IP address with EC2 instances in a VPC. | `bool` | `false` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | Instance type for EC2 instances. | `string` | n/a | yes |
| <a name="input_ec2_key_pair_name"></a> [ec2\_key\_pair\_name](#input\_ec2\_key\_pair\_name) | EC2 Key Pair name to allow SSH to EC2 instances. | `string` | `""` | no |
| <a name="input_github_organisation_name"></a> [github\_organisation\_name](#input\_github\_organisation\_name) | GitHub orgnisation name. Derived from `github_url` by default. | `string` | `""` | no |
| <a name="input_github_runner_group"></a> [github\_runner\_group](#input\_github\_runner\_group) | Custom GitHub runner group. | `string` | `""` | no |
| <a name="input_github_runner_labels"></a> [github\_runner\_labels](#input\_github\_runner\_labels) | Custom GitHub runner labels, for example: "gpu,x64,linux". | `list(string)` | `[]` | no |
| <a name="input_github_url"></a> [github\_url](#input\_github\_url) | GitHub url, for example: "https://github.com/cloudandthings/". | `string` | n/a | yes |
| <a name="input_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#input\_iam\_instance\_profile\_arn) | IAM Instance Profile to launch EC2 instances with. Must allow permissions to read the SSM Parameter. Will be created by default. | `string` | `""` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Created resources will be prefixed with this. | `string` | `"github-runner"` | no |
| <a name="input_scaling_mode"></a> [scaling\_mode](#input\_scaling\_mode) | TODO. How instances should be created and scaled. | `string` | `"autoscaling-group"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security groups to assign to EC2 instances. If none are provided, a new security group will be used, which will deny inbound traffic (including SSH). | `list(string)` | `[]` | no |
| <a name="input_software_packs"></a> [software\_packs](#input\_software\_packs) | A list of pre-defined software packs to install. Valid options are: ["ALL", "docker-engine", "node", "python3", "terraform", "terraform-docs", "tflint"]. An empty list will mean none are installed. | `list(string)` | <pre>[<br>  "ALL"<br>]</pre> | no |
| <a name="input_ssm_parameter_name"></a> [ssm\_parameter\_name](#input\_ssm\_parameter\_name) | SSM Parameter name for the GitHub Runner token. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of Subnet IDs to launch EC2 instances in. If `scaling_mode=single-instance` then the first Subnet ID from this list will be used. | `list(string)` | n/a | yes |
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
| <a name="output_software_packs"></a> [software\_packs](#output\_software\_packs) | List of software packs that were installed. |
----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.27.0 |
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
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
----
```
<!-- END_TF_DOCS -->
