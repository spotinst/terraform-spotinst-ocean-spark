# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id

  use_cli = false
}

data "azurerm_subnet" "this" {
  name                 = var.vnet_subnet_id
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "6.7.1"

  prefix              = "oceanspark"
  resource_group_name = var.resource_group_name
  sku_tier            = "Paid"
  cluster_name        = var.cluster_name
  kubernetes_version  = var.cluster_version
  vnet_subnet_id      = data.azurerm_subnet.this.id

  rbac_aad                          = true
  rbac_aad_managed                  = true
  role_based_access_control_enabled = true

  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret


  log_analytics_workspace_enabled = false


  tags = var.tags
}

###############################################################################
# Import AKS cluster into Ocean
###############################################################################

provider "kubernetes" {
  host                   = module.aks.admin_host
  username               = module.aks.admin_username
  password               = module.aks.admin_password
  client_certificate     = base64decode(module.aks.admin_client_certificate)
  client_key             = base64decode(module.aks.admin_client_key)
  cluster_ca_certificate = base64decode(module.aks.admin_cluster_ca_certificate)
}

module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  cluster_identifier    = var.cluster_name
  aks_connector_enabled = true
  acd_identifier        = var.cluster_name
}


module "ocean-aks-np" {
  source  = "spotinst/ocean-aks-np-k8s/spotinst"
  version = "0.2.0"

  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  ocean_cluster_name                        = var.cluster_name
  controller_cluster_id                     = var.cluster_name
  aks_region                                = var.location
  aks_cluster_name                          = module.aks.aks_name
  aks_infrastructure_resource_group_name    = module.aks.node_resource_group
  aks_resource_group_name                   = var.resource_group_name
  autoscaler_is_enabled                     = true
  autoscaler_resource_limits_max_vcpu       = 20000
  autoscaler_resource_limits_max_memory_gib = 100000
  autoscaler_max_scale_down_percentage      = 10
  autoscaler_headroom_automatic_is_enabled  = true
  autoscaler_headroom_automatic_percentage  = 5
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

  depends_on = [module.ocean-aks-np]
}
