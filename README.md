# Terraform EKS test deployment

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
terraform apply
aws eks update-kubeconfig --name terraform-eks-demo
terraform output config_map_aws_auth > config_map_aws_auth.yaml
kubectl apply -f config_map_aws_auth.yaml
kubectl get nodes --watch
kubectl get pods -n kube-system
```
### deply postgres on kubernetes
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
### fill database
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
### kill database pod and check new provicioned pod
```
kubectl delete pod ${POD}
POD=`kubectl get pods -l app=postgres | grep Running | grep 1/1 | awk '{print $1}'`
kubectl exec -it $POD bash
su postgres
psql pxdemo
\dt
select count(*) from pgbench_accounts;
\q
exit
exit
```
### kill node and check new provisioned node
```
NODE=`kubectl get pods -o wide | grep postgres | awk '{print $7}'`
kubectl get pods -o wide --all-namespaces
```

### destroy cluster
terraform destroy
