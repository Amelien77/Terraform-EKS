# VPC ID où déployer les ressources
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# Liste des sous-réseaux publics pour l'ALB
variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

# ARN du certificat SSL/TLS pour HTTPS
variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}

# Nom du cluster EKS
variable "eks_cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
}

# ID du Security Group des nodes EKS (pour autoriser ALB à y accéder)
variable "eks_nodes_sg_id" {
  description = "Security Group ID for EKS nodes"
  type        = string
}
