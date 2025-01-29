# Variable for the database username
variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true  # This is sensitive data and should not be exposed
}

# Variable for the database password
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true  # This is sensitive data and should not be exposed
}

# Variable for the VPC ID where the RDS will be deployed
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

# Variable for the private subnets where the RDS instance will be deployed (two subnets in different AZs)
variable "private_subnets" {
  description = "List of private subnets in different availability zones"
  type        = list(string)
}

# Variable for the CIDR block of the private subnet A
variable "cidr_app_subnet_a" {
  description = "CIDR block for private subnet A"
  type        = string
}

# Variable for the CIDR block of the private subnet B
variable "cidr_app_subnet_b" {
  description = "CIDR block for private subnet B"
  type        = string
}
