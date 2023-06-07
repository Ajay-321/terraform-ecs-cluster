###############################################
###VPC Resource Block###
###############################################
resource "aws_vpc" "tf-vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-VPC"
  }
}

###############################################
###Private Subnet Resource Block###
###############################################

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.tf-vpc.id
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.prefix}-private-subnet-${var.azs[count.index]}"
  }
}

###############################################
###Public Subnet Resource Block###
###############################################


resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.tf-vpc.id
  count                   = length(var.public_subnets)
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public-subnet-${var.azs[count.index]}"
  }
}

###############################################
###IGW Resource Block###
###############################################

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

###############################################
###NAT Gateway Resource Block###
###############################################

resource "aws_nat_gateway" "tf-nat" {
  allocation_id = aws_eip.tf-eip.id
  subnet_id     = element(aws_subnet.public_subnets[*].id, 0)

  tags = {
    Name = "${var.prefix}-nat-gateway"
  }
  depends_on = [aws_internet_gateway.myigw]
}

###############################################
###EIP Resource Block###
###############################################

resource "aws_eip" "tf-eip" {
  vpc = true
}

###############################################
###Public Route Table Resource Block###
###############################################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.tf-vpc.id
  tags = {
    Name = "${var.prefix}-public-route-table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

###############################################
###Private Route Table Resource Block###
###############################################

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.tf-vpc.id
  tags = {
    Name = "${var.prefix}-private-route-table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf-nat.id

  }
}

########################################################
###Public Route Table Association Resource Block ###
########################################################
resource "aws_route_table_association" "public_route_association" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id

}

########################################################
###Private Route Table Association Resource Block ###
########################################################

resource "aws_route_table_association" "private_route_association" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id

}

