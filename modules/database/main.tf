#-----------------------------Database-----------------------------#

resource "aws_db_instance" "wordpress_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "wordpress_db"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  multi_az             = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  skip_final_snapshot = true

  tags = {
    Name = "wordpress-rds"
  }
}

#--------------- groupe de sous-réseaux pour db ------------------------------#

resource "aws_db_subnet_group" "db_subnet" {
  name       = "wordpress-db-subnet"
  subnet_ids = var.private_subnets

  tags = {
    Name = "wordpress-db-subnet-group"
  }
}

#------------------ groupe de sécurité pour db -------------------------------#

resource "aws_security_group" "db_sg" {
  name        = "wordpress-db-sg"
  description = "Security group for WordPress database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.app_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
