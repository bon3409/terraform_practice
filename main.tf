terraform {
  cloud {
    organization = var.organization

    workspaces {
      name = var.workspace
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# 1. Create VPC
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}

# 2. Create Internet Gateway
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    "Name" = "terraform-igw"
  }
}

# 3. Create Route Table
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "terraform-route-table" {
  vpc_id = aws_vpc.terraform-vpc.id

  # IPv4
  route {
    cidr_block = "0.0.0.0/0" # means all traffic
    gateway_id = aws_internet_gateway.terraform-igw.id
  }

  tags = {
    "Name" = "terraform-route-table"
  }
}

# 4. Create Subnet
# Reference:  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "terraform-subnet-1" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = var.subnets_cidr_block[0] # make sure within the vpc cidr_block range
  availability_zone = var.availability_zone     # if no specific az, will random one

  tags = {
    Name = "ferraform-subnet-1"
  }
}

# 5. Associate subnet with Route Table
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "ferraform-route-table-associate-a" {
  subnet_id      = aws_subnet.terraform-subnet-1.id
  route_table_id = aws_route_table.terraform-route-table.id
}

# 6. Create Security Group
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "terraform-sg" {
  name        = "allow-web-traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # -1 means ny protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "terraform-sg"
  }
}

# 7. Create Elastic Network Interface
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface
resource "aws_network_interface" "terraform-eni" {
  subnet_id       = aws_subnet.terraform-subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.terraform-sg.id]
}

# 8. Assign an Elastic Ip to the Elastic Network Interface
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "terraform-eip" {
  vpc                       = true # Boolean if the EIP is in a VPC or not. Defaults to true unless the region supports EC2-Classic.
  network_interface         = aws_network_interface.terraform-eni.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.terraform-igw,
    aws_instance.terraform-ec2
  ]
}

# 9. Create Server
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "terraform-ec2" {
  ami               = var.instance_ami
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  key_name          = var.instance_key

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.terraform-eni.id
  }

  user_data = <<EOF
                #!/bin/bash
                # Use this for your user data (script from top to bottom)
                # install httpd (Linux 2 version)
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
                EOF
  tags = {
    Name = "terraform-ec2"
  }
}

# output some parameters
output "server_pulic_ip" {
  value = aws_eip.terraform-eip.public_ip
}
