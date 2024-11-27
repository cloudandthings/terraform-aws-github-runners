resource "aws_codebuild_project" "this" {
  name          = var.name
  description   = var.description
  build_timeout = var.build_timeout
  service_role  = local.create_iam_role ? aws_iam_role.this[0].arn : "arn:aws:iam::${local.aws_account_id}:role/${var.iam_role_name}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type                        = var.environment_type
    compute_type                = var.environment_compute_type
    image                       = var.use_ecr_image ? "${aws_ecr_repository.this[0].repository_url}:latest" : var.environment_image
    image_pull_credentials_type = var.use_ecr_image ? "SERVICE_ROLE" : "CODEBUILD"
    # privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name = (
        var.create_cloudwatch_log_group
        ? aws_cloudwatch_log_group.codebuild[0].name
        : data.aws_cloudwatch_log_group.codebuild[0].name
      )
      stream_name = local.cloudwatch_logs_steam_name
    }

    dynamic "s3_logs" {
      for_each = try(var.s3_logs_bucket_name, null) == null ? toset([]) : toset([1])
      content {
        status   = "ENABLED"
        location = "${var.s3_logs_bucket_name}/${var.s3_logs_bucket_prefix}"
      }
    }
  }

  source {
    type            = "GITHUB"
    location        = var.source_location
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  dynamic "vpc_config" {
    for_each = local.has_vpc_config ? toset([1]) : toset([])
    content {
      vpc_id             = var.vpc_id
      subnets            = var.subnet_ids
      security_group_ids = local.security_group_ids
    }
  }
}

resource "aws_codebuild_source_credential" "string" {
  count       = local.has_github_personal_access_token ? 1 : 0
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_personal_access_token
}

resource "aws_codebuild_source_credential" "ssm" {
  count       = local.has_github_personal_access_token_ssm_parameter ? 1 : 0
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = data.aws_ssm_parameter.github_personal_access_token[0].value
}

resource "aws_codebuild_webhook" "this" {
  depends_on   = [aws_codebuild_source_credential.string, aws_codebuild_source_credential.ssm]
  project_name = aws_codebuild_project.this.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}

resource "aws_security_group" "codebuild" {
  #checkov:skip=CKV2_AWS_5:access logging not required
  count       = local.has_vpc_config ? 1 : 0
  vpc_id      = var.vpc_id
  name        = var.name
  description = "Security group for CodeBuild project ${var.name}"
  tags = {
    Name = var.name
  }
}

resource "aws_vpc_security_group_egress_rule" "codebuild" {
  count             = local.has_vpc_config ? 1 : 0
  security_group_id = aws_security_group.codebuild[count.index].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all traffic to ALL"
}

resource "aws_vpc_security_group_ingress_rule" "codebuild" {
  count             = local.has_vpc_config ? 1 : 0
  security_group_id = aws_security_group.codebuild[count.index].id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  description = "Allow HTTPS traffic from ALL"
}

# TODO
resource "aws_ecr_repository" "this" {
  #checkov:skip=CKV_AWS_136:encryption not required
  #checkov:skip=CKV_AWS_51:latest tag used by codebuild so tag needs to be overwritten
  count = var.use_ecr_image ? 1 : 0
  name  = var.name

  image_tag_mutability = "IMMUTABLE"

  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_id
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  count      = var.use_ecr_image ? 1 : 0
  repository = aws_ecr_repository.this[0].name

  policy = <<-EOF
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Expire images older than 14 days",
                "selection": {
                    "tagStatus": "untagged",
                    "countType": "sinceImagePushed",
                    "countUnit": "days",
                    "countNumber": 14
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
    EOF
}
