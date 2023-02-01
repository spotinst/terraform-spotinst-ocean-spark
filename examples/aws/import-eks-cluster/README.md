# Import an existing EKS cluster into Ocean Spark

This example shows how to import an EKS cluster into Ocean and Ocean Spark.

## About the EKS cluster

To illustrate this example, folder `eks-cluster/` contains a Terraform script that deploys an EKS cluster into a private VPC.

This EKS cluster can then be used as example input to the main Terraform script, which will import the cluster into Ocean and Ocean Spark.

## Using the Terraform script

All required inputs are described in `variables.tf`.
In particular, the following information must be provided about the existing EKS cluster:
* the `cluster_name`
* the subnet id where the nodes will register `node_subnet_ids` (likely the private subnets if your private VPC has private and public subnets)
* the instance profile to be used by the nodes `node_iam_instance_profile_arn`
* the security group of the nodes `node_security_group_id`
