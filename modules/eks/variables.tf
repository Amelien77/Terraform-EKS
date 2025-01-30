#===========================
# Variables for Project Configuration
#===========================

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "prod"
}

#===========================
# VPC & Networking Configuration
#===========================

variable "vpc_id" {
  description = "ID du VPC pour les ressources"
  type        = string
}

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
  default     = []  
}

#===========================
# Instance Configuration
#===========================

variable "instance_type" {
  description = "Type d'instance EC2 pour les nœuds EKS"
  type        = string
  default     = "t3.medium" 
}

variable "node_desired_size" {
  description = "Nombre souhaité de nœuds dans le groupe"
  type        = number
  default     = 2  
}

variable "node_max_size" {
  description = "Taille maximale du groupe de nœuds"
  type        = number
  default     = 3 
}

variable "node_min_size" {
  description = "Taille minimale du groupe de nœuds"
  type        = number
  default     = 1  
}
