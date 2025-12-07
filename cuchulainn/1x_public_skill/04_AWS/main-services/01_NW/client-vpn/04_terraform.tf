# Client VPNエンドポイントを作成し、個々のクライアントデバイスからVPCに安全に接続できるようにします。

variable "server_certificate_arn" {
  description = "ACM Server Certificate ARN"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

resource "aws_cloudwatch_log_group" "client_vpn" {
  name              = "/aws/clientvpn"
  retention_in_days = 7
}

resource "aws_ec2_client_vpn_endpoint" "my_client_vpn" {
  description            = "Client VPN endpoint"
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = "10.0.0.0/22"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.server_certificate_arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.client_vpn.name
    cloudwatch_log_stream = "client-vpn-logs"
  }

  dns_servers = ["8.8.8.8"]

  tags = {
    Name = "my-client-vpn"
  }
}

resource "aws_ec2_client_vpn_network_association" "my_client_vpn" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  subnet_id              = var.subnet_id
}

output "client_vpn_endpoint_id" {
  description = "Client VPN Endpoint ID"
  value       = aws_ec2_client_vpn_endpoint.my_client_vpn.id
}
