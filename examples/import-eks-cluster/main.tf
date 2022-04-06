resource "spotinst_ocean_aws" "this" {
  name                 = var.cluster_name
  controller_id        = var.cluster_name
  region               = var.aws_region
  subnet_ids           = data.aws_eks_cluster.this.vpc_config.0.subnet_ids
  security_groups      = [data.aws_eks_cluster.this.vpc_config.0.cluster_security_group_id]
  iam_instance_profile = var.node_instance_profile

  image_id = data.aws_ami.eks_default.image_id

  user_data = <<-EOF
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${var.cluster_name}
EOF

  tags {
    key   = "kubernetes.io/cluster/${var.cluster_name}"
    value = "owned"
  }
}

module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

  # Credentials.
  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  # Configuration.
  cluster_identifier = var.cluster_name
}

module "ocean-spark" {
  source = "../.."
  depends_on = [
    module.ocean-controller,
    spotinst_ocean_aws.this
  ]
}
