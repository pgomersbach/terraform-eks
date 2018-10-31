#!/bin/bash
#### install packages
apt-get update
apt-get install -y unzip apt-transport-https git wget curl python-pip

#### install kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl

#### install aws cli
pip install awscli

#### install terraform
curl -s  https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip -o terraform_0.11.10_linux_amd64.zip && unzip terraform_0.11.10_linux_amd64.zip && mv terraform /usr/local/bin && rm -y terraform_0.11.10_linux_amd64.zip

#### install aws-iam-authenticator
curl -s  https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64 -o /usr/local/bin/aws-iam-authenticator && chmod +x /usr/local/bin/aws-iam-authenticator

#### create example profile for default user
cat << 'EOF' > /home/ubuntu/.bash_profile
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION="us-east-1"
[ -z "$AWS_ACCESS_KEY_ID" ] && echo "Please export AWS credentials, for example in ~/.bash_profile"
EOF
chown ubuntu:ubuntu /home/ubuntu/.bash_profile

#### clone repo
su -c "git clone https://github.com/pgomersbach/terraform-eks.git" ubuntu
