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
  version = "~> 2.70"

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
  enable_s3_endpoint   = true

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

################################################################################
# Create the privatelink resources (NLB, TargetGroup)
################################################################################

resource "aws_lb" "this" {
  name               = "${var.cluster_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.private_subnets

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
  vpc_id      = module.vpc.vpc_id

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
  vpc_id      = module.vpc.vpc_id
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
  cluster_version = "1.21"

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
    ingress_node_9443 = {
      description = "Cluster API to load balancer webhook"
      protocol    = "tcp"
      from_port   = 9443
      to_port     = 9443
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
#   Install the aws load balancer controller
################################################################################

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "load-balancer-controller-role" {
  name        = "${var.cluster_name}-aws-load-balancer-controller"
  description = "Permissions required by the Kubernetes AWS Load Balancer controller to do its job."

  force_detach_policies = true

  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json
}


resource "aws_iam_policy" "load-balancer-policy" {
  name        = "${var.vpc_name}AWSLoadBalancerControllerIAMPolicy"
  description = "AWS LoadBalancer Controller IAM Policy"

  policy = file("iam-policy.json")

}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.load-balancer-policy.arn
  role       = aws_iam_role.load-balancer-controller-role.name
}

resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.load-balancer-controller-role.arn
    }
    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_cluster_role" "this" {
  metadata {
    name = "aws-load-balancer-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}


provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  dynamic "set" {

    for_each = {
      "clusterName"           = var.cluster_name
      "serviceAccount.create" = false
      "serviceAccount.name"   = kubernetes_service_account.this.metadata[0].name
      "region"                = var.aws_region
      "vpcId"                 = module.vpc.vpc_id
    }
    content {
      name  = set.key
      value = set.value
    }
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
  source = "spotinst/ocean-aws-k8s/spotinst"

  cluster_name                = module.eks.cluster_id
  region                      = var.aws_region
  subnet_ids                  = module.vpc.private_subnets
  worker_instance_profile_arn = module.eks.self_managed_node_groups["bootstrap"].iam_instance_profile_arn
  security_groups             = [module.eks.node_security_group_id]

  max_scale_down_percentage = 100

}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

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
}
