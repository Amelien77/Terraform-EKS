#---------------------------------VPC----------------------------------------#

resource "aws_vpc" "datascientest_vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "datascientest-vpc"
  }
}

#------------------------------publics subnets in VPC-----------------------------------#

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.datascientest_vpc.id
  cidr_block              = var.cidr_public_subnet_a
  map_public_ip_on_launch = true
  availability_zone       = var.az_a
  tags = {
    Name        = "public-a"
    Environment = var.environment
  }
  
  lifecycle {
    prevent_destroy = false  # Permet de supprimer le sous-réseau
  }

  depends_on = [aws_vpc.datascientest_vpc]
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.datascientest_vpc.id
  cidr_block              = var.cidr_public_subnet_b
  map_public_ip_on_launch = true
  availability_zone       = var.az_b
  tags = {
    Name        = "public-b"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = false  # Permet de supprimer le sous-réseau
  }

  depends_on = [aws_vpc.datascientest_vpc]
}


#------------------------------private subnets in VPC------------------------------------------#

resource "aws_subnet" "app_subnet_a" {
  vpc_id                  = aws_vpc.datascientest_vpc.id
  cidr_block              = var.cidr_app_subnet_a
  availability_zone       = var.az_a
  tags = {
    Name        = "app-a"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = false  # Permet de supprimer le sous-réseau
  }

  depends_on = [aws_vpc.datascientest_vpc]
}

resource "aws_subnet" "app_subnet_b" {
  vpc_id                  = aws_vpc.datascientest_vpc.id
  cidr_block              = var.cidr_app_subnet_b
  availability_zone       = var.az_b
  tags = {
    Name        = "app-b"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = false  # Permet de supprimer le sous-réseau
  }

  depends_on = [aws_vpc.datascientest_vpc]
}

#------------------------ NAT Gateways / elastic IP (EIP) in publics subnets-------#

resource "aws_eip" "eip_public_a" {
  domain = "vpc"
}

resource "aws_nat_gateway" "gw_public_a" {
  allocation_id = aws_eip.eip_public_a.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "datascientest-nat-public-a"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_subnet.public_subnet_a]
}

resource "aws_eip" "eip_public_b" {
  domain = "vpc"
}

resource "aws_nat_gateway" "gw_public_b" {
  allocation_id = aws_eip.eip_public_b.id
  subnet_id     = aws_subnet.public_subnet_b.id

  tags = {
    Name = "datascientest-nat-public-b"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_subnet.public_subnet_b]
}

#---------------------------Gateway internet in VPC-----------------------#

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.datascientest_vpc.id
  tags = {
    Name = "${var.environment}-igw"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_vpc.datascientest_vpc]
}

#--------------------public route table and associations in VPC----------------#

# Creation public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.datascientest_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }
  tags = {
    Name = "${var.environment}-public-route-table"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_internet_gateway.vpc_igw]
}

# association public route table with public subnet a
resource "aws_route_table_association" "public_route_table_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_route_table.public_route_table]
}

# association public route table with public subnet b
resource "aws_route_table_association" "public_route_table_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_route_table.public_route_table]
}

#--------------------private route table and associations in VPC----------------#

# Create private route table a / association with NAT in public subnet a
resource "aws_route_table" "private_route_table_a" {
  vpc_id = aws_vpc.datascientest_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_public_a.id
  }
  tags = {
    Name = "${var.environment}-private-route-table-a"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_nat_gateway.gw_public_a]
}


# association private route table a with private subnet a
resource "aws_route_table_association" "private_route_table_association_a" {
  subnet_id      = aws_subnet.app_subnet_a.id
  route_table_id = aws_route_table.private_route_table_a.id

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_route_table.private_route_table_a]
}


# create route table b / association with NAT in public subnet b
resource "aws_route_table" "private_route_table_b" {
  vpc_id = aws_vpc.datascientest_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_public_b.id
  }
  tags = {
    Name = "${var.environment}-private-route-table-b"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_nat_gateway.gw_public_b]
}

# association private route table b with private subnet b
resource "aws_route_table_association" "private_route_table_association_b" {
  subnet_id      = aws_subnet.app_subnet_b.id
  route_table_id = aws_route_table.private_route_table_b.id

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_route_table.private_route_table_b]
}
