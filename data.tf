data "aws_ssm_parameter" "this" {
  name = var.ssm_parameter_name
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.ec2_instance_type
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
