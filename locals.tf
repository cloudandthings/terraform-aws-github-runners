locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.name

  create_cloudwatch_logs_group = var.cloudwatch_logs_group_name == null

  custom_kms_key = var.kms_key_id != null

  s3_log_bucket = var.s3_logs_location != null

  any_vpc_config = var.vpc_id != null

  has_github_personal_access_token = var.github_personal_access_token != null

  has_github_personal_access_token_ssm_parameter = var.github_personal_access_token_ssm_parameter != null

  subnet_arns = [for subnet_id in var.subnet_ids : "arn:aws:ec2:${local.aws_region}:${local.aws_account_id}:subnet/${subnet_id}"]

  security_group_ids = length(var.security_group_ids) == 0 ? try([aws_security_group.codebuild[0].id], []) : concat(try([aws_security_group.codebuild[0].id], []), var.security_group_ids)

  create_iam_role = var.iam_role_name == null

  cloudwatch_logs_group_arn = local.create_cloudwatch_logs_group ? aws_cloudwatch_log_group.codebuild[0].arn : "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:${var.cloudwatch_logs_group_name}"

  cloudwatch_logs_steam_name = var.cloudwatch_logs_stream_name == null ? var.name : var.cloudwatch_logs_stream_name

  s3_logs_bucket_arn = try("arn:aws:s3:::${var.s3_logs_location}", "")
}
