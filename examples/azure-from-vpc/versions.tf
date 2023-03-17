terraform {
  required_providers {
    spotinst = {
      source  = "spotinst/spotinst"
      version = "~> 1.90"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.47"
    }
  }
}
