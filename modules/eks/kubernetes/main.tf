# kubernetes service linked with ALB target group
resource "kubernetes_service" "wordpress_app_service" {
  metadata {
    name = "wordpress-app-service"

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "alb"
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "false"
      "service.beta.kubernetes.io/aws-load-balancer-arn" = aws_lb.wordpress_alb.arn
      "service.beta.kubernetes.io/aws-load-balancer-target-group-arn" = aws_lb_target_group.wordpress_tg.arn
    }
  }

  spec {
    selector = {
      app = "wordpress"
    }

    port {
      port        = 80
      target_port = 80
    }

    port {
      port        = 443
      target_port = 443
    }

    type = "LoadBalancer"
  }
}

#Déploiement

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "wordpress"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = "wordpress:latest"
          ports {
            container_port = 80
          }
        }
      }
    }
  }
}

