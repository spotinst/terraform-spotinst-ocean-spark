# Create an Ocean Spark cluster in an existing VPC

This example shows how to create an EKS cluster into an existing VPC and import into Ocean and Ocean Spark.

## Details about the VPC

In this example, the VPC is a "private VPC". It contains:
* private subnets using a NAT gateway for egress. That's where the nodes and pods will go.
* public subnets. That's where the load balancers and other exposed public IPs will go.

Additionally, the VPC must have the following tags to be suitable for an EKS cluster:
* `kubernetes.io/cluster/<eks-cluster-name> = shared` on the VPC itself, where `<eks-cluster-name>` is the name of the EKS cluster that will use this VPC. This tag should not be useful since Kubernetes 1.19. We recommend to add it anyway.
* `kubernetes.io/cluster/<eks-cluster-name> = shared` on all subnets.
* `kubernetes.io/role/elb = 1` on all public subnets.
* `kubernetes.io/role/internal-elb = 1` on all private subnets.

Folder `vpc/` shows an example Terraform script to create such a VPC.

## Using the Terraform script

All required inputs are described in `variables.tf`.
In particular, the following information must be provided to use the existing VPC:
* the `vpc_id`
* list of `public_subnet_ids`
* list of `private_subnet_ids`
