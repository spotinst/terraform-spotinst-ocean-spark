provider "google" {
  # Configuration options
  project = var.project
}

data "google_client_config" "default" {}

data "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.location
}

################################################################################
# Import GKE cluster into Ocean
################################################################################

provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

resource "spotinst_ocean_gke_import" "ocean" {
  cluster_name          = var.cluster_name
  controller_cluster_id = var.cluster_name
  location              = var.location
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

### Deploy Ocean Controller Pod into Cluster ###
module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  cluster_identifier = var.cluster_name
}

################################################################################
# Import Ocean cluster into Ocean Spark
################################################################################

module "ocean-spark" {
  source = "../.."
}
