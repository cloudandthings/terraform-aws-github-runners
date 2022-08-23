data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Not used directly but require that it exists
data "aws_ssm_parameter" "this" {
  name = var.ssm_parameter_name
}

data "aws_ami" "ami" {
  # TODO Ubuntu or AMI filter
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "this" {
  name = "${var.naming_prefix}-ec2"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  count             = length(var.ec2_key_pair_name) > 0 ? 1 : 0
  description       = "Allow SSH ingress to EC2 instance"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.this.id
}

module "user_data" {
  source = "./modules/user_data"
  config = {
    github_url               = var.github_url
    github_organisation_name = var.github_organisation_name

    aws_region             = var.region
    aws_ssm_parameter_name = data.aws_ssm_parameter.this.name
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix   = var.naming_prefix
  image_id      = data.aws_ami.ami.id
  instance_type = var.ec2_instance_type

  user_data        = module.user_data.user_data
  user_data_base64 = ""

  iam_instance_profile = var.iam_instance_profile_arn
  security_groups      = [aws_security_group.this.id]

  associate_public_ip_address = var.ec2_associate_public_ip_address

  key_name = var.ec2_key_pair_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                 = var.naming_prefix
  min_size             = var.autoscaling_min_size
  max_size             = var.autoscaling_max_size
  desired_capacity     = var.autoscaling_desired_size
  launch_configuration = aws_launch_configuration.this.name
  vpc_zone_identifier  = var.subnet_ids

  lifecycle {
    ignore_changes = [desired_capacity, target_group_arns]
  }

  tag {
    key                 = "Name"
    value               = var.naming_prefix
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_schedule" "on" {
  count                  = length(var.autoscaling_schedule_on_recurrences)
  scheduled_action_name  = "${var.naming_prefix}-on-${count.index}"
  min_size               = var.autoscaling_min_size
  max_size               = var.autoscaling_max_size
  desired_capacity       = var.autoscaling_desired_size
  recurrence             = var.autoscaling_schedule_on_recurrences[count.index]
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_schedule" "off" {
  count                  = length(var.autoscaling_schedule_off_recurrences)
  scheduled_action_name  = "${var.naming_prefix}-off-${count.index}"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = var.autoscaling_schedule_off_recurrences[count.index]
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.naming_prefix}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_description   = "Monitor CPU for ASG ${aws_autoscaling_group.this.name}"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  alarm_name          = "${var.naming_prefix}-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }
}
