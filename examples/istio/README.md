# Use Ocean Spark with Istio

# Infra setup

1. Deploy an EKS cluster (use the `from-scratch` example but comment out all Ocean / Ocean Spark resources)
2. Deploy [Istio with istioctl](https://istio.io/latest/docs/setup/install/istioctl/)
    ```bash
    curl -L https://istio.io/downloadIstio | sh -
    export PATH="$PATH:/Users/julien/netapp/terraform-spotinst-ocean-spark/examples/istio/istio-1.14.2/bin"
    istioctl x precheck
    iostioctl install
    ```
3. Import into Ocean and Ocean Spark (uncomment Ocean / Ocean Spark resources and re-apply TF)

# Test 1: Add Istio proxy to Spark apps

```
kubectl label namespace spark-apps istio-injection=enabled
```

This works.

# Test 2: Add Istio proxy to all namespaces

```
kubectl create ns spot-system
kubectl create ns spark-apps
kubectl label ns spot-system istio-injection=enabled
kubectl label ns spark-apps istio-injection=enabled
```

To do:
* Configure ingress to use Istio
* Driver pod never stops because istio sidecar never stops

# Install Kiali and Prometheus to visualize the mesh

https://istio.io/latest/docs/ops/integrations/kiali/#installation

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.14/samples/addons/kiali.yaml

https://istio.io/latest/docs/ops/integrations/prometheus/

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.14/samples/addons/prometheus.yaml

# Configure nginx to use Kubernetes service rather than direct pod endpoints access

https://www.giffgaff.io/tech/using-istio-with-nginx-ingress

Add the following annotation to all ingresses:
```
nginx.ingress.kubernetes.io/service-upstream: "true"
```

# Ingress Gateways

General information:
https://istio.io/latest/docs/concepts/traffic-management/#gateways
https://istio.io/latest/docs/examples/microservices-istio/istio-ingress-gateway/
https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/#determining-the-ingress-ip-and-ports

Plugging an Istio ingress gateway to an NGINX controller:
https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-sni-passthrough/
This is exactly what we need.

* Deploy an Istio ingress pointing to NGINX with TLS passthrough mode (`ingress-gateway.yaml`)
* Edit control plane k8s service to point to Istio gateway's load balancer instead of NGINX load balancer

```
curl --cacert /etc/pki/data-plane/ca.crt --key /etc/pki/data-plane/tls.key --cert /etc/pki/data-plane/tls.crt https://org-606079875230-osc-49c8ea64.bigdata.svc.cluster.local/
```
