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


