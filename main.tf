terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  single_nat_gateway   = true
  tags = {
    Name = "main-vpc"
  }
}

# subnets
resource "aws_subnet" "main-public-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "main-public-1"
  }
}

resource "aws_subnet" "main-private-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2a"
  tags = {
    Name = "main-private-1"
  }
}

resource "aws_subnet" "main-public-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
  tags = {
    Name = "main-public-2"
  }
}

resource "aws_subnet" "main-private-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.12.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2b"
  tags = {
    Name = "main-private-2"
  }
}

resource "aws_subnet" "main-public-3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
  tags = {
    Name = "main-public-3"
  }
}

resource "aws_subnet" "main-private-3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.13.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2b"
  tags = {
    Name = "main-private-3"
  }
}

# gateway
resource "aws_internet_gateway" "main-gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-gateway"
  }
}

# route table
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gateway.id
  }
  tags = {
    Name = "main-public-1"
  }
}

#route_associations_public
resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = "${aws_subnet.main-public-1.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_route_table_association" "main-public-2-b" {
    subnet_id = "${aws_subnet.main-public-2.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_route_table_association" "main-public-3-b" {
    subnet_id = "${aws_subnet.main-public-3.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "nat-gateway-eip" {
  depends_on = [
    aws_route_table_association.RT-IG-Association
  ]
  vpc        = true
}

# Creating a NAT Gateway!
resource "aws_nat_gateway" "nat-gateway" {

  depends_on = [
    aws_eip.nat-gateway-eip
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.nat-gateway-eip.id

  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.subnet1.id
  tags = {
    Name = "main-nat-gateway"
  }
}
