<!-- BEGIN_TF_DOCS -->
----
## main.tf
```hcl
locals {
  naming_prefix = "test-github-runner"
  vpc_id        = "vpc-0ffaabbcc1122"
  vpc_cidr      = "10.0.0.0/16"
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

# Example: Using the default security group with custom ingress rules for Packer
module "github_runner_with_packer" {
  source = "../../"

  # Required parameters
  source_location = "https://github.com/my-org/my-repo.git"
  name            = "github-runner-packer"

  # VPC configuration
  vpc_id     = local.vpc_id
  subnet_ids = ["subnet-0123", "subnet-0456"]

  # Custom ingress rules added to the default security group
  # This is useful when running Packer which requires ephemeral ports for WinRM/SSH
  ingress_with_cidr_blocks = [
    {
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      description = "Ephemeral ports required for Packer WinRM/SSH communication"
      cidr_blocks = [local.vpc_cidr]
    },
    {
      from_port   = 5985
      to_port     = 5986
      protocol    = "tcp"
      description = "WinRM ports for Packer"
      cidr_blocks = [local.vpc_cidr]
    }
  ]
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
| <a name="module_github_runner_with_packer"></a> [github\_runner\_with\_packer](#module\_github\_runner\_with\_packer) | ../../ | n/a |

----
### Outputs

No outputs.

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.0 |

----
### Resources

| Name | Type |
|------|------|
| [aws_codebuild_source_credential.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

----
<!-- END_TF_DOCS -->
