terraform {
  required_version = ">= 0.13.1"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    spotinst = {
      source  = "spotinst/spotinst"
      version = ">= 1.115.0, < 2.0.0"
    }

    validation = {
      source  = "tlkamp/validation"
      version = "1.0.0"
    }
  }
}