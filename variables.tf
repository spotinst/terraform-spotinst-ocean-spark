variable "ocean_cluster_id" {
  type        = string
  description = "Specifies the Ocean cluster identifier"
}

variable "create_cluster" {
  type        = bool
  description = "Controls whether the Ocean for Apache Spark cluster should be created (it affects all resources)"
  default     = true
}

variable "compute_create_vngs" {
  type        = bool
  description = "Controls whether dedicated Ocean Spark VNGs will be created by the cluster creation process"
  default     = true
}

variable "compute_use_taints" {
  type        = bool
  description = "Controls whether the Ocean Spark cluster will use taints to schedule workloads"
  default     = true
}

variable "ofas_managed_load_balancer" {
  type        = bool
  description = "Controls whether a load balancer managed by Ocean for Apache Spark will be provisioned for the cluster"
  default     = true
}
variable "ingress_load_balancer_service_annotations" {
  type        = map(string)
  description = "Annotations that will be added to the load balancer service, allowing for customization of the load balancer"
  default     = {}
}

variable "ingress_load_balancer_target_group_arn" {
  type        = string
  description = "The ARN of a target group that the Ocean for Apache Spark ingress controller will be bound to."
  default     = null
}

variable "enable_custom_endpoint" {
  type        = bool
  description = "Controls whether the Ocean for Apache Spark control plane address the cluster using a custom endpoint."
  default     = false
}
variable "ingress_custom_endpoint_address" {
  type        = string
  description = "The address the Ocean for Apache Spark control plane will use when addressing the cluster when custom endpoint is enabled"
  default     = null
}


variable "enable_private_link" {
  type        = bool
  description = "Controls whether the Ocean for Apache Spark control plane address the cluster via an AWS Private Link"
  default     = false
}

variable "ingress_private_link_endpoint_service_address" {
  type        = string
  description = "The name of the VPC Endpoint Service the Ocean for Apache Spark control plane should bind to when privatelink is enabled"
  default     = null
}

variable "log_collection_collect_driver_logs" {
  type        = bool
  description = "Controls whether the Ocean Spark cluster will collect Spark driver logs"
  default     = true
}

variable "webhook_use_host_network" {
  type        = bool
  description = "Controls whether Ocean Spark system pods that expose webhooks will use the host network"
  default     = false
}

variable "webhook_host_network_ports" {
  type        = list(number)
  description = "Assign a list of ports on the host networks for our system pods"
  default     = []
}
