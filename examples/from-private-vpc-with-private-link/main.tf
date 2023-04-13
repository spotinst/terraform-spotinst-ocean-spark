provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

################################################################################
# Create the privatelink resources (NLB, TargetGroup)
################################################################################

resource "aws_lb" "this" {
  name               = "${var.cluster_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

}

resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.this.arn]

}

resource "aws_vpc_endpoint_service_allowed_principal" "service_to_client" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.this.id
  principal_arn           = "arn:aws:iam::066597193667:root"
}

resource "aws_lb_target_group" "this" {
  name        = "${var.cluster_name}-nlb-tg"
  port        = var.target_group.Port
  target_type = "ip"
  protocol    = var.target_group.Protocol
  vpc_id      = var.vpc_id

  depends_on = [
    aws_lb.this
  ]

}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  protocol          = var.target_group.Protocol
  port              = var.target_group.Port
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_security_group" "this" {
  description = "Allow connection between NLB and target"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.this.id
  from_port         = var.target_group.Port
  to_port           = var.target_group.Port
  protocol          = var.target_group.Protocol
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
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
    ingress_node_9443 = {
      description                   = "Cluster API to load balancer webhook"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_node_443 = {
      description = "VPC to Nodes (LB health check)"
      protocol    = "TCP"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.this.cidr_block]
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
#   Install the aws load balancer controller
################################################################################
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

module "load_balancer_controller" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git"

  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = module.eks.cluster_id

  enabled = true
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
  version = "0.41.0"

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

  ingress_managed_load_balancer          = false
  ingress_load_balancer_target_group_arn = aws_lb_target_group.this.arn


  enable_private_link                           = true
  ingress_private_link_endpoint_service_address = aws_vpc_endpoint_service.this.service_name
}
