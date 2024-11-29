module "runners" {
  source = "../../"

  name            = "${var.name}-github-runner"
  source_location = var.source_location

  github_personal_access_token_ssm_parameter = var.github_personal_access_token_ssm_parameter

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  iam_role_policies = {
    "allow_secrets_manager" = aws_iam_policy.secrets_manager.arn,
    "s3_managed_policy"     = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  }
}
