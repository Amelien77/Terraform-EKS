#===========================
# Variables for Project Configuration
#===========================

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement de déploiement (par exemple, dev, prod)"
  type        = string
}

#===========================
# VPC & Networking Configuration
#===========================

variable "private_subnets" {
  description = "Liste des sous-réseaux privés pour le cluster EKS"
  type        = list(string)
}

variable "availability_zones" {
  description = "Liste des zones de disponibilité pour le groupe Auto Scaling"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Liste des groupes de sécurité pour les instances EC2"
  type        = list(string)
}

#===========================
# Instance Configuration
#===========================

variable "instance_type" {
  description = "Type d'instance EC2 pour les nœuds EKS"
  type        = string
}

variable "node_desired_size" {
  description = "Nombre souhaité de nœuds dans le groupe"
  type        = number
}

variable "node_max_size" {
  description = "Taille maximale du groupe de nœuds"
  type        = number
}

variable "node_min_size" {
  description = "Taille minimale du groupe de nœuds"
  type        = number
}
