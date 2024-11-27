resource "aws_cloudwatch_log_group" "codebuild" {
  #checkov:skip=CKV_AWS_338:log retention set to 14 days as it only shows the github runner initialise
  count             = var.create_cloudwatch_log_group ? 1 : 0
  name              = coalesce(var.cloudwatch_logs_group_name, "/aws/codebuild/${var.name}")
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.kms_key_id
}
data "aws_cloudwatch_log_group" "codebuild" {
  count = var.create_cloudwatch_log_group ? 0 : 1
  name  = var.cloudwatch_logs_group_name
}
