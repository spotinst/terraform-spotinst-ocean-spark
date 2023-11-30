provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

################################################################################
# Create VPC
################################################################################

data "aws_availability_zones" "available" {}

locals {
  public_1  = cidrsubnet(var.vpc_cidr, 2, 0)
  public_2  = cidrsubnet(var.vpc_cidr, 2, 1)
  private_1 = cidrsubnet(var.vpc_cidr, 2, 2)
  private_2 = cidrsubnet(var.vpc_cidr, 2, 3)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.2.0"

  create_vpc           = true
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = [local.private_1, local.private_2]
  public_subnets       = [local.public_1, local.public_2]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.2.0"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      tags         = { Name = "s3-vpc-endpoint" }
    },
  }
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

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  self_managed_node_groups = {
    # This node group is needed upon cluster creation so that the controller pods enabling
    # Ocean and Ocean Spark functionalities can be scheduled.
    bootstrap = {
      instance_type = "c5.large"
      max_size      = 5
      desired_size  = 1
      min_size      = 0
      subnet_ids    = module.vpc.private_subnets
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
  subnet_ids                  = module.vpc.private_subnets
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
# Install EKS ADD-ONs with necessary IAM resources
# (ebs-csi, vpc-cni, core-dns, proxy)
################################################################################

module "vpc_cni_ipv4_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.17.0"

  role_name             = "${var.cluster_name}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

}

data "aws_eks_addon_version" "vpc-cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.cluster_version
}

data "aws_eks_addon_version" "kube-proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.cluster_version
}

data "aws_eks_addon_version" "core-dns" {
  addon_name         = "coredns"
  kubernetes_version = var.cluster_version
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name                = module.eks.cluster_id
  addon_name                  = "vpc-cni"
  addon_version               = data.aws_eks_addon_version.vpc-cni.version
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = module.vpc_cni_ipv4_irsa_role.iam_role_arn
}

resource "aws_eks_addon" "core-dns" {
  cluster_name                = module.eks.cluster_id
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.core-dns.version
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name                = module.eks.cluster_id
  addon_name                  = "kube-proxy"
  addon_version               = data.aws_eks_addon_version.kube-proxy.version
  resolve_conflicts_on_update = "OVERWRITE"
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

  cluster_config = {
    cluster_name               = module.eks.cluster_id
    certificate_authority_data = module.eks.cluster_certificate_authority_data
    server_endpoint            = module.eks.cluster_endpoint
    token                      = data.aws_eks_cluster_auth.this.token
  }
}
