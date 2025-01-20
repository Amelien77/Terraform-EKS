# ------------------- Rôle IAM pour le Cluster EKS ------------------- #

resource "aws_iam_role" "eks_role" {
  name = "wordpress-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

# ------------------- Politique IAM attachée au Cluster EKS ------------------- #

resource "aws_iam_role_policy_attachment" "eks_role_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# ------------------- Rôle IAM pour les Nœuds de Travail ------------------- #

resource "aws_iam_role" "eks_node_role" {
  name = "wordpress-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

# ------------------- Attach Policies aux Rôles des Nœuds ------------------- #

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_readonly_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ------------------- Politique IAM pour l'accès Kubernetes ------------------- #

resource "aws_iam_policy" "eks_k8s_policy" {
  name        = "eks-k8s-policy"
  description = "Policy for Kubernetes Deployment on EKS"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_k8s_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.eks_k8s_policy.arn
}

# ------------------- Politique IAM pour l'accès S3 ------------------- #

resource "aws_iam_role_policy_attachment" "eks_s3_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# ------------------- Politique IAM pour détacher et supprimer les interfaces réseau ------------------- #

resource "aws_iam_policy" "detach_and_delete_network_interface_policy" {
  name        = "DetachAndDeleteNetworkInterfacePolicy"
  description = "Policy to allow detaching and deleting network interfaces"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DetachNetworkInterface",
          "ec2:DeleteNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "detach_and_delete_network_interface_attachment" {
  name       = "DetachAndDeleteNetworkInterfaceAttachment"
  policy_arn = aws_iam_policy.detach_and_delete_network_interface_policy.arn
  users      = ["student16_jan24_continue_webservice"]
}

# ------------------- Configuration de l'authentification AWS pour Kubernetes ------------------- #

resource "kubernetes_config_map" "aws_auth" {
  depends_on = [
    aws_iam_role.eks_role,
    aws_iam_role.eks_node_role,
    aws_iam_role_policy_attachment.eks_role_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_vpc_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly_policy,
    aws_iam_role_policy_attachment.eks_k8s_policy_attachment,
    aws_iam_role_policy_attachment.eks_s3_policy,
    aws_iam_policy_attachment.detach_and_delete_network_interface_attachment
  ]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = yamlencode([{
      userarn  = "arn:aws:iam::885801475464:user/student16_jan24_continue_webservice"
      username = "student16_jan24_continue_webservice"
      groups   = ["system:masters"]
    }])

    mapRoles = yamlencode([{
      rolearn  = "arn:aws:iam::885801475464:role/wordpress-eks-node-role"
      username = "node-group"
      groups   = ["system:node"]
    }])
  }
}

