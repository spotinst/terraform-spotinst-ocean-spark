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

variable "cluster_version" {
  type    = string
  default = "1.23"
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

variable "shutdown_time_windows" {
  type = list(string)
  default = [              # GMT
    "Fri:23:30-Mon:07:30", # Weekends
    "Mon:23:30-Tue:07:30", # Weekday evenings
    "Tue:23:30-Wed:07:30",
    "Wed:23:30-Thu:07:30",
    "Thu:23:30-Fri:07:30",
  ]
}

variable "enable_shutdown_hours" {
  type    = bool
  default = false
}