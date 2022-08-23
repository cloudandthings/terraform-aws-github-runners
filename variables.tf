# Required variables
variable "region" {
  description = "TODO"

  type = string
}

variable "naming_prefix" {
  description = "TODO"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "TODO"
}

variable "subnet_ids" {
  type        = list(string)
  description = "TODO"
}

variable "ssm_parameter_name" {
  description = "TODO"

  type    = string
  default = "/github/runner/token"
}

variable "iam_instance_profile_arn" {
  description = "TODO"

  type = string
}

variable "github_organisation_name" {
  description = "TODO"

  type = string
}

variable "github_url" {
  description = "TODO"

  type = string
}

# Optional variables
variable "ec2_key_pair_name" {
  description = "TODO"
  type        = string
  default     = ""
}

variable "ec2_instance_type" {
  description = "TODO"

  type    = string
  default = "t3.micro"
}

variable "ec2_associate_public_ip_address" {
  description = "TODO"
  type        = bool
  default     = false
}

variable "autoscaling_min_size" {
  description = "TODO"
  type        = number
  default     = 1
}

variable "autoscaling_desired_size" {
  description = "TODO"
  type        = number
  default     = 1
}

variable "autoscaling_max_size" {
  description = "TODO"
  type        = number
  default     = 3
}

variable "autoscaling_schedule_on_recurrences" {
  description = "TODO"
  type        = list(string)
  default     = []
}

variable "autoscaling_schedule_off_recurrences" {
  description = "TODO"
  type        = list(string)
  default     = []
}

variable "autoscaling_time_zone" {
  description = "TODO"
  type        = string
  default     = ""
}

variable "cloud_init_install_python3" {
  type        = bool
  default     = true
  description = "TODO"
}

variable "cloud_init_install_docker_engine" {
  type        = bool
  default     = true
  description = "TODO"
}

variable "cloud_init_install_terraform" {
  type        = bool
  default     = true
  description = "TODO"
}

variable "cloud_init_extra_users" {
  description = "TODO"
  type        = list(string)
  default     = []
}

variable "cloud_init_extra_packages" {
  description = "TODO"
  type        = list(string)
  default     = []
}

variable "cloud_init_extra_runcmds" {
  description = "TODO"
  type        = list(string)
  default     = []
}

variable "cloud_init_extra_write_files" {
  description = "TODO"
  type        = list(string)
  default     = []
}

variable "cloud_init_extra_other" {
  description = "TODO"
  type        = string
  default     = ""
}
