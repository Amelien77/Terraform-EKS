output "wordpress_service_ip" {
  description = "The public IP of the WordPress service"
  value       = kubernetes_service.wordpress_app_service.status[0].load_balancer[0].ingress[0].hostname
}
