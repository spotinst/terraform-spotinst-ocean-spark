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

variable "ingress_service_annotations" {
  type        = map(string)
  description = "Annotations that will be added to the load balancer service, allowing for customization of the load balancer"
  default     = {}
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
