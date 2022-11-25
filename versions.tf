terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9, <5"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.0.1"
    }
  }
}
