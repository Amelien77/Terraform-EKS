#===========================
# EKS Cluster
#===========================
resource "aws_eks_cluster" "this" {
  name     = "aws-eks-cluster"  # Nom simplifié sans interpolation
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = var.private_subnets
  }

  tags = {
    Name        = "aws-eks-cluster"
    Environment = var.environment
  }
}

#===========================
# IAM Role for EKS Cluster
#===========================
resource "aws_iam_role" "eks" {
  name = "aws-eks-cluster-role"  # Nom simplifié sans interpolation

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name        = "aws-eks-cluster-role"
    Environment = var.environment
  }
}

# AWS policy attachments for EKS cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

#===========================
# EKS Node Group
#===========================
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "aws-eks-node-group"  # Nom simplifié sans interpolation
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "aws-eks-node-group"
    Environment = var.environment
    "kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.worker_ssm_policy,
  ]
}

# ===========================
# Security Group for EKS Nodes
# ===========================
resource "aws_security_group" "eks_nodes" {
  name        = "aws-eks-nodes-sg"  # Nom simplifié sans interpolation
  description = "Security group for EKS nodes"
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

  tags = {
    Name        = "aws-eks-nodes-sg"
    Environment = var.environment
  }
}

#===========================
# Auto Scaling Group
#===========================
resource "aws_autoscaling_group" "this" {
  availability_zones        = var.availability_zones
  name                      = "aws-eks-asg"  # Nom simplifié sans interpolation
  max_size                  = var.node_max_size
  min_size                  = var.node_min_size
  desired_capacity          = var.node_desired_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance"]

  launch_configuration = aws_launch_template.this.id

  tags = [
    {
      key                 = "Name"
      value               = "aws-eks-autoscaling-group"  # Nom simplifié sans interpolation
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    }
  ]
}

#===========================
# IAM Role for EKS Nodes
#===========================
resource "aws_iam_role" "eks_nodes" {
  name               = "aws-eks-nodes-role"  # Nom simplifié sans interpolation
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_nodes.json

  tags = {
    Name        = "aws-eks-nodes-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_ssm_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#===========================
# Launch Template for Worker Nodes
#===========================
resource "aws_launch_template" "this" {
  name_prefix   = "aws-eks-launch-template"  # Nom simplifié sans interpolation
  image_id      = data.aws_ssm_parameter.ami.value
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "aws-eks-node"  # Nom simplifié sans interpolation
      Environment = var.environment
    }
  }
}

#===========================
# IAM Policy and Role for EC2
#===========================
resource "aws_iam_role" "test_role" {
  name = "test_role"

  # JSON encoding for assume role policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "test_role"
    Environment = var.environment
  }
}

# IAM Policy for EC2 Role
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.test_role.id

  # Policy allowing EC2 Describe* actions
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = {
    Name        = "test_policy"
    Environment = var.environment
  }
}

# IAM Role with Custom Path
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "instance_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

#===========================
# Data Sources
#===========================
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_nodes" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/eks/optimized-ami/1.27/amazon-linux-2/recommended/image_id"
}
