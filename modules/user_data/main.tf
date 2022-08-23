locals {
  user_data = templatefile(
    "${path.module}/cloud-init.yaml", {
      AWS_REGION             = var.config.aws_region
      AWS_SSM_PARAMETER_NAME = var.config.aws_ssm_parameter_name

      PACKAGES    = var.config.cloud_init_packages
      RUNCMDS     = var.config.cloud_init_runcmds
      WRITE_FILES = var.config.cloud_init_write_files
      OTHER       = var.config.cloud_init_other

      GITHUB_URL               = var.config.github_url
      GITHUB_ORGANISATION_NAME = var.config.github_organisation_name
  })
}
