terraform {
  required_providers {
    spotinst = {
      source  = "spotinst/spotinst"
      version = "~> 1.90"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.22"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}
