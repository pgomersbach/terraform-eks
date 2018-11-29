#
# Variables Configuration
#

variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = "string"
}

variable "install_jenkins" {
  default = true
  type    = "string"
}

