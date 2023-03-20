terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

data "aws_eks_cluster" "jaymie" {
  name = "jaymie"
}
data "aws_eks_cluster_auth" "jaymie" {
  name = "jaymie"
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.jaymie.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.jaymie.certificate_authority[0].data)
  version          = "2.16.1"
  config_path = "~/.kube/config"
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--jaymie-name", "jaymie"]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "kube-namespace" {
  metadata {
    name = "sock-shop"
  }
}