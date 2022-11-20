variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-2"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

# VPC Variables
variable "vpc_cidr" {
  type        = string
  description = "CIDR used for subnets"
  default     = "10.10.0.0/16"
}

# Subnet variables
variable "public_subnet_cidr" {
  type        = string
  description = "CIDR used for public subnet"
  default     = "10.10.0.128/26"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR used for private subnet"
  default     = "10.10.0.192/26"
}

variable "vm_instance_type" {
  type    = string
  default = "t3.nano"
}

variable "vm_has_public_ip_address" {
  type    = bool
  default = true
}

variable "vm_root_volume_size" {
  type = number
}

variable "vm_data_volume_size" {
  type = number
}

# EBS
variable "vm_root_volume_type" {
  type    = string
  default = "gp3"
}

variable "vm_data_volume_type" {
  type    = string
  default = "gp3"
}
