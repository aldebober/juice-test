provider "aws" {
  region = var.region
  profile = var.profile
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.${var.segment}.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-rtb-public"
  }
}

resource "aws_route" "public-igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_internet_gateway.igw]
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_s3_bucket" "kops-bucket" {
  bucket = "${var.project}-kops-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags   = {
    Name = "Source bucket"
  }
}

