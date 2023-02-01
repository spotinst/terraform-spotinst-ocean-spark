variable "spotinst_token" {
  type = string
}

variable "spotinst_account" {
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

variable "node_subnet_ids" {
  type = list(string)
}

variable "node_iam_instance_profile_arn" {
  type = string
}

variable "node_security_group_id" {
  type = string
}
