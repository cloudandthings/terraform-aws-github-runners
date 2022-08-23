locals {
  user_data = templatefile(
    "${path.module}/cloud-init.yaml", {
      AWS_REGION             = var.config.aws_region
      AWS_SSM_PARAMETER_NAME = var.config.aws_ssm_parameter_name

      GITHUB_URL               = var.config.github_url
      GITHUB_ORGANISATION_NAME = var.config.github_organisation_name
  })
}
