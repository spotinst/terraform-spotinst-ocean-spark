provider "google" {
  # Configuration options
  project = var.project
  region  = var.region
}

################################################################################
# Create networking
################################################################################

resource "google_compute_network" "this" {
  name = "${var.cluster_name}-network"
}


resource "google_compute_subnetwork" "this" {
  name          = "${var.cluster_name}-subnetwork"
  ip_cidr_range = "10.42.0.0/16"
  network       = google_compute_network.this.self_link

  private_ip_google_access = true
}
resource "google_compute_router" "this" {
  name    = "${var.cluster_name}-router"
  network = google_compute_network.this.name
}

resource "google_compute_address" "nat_ips" {
  count  = 3
  name   = "${var.cluster_name}-nat-ip-${count.index}"
  region = var.region
}

resource "google_compute_router_nat" "this" {
  name   = "${var.cluster_name}-nat"
  router = google_compute_router.this.name
  region = google_compute_router.this.region

  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_ips.*.self_link
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.this.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

################################################################################
# Create GKE cluster
################################################################################

resource "google_container_cluster" "cluster" {
  name               = var.cluster_name
  min_master_version = var.cluster_version

  location = var.region

  initial_node_count = 1

  network    = google_compute_network.this.name
  subnetwork = google_compute_subnetwork.this.name

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "192.168.1.0/28"

  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "172.16.0.0/16"
    services_ipv4_cidr_block = "172.20.0.0/16"
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
  cluster_name          = google_container_cluster.cluster.name
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
