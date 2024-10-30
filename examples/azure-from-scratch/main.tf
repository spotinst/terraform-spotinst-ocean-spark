# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id

  use_cli = false
}


resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "${var.cluster_name}-rg"

  tags = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/8"]

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  name                 = var.cluster_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.240.0.0/16"]

  private_endpoint_network_policies_enabled = true
}


module "aks" {
  source  = "Azure/aks/azurerm"
  version = "6.7.1"

  prefix              = "oceanspark"
  resource_group_name = azurerm_resource_group.this.name
  sku_tier            = "Standard"
  cluster_name        = var.cluster_name
  kubernetes_version  = var.cluster_version
  vnet_subnet_id      = azurerm_subnet.this.id

  rbac_aad                          = true
  rbac_aad_managed                  = true
  role_based_access_control_enabled = true

  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret


  log_analytics_workspace_enabled = false


  tags = var.tags

  depends_on = [azurerm_resource_group.this]
}

###############################################################################
# Import AKS cluster into Ocean
###############################################################################
provider "helm" {
  kubernetes {
    host                   = module.aks.admin_host
    username               = module.aks.admin_username
    password               = module.aks.admin_password
    cluster_ca_certificate = base64decode(module.aks.admin_cluster_ca_certificate)
    client_certificate     = base64decode(module.aks.admin_client_certificate)
    client_key             = base64decode(module.aks.admin_client_key)
  }
}

module "ocean-controller" {
  source  = "spotinst/kubernetes-controller/ocean"
  version = "0.0.14"

  cluster_identifier = var.cluster_name
  spotinst_token     = var.spotinst_token
  spotinst_account   = var.spotinst_account
}

module "ocean-aks-np" {
  source  = "spotinst/ocean-aks-np-k8s/spotinst"
  version = "0.5.0"

  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  ocean_cluster_name                        = var.cluster_name
  controller_cluster_id                     = var.cluster_name
  aks_region                                = var.location
  aks_cluster_name                          = module.aks.aks_name
  aks_infrastructure_resource_group_name    = module.aks.node_resource_group
  aks_resource_group_name                   = azurerm_resource_group.this.name
  autoscaler_is_enabled                     = true
  autoscaler_resource_limits_max_vcpu       = 20000
  autoscaler_resource_limits_max_memory_gib = 100000
  autoscaler_max_scale_down_percentage      = 10
  autoscaler_headroom_automatic_percentage  = 5
  autoscale_headrooms_cpu_per_unit          = 6
  autoscale_headrooms_memory_per_unit       = 10
  autoscale_headrooms_gpu_per_unit          = 0
  autoscale_headrooms_num_of_units          = 10
  health_grace_period                       = 600
  max_pods_per_node                         = 110
  enable_node_public_ip                     = false
  os_disk_size_gb                           = 128
  os_disk_type                              = "Managed"
  os_type                                   = "Linux"
  node_min_count                            = 0
  node_max_count                            = 1000
  spot_percentage                           = 100
  fallback_to_ondemand                      = true
  availability_zones                        = [1, 2, 3, ]
  tags                                      = var.tags
  vmsizes_filters_min_vcpu                  = 2
  vmsizes_filters_max_vcpu                  = 16
  vmsizes_filters_min_memory_gib            = 10
  vmsizes_filters_max_memory_gib            = 18
  vmsizes_filters_series                    = ["D v3", "Dds_v4", "Dsv2"]
  vmsizes_filters_architectures             = ["X86_64"]
  scheduling_shutdown_hours_time_windows    = ["Sat:08:00-Sun:08:00"]
  scheduling_shutdown_hours_is_enabled      = true
}


################################################################################
# Import Ocean cluster into Ocean Spark
################################################################################
provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

module "ocean-spark" {
  source = "../.."

  ocean_cluster_id = module.ocean-aks-np.ocean_id

  depends_on = [
    module.ocean-aks-np,
    module.ocean-controller,
  ]

  cluster_config = {
    cluster_name               = var.cluster_name
    certificate_authority_data = module.aks.admin_cluster_ca_certificate
    server_endpoint            = module.aks.admin_host
    client_certificate         = module.aks.admin_client_certificate
    client_key                 = module.aks.admin_client_key
  }
}