terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.38.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "my_vpc"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create elastic IP
resource "aws_eip" "my_elastic_ip" {
  vpc = true
  depends_on = [
    aws_internet_gateway.my_igw
  ]
}

# Create NAT
resource "aws_nat_gateway" "my_nat_gw" {
  allocation_id = aws_eip.my_elastic_ip.id
  subnet_id     = aws_subnet.my_public_subnet.id
  depends_on = [
    aws_eip.my_elastic_ip
  ]
}

# Create public subnet
resource "aws_subnet" "my_public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_cidr
}

# Create private subnet
resource "aws_subnet" "my_private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_cidr
}

# Create public route table
resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Create private route table
resource "aws_route_table" "my_private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_nat_gw.id
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "my_public_rt_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_rt.id
}

# Associate route table with private subnet
resource "aws_route_table_association" "my_private_rt_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_rt.id
}
