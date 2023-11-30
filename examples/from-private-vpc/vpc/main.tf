provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

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

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
