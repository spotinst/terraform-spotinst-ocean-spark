provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

################################################################################
# Data sources
################################################################################

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Tier = "Private"
  }
}

################################################################################
# Create the privatelink resources (NLB, TargetGroup)
################################################################################

resource "aws_lb" "this" {
  name               = "${var.cluster_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [data.aws_subnets.private.ids]

  security_groups = [aws_security_group.this.id]

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
  name               = "${var.cluster_name}-nlb-tg"
  port               = 443
  target_type        = "ip"
  protocol           = "TCP"
  vpc_id             = var.vpc_id
  preserve_client_ip = "true"

  depends_on = [
    aws_lb.this
  ]

}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  protocol          = "TCP"
  port              = 443
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_security_group" "this" {
  description = "Allow inbound/outbound traffic between NLB and OfAS VPC"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.this.id
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
}

resource "aws_security_group_rule" "ingress_https" {
  security_group_id = aws_security_group.this.id
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  type              = "ingress"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
}


################################################################################
#   Install the aws load balancer controller
################################################################################

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

module "load_balancer_controller" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git"

  cluster_identity_oidc_issuer     = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = data.aws_iam_openid_connect_provider.this.arn
  cluster_name                     = var.cluster_name

  enabled = true
}


# ################################################################################
# # Import Ocean cluster into Ocean Spark
# ################################################################################

# module "ocean-spark" {
#   source = "../.."

#   ocean_cluster_id = module.ocean-aws-k8s.ocean_id

#   ingress_managed_load_balancer          = false
#   ingress_load_balancer_target_group_arn = aws_lb_target_group.this.arn


#   enable_private_link                           = true
#   ingress_private_link_endpoint_service_address = aws_vpc_endpoint_service.this.service_name

#   cluster_config = {
#     cluster_name               = var.cluster_name
#     certificate_authority_data = data.aws_eks_cluster.this.certificate_authority[0].data
#     server_endpoint            = data.aws_eks_cluster.this.endpoint
#     token                      = data.aws_eks_cluster_auth.this.token
#   }

# }
