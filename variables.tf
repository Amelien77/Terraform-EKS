# Variable pour l'environnement (prod dans ce cas)
variable "environment" {
  description = "The environment where the infrastructure is being deployed (prod, dev, etc.)"
  type        = string
  default     = "prod"
}

# Variable pour la taille des instances des nœuds EKS
variable "instance_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
  default     = "m5.xlarge"
}

# Variable pour le nombre de nœuds désirés dans le groupe de nœuds EKS
variable "node_desired_size" {
  description = "Desired number of worker nodes in the EKS cluster"
  type        = number
  default     = 2
}

# Variable pour la taille minimale des nœuds dans le groupe EKS
variable "node_min_size" {
  description = "Minimum number of worker nodes in the EKS node group"
  type        = number
  default     = 2
}

# Variable pour la taille maximale des nœuds dans le groupe EKS
variable "node_max_size" {
  description = "Maximum number of worker nodes in the EKS node group"
  type        = number
  default     = 10
}

# Variable pour les IDs de groupes de sécurité
variable "security_group_ids" {
  description = "The security group IDs to associate with the EKS nodes"
  type        = list(string)
  default     = []
}

# Variable pour le nom du projet
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "wordpress-project"
}

# Variable pour l'AMI ID des instances du Load Balancer
variable "ami_id" {
  description = "The AMI ID to use for the Load Balancer instances"
  type        = string
  default     = "ami-00fdc3cbd36544fea"
}


# Variable pour le nom d'utilisateur de la base de données RDS
variable "db_username" {
  description = "The username for the RDS database"
  type        = string
}

# Variable pour le mot de passe de la base de données RDS
variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}

# Variable pour la région AWS
variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "eu-west-3"
}


# Variable pour l'ARN du certificat SSL
variable "certificate_arn" {
  description = "The ARN of the SSL certificate to use for HTTPS listeners"
  type        = string
}

# Variable pour le nom du cluster EKS
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# --- Variables spécifiques pour Velero ---

# Nom du bucket S3 pour Velero
variable "bucket_name" {
  description = "Name of the S3 bucket for Velero backups"
  type        = string
}

