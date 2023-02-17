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

variable "aws_profile" {
  description = "AWS profile"
  type        = string
}

variable "vpc_name" {
  description = "Desired VPC Name"
  type        = string
}

variable "vpc_cidr" {
  description = "Desired VPC CIDR"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "creator_email" {
  description = "Creator's email"
  type        = string
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