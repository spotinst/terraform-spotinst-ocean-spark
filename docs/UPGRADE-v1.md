###  v1 upgrade guide

*This upgrade revolves around one topic:*

The use of the `spotinst_ocean_spark` resource to manage the cluster state instead of relying on a `kubernetes job` on the first apply.

To upgrade to v1 please follow the steps bellow:

1- Upgrade `spotinst provider` to `>= 1.89`

2- [Retrieve from the UI](https://console.spotinst.com/ocean/spark/clusters) your Ocean Spark `Cluster ID`

3- Import the resource into your `terraform state`:

```
terraform import module.ocean-spark.spotinst_ocean_spark.example osc-abcd1234
```
