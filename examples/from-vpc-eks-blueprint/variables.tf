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

variable "vpc_id" {
  description = "AWS VPC ID"
  type        = string
}

variable "private_subnets_ids" {
  description = "AWS private subnet IDs"
  type        = list(any)
}

variable "public_subnets_ids" {
  description = "AWS public subnet IDs"
  type        = list(any)
}

variable "creator_email" {
  description = "Creator's email"
  type        = string
  default     = ""
}

variable "shutdown_time_windows" {
  type = list(string)
  default = [
    "Fri:23:30-Mon:13:30", # Weekends
    "Mon:23:30-Tue:13:30", # Weekday evenings
    "Tue:23:30-Wed:13:30",
    "Wed:23:30-Thu:13:30",
    "Thu:23:30-Fri:13:30",
  ]
}

variable "enable_shutdown_hours" {
  type    = bool
  default = false
}