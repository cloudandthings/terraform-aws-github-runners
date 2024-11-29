variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "source_location" {
  type = string
}

variable "source_name" {
  type = string
}

variable "github_personal_access_token_ssm_parameter" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}