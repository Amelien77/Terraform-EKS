# Module Network_vpc: VPC, subnet, tables and association
module "network_vpc" {
  source = "./modules/network_vpc"
}

# Module EKS : EKS Cluster via module AWS officiel
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.31"

  bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  cluster_endpoint_public_access = false

  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.network_vpc.vpc_id
  subnet_ids               = module.network_vpc.private_subnets
  control_plane_subnet_ids = module.network_vpc.private_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    example = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]
      min_size       = 2
      max_size       = 10
      desired_size   = 2
    }
  }

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}

# Module ALB : Gestion du Load Balancer
module "alb" {
  source           = "./modules/alb"
  vpc_id           = module.network_vpc.vpc_id
  public_subnets   = module.network_vpc.public_subnets
  eks_cluster_name = module.eks.cluster_name
  eks_nodes_sg_id  = module.eks.node_security_group_id
}

# Module RDS : Création de la base de données.
module "rds" {
  source          = "./modules/rds"
  db_username     = var.db_username
  db_password     = var.db_password
  vpc_id          = module.network_vpc.vpc_id
  private_subnets = module.network_vpc.private_subnets

  cidr_app_subnet_a = "10.1.2.0/24"
  cidr_app_subnet_b = "10.1.3.0/24"
}

# Module VELERO
module "velero" {
  source  = "terraform-module/velero/kubernetes"
  version = "1.2.1" # Choisis la version appropriée

  namespace_deploy            = true
  app_deploy                  = true
  cluster_name                = var.cluster_name
  openid_connect_provider_uri = module.eks.cluster_oidc_issuer_url
  bucket                      = var.bucket_name
  values = [
    templatefile("${path.module}/modules/velero/template/values.yaml", {
      bucket_name     = var.bucket_name
      velero_provider = var.velero_provider
      region          = var.region
    })
  ]
}
