################################################################################
# Cloudwatch permissions
################################################################################
data "aws_iam_policy_document" "cloudwatch_required" {
  statement {
    sid    = "AllowCreateLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
    ]
    resources = [local.cloudwatch_logs_group_arn]
  }

  statement {
    sid    = "AllowPutLogEvents"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${local.cloudwatch_logs_group_arn}:log-stream:${local.cloudwatch_logs_steam_name}/*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_required" {
  name   = "${var.name}-cloudwatch-logs"
  role   = local.create_iam_role ? aws_iam_role.this[0].name : var.iam_role_name
  policy = data.aws_iam_policy_document.cloudwatch_required.json
}

################################################################################
# VPC permissions
################################################################################
data "aws_iam_policy_document" "networking_required" {
  count = local.has_vpc_config ? 1 : 0
  statement {
    sid    = "AllowNetworkingDescribe"
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AllowNetworkingAttachDetach"
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:${local.aws_region}:${local.aws_account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"

      values = local.subnet_arns
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "networking_required" {
  count  = local.has_vpc_config ? 1 : 0
  name   = "${var.name}-networking"
  role   = local.create_iam_role ? aws_iam_role.this[0].name : var.iam_role_name
  policy = data.aws_iam_policy_document.networking_required[0].json
}

################################################################################
# S3 permissions
################################################################################
data "aws_iam_policy_document" "s3_required" {
  count = local.has_s3_log_bucket ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["s3:PutObject*"]
    resources = [
      local.s3_logs_bucket_arn,
      "${local.s3_logs_bucket_arn}/${var.s3_logs_bucket_prefix}*",
    ]
  }
}

resource "aws_iam_role_policy" "s3_required" {
  count  = local.has_s3_log_bucket ? 1 : 0
  name   = "${var.name}-s3-logging"
  role   = local.create_iam_role ? aws_iam_role.this[0].name : var.iam_role_name
  policy = data.aws_iam_policy_document.s3_required[0].json
}

################################################################################
# ECR permissions
################################################################################
data "aws_iam_policy_document" "ecr_required" {
  count = local.use_ecr_repository ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "arn:aws:ecr:${local.aws_region}:${local.aws_account_id}:repository/${local.ecr_repository_name}",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr_required" {
  count  = local.use_ecr_repository ? 1 : 0
  name   = "${var.name}-ecr"
  role   = local.create_iam_role ? aws_iam_role.this[0].name : var.iam_role_name
  policy = data.aws_iam_policy_document.ecr_required[count.index].json
}

data "aws_iam_policy_document" "codeconnection_required" {
  count = local.has_github_codeconnection_arn ? 1 : 0
  statement {
    effect = "Allow"
    # https://docs.aws.amazon.com/dtconsole/latest/userguide/rename.html
    actions = length(regexall("^arn:aws:codestar-connections:.*", var.github_codeconnection_arn)) > 0 ? [
      "codestar-connections:GetConnection",
      "codestar-connections:GetConnectionToken"
      ] : [
      "codeconnections:GetConnection",
      "codeconnections:GetConnectionToken",
      "codeconnections:UseConnection"
    ]
    resources = [var.github_codeconnection_arn]
  }
}

resource "aws_iam_role_policy" "codeconnection_required" {
  count  = local.has_github_codeconnection_arn ? 1 : 0
  name   = "${var.name}-codeconnection"
  role   = local.create_iam_role ? aws_iam_role.this[0].name : var.iam_role_name
  policy = data.aws_iam_policy_document.codeconnection_required[count.index].json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

locals {
  assume_role_policy = var.iam_role_assume_role_policy == null ? data.aws_iam_policy_document.assume_role.json : var.iam_role_assume_role_policy
}

################################################################################
# Create role
################################################################################
resource "aws_iam_role" "this" {
  count                = local.create_iam_role ? 1 : 0
  name                 = var.name
  assume_role_policy   = local.assume_role_policy
  permissions_boundary = var.iam_role_permissions_boundary == null ? null : var.iam_role_permissions_boundary
}

################################################################################
# Custom permissions
################################################################################
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.iam_role_policies

  role       = local.create_iam_role ? aws_iam_role.this[0].name : var.iam_role_name
  policy_arn = each.value
}
