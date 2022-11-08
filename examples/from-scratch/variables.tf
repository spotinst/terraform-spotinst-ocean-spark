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

variable "vpc_name" {
  type = string
  default = ""
}

variable "vpc_cidr" {
  type = string
  default = "192.168.0.0/16"
  description = "The CIDRs for the new vpc"
}
