variable "config" {
  type = object({
    aws_region             = string
    aws_ssm_parameter_name = string

    cloud_init_packages = list(string)
    cloud_init_runcmds  = list(string)
    cloud_init_other    = string

    runner_name   = string
    runner_group  = string
    runner_labels = list(string)

    github_url               = string
    github_organisation_name = string
  })
  description = "TODO"
}
