terraform {
  required_version = ">= 1.5.7, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6, < 7"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
