# Create an Ocean Spark cluster from scratch

This example shows how to create a VPC and an EKS cluster inside of it. 
The EKS cluster is then imported into Ocean and Ocean Spark.

## Details about the VPC

In this example, the VPC is a "private VPC". It contains:
* private subnets using a NAT gateway for egress. That's where the nodes and pods will go.
* public subnets. That's where the load balancers and other exposed public IPs will go.

Additionally, the VPC has the following tags to be suitable for an EKS cluster:
* `kubernetes.io/cluster/<eks-cluster-name> = shared` on the VPC itself, where `<eks-cluster-name>` is the name of the EKS cluster that will use this VPC. This tag should not be necessary since Kubernetes 1.19. We recommend to add it anyway.
* `kubernetes.io/cluster/<eks-cluster-name> = shared` on all subnets.
* `kubernetes.io/role/elb = 1` on all public subnets.
* `kubernetes.io/role/internal-elb = 1` on all private subnets.

## Using the Terraform script

All required inputs are described in `variables.tf`.
