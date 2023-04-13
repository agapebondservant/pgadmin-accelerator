# PgAdmin4 Accelerator

This is an accelerator that can be used to deploy  [pgAdmin4](https://www.pgadmin.org).

* Install App Accelerator: (see https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-cert-mgr-contour-fcd-install-cert-mgr.html)
```
tanzu package available list accelerator.apps.tanzu.vmware.com --namespace tap-install
tanzu package install accelerator -p accelerator.apps.tanzu.vmware.com -v 1.0.1 -n tap-install -f resources/app-accelerator-values.yaml
Verify that package is running: tanzu package installed get accelerator -n tap-install
Get the IP address for the App Accelerator API: kubectl get service -n accelerator-system
```

Publish Accelerators:
```
tanzu plugin install --local <path-to-tanzu-cli> all
tanzu acc create pgadmin --git-repository https://github.com/agapebondservant/pgadmin-accelerator.git --git-branch main
```

### How to Deploy
* Create an .env file - use .env sample as a template.

* Set up TAP RBAC for the target namespace:
```
source .env
envsubst < tap-rbac.in.yaml > tap-rbac.yaml
kubectl create ns ${PGADMIN_NAMESPACE} || true
tanzu secret registry delete registry-credentials -n ${PGADMIN_NAMESPACE} -y || true
tanzu secret registry add registry-credentials \
    --username ${DATA_E2E_REGISTRY_USERNAME} --password ${DATA_E2E_REGISTRY_PASSWORD} \
    --server ${DATA_E2E_GIT_SECRETGEN_SERVER} \
    --export-to-all-namespaces --yes --namespace ${PGADMIN_NAMESPACE} || true
kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=${PGADMIN_NAMESPACE}:default -n ${PGADMIN_NAMESPACE}
kubectl apply -f resources/tap-rbac.yaml -n ${PGADMIN_NAMESPACE}
kubectl apply -f resources/tap-rbac-1.3.yaml -n ${PGADMIN_NAMESPACE}
```

* Set up ServiceBindings:
```
resources/set-up-service-bindings.sh
```
* Deploy pgadmin as a Workload:
```
envsubst < resources/pgadmin-workload.in.yaml > resources/pgadmin-workload.yaml
tanzu apps workload create pgadmin-tap -f resources/pgadmin-workload.yaml --yes -n ${PGADMIN_NAMESPACE}
```

* Tail the logs of the main app:
```
tanzu apps workload tail pgadmin-tap -n ${PGADMIN_NAMESPACE} --since 64h
```

* Once deployment succeeds, get the URL for the main app and launch the app in your browser:
```
tanzu apps workload get pgadmin-tap -n ${PGADMIN_NAMESPACE}  #should yield pgadmin-tap.default.<your-domain>
```

* Access ServiceBindings:
```
export PGADMIN_POD=$(kubectl get pod -l "app.kubernetes.io/part-of=pgadmin-tap,app.kubernetes.io/component=run" -oname -n ${PGADMIN_NAMESPACE})
kubectl exec -it $PGADMIN_POD -n ${PGADMIN_NAMESPACE} -- sh
```

* To delete the app:
```
tanzu apps workload delete pgadmin-tap -n ${PGADMIN_NAMESPACE}  --yes
```

* To delete the workspace:
```
kubectl delete all --all -n ${PGADMIN_NAMESPACE}
kubectl delete ns ${PGADMIN_NAMESPACE}
```

