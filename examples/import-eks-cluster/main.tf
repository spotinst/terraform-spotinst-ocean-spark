provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

################################################################################
# Import EKS cluster into Ocean
################################################################################

provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

module "ocean-aws-k8s" {
  source  = "spotinst/ocean-aws-k8s/spotinst"
  version = "1.5.0"

  cluster_name                = var.cluster_name
  region                      = var.aws_region
  subnet_ids                  = var.node_subnet_ids
  worker_instance_profile_arn = var.node_iam_instance_profile_arn
  security_groups             = [var.node_security_group_id]

  max_scale_down_percentage = 100

  shutdown_hours = {
    time_windows = var.shutdown_time_windows,
    is_enabled   = var.enable_shutdown_hours
  }

}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

module "ocean-controller" {
  source  = "spotinst/kubernetes-controller/ocean"
  version = "~> 0.0.14"

  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  cluster_identifier = var.cluster_name
}

################################################################################
# Import Ocean cluster into Ocean Spark
################################################################################

module "ocean-spark" {
  source = "../.."

  ocean_cluster_id = module.ocean-aws-k8s.ocean_id

  cluster_config = {
    cluster_name               = var.cluster_name
    certificate_authority_data = data.aws_eks_cluster.this.certificate_authority[0].data
    server_endpoint            = data.aws_eks_cluster.this.endpoint
    token                      = data.aws_eks_cluster_auth.this.token
  }

  depends_on = [
    module.ocean-aws-k8s,
    module.ocean-controller,
  ]
}
