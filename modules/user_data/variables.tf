variable "config" {
  type = object({
    region               = string
    ssm_parameter_name   = string
    cloudwatch_log_group = string

    cloud_init_packages    = list(string)
    cloud_init_runcmds     = list(string)
    cloud_init_write_files = list(string)
    cloud_init_other       = string

    per_instance_runner_count = number

    runner_group  = string
    runner_labels = list(string)

    github_url               = string
    github_organisation_name = string
  })
  description = "Various configuration needed to generate a GitHub Runner cloudinit script."
}
