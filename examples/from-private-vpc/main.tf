provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

################################################################################
# Create EKS cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cloudwatch_log_group     = false

  vpc_id     = var.vpc_id
  subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)

  self_managed_node_groups = {
    # This node group is needed upon cluster creation so that the controller pods enabling
    # Ocean and Ocean Spark functionalities can be scheduled.
    bootstrap = {
      instance_type = "c5.large"
      max_size      = 5
      desired_size  = 1
      min_size      = 0
      subnet_ids    = var.private_subnet_ids
    }
  }

  node_security_group_additional_rules = {
    egress_all = {
      description      = "Egress from nodes to the Internet, all protocols and ports"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_self_all_to_all = {
      description = "Node to node all traffic"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

}

################################################################################
# Create aws-auth configmap
# (the eks module recently removed their support for aws-auth management (>=18))
################################################################################

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
}

resource "null_resource" "patch" {
  triggers = {
    kubeconfig = base64encode(local.kubeconfig)
    cmd_patch  = "echo \"${module.eks.aws_auth_configmap_yaml}\" | kubectl apply --kubeconfig <(echo $KUBECONFIG | base64 --decode) -f -"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
    command = self.triggers.cmd_patch
  }
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
  version = "0.2.3"

  cluster_name                = module.eks.cluster_id
  region                      = var.aws_region
  subnet_ids                  = var.private_subnet_ids
  worker_instance_profile_arn = module.eks.self_managed_node_groups["bootstrap"].iam_instance_profile_arn
  security_groups             = [module.eks.node_security_group_id]

  max_scale_down_percentage = 100

  shutdown_hours = {
    time_windows = var.shutdown_time_windows,
    is_enabled   = var.enable_shutdown_hours
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

module "ocean-controller" {
  source  = "spotinst/ocean-controller/spotinst"
  version = "0.43.0"

  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  cluster_identifier = module.eks.cluster_id
}

################################################################################
# Import Ocean cluster into Ocean Spark
################################################################################

module "ocean-spark" {
  source = "../.."

  ocean_cluster_id = module.ocean-aws-k8s.ocean_id

  depends_on = [
    module.ocean-aws-k8s,
    module.ocean-controller,
  ]
}
