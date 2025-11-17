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
  #checkov:skip=CKV_AWS_382:Egress to GitHub Actions is required for the runner to work.
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

# Example demonstrating custom security group ingress rules
# This uses the default security group created by the module
module "github_runner_with_custom_sg_rules" {
  source = "../../"

  # Required parameters
  ############################
  source_location = "https://github.com/my-org/my-repo.git"
  name            = "github-runner-custom-sg-rules"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]

  # Optional parameters
  ################################
  description = "GitHub runner with custom security group ingress rules"

  # Override the baseline CodeBuild credential
  source_auth = {
    type     = "SECRETS_MANAGER"
    resource = "arn:aws:secretsmanager:af-south-1:123456789012:secret:my-github-oauth-token-secret-nwYBWW"
  }

  # Add custom ingress rules to the default security group
  # Useful for tools like Packer that need additional ports (e.g., WinRM, SSH)
  security_group_ingress_rules = [
    {
      from_port   = 1024
      to_port     = 65535
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/16" # Replace with your VPC CIDR
      description = "Allow ephemeral ports from VPC for tools like Packer"
    }
  ]

  cloudwatch_logs_group_name = "/some/log/group"
}
