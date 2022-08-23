data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Not used directly but require that it exists
data "aws_ssm_parameter" "runner" {
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

resource "aws_security_group" "runners_ec2" {
  name = "${var.naming_prefix}-runners-ec2"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  count             = length(var.key_name) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.runners_ec2.id
}

module "user_data" {
  source = "./modules/user_data"
  config = {
    github_url               = var.github_url
    github_organisation_name = var.github_organisation_name

    aws_region             = var.region
    aws_ssm_parameter_name = data.aws_ssm_parameter.runner.name
  }
}

resource "aws_launch_configuration" "runners" {
  name_prefix   = "${var.naming_prefix}-runners"
  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type
  spot_price    = var.spot_price

  user_data = module.user_data.user_data

  iam_instance_profile = var.iam_instance_profile_arn
  security_groups      = [aws_security_group.runners_ec2.id]

  associate_public_ip_address = var.associate_public_ip_address

  key_name = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "runners" {
  name                 = "${var.naming_prefix}-runners"
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_size
  launch_configuration = aws_launch_configuration.runners.name
  vpc_zone_identifier  = var.subnet_ids

  lifecycle {
    ignore_changes = [desired_capacity, target_group_arns]
  }

  tag {
    key                 = "Name"
    value               = "${var.naming_prefix}-runners"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_schedule" "min" {
  count                  = length(var.aws_autoscaling_schedule_min_recurrences)
  scheduled_action_name  = "${var.naming_prefix}-min-${count.index}"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.min_size
  recurrence             = var.aws_autoscaling_schedule_min_recurrences[count.index]
  autoscaling_group_name = aws_autoscaling_group.runners.name
}

resource "aws_autoscaling_schedule" "desired" {
  count                  = length(var.aws_autoscaling_schedule_desired_recurrences)
  scheduled_action_name  = "${var.naming_prefix}-desired-${count.index}"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_size
  recurrence             = var.aws_autoscaling_schedule_desired_recurrences[count.index]
  autoscaling_group_name = aws_autoscaling_group.runners.name
}

resource "aws_autoscaling_schedule" "max" {
  count                  = length(var.aws_autoscaling_schedule_max_recurrences)
  scheduled_action_name  = "${var.naming_prefix}-max-${count.index}"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.max_size
  recurrence             = var.aws_autoscaling_schedule_max_recurrences[count.index]
  autoscaling_group_name = aws_autoscaling_group.runners.name
}

resource "aws_autoscaling_policy" "runners_scale_down" {
  name                   = "${var.naming_prefix}-runners-scale-down"
  autoscaling_group_name = aws_autoscaling_group.runners.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "runners_scale_down" {
  alarm_description   = "Monitors CPU utilization for Github runners ASG"
  alarm_actions       = [aws_autoscaling_policy.runners_scale_down.arn]
  alarm_name          = "${var.naming_prefix}-runners-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.runners.name
  }
}
