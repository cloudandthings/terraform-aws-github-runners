data "aws_caller_identity" "current" {
  provider = aws
}

locals {
  naming_prefix = "${var.naming_prefix}-${var.run_id}"
}

resource "null_resource" "tf_guard_provider_account_match" {
  count = tonumber(data.aws_caller_identity.current.account_id == var.aws_account_id ? "1" : "fail")
}

resource "aws_security_group" "this" {
  name        = local.naming_prefix
  description = "GitHub runner ${local.naming_prefix}-sg"

  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    description = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
  #checkov:skip=CKV2_AWS_5:The SG is attached by the module.
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
  source          = "../../../"
  source_location = "https://github.com/my-org/my-repo.git"

  security_group_ids = [aws_security_group.this.id]

  subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id
}
