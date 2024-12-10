module "runners" {
  for_each = var.source_locations

  source = "../../"

  name            = "${each.value.source_name}-github-runner"
  source_location = each.value.source_location

  github_personal_access_token_ssm_parameter = var.github_personal_access_token_ssm_parameter

  # Environment image is not specified so it will default to:
  # "aws/codebuild/amazonlinux2-x86_64-standard:5.0"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
}
