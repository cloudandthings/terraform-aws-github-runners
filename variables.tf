# Required variables
variable "ssm_parameter_name" {
  description = "SSM parameter name for the GitHub Runner token.<br>Example: \"/github/runner/token\"."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "github_url" {
  description = "GitHub organisation URL.<br>Example: \"https://github.com/cloudandthings/\"."
  type        = string
}

variable "naming_prefix" {
  description = "Created resources will be prefixed with this."
  type        = string
  default     = "github-runner"
  validation {
    condition     = length(var.naming_prefix) > 0
    error_message = "The naming_prefix value cannot be an empty string."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of Subnet IDs to launch EC2 instances in. <br> If `scaling_mode=\"single-instance\"` then the first Subnet ID from this list will be used."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to launch instances in."
}

# Optional variables
variable "ami_name" {
  description = "AWS AMI name filter for launching instances. <br> GitHub supports specific operating systems and architectures, including Ubuntu 22.04 amd64 which is the default. <br> Note: The included software packs are not tested with other AMIs."
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609"
}

variable "ami_owners" {
  description = "AWS AMI owners to limit AMI search. <br> Values may be an AWS Account ID, \"self\", or an AWS owner alias eg \"amazon\"."
  type        = list(string)
  default     = ["amazon"]
}

variable "scaling_mode" {
  description = "How instances are managed. <br> Can be either `\"autoscaling-group\"` or `\"single-instance\"`."
  type        = string
  default     = "autoscaling-group"

  validation {
    condition = contains([
      "autoscaling-group", "single-instance"
    ], var.scaling_mode)
    error_message = "The scaling mode must be \"autoscaling-group\" or \"single-instance\"."
  }
}

variable "cloudwatch_log_group" {
  description = "CloudWatch log group name prefix. Runner logs from /var/log/syslog are sent here. <br>Example: `github_runner`, with this value logs will be written to `github_runner/var/log/syslog/<instance_id>`.<br>If left unspecified then logging is disabled."
  type        = string
  default     = ""
}

variable "autoscaling_min_size" {
  description = "The minimum size of the Auto Scaling Group.<br>*When `scaling_mode=\"autoscaling-group\"`*"
  type        = number
  default     = 1
}

variable "autoscaling_desired_size" {
  description = "The number of Amazon EC2 instances that should be running.<br>*When `scaling_mode=\"autoscaling-group\"`*"
  type        = number
  default     = 1
}

variable "autoscaling_max_size" {
  description = "The maximum size of the Auto Scaling Group.<br>*When `scaling_mode=\"autoscaling-group\"`*"
  type        = number
  default     = 3
}

variable "autoscaling_max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service. Values must be either equal to `0` or between `86400` and `31536000` seconds.<br>*When `scaling_mode=\"autoscaling-group\"`*"
  type        = string
  default     = 0
}

variable "autoscaling_schedule_on_recurrences" {
  description = "A list of schedule cron expressions, specifying when the Auto Scaling Group will launch instances.<br>Example: `[\"0 07 * * MON-FRI\"]`<br>*When `scaling_mode=\"autoscaling-group\"`*"
  type        = list(string)
  default     = []
}

variable "autoscaling_schedule_off_recurrences" {
  description = "A list of schedule cron expressions, specifying when the Auto Scaling Group will terminate all instances.<br>Example: `[\"0 18 * * *\"]`<br>*When `scaling_mode=\"autoscaling-group\"`*"
  type        = list(string)
  default     = []
}

variable "autoscaling_schedule_time_zone" {
  description = "The timezone for schedule cron expressions.<br>https://www.joda.org/joda-time/timezones.html<br>*When `scaling_mode=\"autoscaling-group\"`*"
  type        = string
  default     = ""
}

variable "cloud_init_extra_packages" {
  description = "A list of strings to append beneath the `packages:` section of the `cloudinit` script.<br>https://cloudinit.readthedocs.io/en/latest/topics/modules.html#package-update-upgrade-install"
  type        = list(string)
  default     = []
}

variable "cloud_init_extra_runcmds" {
  description = "A list of strings to append beneath the `runcmd:` section of the `cloudinit` script.<br>https://cloudinit.readthedocs.io/en/latest/topics/modules.html#runcmd"
  type        = list(string)
  default     = []
}

variable "cloud_init_extra_write_files" {
  description = "A list of strings to append beneath the `write_files:` section of the `cloudinit` script.<br>https://cloudinit.readthedocs.io/en/latest/topics/modules.html#write-files"
  type        = list(string)
  default     = []
}

variable "cloud_init_extra_other" {
  description = "Arbitrary text to append to the `cloudinit` script."
  type        = string
  default     = ""
}

variable "ec2_associate_public_ip_address" {
  description = "Whether to associate a public IP address with EC2 instances in a VPC."
  type        = bool
  default     = false
}

variable "ec2_instance_type" {
  description = "Instance type for EC2 instances."
  type        = string
}

variable "ec2_ebs_volume_size" {
  description = "Size in GB of instance-attached EBS storage. By default this is set to number of vCPUs per instance * 20 GB."
  type        = number
  default     = -1
}

variable "ec2_key_pair_name" {
  description = "EC2 Key Pair name to allow SSH to EC2 instances."
  type        = string
  default     = ""
}

variable "per_instance_runner_count" {
  description = "Number of runners per instance. By default this is set equal to the number of vCPUs per instance. May be set to 0 to never create runners."
  type        = number
  default     = -1
}

variable "github_organisation_name" {
  description = "GitHub orgnisation name. Derived from `github_url` by default."
  type        = string
  default     = ""
}

variable "github_runner_group" {
  description = "Custom GitHub runner group."
  type        = string
  default     = ""
}

variable "github_runner_labels" {
  description = "Custom GitHub runner labels. <br>Example: `\"gpu,x64,linux\"`."
  type        = list(string)
  default     = []
}

variable "create_iam_resources" {
  description = "Should the module create the IAM resources needed. If set to false then an \"iam_instance_profile_arn\" must be provided."
  type        = bool
  default     = true
}

variable "iam_instance_profile_arn" {
  description = "IAM Instance Profile to launch EC2 instances with. Must allow permissions to read the SSM Parameter. Will be created by default."
  type        = string
  default     = ""
}

variable "security_groups" {
  description = "A list of security groups to assign to EC2 instances.<br>Note: If none are provided, a new security group will be used which will deny inbound traffic **including SSH**."
  type        = list(string)
  default     = []
}

variable "software_packs" {
  type        = list(string)
  description = "A list of pre-defined software packs to install.<br>Valid options are: `\"ALL\"`, `\"docker-engine\"`, `\"node\"`, `\"python2\"`, `\"python3\"`, `\"terraform\"`, `\"terraform-docs\"`, `\"tflint\"`, `\"tfsec\"`.<br>An empty list will mean none are installed."
  default     = ["ALL"]

  validation {
    condition = alltrue(
      [for x in var.software_packs : contains([
        "ALL", "docker-engine", "node", "python2", "python3", "terraform", "terraform-docs", "tflint", "tfsec"
      ], x)]
    )
    error_message = "Software packs must be a list of: [\"ALL\", \"docker-engine\", \"node\", \"python2\", \"python3\", \"terraform\", \"terraform-docs\", \"tflint\", \"tfsec\"]."
  }
}
