#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "demo-cluster" {
  name = "terraform-eks-demo-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.demo-cluster.name
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.demo-cluster.name
}

resource "aws_security_group" "demo-cluster" {
  name = "terraform-eks-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id = aws_vpc.demo.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_security_group_rule" "demo-cluster-ingress-node-https" {
  description = "Allow pods to communicate with the cluster API Server"
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.demo-cluster.id
  source_security_group_id = aws_security_group.demo-node.id
  to_port = 443
  type = "ingress"
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks = [local.workstation-external-cidr]
  description = "Allow workstation to communicate with the cluster API Server"
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.demo-cluster.id
  to_port = 443
  type = "ingress"
}

resource "aws_eks_cluster" "demo" {
  name = var.cluster-name
  role_arn = aws_iam_role.demo-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.demo-cluster.id]
    subnet_ids = aws_subnet.demo.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSServicePolicy,
  ]
}

resource "null_resource" "authorize" {
  depends_on = [aws_eks_cluster.demo]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster-name}"
  }
}

data "template_file" "config_map_aws_auth" {
  template = file("${path.module}/templates/config-map-aws-auth.yaml.tpl")
  vars = {
    rolearn = aws_iam_role.demo-node.arn
  }
}

resource "local_file" "config_map_aws_auth" {
  depends_on = [null_resource.authorize]
  content = data.template_file.config_map_aws_auth.rendered
  filename = "config-map-aws-auth_${var.cluster-name}.yaml"
}

resource "null_resource" "authorize_nodes" {
  depends_on = [local_file.config_map_aws_auth]
  provisioner "local-exec" {
    command = "sleep 10 && kubectl apply -f config-map-aws-auth_${var.cluster-name}.yaml"
  }
}

resource "null_resource" "init_helm" {
  depends_on = [null_resource.authorize_nodes]
  provisioner "local-exec" {
    command = "helm init --wait && helm repo add jfrog https://charts.jfrog.io && helm repo update"
  }
}

resource "null_resource" "authorize_helm" {
  depends_on = [null_resource.init_helm]
  provisioner "local-exec" {
    command = <<EOT
      kubectl create serviceaccount --namespace kube-system tiller
      kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
      kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
    
EOT

}
}

