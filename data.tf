data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "github_personal_access_token" {
  count           = local.has_github_personal_access_token_ssm_parameter ? 1 : 0
  name            = var.github_personal_access_token_ssm_parameter
  with_decryption = true
}
