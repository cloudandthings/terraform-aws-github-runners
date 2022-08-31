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
