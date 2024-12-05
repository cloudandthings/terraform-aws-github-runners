variable "source_location" {
  type        = string
  description = "Your source code repo location, for example https://github.com/my/repo.git"
}

variable "name" {
  type        = string
  description = "Name used as a prefix for all resources in this module"
}

variable "github_personal_access_token_ssm_parameter" {
  type        = string
  description = "The GitHub personal access token to use for accessing the repository"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID for AWS Codebuild to launch ephemeral instances in."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of Subnet IDs for AWS Codebuild to launch ephemeral EC2 instances in."
}
