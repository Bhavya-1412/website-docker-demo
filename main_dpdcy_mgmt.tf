provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnet (depends on VPC → implicit dependency)
resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Security Group (depends on VPC)
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance (depends on subnet + SG)
resource "aws_instance" "web" {
  ami = "ami-0f559c3642608c138"
  instance_type="t3.micro"

  subnet_id              = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  # Explicit dependency (optional but shows concept)
  depends_on = [
    aws_subnet.main_subnet,
    aws_security_group.sg
  ]
}