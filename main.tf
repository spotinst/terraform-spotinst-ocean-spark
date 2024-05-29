locals {
  collect_app_logs   = coalesce(var.log_collection_collect_driver_logs, var.log_collection_collect_app_logs)
  ofas_deployer_path = "https://spotinst-public.s3.amazonaws.com/integrations/kubernetes/ocean-spark/templates/ocean-spark-deploy.yaml"
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = var.cluster_config.cluster_name
      cluster = {
        certificate-authority-data = var.cluster_config.certificate_authority_data
        server                     = var.cluster_config.server_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = var.cluster_config.cluster_name
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token                   = var.cluster_config.token
        client-certificate-data = var.cluster_config.client_certificate
        client-key-data         = var.cluster_config.client_key
      }
    }]
  })
}

resource "null_resource" "apply_kubernetes_manifest" {
  provisioner "local-exec" {
    command = <<-EOT
      cat <<EOF > cluster_kubeconfig.yaml
      ${local.kubeconfig}
      EOF
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      bash -c '
      curl  ${local.ofas_deployer_path} | kubectl --kubeconfig="cluster_kubeconfig.yaml" apply -f -'
    EOT
  }

  provisioner "local-exec" {
    command = "rm cluster_kubeconfig.yaml"
  }
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
      managed             = var.ingress_managed_load_balancer
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
    collect_app_logs = local.collect_app_logs
  }

  webhook {
    use_host_network   = var.webhook_use_host_network
    host_network_ports = var.webhook_host_network_ports
  }

  spark {
    additional_app_namespaces = var.spark_additional_app_namespaces
  }

  depends_on = [null_resource.apply_kubernetes_manifest]
}

resource "spotinst_ocean_spark_virtual_node_group" "this" {
  for_each = toset(var.attach_dedicated_virtual_node_groups)

  virtual_node_group_id  = each.key
  ocean_spark_cluster_id = spotinst_ocean_spark.cluster.id
}