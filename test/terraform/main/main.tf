data "aws_caller_identity" "current" {
  provider = aws
}

resource "null_resource" "tf_guard_provider_account_match" {
  count = tonumber(data.aws_caller_identity.current.account_id == var.aws_account_id ? "1" : "fail")
}

resource "aws_security_group" "this" {
  name = var.naming_prefix

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group_rule" "ingress" {
  description       = "Allow SSH ingress to EC2 instance"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.this.id
}

module "this" {
  source = "../../../"

  naming_prefix = var.naming_prefix

  github_url = var.github_url

  security_groups                 = [aws_security_group.this.id]
  ec2_instance_type               = "t3.micro"
  ec2_associate_public_ip_address = true
  scaling_mode                    = "single-instance"

  ssm_parameter_name = "/github/runner/token"

  # cloud_init_extra_packages = ["cloud-utils"]
  # cloud_init_extra_runcmds = [
  #   "INSTANCE_ID=`ec2metadata --instance-id`",
  #   "aws ec2 create-tags --resources $INSTANCE_ID --tags Key=cloud-init,Value=DONE"]
  cloud_init_extra_other = <<-EOT
        users:
          - default
          - name: ubuntu
            ssh_authorized_keys:
              - ${var.public_key}
    EOT

  iam_instance_profile_arn = var.iam_instance_profile_arn

  subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id
}
