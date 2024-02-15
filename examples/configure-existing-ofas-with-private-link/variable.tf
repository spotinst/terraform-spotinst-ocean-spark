variable "spotinst_token" {
  type = string
}

variable "spotinst_account" {
  type = string
}

variable "oceanspark_cluster_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}


variable "target_group" {
  type = map(string)
  default = {
    "Protocol" = "TCP"
    "Port"     = "443"
  }
}

