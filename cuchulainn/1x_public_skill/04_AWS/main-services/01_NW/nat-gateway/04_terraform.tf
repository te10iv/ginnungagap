# NAT Gatewayを作成し、プライベートサブネットからインターネットへのアウトバウンド接続を可能にします。

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
}

variable "private_route_table_id" {
  description = "Private Route Table ID"
  type        = string
}

resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "my-nat-gateway"
  }

  depends_on = [aws_eip.nat_gateway_eip]
}

resource "aws_route" "nat_route" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.my_nat_gateway.id
}
