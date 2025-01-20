# ------------------- Variables pour le Cluster EKS ------------------- #

variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
  default     = "wordpress-cluster"
}

variable "k8s_version" {
  description = "Version de Kubernetes à utiliser"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "ID du VPC où le cluster sera déployé"
  type        = string
}

variable "public_subnets" {
  description = "Liste des sous-réseaux publics pour le cluster"
  type        = list(string)
}

variable "private_subnets" {
  description = "Liste des sous-réseaux privés pour les nœuds"
  type        = list(string)
}

# ------------------- Variables pour le Groupe de Nœuds ------------------- #

variable "node_group_name" {
  description = "Nom du groupe de nœuds"
  type        = string
  default     = "wordpress-node-group"
}

variable "asg_min_size" {
  description = "Taille minimale du groupe de nœuds"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Taille maximale du groupe de nœuds"
  type        = number
  default     = 3
}

variable "asg_desired_size" {
  description = "Taille désirée du groupe de nœuds"
  type        = number
  default     = 2
}

variable "instance_types" {
  description = "Types d'instances EC2 pour les nœuds"
  type        = list(string)
  default     = ["t2.micro"]
}
