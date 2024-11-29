variable "source_locations" {
  type = map(object({
    source_location = string
    source_name     = string
  }))
  description = "Map of source locations to use when creating runners"
  default = {
    example-1 = {
      "source_name"     = "example-1"
      "source_location" = "https://github.com/my-org/example-1.git"
    }
    example-2 = {
      "source_name"     = "example-2"
      "source_location" = "https://github.com/my-org/example-2.git"
    }
  }
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