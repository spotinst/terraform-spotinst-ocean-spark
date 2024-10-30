terraform {
  required_providers {
    spotinst = {
      source  = "spotinst/spotinst"
      version = "~> 1.90"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.28"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}
