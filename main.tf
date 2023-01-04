locals {
  spot_system_namespace = "spot-system"
  service_account_name  = "bigdata-deployer"
  role_binding_name     = "bigdata-deployer-admin"
}

resource "kubernetes_namespace" "spot-system" {
  count = var.create_cluster ? 1 : 0
  metadata {
    name = local.spot_system_namespace
  }
}

resource "kubernetes_service_account" "deployer" {
  count = var.create_cluster ? 1 : 0
  metadata {
    name      = local.service_account_name
    namespace = local.spot_system_namespace
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
    namespace = local.spot_system_namespace
  }
}
resource "spotinst_ocean_spark" "cluster" {
  ocean_cluster_id = var.ocean_cluster_id

  compute {
    create_vngs = var.compute_create_vngs
    use_taints  = var.compute_use_taints
  }

  ingress {
    load_balancer {
      managed             = var.ofas_managed_load_balancer
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

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl apply -f ../../ofas-uninstall.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    isCleaned=''
    countWaiting=0
    while [ $countWaiting -le 300 ] ;
    do
        isCleaned=$(kubectl get jobs ofas-uninstall -n spot-system -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' | grep True)
        if [ "$isCleaned" != "True" ]; then
            sleep 10;
            ((countWaiting+=10))
        else
            break
        fi
    done
    echo "done"
    EOT
  }

  depends_on = [
    kubernetes_namespace.spot-system,
    kubernetes_service_account.deployer,
    kubernetes_cluster_role_binding.deployer
  ]
}

