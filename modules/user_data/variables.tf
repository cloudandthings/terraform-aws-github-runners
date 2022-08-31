variable "config" {
  type = object({
    ssm_parameter_arn = string

    cloud_init_packages    = list(string)
    cloud_init_runcmds     = list(string)
    cloud_init_write_files = list(string)
    cloud_init_other       = string

    runner_group  = string
    runner_labels = list(string)

    github_url               = string
    github_organisation_name = string
  })
  description = "Various configuration needed to generate a GitHub Runner cloudinit script."
}
