variable "spotinst_token" {
  type = string
}

variable "spotinst_account" {
  type = string
}

variable "project" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "network_name" {
  type = string
}

variable "subnetwork_name" {
  type = string
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "192.168.1.0/28"
}

variable "cluster_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}

variable "services_ipv4_cidr_block" {
  type    = string
  default = "172.20.0.0/16"
}
