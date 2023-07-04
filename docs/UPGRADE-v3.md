## Upgrade to v3.x.x from v2.x.x

To migrate from *v2.xx* to *v3.x.x*, please follow the steps bellow:

1- If you specified the spot-system namespace for the deployer job to run, then you will need to remove it from the terraform state:

`terraform state rm module.ocean-spark.kubernetes_namespace.spot-system`

2- Remove the deployer RBAC service-account and role-binding from the terraform state as well:

- `terraform state rm module.ocean-spark.kubernetes_service_account.deployer`

- `terraform state rm module.ocean-spark.kubernetes_cluster_role_binding.deployer`

3- Add the new required `cluster_config` variable depending on your cloud provider

- for *AWS*:

    ```diff
    module "ocean-spark" {
    source = "spotinst/ocean-spark/spotinst"
    version = "3.0.0"

    ocean_cluster_id = var.ocean_cluster_id

    + cluster_config = {
    +     cluster_name               = var.cluster_name
    +    certificate_authority_data = data.aws_eks_cluster.this.certificate_authority[0].data
    +    server_endpoint            = data.aws_eks_cluster.this.endpoint
    +    token                      = data.aws_eks_cluster_auth.this.token
    + }
    }
    ```

- for *GCP*:

    ```diff
    module "ocean-spark" {
    source = "spotinst/ocean-spark/spotinst"
    version = "3.0.0"

    ocean_cluster_id = var.ocean_cluster_id

    + cluster_config = {
    +    cluster_name               = google_container_cluster.cluster.name
    +    certificate_authority_data = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
    +    server_endpoint            = "https://${google_container_cluster.cluster.endpoint}"
    +    token                      = data.google_client_config.default.access_token
    + }
    }
    ```

- for *Azure*:

    ```diff
    module "ocean-spark" {
    source = "spotinst/ocean-spark/spotinst"
    version = "3.0.0"

    ocean_cluster_id = var.ocean_cluster_id

    + cluster_config = {
    +    cluster_name               = var.cluster_name
    +    certificate_authority_data = module.aks.admin_cluster_ca_certificate
    +    server_endpoint            = module.aks.admin_host
    +    client_certificate         = module.aks.admin_client_certificate
    +    client_key                 = module.aks.admin_client_key
    + }
    }
    ```

4- Run `terraform init`  then `terraform apply` and that's it.