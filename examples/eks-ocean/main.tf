provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {
  host                   = module.ocean-eks.cluster_endpoint
  token                  = module.ocean-eks.cluster_token
  cluster_ca_certificate = base64decode(module.ocean-eks.cluster_ca_certificate)
}

module "ocean-eks" {
  source = "spotinst/ocean-eks/spotinst"

  # Credentials.
  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account
}

module "ocean-spark" {
  source = "../.."
  depends_on = [
    module.ocean-eks
  ]
}
