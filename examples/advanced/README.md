<!-- BEGIN_TF_DOCS -->
----
## main.tf
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

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.0.1 |

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
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ssh_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/3.0.1/docs/data-sources/http) | data source |

----
<!-- END_TF_DOCS -->
