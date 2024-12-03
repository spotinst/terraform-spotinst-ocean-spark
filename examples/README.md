## Examples

#### 1. Create an Ocean Spark cluster in AWS from scratch

1. Use the [AWS `vpc` Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) to create a VPC network.
2. use the [AWS `eks` Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) to create an EKS cluster.
3. Use the [SPOTINST `ocean-aws-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aws-k8s/spotinst/latest) to import the EKS cluster into Ocean
4. Use the [SPOTINST `kubernetes-controller` Terraform module](https://registry.terraform.io/modules/spotinst/kubernetes-controller/ocean/latest) to install the ocean controller deployment into kubernetes
5. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

The folder [`from-scratch/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/from-scratch) contains a full example.


#### 2. Create an Ocean Spark Cluster from scratch with AWS Private Link support.

1. Use the [AWS `vpc` Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) to create a VPC network.
2. Use the [AWS `eks` Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) to create an EKS cluster.
3. Use the [SPOTINST `ocean-aws-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aws-k8s/spotinst/latest) to import the EKS cluster into Ocean
4. Use the [SPOTINST `kubernetes-controller` Terraform module](https://registry.terraform.io/modules/spotinst/kubernetes-controller/ocean/latest) to install the ocean controller deployment into kubernetes
5. Create the Private link required resources (NLB, VPC endpoint service and LB TargetGroup). [AWS Docs About PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/getting-started.html).
6. Use the [ Terraform AWS EKS LB Controller Module](https://github.com/DNXLabs/terraform-aws-eks-lb-controller) to install the aws load balancer controller in the EKS cluster.
7. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark and set the [ ingress private link input ](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_spark#nestedblock--ingress--private_link)

The folder [`from-scratch-with-private-link/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/from-scratch-with-private-link) contains a full example.


#### 3. Create an Ocean Spark cluster in GCP from scratch

1. use the [GCP `google_container_cluster` Terraform resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) to create an GKE cluster.
2. Use the [SPOTINST `spotinst_ocean_gke_import` Terraform resource](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_gke_import) to import the GKE cluster into Ocean
3. Use the [SPOTINST `kubernetes-controller` Terraform module](https://registry.terraform.io/modules/spotinst/kubernetes-controller/ocean/latest) to install the ocean controller deployment into kubernetes
4. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

The folder [`gcp-from-scratch/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/blob/main/examples/gcp-from-scratch/main.tf) contains a full example.


#### 4. Create an Ocean Spark cluster in AKS from scratch

1. Use the [Azure `azurerm_virtual_network` Terraform resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) and [Azure `azurerm_subnet` Terraform resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) to create a VPC network
2. Use the [Azure `aks` Terraform Module](https://registry.terraform.io/modules/Azure/aks/azurerm/latest) to create an Azure cluster.
3. Use the [SPOTINST `ocean-aks-np-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aks-np-k8s/spotinst/latest) to import the AKS cluster into Ocean
4. Use the [SPOTINST `ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) to install the controller deployment into kubernetes
5. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

The folder [`azure-from-scratch/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/blob/main/examples/azure-from-scratch/main.tf) contains a full example.


#### 5. Import an existing EKS cluster

1. Use the [SPOTINST `ocean-aws-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aws-k8s/spotinst/latest) to import the EKS cluster into Ocean
2. Use the [SPOTINST `kubernetes-controller` Terraform module](https://registry.terraform.io/modules/spotinst/kubernetes-controller/ocean/latest) to install the ocean controller deployment into kubernetes
3. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

The folder [`import-eks-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/import-eks-cluster) contains a full example.


#### 6. Import an existing GKE cluster

1. Use the [SPOTINST `spotinst_ocean_gke_import` Terraform resource](https://registry.terraform.io/providers/spotinst/spotinst/latest/docs/resources/ocean_gke_import) to import the GKE cluster into Ocean
2. Use the [SPOTINST `kubernetes-controller` Terraform module](https://registry.terraform.io/modules/spotinst/kubernetes-controller/ocean/latest) to install the ocean controller deployment into kubernetes
3. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

The folder [`examples/gcp-import-gke-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/blob/main/examples/gcp-import-gke-cluster/) contains a full example.


#### 7. Import an existing AKS cluster

1. Use the [SPOTINST `ocean-aks-np-k8s` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-aks-np-k8s/spotinst/latest) to import the AKS cluster into Ocean
2. Use the [SPOTINST `ocean-controller` Terraform module](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest) to install the controller deployment into kubernetes
3. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

The folder [`azure-import-aks-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/blob/main/examples/azure-import-aks-cluster/) contains a full example.


#### 8. Import an existing Ocean cluster

1. Use the [SPOTINST `ocean-spark` Terraform module](this module) to import the cluster into Ocean Spark.

The folder [`import-ocean-cluster/`](https://github.com/spotinst/terraform-spotinst-ocean-spark/tree/main/examples/import-ocean-cluster) contains a full example.