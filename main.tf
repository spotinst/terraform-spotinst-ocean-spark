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

resource "kubernetes_job" "deployer" {
  count = var.create_cluster ? 1 : 0
  metadata {
    generate_name = "ofas-deploy-"
    namespace     = local.spot_system_namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name              = "deployer"
          image             = "${var.deployer_image}:${var.deployer_tag}"
          image_pull_policy = var.image_pull_policy
          args              = ["install", "--create-bootstrap-environment"]
        }
        restart_policy       = "Never"
        service_account_name = local.service_account_name
      }
    }
    ttl_seconds_after_finished = 300
  }
  wait_for_completion = true
  timeouts {
    create = "10m"
    update = "10m"
  }
  depends_on = [
    kubernetes_namespace.spot-system,
    kubernetes_service_account.deployer,
    kubernetes_cluster_role_binding.deployer,
  ]
}
