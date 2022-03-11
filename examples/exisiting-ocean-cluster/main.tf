provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "ocean-spark" {
  source = "../.."
}