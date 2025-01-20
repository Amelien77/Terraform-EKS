# Module VPC
module "network_vpc" {
  source = "./modules/network_vpc"
}

# Module EKS : Créer le cluster Kubernetes pour WordPress
module "eks" {
  source          = "./modules/eks"
  cluster_name    = "wordpress_cluster"
  vpc_id          = module.network_vpc.vpc_id
  public_subnets  = module.network_vpc.public_subnets
  private_subnets = module.network_vpc.private_subnets
}

# Module Load Balancer : Gestion du Load Balancer
module "load_balancer" {
  source          = "./modules/load_balancer"
  public_subnets  = module.network_vpc.public_subnets
  private_subnets = module.network_vpc.private_subnets
  vpc_id          = module.network_vpc.vpc_id

  ami_id          = var.ami_id
  instance_type   = "t2.micro"

  asg_min_size    = 1
  asg_max_size    = 3

  tags = {
    Name = "wordpress-load-balancer"
  }
}

# Module WordPress : Déploiement de WordPress sur Kubernetes
module "wordpress" {
  source          = "./modules/wordpress"
  cluster_name    = module.eks.cluster_name
  vpc_id          = module.network_vpc.vpc_id
  private_subnets = module.network_vpc.private_subnets
  wordpress_asg_id = module.load_balancer.wordpress_asg_id  # Passer l'ID du groupe de mise à l'échelle automatique
}

# Module base de données : Création de la base de données.
module "database" {
  source          = "./modules/database"
  db_username     = var.db_username
  db_password     = var.db_password
  vpc_id          = module.network_vpc.vpc_id
  private_subnets = module.network_vpc.private_subnets
  app_subnet_cidrs = [
    "10.1.2.0/24",
    "10.1.3.0/24"
  ]
}
