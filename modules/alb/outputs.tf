# URL du Load Balancer HTTP
output "wordpress_alb_url_http" {
  description = "URL for the HTTP listener of the WordPress ALB"
  value       = "http://${aws_lb.wordpress_alb.dns_name}"
}

# URL du Load Balancer HTTPS
output "wordpress_alb_url_https" {
  description = "URL for the HTTPS listener of the WordPress ALB"
  value       = "https://${aws_lb.wordpress_alb.dns_name}"
}

# ARN du certificat SSL pour HTTPS
output "wordpress_cert_arn" {
  description = "ARN of the ACM certificate for WordPress HTTPS"
  value       = aws_acm_certificate.wordpress_cert.arn
}

# Nom du groupe cible pour HTTP
output "wordpress_target_group_http" {
  description = "Name of the target group for HTTP"
  value       = aws_lb_target_group.wordpress_tg.name
}

# Nom du groupe cible pour HTTPS
output "wordpress_target_group_https" {
  description = "Name of the target group for HTTPS"
  value       = aws_lb_target_group.wordpress_tg_https.name
}

# ARN du Load Balancer
output "wordpress_alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.wordpress_alb.arn
}

# ID du Security Group de l'ALB
output "wordpress_alb_sg_id" {
  description = "Security Group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

output "eks_nodes_sg_id" {
  description = "The security group ID for EKS nodes"
  value       =  var.eks_nodes_sg_id
}

output "alb_dns_name" {
  description = "Nom DNS de l'ALB"
  value       = aws_lb.wordpress_alb.dns_name  # Remplacer 'this' par 'wordpress_alb'
}
