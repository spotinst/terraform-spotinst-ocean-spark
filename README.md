# terraform-spotinst-ocean-spark

A Terraform module to install the [Ocean for Apache Spark](https://spot.io/products/ocean-apache-spark/) data platform.

## *Introduction*

This module imports an existing Ocean cluster into Ocean Spark.

### Pre-Reqs
* Existing EKS/GKE/AKS Cluster
* EKS/GKE/AKS cluster integrated with Spot Ocean

## *Usage*

```hcl
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

data "aws_eks_cluster_auth" "this" {
  name = "cluster-name"
}

data "aws_eks_cluster" "this" {
  name = "cluster-name"
}

module "ocean-spark" {
  source = "spotinst/ocean-spark/spotinst"
  version = "~> 3.0.0"

  ocean_cluster_id = var.ocean_cluster_id

  cluster_config = {
    cluster_name               = "cluster-name"
    certificate_authority_data = data.aws_eks_cluster.this.certificate_authority[0].data
    server_endpoint            = data.aws_eks_cluster.this.endpoint
    token                      = data.aws_eks_cluster_auth.this.token
  }
}
```

##  *Upgrade guides*
- [Upgrade to v3.x.](/docs/UPGRADE-v3.md)
- [Upgrade to v2.x.](/docs/UPGRADE-v2.md)
- [Upgrade to v1.x](/docs/UPGRADE-v1.md)


## *Examples*

This module can be combined with other Terraform modules to support a number of installation methods for Ocean Spark:

1. [Create an Ocean Spark cluster from scratch in your AWS account](/examples/from-scratch/)
2. [Create an Ocean Spark Cluster from scratch in your AWS account with AWS Private Link support](/examples/from-scratch-with-private-link/)
3. [Create an Ocean Spark cluster from scratch in your GCP account](/examples/gcp-from-scratch/)
4. [Create an Ocean Spark cluster from scratch in your Azure account](/examples/azure-from-scratch/)
5. [Import an existing EKS cluster into Ocean Spark](/examples/import-eks-cluster/)
6. [Import an existing GKE cluster into Ocean Spark](/examples/gcp-import-gke-cluster/)
7. [Import an existing AKS cluster into Ocean Spark](/examples/azure-import-aks-cluster/)
8. [Import an existing Ocean cluster into Ocean Spark](/examples/import-ocean-cluster/)

### :warning: Before running `terraform destroy` :warning:
#### If your cluster was created with `v1` of the module or you set `deployer_namespace = spot-system`, follow these steps:

1- Switch your kubectl context to the targeted cluster

2- Run the script  `scripts/ofas-uninstall.sh` job to safely clean the ocean spark components

3- Once the script is completed with success, you can now run `terraform destroy`


## Terraform module documentation

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |
| <a name="requirement_spotinst"></a> [spotinst](#requirement\_spotinst) | >= 1.115.0, < 2.0.0 |
| <a name="requirement_validation"></a> [validation](#requirement\_validation) | 1.0.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_spotinst"></a> [spotinst](#provider\_spotinst) | >= 1.115.0, < 2.0.0 |
| <a name="provider_validation"></a> [validation](#provider\_validation) | 1.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [null_resource.apply_kubernetes_manifest](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [spotinst_ocean_spark.cluster](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_spark) | resource |
| [spotinst_ocean_spark_virtual_node_group.this](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_spark_virtual_node_group) | resource |
| [validation_warning.log_collection_collect_driver_logs](https://registry.terraform.io/providers/tlkamp/validation/1.0.0/docs/data-sources/warning) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_dedicated_virtual_node_groups"></a> [attach\_dedicated\_virtual\_node\_groups](#input\_attach\_dedicated\_virtual\_node\_groups) | List of virtual node group IDs to attach to the cluster | `list(string)` | `[]` | no |
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Configuration for Ocean Kubernetes cluster | <pre>object({<br>    cluster_name               = string<br>    certificate_authority_data = string<br>    server_endpoint            = string<br>    token                      = optional(string)<br>    client_certificate         = optional(string)<br>    client_key                 = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_compute_create_vngs"></a> [compute\_create\_vngs](#input\_compute\_create\_vngs) | Controls whether dedicated Ocean Spark VNGs will be created by the cluster creation process | `bool` | `true` | no |
| <a name="input_compute_use_taints"></a> [compute\_use\_taints](#input\_compute\_use\_taints) | Controls whether the Ocean Spark cluster will use taints to schedule workloads | `bool` | `true` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | Controls whether the Ocean for Apache Spark cluster should be created (it affects all resources) | `bool` | `true` | no |
| <a name="input_deployer_namespace"></a> [deployer\_namespace](#input\_deployer\_namespace) | The namespace Ocean Spark deployer jobs will run in (must be either 'spot-system' or 'kube-system'). The deployer jobs are used to manage Ocean Spark cluster components. | `string` | `"kube-system"` | no |
| <a name="input_enable_custom_endpoint"></a> [enable\_custom\_endpoint](#input\_enable\_custom\_endpoint) | Controls whether the Ocean for Apache Spark control plane address the cluster using a custom endpoint. | `bool` | `false` | no |
| <a name="input_enable_private_link"></a> [enable\_private\_link](#input\_enable\_private\_link) | Controls whether the Ocean for Apache Spark control plane address the cluster via an AWS Private Link | `bool` | `false` | no |
| <a name="input_ingress_custom_endpoint_address"></a> [ingress\_custom\_endpoint\_address](#input\_ingress\_custom\_endpoint\_address) | The address the Ocean for Apache Spark control plane will use when addressing the cluster when custom endpoint is enabled | `string` | `null` | no |
| <a name="input_ingress_load_balancer_service_annotations"></a> [ingress\_load\_balancer\_service\_annotations](#input\_ingress\_load\_balancer\_service\_annotations) | Annotations that will be added to the load balancer service, allowing for customization of the load balancer | `map(string)` | `{}` | no |
| <a name="input_ingress_load_balancer_target_group_arn"></a> [ingress\_load\_balancer\_target\_group\_arn](#input\_ingress\_load\_balancer\_target\_group\_arn) | The ARN of a target group that the Ocean for Apache Spark ingress controller will be bound to. | `string` | `null` | no |
| <a name="input_ingress_managed_controller"></a> [ingress\_managed\_controller](#input\_ingress\_managed\_controller) | Controls whether an ingress controller managed by Ocean for Apache Spark will be installed on the cluster | `bool` | `true` | no |
| <a name="input_ingress_managed_load_balancer"></a> [ingress\_managed\_load\_balancer](#input\_ingress\_managed\_load\_balancer) | Controls whether a load balancer managed by Ocean for Apache Spark will be provisioned for the cluster | `bool` | `true` | no |
| <a name="input_ingress_private_link_endpoint_service_address"></a> [ingress\_private\_link\_endpoint\_service\_address](#input\_ingress\_private\_link\_endpoint\_service\_address) | The name of the VPC Endpoint Service the Ocean for Apache Spark control plane should bind to when privatelink is enabled | `string` | `null` | no |
| <a name="input_log_collection_collect_app_logs"></a> [log\_collection\_collect\_app\_logs](#input\_log\_collection\_collect\_app\_logs) | Controls whether the Ocean Spark cluster will collect Spark driver/executor logs | `bool` | `true` | no |
| <a name="input_log_collection_collect_driver_logs"></a> [log\_collection\_collect\_driver\_logs](#input\_log\_collection\_collect\_driver\_logs) | Controls whether the Ocean Spark cluster will collect Spark driver logs (Deprecated: use log\_collection\_collect\_app\_logs instead) | `bool` | `null` | no |
| <a name="input_ocean_cluster_id"></a> [ocean\_cluster\_id](#input\_ocean\_cluster\_id) | Specifies the Ocean cluster identifier | `string` | n/a | yes |
| <a name="input_spark_additional_app_namespaces"></a> [spark\_additional\_app\_namespaces](#input\_spark\_additional\_app\_namespaces) | List of Kubernetes namespaces that should be configured to run Spark applications, in addition to the default 'spark-apps' namespace | `list(string)` | `[]` | no |
| <a name="input_webhook_host_network_ports"></a> [webhook\_host\_network\_ports](#input\_webhook\_host\_network\_ports) | Assign a list of ports on the host networks for our system pods | `list(number)` | `[]` | no |
| <a name="input_webhook_use_host_network"></a> [webhook\_use\_host\_network](#input\_webhook\_use\_host\_network) | Controls whether Ocean Spark system pods that expose webhooks will use the host network | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ocean_spark_id"></a> [ocean\_spark\_id](#output\_ocean\_spark\_id) | The Ocean Spark cluster Id |
<!-- END_TF_DOCS -->
