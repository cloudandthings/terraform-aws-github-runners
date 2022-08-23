variable "config" {
  type = object({
    aws_region             = string
    aws_ssm_parameter_name = string

    cloud_init_packages = list(string)

    github_url               = string
    github_organisation_name = string
  })
  description = "TODO"
}
