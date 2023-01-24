terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.26.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.0.1"
    }
    null = {
      source  = "hashicorp/null"
      version = " >= 3.1.1"
    }
  }
}

provider "aws" {
  region = var.region
}
