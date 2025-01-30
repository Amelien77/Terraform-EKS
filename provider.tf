terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

# Créer un null_resource pour attendre que le cluster soit créé
resource "null_resource" "wait_for_eks_cluster" {
  provisioner "local-exec" {
    command = "echo 'Waiting for the EKS cluster to be available...'"
  }
}

# Donner un délai d'attente ou une autre condition ici pour t'assurer que le cluster est créé avant de récupérer les infos
data "aws_eks_cluster" "this" {
  depends_on = [null_resource.wait_for_eks_cluster]
  name       = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  depends_on = [null_resource.wait_for_eks_cluster]
  name       = data.aws_eks_cluster.this.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
