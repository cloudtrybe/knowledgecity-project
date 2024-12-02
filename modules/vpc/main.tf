data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${terraform.workspace}-vpc"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    name      = "${terraform.workspace}-private-subnet-${count.index + 1}"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    name      = "${terraform.workspace}-public-subnet-${count.index + 1}"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    name      = "${terraform.workspace}-igw"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    name      = "${terraform.workspace}-public-route-table"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

# Route table association for public subnets
resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count  = var.az_count
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = {
    name      = "${terraform.workspace}-eip-${count.index + 1}"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    name      = "${terraform.workspace}-nat-gw-${count.index + 1}"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

# Route table for private subnets
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    name      = "${terraform.workspace}-private-route-table-${count.index + 1}"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

# Route table association for private subnets
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}