#----------------------- Load Balancer AWS in public subnet ---------------------------#
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
# Exemple de mise à jour dans le module ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = ["0.0.0.0/0"]
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

  # Redirection HTTP --> HTTPS
  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# ------------------ Listener HTTPS ------------------- #
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }
}

# ------------------ Target group for ALB and EKS ------------------- #
resource "aws_lb_target_group" "wordpress_tg" {
  name     = "wordpress-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"  # Permet d'envoyer le trafic aux instances privées

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "wordpress_tg_https" {
  name     = "wordpress-tg-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# ------------------ Security Group pour EKS (Autorise ALB) ------------------- #
resource "aws_security_group_rule" "eks_allow_alb" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id        = var.eks_nodes_sg_id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "eks_allow_alb_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  security_group_id        = var.eks_nodes_sg_id
  source_security_group_id = aws_security_group.alb_sg.id
}

