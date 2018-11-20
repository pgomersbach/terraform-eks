# Terraform EKS test deployment
This procedure installs an AWS EKS cluster and helm (tiller).  

**Warning: the cost is about $ 0.40 per hour.**
## Get started
### Prerequisites
- AWS account  
- AWS AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY  
### Install development workstation
```
- boot a new Ubuntu 18.04 development station  
- login as ubuntu user  
- become root  
- download and run https://raw.githubusercontent.com/pgomersbach/terraform-eks/master/scripts/bootstrap_dev.sh  
- exit root  
- export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION for example in ~/.bash_profile  
```
### Install EKS cluster using Terraform
```
cd ~/terraform-eks
terraform init
terraform plan
terraform apply  # and wait about ten minutes
```
### Check ECS cluster
```
kubectl get nodes --watch
kubectl get pods -n kube-system
```
### Install jenkins
```
sudo usermod -aG docker $USER
exec sg docker newgrp `id -gn`
docker login --username=yourhubusername
docker build -t pgomersbach/my-jenkins-image:1.1 jenkins/
docker push pgomersbach/my-jenkins-image
kubectl create -f jenkins/jenkins-deployment.yaml
kubectl create -f jenkins/jenkins-service.yaml
kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default
kubectl get service jenkins
```
### Destroy jenkins
```
kubectl delete -f jenkins/jenkins-deployment.yaml
kubectl delete -f jenkins/jenkins-service.yaml
```
### Install artifactory
```
kubectl create -f artifactory/postgres-configmap.yaml
kubectl create -f artifactory/postgres-storage.yaml
kubectl create -f artifactory/postgres-deployment.yaml
kubectl create -f artifactory/postgres-service.yaml
kubectl create -f artifactory/artifactory-configmap.yaml
kubectl create -f artifactory/artifactory-storage.yaml
kubectl create -f artifactory/artifactory-deployment.yaml
kubectl create -f artifactory/artifactory-service.yaml
```
### Deploy postgres on kubernetes
```
kubectl create -f postgres/postgres-configmap.yaml
kubectl create -f postgres/postgres-storage.yaml
kubectl create -f postgres/postgres-deployment.yaml
kubectl create -f postgres/postgres-service.yaml
kubectl get configmap
kubectl get persistentvolumeclaims
kubectl get persistentvolumes
kubectl get deployments
kubectl get pods
kubectl get services
```
### Fill database
```
POD=`kubectl get pods -l app=postgres | grep Running | grep 1/1 | awk '{print $1}'`
kubectl exec -it $POD bash
su postgres
psql
create database pxdemo;
\l
\q
pgbench -i -s 50 pxdemo;
psql pxdemo
\dt
select count(*) from pgbench_accounts;
\q
exit
exit
```
### Kill database pod and check new provisioned pod
```
POD=`kubectl get pods -l app=postgres | grep Running | grep 1/1 | awk '{print $1}'`
kubectl delete pod ${POD}
kubectl exec -it $POD bash
su postgres
psql pxdemo
\dt
select count(*) from pgbench_accounts;
\q
exit
exit
```
### install jenkins and pipeline using helm
```
kubectl create -f helm/jenkins-namespace.yaml
kubectl create -f helm/jenkins-volume.yaml
helm install stable/jenkins -f helm/jenkins-values.yaml -f helm/jenkins-jobs.yaml --wait --name jenkins-master --timeout 600
JENKINS_USER=$(kubectl get secret --namespace default jenkins-master -o jsonpath="{.data.jenkins-admin-user}" | base64 --decode)
JENKINS_PASS=$(kubectl get secret --namespace default jenkins-master -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)
JENKINS_IP=$(kubectl get svc --namespace default jenkins-master --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
JENKINS_PORT=$(kubectl get svc --namespace default jenkins-master --output jsonpath={.spec.ports[*].port})
```
### Destroy cluster
```
terraform destroy # and wait about ten minutes
```
