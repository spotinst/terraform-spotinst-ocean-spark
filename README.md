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
| <a name="input_create_ofas_cluster"></a> [create\_ofas\_cluster](#input\_create\_ofas\_cluster) | Specifies whether to create an Ocean for Apache Spark cluster | `bool` | `true` | no |
| <a name="input_create_spot_system_namespace"></a> [create\_spot\_system\_namespace](#input\_create\_spot\_system\_namespace) | Specifies whether to create a namespace for the Spot components | `bool` | `true` | no |
| <a name="input_image_pull_policy"></a> [image\_pull\_policy](#input\_image\_pull\_policy) | Specifies the image pull policy (one of: Always, Never, IfNotPresent) | `string` | `"Always"` | no |
| <a name="input_ofas_deployer_image"></a> [ofas\_deployer\_image](#input\_ofas\_deployer\_image) | Specifies the Docker image name used in the deployer Job | `string` | `"public.ecr.aws/f4k1p1n4/bigdata-deployer"` | no |
| <a name="input_ofas_deployer_tag"></a> [ofas\_deployer\_tag](#input\_ofas\_deployer\_tag) | Specifies the Docker image tag used in the deployer Job | `string` | `"main"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->