# Output du nom du cluster EKS
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

# Output du point de terminaison du cluster EKS
output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

# Output de l'ARN du rôle IAM du cluster EKS
output "eks_cluster_iam_role_arn" {
  description = "The IAM role ARN associated with the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

# Output de l'URL de l'ALB (si nécessaire pour accéder au service)
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

# Output de l'ARN du certificat SSL/TLS (si nécessaire pour HTTPS)
output "wordpress_ssl_certificate_arn" {
  description = "The ARN of the SSL certificate used for WordPress"
  value       = module.alb.wordpress_cert_arn
}

# Output de l'URL du point de terminaison RDS
output "rds_endpoint" {
  description = "The endpoint of the RDS database"
  value       = module.rds.db_endpoint
}

output "eks_nodes_sg_id" {
  description = "The security group ID for EKS nodes"
  value       = var.eks_nodes_sg_id  # Utilisation de la variable si elle est définie
}
