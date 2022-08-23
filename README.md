<!-- BEGIN_TF_DOCS -->
## Module Docs
### Examples

```hcl

```
----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_desired_size"></a> [autoscaling\_desired\_size](#input\_autoscaling\_desired\_size) | TODO | `number` | `1` | no |
| <a name="input_autoscaling_max_size"></a> [autoscaling\_max\_size](#input\_autoscaling\_max\_size) | TODO | `number` | `3` | no |
| <a name="input_autoscaling_min_size"></a> [autoscaling\_min\_size](#input\_autoscaling\_min\_size) | TODO | `number` | `1` | no |
| <a name="input_autoscaling_schedule_off_recurrences"></a> [autoscaling\_schedule\_off\_recurrences](#input\_autoscaling\_schedule\_off\_recurrences) | TODO | `list(string)` | `[]` | no |
| <a name="input_autoscaling_schedule_on_recurrences"></a> [autoscaling\_schedule\_on\_recurrences](#input\_autoscaling\_schedule\_on\_recurrences) | TODO | `list(string)` | `[]` | no |
| <a name="input_autoscaling_time_zone"></a> [autoscaling\_time\_zone](#input\_autoscaling\_time\_zone) | TODO | `string` | `""` | no |
| <a name="input_cloud_init_extra_packages"></a> [cloud\_init\_extra\_packages](#input\_cloud\_init\_extra\_packages) | TODO | `list(string)` | `[]` | no |
| <a name="input_cloud_init_extra_runcmds"></a> [cloud\_init\_extra\_runcmds](#input\_cloud\_init\_extra\_runcmds) | TODO | `list(string)` | `[]` | no |
| <a name="input_cloud_init_install_docker_engine"></a> [cloud\_init\_install\_docker\_engine](#input\_cloud\_init\_install\_docker\_engine) | TODO | `bool` | `true` | no |
| <a name="input_cloud_init_install_python3"></a> [cloud\_init\_install\_python3](#input\_cloud\_init\_install\_python3) | TODO | `bool` | `true` | no |
| <a name="input_ec2_associate_public_ip_address"></a> [ec2\_associate\_public\_ip\_address](#input\_ec2\_associate\_public\_ip\_address) | TODO | `bool` | `false` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | TODO | `string` | `"t3.micro"` | no |
| <a name="input_ec2_key_pair_name"></a> [ec2\_key\_pair\_name](#input\_ec2\_key\_pair\_name) | TODO | `string` | `""` | no |
| <a name="input_github_organisation_name"></a> [github\_organisation\_name](#input\_github\_organisation\_name) | TODO | `string` | n/a | yes |
| <a name="input_github_url"></a> [github\_url](#input\_github\_url) | TODO | `string` | n/a | yes |
| <a name="input_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#input\_iam\_instance\_profile\_arn) | TODO | `string` | n/a | yes |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | TODO | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | TODO | `string` | n/a | yes |
| <a name="input_ssm_parameter_name"></a> [ssm\_parameter\_name](#input\_ssm\_parameter\_name) | TODO | `string` | `"/github/runner/token"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | TODO | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | TODO | `string` | n/a | yes |
----
### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_user_data"></a> [user\_data](#module\_user\_data) | ./modules/user_data | n/a |
----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_autoscaling_group_arn"></a> [aws\_autoscaling\_group\_arn](#output\_aws\_autoscaling\_group\_arn) | TODO |
| <a name="output_aws_launch_configuration_arn"></a> [aws\_launch\_configuration\_arn](#output\_aws\_launch\_configuration\_arn) | TODO |
| <a name="output_aws_security_group_id"></a> [aws\_security\_group\_id](#output\_aws\_security\_group\_id) | TODO |
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
| [aws_launch_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/3.0.1/docs/data-sources/http) | data source |
----
```
<!-- END_TF_DOCS -->
