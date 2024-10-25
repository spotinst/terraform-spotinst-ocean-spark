variable "spotinst_token" {
  type      = string
  sensitive = true
}

variable "spotinst_account" {
  type = string
}

variable "ocean_cluster_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}