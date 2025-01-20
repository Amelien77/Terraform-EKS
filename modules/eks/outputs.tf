# ------------------- Sorties du Cluster EKS ------------------- #

output "cluster_name" {
  description = "Nom du cluster EKS"
  value       = aws_eks_cluster.wordpress_eks.name
}

output "cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = aws_eks_cluster.wordpress_eks.endpoint
}

output "cluster_arn" {
  description = "ARN du cluster EKS"
  value       = aws_eks_cluster.wordpress_eks.arn
}


# ------------------- Sorties des Nœuds de Travail ------------------- #

output "node_group_name" {
  description = "Nom du groupe de nœuds"
  value       = aws_eks_node_group.wordpress_node_group.node_group_name
}

output "node_group_arn" {
  description = "ARN du groupe de nœuds"
  value       = aws_eks_node_group.wordpress_node_group.arn
}

output "node_security_group_id" {
  description = "ID du groupe de sécurité des nœuds de travail"
  value       = aws_security_group.eks_sg.id
}


output "cluster_certificate_authority" {
  description = "L'autorité de certificat pour Kubernetes"
  value = aws_eks_cluster.wordpress_eks.certificate_authority[0].data
}
