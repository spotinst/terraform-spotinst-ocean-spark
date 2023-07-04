provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

module "ocean-spark" {
  source = "../.."

  ocean_cluster_id = var.ocean_cluster_id

  cluster_config = {
    cluster_name               = var.cluster_name
    certificate_authority_data = data.aws_eks_cluster.this.certificate_authority[0].data
    server_endpoint            = data.aws_eks_cluster.this.endpoint
    token                      = data.aws_eks_cluster_auth.this.token
  }
}