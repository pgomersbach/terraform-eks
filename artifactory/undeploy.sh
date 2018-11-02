kubectl delete -f postgres-service.yaml
kubectl delete -f postgres-deployment.yaml
kubectl delete -f postgres-storage.yaml
kubectl delete -f postgres-configmap.yaml

kubectl delete -f artifactory-service.yaml
kubectl delete -f artifactory-deployment.yaml
kubectl delete -f artifactory-storage.yaml
kubectl delete -f artifactory-configmap.yaml
