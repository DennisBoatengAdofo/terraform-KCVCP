terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.59.0"
    }
  }
}
# Create A VPC
resource "aws_vpc" "kcvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "KCVPC"
  }
}

 #Create Suaws_subnet" "
resource "aws_subnet" "PublicSubnet" {
  vpc_id     = aws_vpc.kcvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch= true
  tags = {
    Name = "PublicSubnet"
    
  }
}

 #Create Subnets
resource "aws_subnet" "PrivateSubnet" {
  vpc_id     = aws_vpc.kcvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = false 
  tags = {
    Name = "PrivateSubnet"
  }
}

 #Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kcvpc.id

  tags = {
    Name = "InternetGateway"
  }
}

#Create Route Table
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.kcvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

 resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.kcvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NATGateway.id
  }
  tags = {
    Name = "PrivateRouteTable"
  }
}

 #Associate Route Table PublicSubnet
 resource "aws_route_table_association" "PublicRouteTableAssociation" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRouteTable.id
}
#Associate Route Table PrivateSubnet
 resource "aws_route_table_association" "PrivateRouteTableAssociation" {
  subnet_id      = aws_subnet.PrivateSubnet.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

 #Create NAT Gateway
resource "aws_nat_gateway" "NATGateway" {
  allocation_id = aws_eip.NATGateway.id
  subnet_id     = aws_subnet.PublicSubnet.id

  tags = {
    Name = "NAT_GW"
  }
}

# Create an EIP for the NAT Gateway
resource "aws_eip" "NATEGateway" {
  tags = {
    Name = "NAT-EIP"
  }
}

# Create a Security Group for the Public Subnet
resource "aws_security_group" "public_sg"{
  name        = "Public-SG"
  description = "Allow inbound traffic from the internet"
  vpc_id      = aws_vpc.kcvpc.id 

    tags = {
      Name = "Public_Sg"
    }
        
  ingress {
  
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress { 
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }



 egress {
  
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
# Create a Security Group for the Private Subnet

resource "aws_security_group" "private_sg" {
  name        = "Private-SG"
  description = "Allow inbound traffic from the internet"
  vpc_id      = aws_vpc.kcvpc.id 

  ingress {
    from_port   = 5432 
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks  = ["10.0.1.0/24"]
  }
}

egress = {
  
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 }


 #Create NETWORK ACLs
 "aws_network_acl" "public_nacl" {

  vpc_id = aws_vpc.kcvpc.id
   subnet_ids = [aws_subnet.publicSubnet.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

   ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 443
    to_port    = 443
  }

  }


}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.kcvpc.id
  subnet_ids = [aws_subnet.PrivateSubnet.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 5432  
    to_port    = 5432
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
resource "aws_instance" "public_instance" {
  ami           = "ami-05842291b9a0bd79f" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.public_sg.id]

  tags = {
    Name = "PublicInstance"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              EOF
}

resource "aws_instance" "private_instance" {
  ami           = "ami-05842291b9a0bd79f" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_sg.id]

  tags = {
    Name = "PrivateInstance"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y postgresql
              EOF

}

