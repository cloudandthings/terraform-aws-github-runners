data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ssm_parameter" "this" {
  name = var.ssm_parameter_name
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
