provider "aws" {
  region = var.region
}

############################################
# VPC
############################################
resource "aws_vpc" "deepak_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project}-vpc"
  }
}

############################################
# Internet Gateway
############################################
resource "aws_internet_gateway" "deepak_igw" {
  vpc_id = aws_vpc.deepak_vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

############################################
# Public Subnet
############################################
resource "aws_subnet" "deepak_public_subnet" {
  vpc_id                  = aws_vpc.deepak_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az

  tags = {
    Name = "${var.project}-public-subnet"
  }
}

############################################
# Route Table
############################################
resource "aws_route_table" "deepak_rt" {
  vpc_id = aws_vpc.deepak_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.deepak_igw.id
  }

  tags = {
    Name = "${var.project}-rt"
  }
}

############################################
# Associate Subnet with Route Table
############################################
resource "aws_route_table_association" "deepak_rta" {
  subnet_id      = aws_subnet.deepak_public_subnet.id
  route_table_id = aws_route_table.deepak_rt.id
}

############################################
# Security Group
############################################
resource "aws_security_group" "deepak_sg" {
  name        = "${var.project}-sg"
  description = "Allow SSH and MySQL"
  vpc_id      = aws_vpc.deepak_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_ranges
  }

  # MySQL
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_ranges
  }

  # ALL outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-sg"
  }
}

############################################
# Key Pair (Generated Automatically)
############################################
resource "tls_private_key" "deepak_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deepak_keypair" {
  key_name   = "${var.project}-key"
  public_key = tls_private_key.deepak_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${var.project}-key.pem"
  content         = tls_private_key.deepak_key.private_key_pem
  file_permission = "0400"
}

############################################
# EC2 Instance with Docker + MySQL
############################################
resource "aws_instance" "deepak_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.deepak_public_subnet.id
  key_name                    = aws_key_pair.deepak_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.deepak_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
set -ex

# Update system
dnf update -y

# Install Docker for Amazon Linux 2023
dnf install -y docker

systemctl enable docker
systemctl start docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Run MySQL container
docker pull mysql:8.0
docker run -d --name mysql-container \
  -e MYSQL_ROOT_PASSWORD=${var.mysql_root_password} \
  -e MYSQL_DATABASE=${var.mysql_database} \
  -p 3306:3306 \
  mysql:8.0

EOF

  tags = {
    Name = "${var.project}-ec2"
  }
}