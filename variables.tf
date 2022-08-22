variable "ssm_parameter_name" {
  description = "TODO"

  type    = string
  default = "/github/runner/token"
}

variable "ssh_authorized_key" {
  description = "TODO"

  type    = string
  default = ""
}

variable "key_name" {
  description = "TODO"
  type        = string
  default     = ""
}

variable "iam_instance_profile_arn" {
  description = "TODO"

  type = string
}

variable "instance_type" {
  description = "TODO"

  type = string
  # default = "t3.micro"
}

variable "spot_price" {
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

variable "associate_public_ip_address" {
  description = "TODO"
  type        = bool
  default     = false
}

variable "min_size" {
  description = "TODO"
  type        = number
  default     = 0
}

variable "desired_size" {
  description = "TODO"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "TODO"
  type        = number
  default     = 3
}

variable "aws_autoscaling_schedule_min_recurrences" {
  description = "TODO"
  type        = list(string)
  default     = []
}

variable "aws_autoscaling_schedule_desired_recurrences" {
  description = "TODO"
  type        = list(string)
  default     = []
}

variable "aws_autoscaling_schedule_max_recurrences" {
  description = "TODO"
  type        = list(string)
  default     = []
}
