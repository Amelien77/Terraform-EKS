# Déploiement Kubernetes pour WordPress
resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
      cluster_name = var.cluster_name
   }
  }

  spec {
    replicas = 3

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
          image = "wordpress:latest"  # Image officielle de WordPress
          port {
            container_port = 80
          }

          env {
            name  = "WORDPRESS_DB_HOST"
            value = "db"
          }

          env {
            name  = "WORDPRESS_DB_NAME"
            value = "josy"
          }

          env {
            name  = "WORDPRESS_DB_USER"
            value = "josypass"
          }

          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = "josydb"
          }
        }
      }
    }
  }
}

# Service Kubernetes pour exposer WordPress via un LoadBalancer
resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress-service"
  }

  spec {
    selector = {
      app = "wordpress"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

# AWS autoscaling group

resource "aws_autoscaling_group" "wordpress_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = var.private_subnets
  launch_configuration = aws_launch_configuration.wordpress_lc.id

 tag {
   key                 = "Name"
   value               = "wordpress-instance"
   propagate_at_launch = true
 }
}

# AWS Launch config 

resource "aws_launch_configuration" "wordpress_lc" {
  name          = var.launch_configuration_name
  image_id      = var.ami_id
  instance_type = var.instance_type

  security_groups = [aws_security_group.wordpress_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

# AWS Security Group

resource "aws_security_group" "wordpress_sg" {
  name_prefix = "wordpress-sg-"
  description = "Security group for WordPress"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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
