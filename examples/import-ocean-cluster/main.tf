provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

module "ocean-spark" {
  source = "../.."

  ocean_cluster_id = var.ocean_cluster_id
}