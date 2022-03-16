variable "create_cluster" {
  type        = bool
  description = "Controls whether the Ocean for Apache Spark cluster should be created (it affects all resources)"
  default     = true
}

variable "deployer_image" {
  type        = string
  description = "Specifies the Docker image name used in the deployer Job"
  default     = "public.ecr.aws/f4k1p1n4/bigdata-deployer"
}

variable "deployer_tag" {
  type        = string
  description = "Specifies the Docker image tag used in the deployer Job"
  default     = "main"
}

variable "image_pull_policy" {
  type        = string
  description = "Specifies the image pull policy (one of: Always, Never, IfNotPresent)"
  default     = "Always"
}
