variable "spotinst_token" {
  type        = string
  description = "Spot Personal Access token"
}

variable "spotinst_account" {
  type        = string
  description = "Spot account ID"
}

variable "aws_region" {
  type        = string
  description = "EKS cluster region"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile to use"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "node_instance_profile" {
  type        = string
  description = "EKS Node Instance Profile"
}
