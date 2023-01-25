variable "spotinst_token" {
  description = "Spot token"
  type        = string
}

variable "spotinst_account" {
  description = "Spot account id"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster and Ocean cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_name" {
  description = "Desired VPC Name"
  type = string
}

variable "vpc_cidr" {
  description = "Desired VPC CIDR"
  type = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "creator_email" {
  description = "Creator's email"
  type        = string
}