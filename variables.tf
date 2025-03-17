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
  description = "Your source code repo location, for example https://github.com/my/repo.git, or `CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION` for org-level webhooks"
}

# -----------------------------------------------------
# Optional variables
# -----------------------------------------------------

# General
variable "source_organization" {
  type        = string
  default     = null
  description = "Your Github organization name for organization-level webhook creation"
}

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
  description = "Type of build environment to use for related builds. Valid values: `LINUX_CONTAINER`, `LINUX_GPU_CONTAINER`, `WINDOWS_CONTAINER` (deprecated), `WINDOWS_SERVER_2019_CONTAINER`, `ARM_CONTAINER`, `LINUX_LAMBDA_CONTAINER`, `ARM_LAMBDA_CONTAINER`"
}

variable "environment_compute_type" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  description = " Information about the compute resources the build project will use. Valid values: `BUILD_GENERAL1_SMALL`, `BUILD_GENERAL1_MEDIUM`, `BUILD_GENERAL1_LARGE`, `BUILD_GENERAL1_2XLARGE`, `BUILD_LAMBDA_1GB`, `BUILD_LAMBDA_2GB`, `BUILD_LAMBDA_4GB`, `BUILD_LAMBDA_8GB`, `BUILD_LAMBDA_10GB`. `BUILD_GENERAL1_SMALL` is only valid if type is set to `LINUX_CONTAINER`. When type is set to `LINUX_GPU_CONTAINER`, compute_type must be `BUILD_GENERAL1_LARGE`. When type is set to `LINUX_LAMBDA_CONTAINER` or `ARM_LAMBDA_CONTAINER`, compute_type must be `BUILD_LAMBDA_XGB`"
}

variable "environment_image" {
  type        = string
  default     = null
  description = "Docker image to use for this build project. Valid values include Docker images provided by CodeBuild (e.g `aws/codebuild/amazonlinux2-x86_64-standard:4.0`), Docker Hub images (e.g., `hashicorp/terraform:latest`) and full Docker repository URIs such as those for ECR (e.g., `137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest`). If not specified and not using ECR, then a default CodeBuild image is used, or if using ECR then an ECR image with a `latest` tag is used."
}

# logs
variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_logs_group_name" {
  description = "Name of the log group used by the CodeBuild project. If not specified then a default is used."
  type        = string
  default     = null
}

variable "cloudwatch_logs_stream_name" {
  description = "Name of the log stream used by the CodeBuild project. If not specified then a default is used."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 14
}

variable "s3_logs_bucket_name" {
  description = "Name of the S3 bucket to store logs in. If not specified then logging to S3 will be disabled."
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
  description = "The VPC ID for AWS CodeBuild to launch ephemeral instances in."
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of Subnet IDs for AWS CodeBuild to launch ephemeral EC2 instances in."
  default     = []
}

variable "security_group_name" {
  description = "Name to use on created Security Group. Defaults to `name`"
  type        = string
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of Security Group IDs for AWS CodeBuild to launch ephemeral EC2 instances in."
  default     = []
}

# IAM
variable "iam_role_name" {
  description = "Name of the IAM role to be used. If not specified then a role will be created"
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
  description = "The GitHub personal access token to use for accessing the repository. If not specified then GitHub auth must be configured separately."
  type        = string
  default     = null
}

variable "github_personal_access_token_ssm_parameter" {
  description = "The GitHub personal access token to use for accessing the repository. If not specified then GitHub auth must be configured separately."
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
variable "create_ecr_repository" {
  description = "If set to true then an ECR repository will be created, and an image needs to be pushed to it before running the build project"
  type        = string
  default     = false
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository to create or use. If not specified and `create_ecr_repository` is true, then a default is used."
  type        = string
  default     = null
}
