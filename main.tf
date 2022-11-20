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

# Security Group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_security_group_rule" "my_security_group_rule_allow_http" {
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_security_group_rule" "my_security_group_rule_allow_https" {
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_security_group_rule" "my_security_group_rule_allow_outbound_connections" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Outbound allowed on all ports"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_security_group_rule" "my_security_group_rule_allow_ssh" {
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.my_security_group.id
}

# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "ec2_key_pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

# EC2
resource "aws_instance" "my_ec2" {
  ami                         = data.aws_ami.az_linux_2.id
  instance_type               = var.vm_instance_type
  subnet_id                   = aws_subnet.my_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]
  source_dest_check           = false
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = var.vm_has_public_ip_address
  user_data                   = data.template_file.user_data.rendered

  root_block_device {
    volume_size           = var.vm_root_volume_size
    volume_type           = var.vm_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.vm_data_volume_size
    volume_type           = var.vm_data_volume_type
    delete_on_termination = true
    encrypted             = true
  }
}
