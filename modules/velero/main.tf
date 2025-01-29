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

    velero = {
      source  = "vmware-tanzu/velero"
      version = "2.0.0"  # Vérifie la dernière version compatible avec ton cluster
    }
  }

  required_version = ">= 0.13"
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "aws_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.1"
  bucket  = var.bucket_name
  acl     = "private"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_policy = false
  attach_deny_insecure_transport_policy = false

  versioning = {
    enabled = true
  }
}

module "eks" {
  source = "../eks"  # Assurez-vous que le module EKS est dans ce chemin relatif
}

module "velero" {
  source  = "vmware-tanzu/velero/kubernetes"
  version = "2.0.0"

  namespace_deploy            = true
  app_deploy                  = true
  cluster_name                = var.cluster_name
  openid_connect_provider_uri = module.eks.cluster_oidc_issuer_url
  bucket                      = var.bucket_name
  values = [
    templatefile("${path.module}/modules/velero/template/values.yaml", {
      bucket_name    = var.bucket_name
      velero_provider = var.velero_provider
      region          = var.region
    })
  ]
}

locals {
  openid_connect_provider_uri = replace(var.cluster_oidc_issuer_url, "https://", "")
}

# Utilisation de EKS pour obtenir l'URL du fournisseur OIDC
resource "velero_iam_service_account" "example" {
  cluster_name                = module.eks.cluster_name
  region                      = var.region
  openid_connect_provider_uri = module.eks.cluster_oidc_issuer_url
}

# Output pour s'assurer que l'URL OIDC est récupérée correctement
output "cluster_oidc_issuer_url" {
  value = "https://eks.${var.region}.amazonaws.com/cluster/${module.eks.cluster_name}"
}
