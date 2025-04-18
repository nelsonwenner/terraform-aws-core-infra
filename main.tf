terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "infra-basic-vpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "infra-basic-vpc"
  }
}

resource "aws_subnet" "infra-basic-subnet-public" {
  vpc_id     = aws_vpc.infra-basic-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "infra-basic-subnet-public"
  }
}

resource "aws_subnet" "infra-basic-subnet-private" {
  vpc_id     = aws_vpc.infra-basic-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "infra-basic-subnet-private"
  }
}

resource "aws_eip" "infra-basic-nat-eip" {
  domain = "vpc"

  tags = {
    Name = "infra-basic-nat-eip"
  }
}

resource "aws_internet_gateway" "infra-basic-internet-gateway" {
  vpc_id = aws_vpc.infra-basic-vpc.id

  tags = {
    Name = "infra-basic-internet-gateway"
  }
}

resource "aws_nat_gateway" "infra-basic-nat-gateway" {
  allocation_id = aws_eip.infra-basic-nat-eip.id
  subnet_id     = aws_subnet.infra-basic-subnet-public.id

  tags = {
    Name = "infra-basic-nat-gateway"
  }
}

resource "aws_route_table" "infra-basic-route-table-public" {
  vpc_id = aws_vpc.infra-basic-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infra-basic-internet-gateway.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "infra-basic-route-table-public"
  }
}

resource "aws_route_table" "infra-basic-route-table-private" {
  vpc_id = aws_vpc.infra-basic-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.infra-basic-nat-gateway.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "infra-basic-route-table-private"
  }
}

resource "aws_route_table_association" "infra-basic-route-table-association-public" {
  subnet_id      = aws_subnet.infra-basic-subnet-public.id
  route_table_id = aws_route_table.infra-basic-route-table-public.id
}

resource "aws_route_table_association" "infra-basic-route-table-association-private" {
  subnet_id      = aws_subnet.infra-basic-subnet-private.id
  route_table_id = aws_route_table.infra-basic-route-table-private.id
}

resource "aws_key_pair" "key-pair" {
  key_name   = "key-pair"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_security_group" "infra-basic-security-group" {
  name        = "infra-basic-security-group"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.infra-basic-vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
     from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "infra-basic-security-group"
  }
}

resource "aws_instance" "infra-basic-ec2" {
  ami           = "ami-084568db4383264d4" # Ubuntu 24.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.infra-basic-subnet-public.id
  associate_public_ip_address = true
  key_name      = aws_key_pair.key-pair.key_name
  vpc_security_group_ids = [aws_security_group.infra-basic-security-group.id]

  tags = {
    Name = "infra-basic-ec2"
  }
}

output "ec2_ip" {
  value = aws_instance.infra-basic-ec2.public_ip
}
