data "aws_ssm_parameter" "this" {
  name = var.ssm_parameter_name
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.ec2_instance_type
}

data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.ami_name]
  }
}

resource "null_resource" "validate_instance_profile" {
  triggers = {
    test = var.create_instance_profile == false && length(var.iam_instance_profile_arn) == 0 ? tonumber("No instance profile arn provided") : 1
  }
}
