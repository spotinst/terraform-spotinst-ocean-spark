terraform {
  required_providers {
    spotinst = {
      source  = "spotinst/spotinst"
      version = "~> 1.90"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.47"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}
