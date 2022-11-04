variable "region" {
  type        = string
  description = "region"
}

variable "public_key" {
  type        = string
  description = "public_key"
}

variable "naming_prefix" {
  type        = string
  description = "naming_prefix"
}

variable "run_id" {
  type        = string
  description = "run_id"
}

variable "ec2_key_pair_name" {
  type        = string
  description = "ec2_key_pair_name"
  default     = ""
}

variable "aws_account_id" {
  type        = string
  description = "aws_account_id"
}

variable "subnet_ids" {
  type        = list(string)
  description = "subnet_ids"
}

variable "vpc_id" {
  type        = string
  description = "vpc_id"
}

variable "github_url" {
  type        = string
  description = "github_url"
}

variable "iam_instance_profile_arn" {
  type        = string
  description = "iam_instance_profile_arn"
}
