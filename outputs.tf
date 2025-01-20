output "load_balancer_id" {
  value = module.load_balancer.alb_id
}

output "load_balancer_target_group_arn" {
  value = module.load_balancer.target_group_arn
}

output "load_balancer_http_listener_arn" {
  value = module.load_balancer.http_listener_arn
}

output "load_balancer_https_listener_arn" {
  value = module.load_balancer.https_listener_arn
}

output "wordpress_asg_id" {
  value = module.wordpress.wordpress_asg_id
}

output "database_db_instance_id" {
  value = module.database.db_instance_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority" {
  value = module.eks.cluster_certificate_authority
}
