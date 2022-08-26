<!-- BEGIN_TF_DOCS -->
## Module Docs
### Examples

```hcl
module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  github_url = "https://github.com/my-org"

  naming_prefix = "test-github-runner"

  ec2_instance_type = "t3.micro"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]

  # Optional parameters
  ################################
  iam_instance_profile_arn = "arn:aws:iam::112233445566:role/terraform-aws-github-runners"

  software_packs = [
    "docker-engine",
    "node",
    "python3",
  ]

  ssm_parameter_name = "my/parameter"

  autoscaling_schedule_time_zone       = "Africa/Johannesburg"
  autoscaling_schedule_off_recurrences = ["0 20 * * *"]
  autoscaling_schedule_on_recurrences  = ["0 6 * * *"]
}
```
----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | AWS AMI name filter for launching instances. GitHub supports specific operating systems and architectures, including Ubuntu 22.04 amd64 which is the default. The included software packs are not tested with other AMIs. | `string` | `"ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609"` | no |
| <a name="input_autoscaling_desired_size"></a> [autoscaling\_desired\_size](#input\_autoscaling\_desired\_size) | The number of Amazon EC2 instances that should be running in the group. | `number` | `1` | no |
| <a name="input_autoscaling_max_instance_lifetime"></a> [autoscaling\_max\_instance\_lifetime](#input\_autoscaling\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service. Values must be either equal to 0 or between 86400 and 31536000 seconds. | `string` | `0` | no |
| <a name="input_autoscaling_max_size"></a> [autoscaling\_max\_size](#input\_autoscaling\_max\_size) | The maximum size of the Auto Scaling Group. | `number` | `3` | no |
| <a name="input_autoscaling_min_size"></a> [autoscaling\_min\_size](#input\_autoscaling\_min\_size) | The minimum size of the Auto Scaling Group. | `number` | `1` | no |
| <a name="input_autoscaling_schedule_off_recurrences"></a> [autoscaling\_schedule\_off\_recurrences](#input\_autoscaling\_schedule\_off\_recurrences) | A list of schedule cron expressions, specifying when the Auto Scaling Group will terminate all instances. Example: ["0 20 * * *"] | `list(string)` | `[]` | no |
| <a name="input_autoscaling_schedule_on_recurrences"></a> [autoscaling\_schedule\_on\_recurrences](#input\_autoscaling\_schedule\_on\_recurrences) | A list of schedule cron expressions, specifying when the Auto Scaling Group will launch instances. Example: ["0 6 * * *"] | `list(string)` | `[]` | no |
| <a name="input_autoscaling_schedule_time_zone"></a> [autoscaling\_schedule\_time\_zone](#input\_autoscaling\_schedule\_time\_zone) | The timezone for schedule cron expressions. See https://www.joda.org/joda-time/timezones.html . | `string` | `""` | no |
| <a name="input_cloud_init_extra_other"></a> [cloud\_init\_extra\_other](#input\_cloud\_init\_extra\_other) | Any other text to append to the cloudinit script. | `string` | `""` | no |
| <a name="input_cloud_init_extra_packages"></a> [cloud\_init\_extra\_packages](#input\_cloud\_init\_extra\_packages) | A list of strings to append beneath the `packages:` section of the cloudinit script. See https://cloudinit.readthedocs.io/en/latest/topics/modules.html#package-update-upgrade-install . | `list(string)` | `[]` | no |
| <a name="input_cloud_init_extra_runcmds"></a> [cloud\_init\_extra\_runcmds](#input\_cloud\_init\_extra\_runcmds) | A list of strings to append beneath the `runcmd:` section of the cloudinit script. See https://cloudinit.readthedocs.io/en/latest/topics/modules.html#runcmd . | `list(string)` | `[]` | no |
| <a name="input_ec2_associate_public_ip_address"></a> [ec2\_associate\_public\_ip\_address](#input\_ec2\_associate\_public\_ip\_address) | Whether to associate a public IP address with instances in a VPC. | `bool` | `false` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | EC2 instance type for launched instances. | `string` | n/a | yes |
| <a name="input_ec2_key_pair_name"></a> [ec2\_key\_pair\_name](#input\_ec2\_key\_pair\_name) | EC2 Key Pair name to allow SSH to launched instances. | `string` | `""` | no |
| <a name="input_github_organisation_name"></a> [github\_organisation\_name](#input\_github\_organisation\_name) | GitHub orgnisation name. Derived from `github_url` by default. | `string` | `""` | no |
| <a name="input_github_runner_group"></a> [github\_runner\_group](#input\_github\_runner\_group) | Custom GitHub runner group. | `string` | `""` | no |
| <a name="input_github_runner_labels"></a> [github\_runner\_labels](#input\_github\_runner\_labels) | Custom GitHub runner labels, for example: "gpu,x64,linux". | `list(string)` | `[]` | no |
| <a name="input_github_runner_name"></a> [github\_runner\_name](#input\_github\_runner\_name) | Custom GitHub runner name. | `string` | `""` | no |
| <a name="input_github_url"></a> [github\_url](#input\_github\_url) | GitHub url, for example: "https://github.com/cloudandthings/". | `string` | n/a | yes |
| <a name="input_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#input\_iam\_instance\_profile\_arn) | IAM Instance Profile to launch the instance with. Must allow permissions to read the SSM Parameter. Will be created by default. | `string` | `""` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Created resources will be prefixed with this. | `string` | `"github-runner"` | no |
| <a name="input_software_packs"></a> [software\_packs](#input\_software\_packs) | A list of pre-defined software packs to install. Valid options are: ["\_\_DEFAULT\_\_", "docker-engine", "node", "python3", "terraform", "terraform-docs", "tflint"] | `list(string)` | <pre>[<br>  "__DEFAULT__"<br>]</pre> | no |
| <a name="input_ssm_parameter_name"></a> [ssm\_parameter\_name](#input\_ssm\_parameter\_name) | SSM Parameter name for the GitHub Runner token. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of Subnet IDs to launch EC2 instances in. If `autoscaling_enabled=false` then the first Subnet ID from this list will be used. | `list(string)` | n/a | yes |
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
| <a name="output_aws_autoscaling_group_arn"></a> [aws\_autoscaling\_group\_arn](#output\_aws\_autoscaling\_group\_arn) | The Auto Scaling Group ARN. |
| <a name="output_aws_launch_template_arn"></a> [aws\_launch\_template\_arn](#output\_aws\_launch\_template\_arn) | The EC2 launch template. |
| <a name="output_aws_security_group_id"></a> [aws\_security\_group\_id](#output\_aws\_security\_group\_id) | The Security Group ID associated with EC2 instances. |
----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.27.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.0.1 |
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
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/3.0.1/docs/data-sources/http) | data source |
----
```
<!-- END_TF_DOCS -->
