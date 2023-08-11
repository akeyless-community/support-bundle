# Akeyless Support Bundle

## Running the support bundle

### Multi-Tenant

``` bash
kubectl cp support.sh <some-pod>:/akeyless
kubectl exec <some-pod> -- /akeyless/support.sh
kubectl cp <some-pod>:/akeyless/support_bundle.tar.gz ./support_bundle.tar.gz
```

### Single-Tenant

``` bash
kubectl cp support.sh <some-pod>:/akeyless
kubectl exec <some-pod> -- AKEYLESS_DOMAIN=<mycorp.akeyless.io> /akeyless/support.sh
kubectl cp <some-pod>:/akeyless/support_bundle.tar.gz ./support_bundle.tar.gz
```
