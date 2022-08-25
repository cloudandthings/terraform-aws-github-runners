# Required variables
variable "region" {
  description = "AWS Region for the SSM Parameter."
  type        = string
}

variable "naming_prefix" {
  description = "Created resources will be prefixed with this."
  type        = string
  default     = "github-runner"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to launch instances in."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of Subnet IDs to launch EC2 instances in. If `autoscaling_enabled=false` then the first Subnet ID from this list will be used."
}

variable "ssm_parameter_name" {
  description = "SSM Parameter name for the Github Runner token."
  type        = string
  default     = "/github/runner/token"
}

variable "iam_instance_profile_arn" {
  description = "IAM Instance Profile to launch the instance with. Must allow permissions to read the SSM Parameter."
  type        = string
}

variable "github_organisation_name" {
  description = "Github orgnisation name. Derived from `github_url` by default."
  type        = string
  default     = ""
}

variable "github_url" {
  description = "Github url, for example: \"https://github.com/cloudandthings/\"."
  type        = string
}

# Optional variables
variable "ami_name" {
  description = "AWS AMI name filter for launching instances. Github supports specific operating systems and architectures, including Ubuntu 22.04 amd64 which is the default. The included software packs are not tested with other AMIs."
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609"
}

variable "ec2_key_pair_name" {
  description = "EC2 Key Pair name to allow SSH to launched instances."
  type        = string
  default     = ""
}

variable "ec2_instance_type" {
  description = "EC2 instance type for launched instances."

  type    = string
  default = "t3.micro"
}

variable "ec2_associate_public_ip_address" {
  description = "Whether to associate a public IP address with instances in a VPC."
  type        = bool
  default     = false
}

variable "autoscaling_min_size" {
  description = "The minimum size of the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "autoscaling_desired_size" {
  description = "The number of Amazon EC2 instances that should be running in the group."
  type        = number
  default     = 1
}

variable "autoscaling_max_size" {
  description = "The maximum size of the Auto Scaling Group."
  type        = number
  default     = 3
}

variable "autoscaling_schedule_on_recurrences" {
  description = "A list of schedule cron expressions, specifying when the Auto Scaling Group will launch instances. Example: [\"0 6 * * *\"]"
  type        = list(string)
  default     = []
}

variable "autoscaling_schedule_off_recurrences" {
  description = "A list of schedule cron expressions, specifying when the Auto Scaling Group will terminate all instances. Example: [\"0 20 * * *\"]"
  type        = list(string)
  default     = []
}

variable "autoscaling_schedule_time_zone" {
  description = "The timezone for schedule cron expressions."
  type        = string
  default     = ""
}

variable "autoscaling_max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service. Values must be either equal to 0 or between 86400 and 31536000 seconds."
  type        = string
  default     = 0
}

variable "software_packs" {
  type        = list(string)
  description = "A list of pre-defined software packs to install. Valid options are: [\"python3\", \"docker-engine\", \"terraform\", \"terraform-docs\", \"tflint\"]"
  default     = []

  validation {
    condition = alltrue([
      for x in var.software_packs : contains([
        "python3", "docker-engine", "terraform", "terraform-docs", "tflint"
      ], x)
    ])
    error_message = "Software packs must be one of [\"python3\", \"docker-engine\", \"terraform\", \"terraform-docs\", \"tflint\"]."
  }
}

variable "cloud_init_extra_packages" {
  description = "A list of strings to append beneath the `packages:` section of the cloudinit script. See https://cloudinit.readthedocs.io/en/latest/topics/modules.html#package-update-upgrade-install ."
  type        = list(string)
  default     = []
}

variable "cloud_init_extra_runcmds" {
  description = "A list of strings to append beneath the `runcmd:` section of the cloudinit script. See https://cloudinit.readthedocs.io/en/latest/topics/modules.html#runcmd ."
  type        = list(string)
  default     = []
}

variable "cloud_init_extra_other" {
  description = "Any other text to append to the cloudinit script."
  type        = string
  default     = ""
}

variable "github_runner_name" {
  description = "Custom Github runner name."
  type        = string
  default     = ""
}

variable "github_runner_group" {
  description = "Custom Github runner group."
  type        = string
  default     = ""
}

variable "github_runner_labels" {
  description = "Custom Github runner labels, for example: \"gpu,x64,linux\"."
  type        = list(string)
  default     = []
}
