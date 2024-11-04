variable "spotinst_token" {
  type      = string
  sensitive = true
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

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "target_group" {
  type = map(string)
  default = {
    "Protocol" = "TCP"
    "Port"     = "443"
  }
}

variable "shutdown_time_windows" {
  type = list(string)
  default = [              # GMT
    "Fri:23:30-Mon:07:30", # Weekends
    "Mon:23:30-Tue:07:30", # Weekday evenings
    "Tue:23:30-Wed:07:30",
    "Wed:23:30-Thu:07:30",
    "Thu:23:30-Fri:07:30"
  ]
}

variable "enable_shutdown_hours" {
  type    = bool
  default = false
}
