locals {
  spot_system_namespace = "spot-system"
  service_account_name  = "bigdata-deployer"
  role_binding_name     = "bigdata-deployer-admin"
}

resource "kubernetes_namespace" "spot-system" {
  count = var.create_cluster && var.deployer_namespace == local.spot_system_namespace ? 1 : 0
  metadata {
    name = local.spot_system_namespace
  }
}

resource "kubernetes_service_account" "deployer" {
  count = var.create_cluster ? 1 : 0
  metadata {
    name      = local.service_account_name
    namespace = var.deployer_namespace
  }

}

resource "kubernetes_cluster_role_binding" "deployer" {
  count = var.create_cluster ? 1 : 0
  metadata {
    name = local.role_binding_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.service_account_name
    namespace = var.deployer_namespace
  }

  depends_on = [
    kubernetes_service_account.deployer
  ]
}

resource "spotinst_ocean_spark" "cluster" {
  ocean_cluster_id = var.ocean_cluster_id

  compute {
    create_vngs = var.compute_create_vngs
    use_taints  = var.compute_use_taints
  }

  ingress {
    controller {
      managed = var.ingress_managed_controller
    }
    load_balancer {
      managed             = try(var.ofas_managed_load_balancer, var.ingress_managed_load_balancer)
      target_group_arn    = var.ingress_load_balancer_target_group_arn
      service_annotations = var.ingress_load_balancer_service_annotations
    }
    custom_endpoint {
      enabled = var.enable_custom_endpoint
      address = var.ingress_custom_endpoint_address
    }
    private_link {
      enabled              = var.enable_private_link
      vpc_endpoint_service = var.ingress_private_link_endpoint_service_address
    }
  }

  log_collection {
    collect_driver_logs = var.log_collection_collect_driver_logs
  }

  webhook {
    use_host_network   = var.webhook_use_host_network
    host_network_ports = var.webhook_host_network_ports
  }

  spark {
    additional_app_namespaces = var.spark_additional_app_namespaces
  }

  depends_on = [
    kubernetes_service_account.deployer,
    kubernetes_cluster_role_binding.deployer,
  ]
}


resource "spotinst_ocean_spark_virtual_node_group" "this" {
  for_each = toset(var.attach_dedicated_virtual_node_groups)

  virtual_node_group_id  = each.key
  ocean_spark_cluster_id = spotinst_ocean_spark.cluster.id
}