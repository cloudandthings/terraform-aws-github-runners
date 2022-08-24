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
variable "ami_name" {
  description = "TODO"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609"
}

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

variable "software" {
  type        = list(string)
  description = "TODO"

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

variable "cloud_init_extra_other" {
  description = "TODO"
  type        = string
  default     = ""
}

variable "runner_name" {
  description = "TODO"
  type        = string
  default     = ""
}

variable "runner_group" {
  description = "TODO"
  type        = string
  default     = ""
}

variable "runner_labels" {
  description = "TODO"
  type        = list(string)
  default     = null
}
