variable "config" {
  type = object({
    aws_region             = string
    aws_ssm_parameter_name = string

    github_url               = string
    github_organisation_name = string
  })
  description = "TODO"
}
