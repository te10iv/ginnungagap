# Transit Gatewayを作成し、複数のVPCを接続します。

resource "aws_ec2_transit_gateway" "my_transit_gateway" {
  description                     = "Transit Gateway for VPC connectivity"
  amazon_side_asn                = 64512
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "my-transit-gateway"
  }
}

output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.my_transit_gateway.id
}
