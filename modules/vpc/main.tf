# Creates a new Virtual Private Cloud (VPC) with DNS support enabled.
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      "Name" = "vpc-${var.env}-${var.project_name}-fargate"
    },
    var.tags
  )
}

# Creates the first public subnet in the specified availability zone.
resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet1_cidr_block
  availability_zone = var.availability_zone1

  tags = merge(
    {
      "Name" = "public_subnet1-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Creates the second public subnet in another availability zone.
resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet2_cidr_block
  availability_zone = var.availability_zone2

  tags = merge(
    {
      "Name" = "public_subnet2-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Creates the first private subnet.
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet1_cidr_block
  availability_zone = var.availability_zone1

  tags = merge(
    {
      "Name" = "private_subnet1-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Creates the second private subnet.
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet2_cidr_block
  availability_zone = var.availability_zone2

  tags = merge(
    {
      "Name" = "private_subnet2-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Creates an Internet Gateway to allow public internet access.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "igw-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Creates a public route table1 with a route to the Internet Gateway.
resource "aws_route_table" "public_rtb1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      "Name" = "public_rtb1-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Creates a public route table2 with a route to the Internet Gateway.
resource "aws_route_table" "public_rtb2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      "Name" = "public_rtb2-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Associates the first public subnet with the public route table.
resource "aws_route_table_association" "public_subnet1_public_rtb1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rtb1.id
}

# Associates the second public subnet with the public route table.
resource "aws_route_table_association" "public_subnet2_public_rtb2_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rtb2.id
}

# Creates a private route table for private_subnet1 (initially without routes).
resource "aws_route_table" "private_rtb1" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "private_rtb1-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Creates a private route table for private_subnet2 (initially without routes).
resource "aws_route_table" "private_rtb2" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "private_rtb2-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Allocates a static Elastic IP for the first NAT Gateway.
resource "aws_eip" "eip1" {
  domain = "vpc"

  tags = merge(
    {
      "Name" = "eip1-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Allocates a static Elastic IP for the second NAT Gateway.
resource "aws_eip" "eip2" {
  domain = "vpc"

  tags = merge(
    {
      "Name" = "eip2-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Creates the first NAT Gateway in public_subnet1.
resource "aws_nat_gateway" "nat_gtw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = merge(
    {
      "Name" = "nat_gtw1-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Creates the second NAT Gateway in public_subnet2.
resource "aws_nat_gateway" "nat_gtw2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet2.id

  tags = merge(
    {
      "Name" = "nat_gtw2-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}

# Adds a default route to the first private route table through nat_gtw1.
resource "aws_route" "private_rtb1_nat_gtw1" {
  route_table_id         = aws_route_table.private_rtb1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gtw1.id
}

# Adds a default route to the second private route table through nat_gtw2.
resource "aws_route" "private_rtb2_nat_gtw2" {
  route_table_id         = aws_route_table.private_rtb2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gtw2.id
}

# Associates private_subnet1 with private route table 1.
resource "aws_route_table_association" "private_subnet1_rtb_association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rtb1.id
}

# Associates private_subnet2 with private route table 2.
resource "aws_route_table_association" "private_subnet2_rtb_association" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rtb2.id
}

# Creates a default security group allowing all inbound/outbound traffic from/to self (not recommended for production).
resource "aws_security_group" "default" {
  name        = "sg_vpc-${var.env}-${var.project_name}-fargate"
  description = "Allow all traffic within group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  tags = merge(
    {
      "Name" = "sg_vpc-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )
}
