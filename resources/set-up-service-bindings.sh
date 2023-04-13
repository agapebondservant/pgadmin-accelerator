source .env
kubectl apply -f resources/pgadmin-externalsecrets.yaml -n $PGADMIN_NAMESPACE
export PGADMIN_GREENPLUM_PASSWORD=$(kubectl get secret greenplum-training-secret -n ${PGADMIN_NAMESPACE} -o jsonpath="{.data.greenplum_master_password}" | base64 --decode)
export PGADMIN_POSTGRES_PASSWORD=$(kubectl get secret postgres-inference-secret -n ${PGADMIN_NAMESPACE} -o jsonpath="{.data.postgres_password}" | base64 --decode)
envsubst < resources/pgadmin-serviceclaimsecrets-template.yaml > resources/pgadmin-serviceclaimsecrets.yaml
kubectl apply -f resources/pgadmin-serviceclaimsecrets.yaml -n $PGADMIN_NAMESPACE
kubectl apply -f resources/pgadmin-serviceclaim.yaml -n $PGADMIN_NAMESPACE
kubectl get resourceclaim greenplum-db-claim -n $PGADMIN_NAMESPACE
kubectl get resourceclaim postgres-db-claim -n $PGADMIN_NAMESPACE
kubectl get secrets -n $PGADMIN_NAMESPACE
