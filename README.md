# terraform-spotinst-ocean-spark

A Terraform module to install the [Ocean for Apache Spark](https://spot.io/products/ocean-apache-spark/) data platform.

## Introduction

This module imports an existing Ocean cluster into Ocean Spark.

### Pre-Reqs
* Existing EKS/GKE/AKS Cluster
* EKS/GKE/AKS cluster integrated with Spot Ocean

### Usage
```hcl
provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

module "ocean-spark" {
  "spotinst/ocean-spark/spotinst"

  ocean_cluster_id = var.ocean_cluster_id
}
```

### Examples
It can be combined with other Terraform modules to support a number of installation methods for Ocean Spark:
1. Create an Ocean Spark cluster from scratch in your AWS account
2. Create an Ocean Spark Cluster from scratch in your AWS account with AWS Private Link support.
3. Create an Ocean Spark cluster from scratch in your GCP account
4. Create an Ocean Spark cluster from scratch in your Azure account
5. Import an existing EKS cluster into Ocean Spark
6. Import an existing GKE cluster into Ocean Spark
7. Import an existing AKS cluster into Ocean Spark
8. Import an existing Ocean cluster into Ocean Spark



#### 1. Create an Ocean Spark cluster in AWS from scratch

1. Use the [AWS `vpc` Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) to create a VPC network.
2. use the [AWS `eks` Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) to create an EKS cluster.
3. Use the [SPOTINST `ocean-aws-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aws-k8s/spotinst/latest) to import the EKS cluster into Ocean
4. Use the [SPOTINST `ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) to install the controller deployment into kubernetes
5. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

Folder [`examples/from-scratch/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/from-scratch) contains a full example.

#### 2. Create an Ocean Spark Cluster from scratch with AWS Private Link support.

1. Use the [AWS `vpc` Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) to create a VPC network.
2. Use the [AWS `eks` Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) to create an EKS cluster.
3. Use the [SPOTINST `ocean-aws-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aws-k8s/spotinst/latest) to import the EKS cluster into Ocean
4. Use the [SPOTINST `ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) to install the controller deployment into kubernetes
5. Create the Private link required resources (NLB, VPC endpoint service and LB TargetGroup). [AWS Docs About PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/getting-started.html).
6. Use the [ Terraform AWS EKS LB Controller Module](https://github.com/DNXLabs/terraform-aws-eks-lb-controller) to install the aws load balancer controller in the EKS cluster.
7. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark and set the [ ingress private link input ](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_spark#nestedblock--ingress--private_link)

Folder [`examples/from-scratch-with-private-link/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/from-scratch-with-private-link) contains a full example.

#### 3. Create an Ocean Spark cluster in GCP from scratch

1. use the [GCP `google_container_cluster` Terraform resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) to create an GKE cluster.
2. Use the [SPOTINST `spotinst_ocean_gke_import` Terraform resource](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_gke_import) to import the GKE cluster into Ocean
3. Use the [SPOTINST `ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) to install the controller deployment into kubernetes
4. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

Folder [`examples/gcp-from-scratch/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/blob/main/examples/gcp-from-scratch/main.tf) contains a full example.

#### 4. Create an Ocean Spark cluster in AKS from scratch


1. Use the [Azure `azurerm_virtual_network` Terraform resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) and [Azure `azurerm_subnet` Terraform resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) to create a VPC network
2. Use the [Azure `aks` Terraform Module](https://registry.terraform.io/modules/Azure/aks/azurerm/latest) to create an Azure cluster.
3. Use the [SPOTINST `ocean-aks-np-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aks-np-k8s/spotinst/latest) to import the AKS cluster into Ocean
4. Use the [SPOTINST `ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) to install the controller deployment into kubernetes
5. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

Folder [`examples/azure-from-scratch/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/blob/main/examples/azure-from-scratch/main.tf) contains a full example.

#### 5. Import an existing EKS cluster

1. Use the [SPOTINST `ocean-aws-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aws-k8s/spotinst/latest) to import the EKS cluster into Ocean
2. Use the [SPOTINST `ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) to install the controller deployment into kubernetes
3. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

Folder [`examples/import-eks-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/import-eks-cluster) contains a full example.

#### 6. Import an existing GKE cluster

1. Use the [SPOTINST `spotinst_ocean_gke_import` Terraform resource](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_gke_import) to import the GKE cluster into Ocean
2. Use the [SPOTINST `ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) to install the controller deployment into kubernetes
3. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

Folder [`examples/gcp-import-gke-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/blob/main/examples/gcp-import-gke-cluster/) contains a full example.

#### 7. Import an existing AKS cluster

1. Use the [SPOTINST `ocean-aks-np-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aks-np-k8s/spotinst/latest) to import the AKS cluster into Ocean
2. Use the [SPOTINST `ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) to install the controller deployment into kubernetes
3. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

Folder [`examples/azure-import-aks-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/blob/main/examples/azure-import-aks-cluster/) contains a full example.


#### 8. Import an existing Ocean cluster

1. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

Folder [`examples/import-ocean-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/import-ocean-cluster) contains a full example.



### :warning: Before running `terraform destroy` :warning:
#### If your cluster was created with `v1` of the module or you set `deployer_namespace = spot-system`, follow those steps:

1- Switch your kubectl context to the targeted cluster

2- Run the script  `scripts/ofas-uninstall.sh` job to safely clean the ocean spark components

3- Once the script is completed with success, you can now run `terraform destroy`

## Migration Guide

### v2 migration guide

#### By default the Ocean Spark deployer jobs now run in the kube-system namespace.

To avoid issues for existing clusters you will need to set the following line:
```diff
module "ocean-spark" {
  "spotinst/ocean-spark/spotinst"

  ocean_cluster_id   = var.ocean_cluster_id
+ deployer_namespace = "spot-system"
}
```

#### Deprecated `ofas_managed_load_balancer` variable has been deleted

Use `ingress_managed_load_balancer` instead

###  v1 migration guide

This migration revolves around 1 topic:

- The use of the `spotinst_ocean_spark` resource to manage the cluster state instead of relying on a `kubernetes job` on the 1st apply

#### Steps

1- Upgrade `spotinst provider` to `>= 1.89`

2- [Retrieve from the UI](https://console.spotinst.com/ocean/spark/clusters) your Ocean Spark `Cluster ID`

3- Import the resource into your `terraform state`
```
terraform import module.ocean-spark.spotinst_ocean_spark.example osc-abcd1234
```


## Terraform module documentation

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |
| <a name="requirement_spotinst"></a> [spotinst](#requirement\_spotinst) | >= 1.115.0, < 1.123.0 |
| <a name="requirement_validation"></a> [validation](#requirement\_validation) | 1.0.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |
| <a name="provider_spotinst"></a> [spotinst](#provider\_spotinst) | >= 1.115.0, < 1.123.0 |
| <a name="provider_validation"></a> [validation](#provider\_validation) | 1.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role_binding.deployer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_namespace.spot-system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.deployer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [spotinst_ocean_spark.cluster](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_spark) | resource |
| [spotinst_ocean_spark_virtual_node_group.this](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_spark_virtual_node_group) | resource |
| [validation_warning.log_collection_collect_driver_logs](https://registry.terraform.io/providers/tlkamp/validation/1.0.0/docs/data-sources/warning) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_dedicated_virtual_node_groups"></a> [attach\_dedicated\_virtual\_node\_groups](#input\_attach\_dedicated\_virtual\_node\_groups) | List of virtual node group IDs to attach to the cluster | `list(string)` | `[]` | no |
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
