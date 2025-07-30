locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.name

  has_s3_log_bucket = var.s3_logs_bucket_name != null

  has_vpc_config = var.vpc_id != null

  has_github_personal_access_token = var.github_personal_access_token != null

  has_github_personal_access_token_ssm_parameter = var.github_personal_access_token_ssm_parameter != null

  has_github_codeconnection_arn = var.github_codeconnection_arn != null

  subnet_arns = [for subnet_id in var.subnet_ids : "arn:aws:ec2:${local.aws_region}:${local.aws_account_id}:subnet/${subnet_id}"]

  create_iam_role = var.iam_role_name == null

  cloudwatch_logs_group_arn = (
    var.create_cloudwatch_log_group
    ? aws_cloudwatch_log_group.codebuild[0].arn
    : data.aws_cloudwatch_log_group.codebuild[0].arn
  )

  cloudwatch_logs_steam_name = (
    var.cloudwatch_logs_stream_name == null
    ? var.name
    : var.cloudwatch_logs_stream_name
  )

  s3_logs_bucket_arn = (
    var.s3_logs_bucket_name == null
    ? null
    : "arn:aws:s3:::${var.s3_logs_bucket_name}"
  )
}
