# -----------------------------------------------------
# Required variables
# -----------------------------------------------------
variable "name" {
  description = "Created resources will be named with this."
  type        = string
  validation {
    condition     = length(var.name) > 0
    error_message = "The name variable cannot be an empty string."
  }
}
# TODO check how this is done elsewhere.

variable "source_location" {
  type        = string
  description = "Your source code repo location, for example https://github.com/my/repo.git"
}

# -----------------------------------------------------
# Optional variables
# -----------------------------------------------------

# General
variable "build_timeout" {
  type        = number
  default     = 5
  description = "Number of minutes, from 5 to 2160 (36 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed."
}

variable "description" {
  type        = string
  default     = null
  description = "Short description of the project."
}

# environment
variable "environment_type" {
  type        = string
  default     = "LINUX_CONTAINER"
  description = "Type of build environment to use for related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER, LINUX_LAMBDA_CONTAINER, ARM_LAMBDA_CONTAINER"
}

variable "environment_compute_type" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  description = " Information about the compute resources the build project will use. Valid values: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE, BUILD_LAMBDA_1GB, BUILD_LAMBDA_2GB, BUILD_LAMBDA_4GB, BUILD_LAMBDA_8GB, BUILD_LAMBDA_10GB. BUILD_GENERAL1_SMALL is only valid if type is set to LINUX_CONTAINER. When type is set to LINUX_GPU_CONTAINER, compute_type must be BUILD_GENERAL1_LARGE. When type is set to LINUX_LAMBDA_CONTAINER or ARM_LAMBDA_CONTAINER, compute_type must be BUILD_LAMBDA_XGB"
}

variable "environment_image" {
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  description = "Docker image to use for this build project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/amazonlinux2-x86_64-standard:4.0), Docker Hub images (e.g., hashicorp/terraform:latest). If use_ecr_image is set to true, this value will be ignored and the ECR image location will be used."
}

# logs
variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_logs_group_name" {
  description = "Name of the log group used by the codebuild project. If blank then a default is used."
  type        = string
  default     = null
}

variable "cloudwatch_logs_stream_name" {
  description = "Name of the log stream used by the codebuild project. If blank then a default is used."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 14
}

variable "s3_logs_bucket_name" {
  description = "Name of the S3 bucket to store logs in. If null then logging to S3 will be disabled."
  type        = string
  default     = null
}
variable "s3_logs_bucket_prefix" {
  description = "Prefix to use for the logs in the S3 bucket"
  type        = string
  default     = ""
}

# vpc
variable "vpc_id" {
  type        = string
  description = "The VPC ID for AWS Codebuild to launch ephemeral instances in."
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of Subnet IDs for AWS Codebuild to launch ephemeral EC2 instances in."
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of Security Group IDs for AWS Codebuild to launch ephemeral EC2 instances in."
  default     = []
}

# IAM
variable "iam_role_name" {
  description = "Name of the IAM role to be used, if one is not given a role will be created"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM service role"
  type        = string
  default     = null
}

# GitHub
variable "github_personal_access_token" {
  description = "The GitHub personal access token to use for accessing the repository"
  type        = string
  default     = null
}

variable "github_personal_access_token_ssm_parameter" {
  description = "The GitHub personal access token to use for accessing the repository"
  type        = string
  default     = null
}

# Encryption
variable "kms_key_id" {
  description = "The AWS KMS key to be used"
  type        = string
  default     = null
}

# Custom image
variable "use_ecr_image" {
  description = "Determines whether the build image will be pulled from ECR, if set to true an ECR repository will be created and an image needs to be pushed to it before running the build project"
  type        = string
  default     = false
}
