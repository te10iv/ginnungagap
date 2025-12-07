# Direct Connect接続をリクエストします（実際の接続には通信事業者との契約が必要）。

variable "location" {
  description = "Direct Connect Location"
  type        = string
}

variable "bandwidth" {
  description = "Connection Bandwidth"
  type        = string
  default     = "1Gbps"
}

variable "connection_name" {
  description = "Connection Name"
  type        = string
  default     = "my-direct-connect"
}

resource "aws_dx_connection" "my_direct_connect" {
  name      = var.connection_name
  bandwidth = var.bandwidth
  location  = var.location
}

output "connection_id" {
  description = "Direct Connect Connection ID"
  value       = aws_dx_connection.my_direct_connect.id
}
