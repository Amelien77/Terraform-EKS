#------------------------Database---------------------------------------------#

variable "db_username" {
  description = "Nom d'utilisateur pour la base de données"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Mot de passe pour la base de données"
  type        = string
  sensitive   = true
}


#-----------------------AMI-------------------------------------------------#

variable "ami_id" {
  description = "The AMI ID to use for the Bastion and Load Balancer instances"
  type        = string
  default     = "ami-00fdc3cbd36544fea"
}

