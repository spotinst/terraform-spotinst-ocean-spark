## Upgrade to v2.x.x from v1.x.x

By default the Ocean Spark deployer jobs now run in the kube-system namespace.

To avoid issues for existing clusters you will need to set the following line:

```diff
module "ocean-spark" {
  "spotinst/ocean-spark/spotinst"

  ocean_cluster_id   = var.ocean_cluster_id
+ deployer_namespace = "spot-system"
}
```


#### Deprecated :

- `ofas_managed_load_balancer` variable has been deleted. Use `ingress_managed_load_balancer` instead