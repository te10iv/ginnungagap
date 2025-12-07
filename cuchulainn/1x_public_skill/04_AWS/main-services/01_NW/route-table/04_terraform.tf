# パブリックサブネット用のカスタムルートテーブルを作成し、インターネットゲートウェイへのルートを追加します。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
}

resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = var.public_subnet_id
  route_table_id = aws_route_table.public_route_table.id
}

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = aws_route_table.public_route_table.id
}
