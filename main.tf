locals {
  iam_policy_statements_cloudwatch = (
    length(var.cloudwatch_log_group) > 0
    ? [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  : [])
}

resource "aws_iam_policy" "this" {
  count = var.create_iam_resources ? 1 : 0
  name  = var.naming_prefix

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Action   = ["ssm:GetParameter*"]
        Effect   = "Allow"
        Resource = data.aws_ssm_parameter.this.arn
      },
      {
        Action   = ["ec2:CreateTags"]
        Effect   = "Allow"
        Resource = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:*/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Name" = var.naming_prefix
            "ec2:CreateAction"     = "RunInstances"
          }
        }
      }
      ],
    local.iam_policy_statements_cloudwatch)
  })
}

resource "aws_iam_role" "this" {
  count = var.create_iam_resources ? 1 : 0
  name  = var.naming_prefix

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = var.naming_prefix
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.create_iam_resources ? 1 : 0
  role       = var.naming_prefix
  policy_arn = aws_iam_policy.this[count.index].arn
}

resource "aws_iam_role_policy_attachment" "user_defined_policies" {
  count      = length(var.iam_policy_arns)
  role       = var.naming_prefix
  policy_arn = var.iam_policy_arns[count.index]
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_resources ? 1 : 0
  name  = var.naming_prefix
  role  = var.naming_prefix
}

locals {
  iam_instance_profile_arn = (
    length(var.iam_instance_profile_arn) == 0
    ? aws_iam_instance_profile.this[0].arn
    : var.iam_instance_profile_arn
  )
}

resource "aws_security_group" "this" {
  count       = length(var.security_groups) > 0 ? 0 : 1
  name        = var.naming_prefix
  description = "GitHub runner instance ${var.naming_prefix}"

  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    description = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
}

locals {
  security_groups = (
    length(var.security_groups) > 0
    ? var.security_groups
    : flatten(aws_security_group.this[*].id)
  )

  default_per_instance_runner_count = (
    data.aws_ec2_instance_type.this.default_vcpus
    * data.aws_ec2_instance_type.this.default_cores
    * data.aws_ec2_instance_type.this.default_threads_per_core
  )

  per_instance_runner_count = (
    var.per_instance_runner_count == -1
    ? local.default_per_instance_runner_count
    : var.per_instance_runner_count
  )
}

module "software_packs" {
  source        = "./modules/software"
  count         = length(var.software_packs)
  software_pack = var.software_packs[count.index]
}

module "user_data" {
  source = "./modules/user_data"
  config = {
    region                   = var.region
    cloudwatch_log_group     = var.cloudwatch_log_group
    github_url               = var.github_url
    github_organisation_name = var.github_organisation_name

    cloud_init_packages = distinct(
      concat(
        flatten(module.software_packs[*].packages),
        var.cloud_init_extra_packages
      )
    )
    cloud_init_runcmds = concat(
      flatten(module.software_packs[*].runcmds),
      var.cloud_init_extra_runcmds
    )
    cloud_init_write_files = var.cloud_init_extra_write_files
    cloud_init_other       = var.cloud_init_extra_other

    per_instance_runner_count = local.per_instance_runner_count

    runner_group  = var.github_runner_group
    runner_labels = var.github_runner_labels

    ssm_parameter_name = var.ssm_parameter_name
  }
}


resource "aws_launch_template" "this" {
  name = var.naming_prefix

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted             = true
      delete_on_termination = true
      volume_size = (
        var.ec2_ebs_volume_size == -1
        ? local.per_instance_runner_count * 20
        : var.ec2_ebs_volume_size
      )
    }
  }

  iam_instance_profile {
    arn = local.iam_instance_profile_arn
  }

  image_id = data.aws_ami.ami.id


  instance_market_options {
    market_type = "spot"
  }

  instance_type = var.ec2_instance_type

  key_name = var.ec2_key_pair_name

  network_interfaces {
    associate_public_ip_address = var.ec2_associate_public_ip_address
    security_groups             = local.security_groups
  }

  user_data = base64gzip(module.user_data.user_data)

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  autoscaling_group_name = var.naming_prefix
}

resource "aws_autoscaling_group" "this" {
  count            = (var.scaling_mode == "autoscaling-group" ? 1 : 0)
  name             = local.autoscaling_group_name
  min_size         = var.autoscaling_min_size
  max_size         = var.autoscaling_max_size
  desired_capacity = var.autoscaling_desired_size

  launch_template {
    id = aws_launch_template.this.id
    # trigger instance refresh
    version = aws_launch_template.this.latest_version
  }

  max_instance_lifetime = var.autoscaling_max_instance_lifetime

  instance_refresh {
    strategy = "Rolling"
  }

  vpc_zone_identifier = var.subnet_ids

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
  count = (
    var.scaling_mode == "autoscaling-group"
    ? length(var.autoscaling_schedule_on_recurrences)
  : 0)
  scheduled_action_name  = "${var.naming_prefix}-on-${count.index}"
  min_size               = var.autoscaling_min_size
  max_size               = var.autoscaling_max_size
  desired_capacity       = var.autoscaling_desired_size
  recurrence             = var.autoscaling_schedule_on_recurrences[count.index]
  time_zone              = var.autoscaling_schedule_time_zone
  autoscaling_group_name = local.autoscaling_group_name
  depends_on = [
    aws_autoscaling_group.this
  ]
}

resource "aws_autoscaling_schedule" "off" {
  count = (
    var.scaling_mode == "autoscaling-group"
    ? length(var.autoscaling_schedule_off_recurrences)
  : 0)
  scheduled_action_name  = "${var.naming_prefix}-off-${count.index}"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = var.autoscaling_schedule_off_recurrences[count.index]
  time_zone              = var.autoscaling_schedule_time_zone
  autoscaling_group_name = local.autoscaling_group_name
  depends_on = [
    aws_autoscaling_group.this
  ]
}

resource "aws_autoscaling_policy" "scale_down" {
  count                  = (var.scaling_mode == "autoscaling-group" ? 1 : 0)
  name                   = "${var.naming_prefix}-scale-down"
  autoscaling_group_name = local.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120

  depends_on = [
    aws_autoscaling_group.this
  ]
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  count               = (var.scaling_mode == "autoscaling-group" ? 1 : 0)
  alarm_description   = "Monitor CPU for ASG ${local.autoscaling_group_name}"
  alarm_actions       = [aws_autoscaling_policy.scale_down[count.index].arn]
  alarm_name          = "${var.naming_prefix}-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = local.autoscaling_group_name
  }
  depends_on = [
    aws_autoscaling_group.this
  ]
}

resource "aws_instance" "this" {
  count = var.scaling_mode == "single-instance" ? 1 : 0
  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  subnet_id = var.subnet_ids[0]

  tags = {
    Name = var.naming_prefix
  }
}
