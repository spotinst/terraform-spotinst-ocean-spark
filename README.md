# terraform-spotinst-ocean-spark

A Terraform module to install [Ocean for Apache Spark](https://spot.io/products/ocean-apache-spark/) on an existing [Spot Ocean cluster](https://spot.io/products/ocean)

### :warning: Ocean for Apache Spark is currently only available on AWS

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role_binding.deployer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_job.deployer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_namespace.spot-system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.deployer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | Controls whether the Ocean for Apache Spark cluster should be created (it affects all resources) | `bool` | `true` | no |
| <a name="input_deployer_image"></a> [deployer\_image](#input\_deployer\_image) | Specifies the Docker image name used in the deployer Job | `string` | `"public.ecr.aws/f4k1p1n4/bigdata-deployer"` | no |
| <a name="input_deployer_tag"></a> [deployer\_tag](#input\_deployer\_tag) | Specifies the Docker image tag used in the deployer Job | `string` | `"main"` | no |
| <a name="input_image_pull_policy"></a> [image\_pull\_policy](#input\_image\_pull\_policy) | Specifies the image pull policy (one of: Always, Never, IfNotPresent) | `string` | `"Always"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->