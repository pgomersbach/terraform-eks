resource "null_resource" "provision_jenkins" {
  depends_on = [ "null_resource.authorize_helm" ]
  count = "${var.install_jenkins ? 1 : 0}"
  provisioner "local-exec" {
    command = <<EOT
      kubectl create -f helm/jenkins-namespace.yaml
      kubectl create -f helm/jenkins-volume.yaml
      scripts/tiller_wait.sh
      helm install stable/jenkins -f helm/jenkins-values.yaml -f helm/jenkins-jobs.yaml --name jenkins-master --namespace jenkins-project
    EOT
  }
}

