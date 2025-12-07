# Site-to-Site VPN接続を作成し、オンプレミス環境とVPC間をVPNで接続します。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "customer_gateway_ip" {
  description = "Customer Gateway Public IP Address"
  type        = string
}

variable "static_routes" {
  description = "Static Routes"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

resource "aws_vpn_gateway" "my_vpg" {
  vpc_id = var.vpc_id

  tags = {
    Name = "my-vpg"
  }
}

resource "aws_customer_gateway" "my_cgw" {
  bgp_asn    = 65000
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name = "my-cgw"
  }
}

resource "aws_vpn_connection" "my_vpn_connection" {
  vpn_gateway_id      = aws_vpn_gateway.my_vpg.id
  customer_gateway_id = aws_customer_gateway.my_cgw.id
  type                = "ipsec.1"
  static_routes_only   = true

  tags = {
    Name = "my-vpn-connection"
  }
}

resource "aws_vpn_connection_route" "vpn_route" {
  count                  = length(var.static_routes)
  destination_cidr_block = var.static_routes[count.index]
  vpn_connection_id      = aws_vpn_connection.my_vpn_connection.id
}

output "vpn_connection_id" {
  description = "VPN Connection ID"
  value       = aws_vpn_connection.my_vpn_connection.id
}
