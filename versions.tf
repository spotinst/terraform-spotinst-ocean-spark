terraform {
  required_version = ">= 0.13.1"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    spotinst = {
      source  = "spotinst/spotinst"
      version = "~> 1.84"
    }
  }
}