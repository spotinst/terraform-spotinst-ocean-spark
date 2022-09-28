# terraform-spotinst-ocean-spark

A Terraform module to install the [Ocean for Apache Spark](https://spot.io/products/ocean-apache-spark/) data platform.

### :warning: Ocean for Apache Spark is currently only available on AWS.

## Overview

This module imports an existing Ocean cluster into Ocean Spark.
It can be combined with other Ocean Terraform modules to support a number of installation methods for Ocean Spark:
1. Create an Ocean Spark cluster from scratch in your cloud account
2. Create an Ocean Spark cluster within an existing VPC
3. Import an existing EKS cluster into Ocean Spark
4. Import an existing Ocean cluster into Ocean Spark

The diagram below details those different installation methods.
Read on for more details.

![Terraform module usage](https://raw.githubusercontent.com/spotinst/terraform-spotinst-ocean-spark/main/docs/module_usage.svg)

### 1. Create an Ocean Spark cluster from scratch

In this case, use the [`ocean-eks` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-eks/spotinst/latest) to create an Ocean cluster from scratch.
Then, use the `ocean-spark` Terraform module (this module) to import the cluster into Ocean Spark.

Folder [`examples/from-scratch/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/from-scratch) contains a full example.

### 2. Create an Ocean Spark cluster within an existing VPC

In this case, use the [AWS `eks` Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) to create an EKS cluster.
Then, use the [`ocean-aws-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aws-k8s/spotinst/latest) to import the EKS cluster into Ocean, and the `ocean-spark` Terraform module (this module) to import the resulting Ocean cluster into Ocean Spark.

Folder [`examples/from-private-vpc/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/from-private-vpc) contains a full example.

### 3. Import an existing EKS cluster

In this case, use the [`ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) and the [`spotinst_ocean_aws` Terraform resource](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_aws) to import the EKS cluster into Ocean.
Then, use the `ocean-spark` Terraform module (this module) to import the resulting Ocean cluster into Ocean Spark.

Folder [`examples/import-eks-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/import-eks-cluster) contains a full example.

### 4. Import an existing Ocean cluster

In this case, use the `ocean-spark` Terraform module (this module) to import the existing Ocean cluster into Ocean Spark.

Folder [`examples/import-ocean-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/import-ocean-cluster) contains a full example.

## Terraform module documentation

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |
| <a name="requirement_spotinst"></a> [spotinst](#requirement\_spotinst) | ~> 1.84 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |
| <a name="provider_spotinst"></a> [spotinst](#provider\_spotinst) | ~> 1.84 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role_binding.deployer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_namespace.spot-system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.deployer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [spotinst_ocean_spark.cluster](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_spark) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_create_vngs"></a> [compute\_create\_vngs](#input\_compute\_create\_vngs) | Controls whether dedicated Ocean Spark VNGs will be created by the cluster creation process | `bool` | `true` | no |
| <a name="input_compute_use_taints"></a> [compute\_use\_taints](#input\_compute\_use\_taints) | Controls whether the Ocean Spark cluster will use taints to schedule workloads | `bool` | `true` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | Controls whether the Ocean for Apache Spark cluster should be created (it affects all resources) | `bool` | `true` | no |
| <a name="input_ingress_service_annotations"></a> [ingress\_service\_annotations](#input\_ingress\_service\_annotations) | Annotations that will be added to the load balancer service, allowing for customization of the load balancer | `map(string)` | `{}` | no |
| <a name="input_log_collection_collect_driver_logs"></a> [log\_collection\_collect\_driver\_logs](#input\_log\_collection\_collect\_driver\_logs) | Controls whether the Ocean Spark cluster will collect Spark driver logs | `bool` | `true` | no |
| <a name="input_ocean_cluster_id"></a> [ocean\_cluster\_id](#input\_ocean\_cluster\_id) | Specifies the Ocean cluster identifier | `string` | n/a | yes |
| <a name="input_webhook_host_network_ports"></a> [webhook\_host\_network\_ports](#input\_webhook\_host\_network\_ports) | Assign a list of ports on the host networks for our system pods | `list(number)` | `[]` | no |
| <a name="input_webhook_use_host_network"></a> [webhook\_use\_host\_network](#input\_webhook\_use\_host\_network) | Controls whether Ocean Spark system pods that expose webhooks will use the host network | `bool` | `false` | no |

### Outputs

No outputs.
<!-- END_TF_DOCS -->
