# VPC内にパブリックサブネットとプライベートサブネットを作成します。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = var.vpc_id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = var.vpc_id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-1a"
  }
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = aws_subnet.private_subnet.id
}
