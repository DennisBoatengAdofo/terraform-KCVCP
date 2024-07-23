
# Variables for VPC
variable "aws_region" {
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

# Variables for Subnets
variable "public_subnet_name" {
  type        = string
  default     = "PublicSubnet"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_name" {
  type        = string
  default     = "PrivateSubnet"
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.0.2.0/24"
}


# Variables for Security Groups
variable "public_security_group_name" {
  type        = string
  default     = "PublicSecurityGroup"
}

variable "private_security_group_name" {
  type        = string
  default     = "PrivateSecurityGroup"
}

# Variables for NAT Gateway
variable "nat_gateway_name" {
  type        = string
  default     = "NATGateway"
}

# Variables for Route Tables
variable "public_route_table_name" {
  type        = string
  default     = "PublicRouteTable"
}

variable "private_route_table_name" {
  type        = string
  default     = "PrivateRouteTable"
}


# Variables for EC2 Instances
variable "public_ec2_instance_name" {
  type        = string
  default     = "PublicEC2Instance"
}

variable "private_ec2_instance_name" {
  type        = string
  default     = "PrivateEC2Instance"
}
# Variable for Local IP
variable "local_ip" {
  type        = string
  description = "Your local IP address"
}


