terraform {
  required_version = ">= 0.13.1"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.0.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
  }
}
