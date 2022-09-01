variable "region" {
  type        = string
  description = "TODO"
}

variable "public_key" {
  type        = string
  description = "TODO"
}

variable "naming_prefix" {
  type        = string
  description = "TODO"
}

variable "run_id" {
  type        = string
  description = "TODO"
}

variable "ec2_key_pair_name" {
  type        = string
  description = "TODO"
  default     = ""
}

variable "aws_account_id" {
  type        = string
  description = "TODO"
}

variable "subnet_ids" {
  type        = list(string)
  description = "TODO"
}

variable "vpc_id" {
  type        = string
  description = "TODO"
}

variable "github_url" {
  type        = string
  description = "TODO"
}

variable "iam_instance_profile_arn" {
  type        = string
  description = "TODO"
}
