variable "create_ofas_cluster" {
  type        = bool
  description = "Specifies whether to create an Ocean for Apache Spark cluster"
  default     = true
}

variable "ofas_deployer_image" {
  type        = string
  description = "Specifies the Docker image name used in the deployer Job"
  default     = "public.ecr.aws/f4k1p1n4/bigdata-deployer"
}

variable "ofas_deployer_tag" {
  type        = string
  description = "Specifies the Docker image tag used in the deployer Job"
  default     = "main"
}

variable "image_pull_policy" {
  type        = string
  description = "Specifies the image pull policy (one of: Always, Never, IfNotPresent)"
  default     = "Always"
}


variable "create_spot_system_namespace" {
  type        = bool
  description = "Specifies whether to create a namespace for the Spot components"
  default     = true
}
