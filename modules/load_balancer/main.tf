#----------------------- Création du Load Balancer AWS ---------------------------#
resource "aws_lb" "wordpress_alb" {
  name               = "wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false
  idle_timeout = 60
}

# ----------------- Création du groupe de sécurité pour le Load Balancer ----------------- #
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# ------------------ Création du certificat SSL/TLS ------------------ #
resource "aws_acm_certificate" "wordpress_cert" {
  domain_name       = "cdojanv24.serviceweb-datascientest.ddns-ip.net"
  validation_method = "DNS"

  tags = {
    Name = "wordpress-cert"
  }
}

# ------------------ Listener HTTP -------------------- #
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}

# ------------------ Listener HTTPS ------------------- #
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = "arn:aws:acm:eu-west-3:885801475464:certificate/1817547b-3794-4c6d-99d9-8ccb9acedbf1"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }
}

# ------------------ Groupe cible pour le Load Balancer ------------------- #
resource "aws_lb_target_group" "wordpress_tg" {
  name     = "wordpress-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# ------------------ Service Kubernetes de type LoadBalancer -------------------- #
resource "kubernetes_service" "wordpress-app-service" {
  metadata {
    name = "wordpress-app-service"
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

resource "aws_launch_configuration" "wordpress_lc" {
  name          = var.launch_configuration_name
  image_id      = var.ami_id
  instance_type = var.instance_type

  security_groups = [aws_security_group.wordpress_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "wordpress_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.private_subnets
  launch_configuration = aws_launch_configuration.wordpress_lc.id

  security_groups = [aws_security_group.wordpress_sg.id]

 tag {
   key                 = "Name"
   value               = "wordpress-instance"
   propagate_at_launch = true
 }
}


resource "aws_security_group" "wordpress_sg" {
  name_prefix = "wordpress-sg-"
  description = "Security group for WordPress instances"
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
