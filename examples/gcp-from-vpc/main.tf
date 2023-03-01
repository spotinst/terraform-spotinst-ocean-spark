provider "google" {
  # Configuration options
  project = var.project
  region  = var.region
}

################################################################################
# Create GKE cluster
################################################################################

resource "google_container_cluster" "cluster" {
  name               = var.cluster_name
  min_master_version = var.cluster_version

  location = var.region

  initial_node_count = 1

  network    = var.network_name
  subnetwork = var.subnetwork_name

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block

  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }
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
  location              = var.region

  scheduled_task {
    shutdown_hours {
      is_enabled   = var.enable_shutdown_hours
      time_windows = var.shutdown_time_windows
    }
  }
}

data "google_client_config" "default" {}
provider "kubernetes" {
  host                   = "https://${google_container_cluster.cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
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

  ocean_cluster_id = spotinst_ocean_gke_import.ocean.id
}
