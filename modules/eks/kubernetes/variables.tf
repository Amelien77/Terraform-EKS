variable "replicas" {
  description = "Number of replicas for the WordPress deployment"
  type        = number
  default     = 2
}

variable "image" {
  description = "Docker image for the WordPress container"
  type        = string
  default     = "wordpress:latest" # à modifier avec notre images poussés
}

variable "environment" {
  description = "Environnement (prod, dev, etc.)"
  type        = string
}
