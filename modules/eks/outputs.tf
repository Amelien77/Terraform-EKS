#===========================
# Outputs
#===========================

output "eks_cluster_name" {
  description = "Nom du cluster EKS"
  value       = aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  description = "Point de terminaison API du cluster EKS"
  value       = aws_eks_cluster.this.endpoint
}

output "eks_cluster_arn" {
  description = "ARN du cluster EKS"
  value       = aws_eks_cluster.this.arn
}

output "eks_node_group_name" {
  description = "Nom du groupe de nœuds EKS"
  value       = aws_eks_node_group.this.node_group_name
}

output "eks_node_group_status" {
  description = "Statut du groupe de nœuds EKS"
  value       = aws_eks_node_group.this.status
}

output "eks_node_group_arn" {
  description = "ARN du groupe de nœuds EKS"
  value       = aws_eks_node_group.this.arn
}

output "autoscaling_group_name" {
  description = "Nom du groupe de mise à l'échelle automatique"
  value       = aws_autoscaling_group.this.name
}

output "autoscaling_group_max_size" {
  description = "Taille maximale du groupe de mise à l'échelle automatique"
  value       = aws_autoscaling_group.this.max_size
}

output "autoscaling_group_min_size" {
  description = "Taille minimale du groupe de mise à l'échelle automatique"
  value       = aws_autoscaling_group.this.min_size
}

output "autoscaling_group_desired_capacity" {
  description = "Capacité désirée du groupe de mise à l'échelle automatique"
  value       = aws_autoscaling_group.this.desired_capacity
}

output "instance_role_arn" {
  description = "ARN du rôle IAM pour les instances EC2"
  value       = aws_iam_role.instance.arn
}

output "test_role_arn" {
  description = "ARN du rôle IAM de test"
  value       = aws_iam_role.test_role.arn
}

output "node_security_group_id" {
  description = "ID du groupe de sécurité des nœuds EKS"
  value       = aws_security_group.eks_nodes.id
}
