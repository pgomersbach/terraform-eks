#!/bin/bash
#### check permissions
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

#### install packages
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y unzip apt-transport-https git wget curl python-pip docker.io jq

#### install kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl

#### install aws cli
pip install awscli

#### install terraform
curl -s  https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip -o terraform_0.11.10_linux_amd64.zip && unzip terraform_0.11.10_linux_amd64.zip && mv terraform /usr/local/bin && rm -f terraform_0.11.10_linux_amd64.zip

#### install aws-iam-authenticator
curl -s -L  https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64 -o /usr/local/bin/aws-iam-authenticator && chmod +x /usr/local/bin/aws-iam-authenticator

#### install helm
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get -o get_helm.sh && chmod +x get_helm.sh && ./get_helm.sh

#### install kompose
curl -s -L https://github.com/kubernetes/kompose/releases/download/v1.17.0/kompose-linux-amd64 -o /usr/local/bin/kompose && chmod +x /usr/local/bin/kompose

#### clone repo
su -c "git clone https://github.com/pgomersbach/terraform-eks.git /home/ubuntu/terraform-eks" ubuntu

echo "Please export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION for example in ~/.bash_profile"
