#################################
### Locals ######################
#################################

locals {
    creator   = var.creator_email
    createdby = "terraform"
    protected = "weekend"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

#############################################
### Create EKS Cluster ######################
#############################################

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  # EKS CLUSTER
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  map_roles = [
    {
      rolearn  = aws_iam_role.nodes.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  #K8s Add-ons
  enable_metrics_server = true

  depends_on = [
    module.ocean-aws-k8s
  ]
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

#############################################
### Create EKS Node IAM Role and Profile ####
#############################################

resource "aws_iam_role" "nodes" {
  name = "${var.cluster_name}-nodeRole-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "amazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.cluster_name}-nodeProfile-group"
  role = aws_iam_role.nodes.name
}

#############################################
### Create Ocean Cluster ####################
#############################################

resource "null_resource" "patience" {
  depends_on = [module.eks_blueprints]

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

module "ocean-aws-k8s" {
  source = "spotinst/ocean-aws-k8s/spotinst"

  # Configuration
  cluster_name                = var.cluster_name
  region                      = var.aws_region
  subnet_ids                  = concat(var.public_subnet_ids, var.private_subnet_ids)
  worker_instance_profile_arn = aws_iam_instance_profile.profile.arn
  security_groups             = [module.eks_blueprints.cluster_primary_security_group_id]
  min_size                    = 0

  tags = local.tags

  shutdown_hours = {
    is_enabled = true
    time_windows = [ # Must be in GMT
      "Fri:23:30-Mon:13:30", # Weekends
      "Mon:23:30-Tue:13:30", # Weekday evenings
      "Tue:23:30-Wed:13:30",
      "Wed:23:30-Thu:13:30",
      "Thu:23:30-Fri:13:30",
    ]
  }

  depends_on = [
    null_resource.patience
  ]
}

#############################################
### Install Ocean Controller ################
#############################################

provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

  # Credentials.
  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  # Configuration.
  cluster_identifier = var.cluster_name

  depends_on = [
    module.ocean-aws-k8s
  ]
}

module "ocean-spark" {
  source = "spotinst/ocean-spark/spotinst"
  version = "1.1.1"

  ocean_cluster_id = module.ocean-aws-k8s.ocean_id

  depends_on = [
    module.ocean-aws-k8s
  ]
}