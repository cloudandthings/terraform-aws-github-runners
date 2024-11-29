variable "source_locations" {
  type = map(object({
    source_location = string
    source_name     = string
  }))
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
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}