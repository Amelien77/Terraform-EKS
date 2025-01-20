# ------------------- Création du Cluster EKS ------------------- #

resource "aws_eks_cluster" "wordpress_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids = var.public_subnets
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

# ------------------- Création du Groupe de Nœuds pour EKS ------------------- #

resource "aws_eks_node_group" "wordpress_node_group" {
  cluster_name    = aws_eks_cluster.wordpress_eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnets  # Utiliser les sous-réseaux privés pour les nœuds

  scaling_config {
    min_size     = var.asg_min_size
    max_size     = var.asg_max_size
    desired_size = var.asg_desired_size
  }

  instance_types = var.instance_types

  ami_type = "AL2_x86_64"

  # Dépendance explicite pour éviter les erreurs de synchronisation
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_vpc_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly_policy
  ]
}

# ------------------- Groupe de Sécurité pour les Nœuds de Travail ------------------- #

resource "aws_security_group" "eks_sg" {
  name        = "eks-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
