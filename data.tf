data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "this" {
  name = var.ssm_parameter_name
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.ec2_instance_type
}

data "aws_ami" "ami" {
  most_recent = true

  owners = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name]
  }
}

#--------------------------------------------------------------------------------------
# Input validation
#--------------------------------------------------------------------------------------
resource "null_resource" "validate_instance_profile" {
  triggers = {
    test = var.create_iam_resources == false && length(var.iam_instance_profile_arn) == 0 ? tonumber("No instance profile arn provided") : 1
  }
}
