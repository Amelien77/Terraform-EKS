terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.wordpress_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.wordpress_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster" "wordpress_cluster" {
  count = module.eks ? 1 : 0  # Utilisation de count pour conditionner la ressource
#  depends_on = [module.eks]
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
#  depends_on = [data.aws_eks_cluster.wordpress_cluster]
  name = data.aws_eks_cluster.wordpress_cluster.name
}

