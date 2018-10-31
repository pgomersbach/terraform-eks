# Terraform EKS test deployment

Get started
boot a new development station
login as ubuntu user
become root
download and run https://raw.githubusercontent.com/pgomersbach/terraform-eks/master/scripts/bootstrap_dev.sh
exit root
export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION for example in ~/.bash_profile
cd ~/terraform-eks
terraform init
terraform plan
terraform apply
