# VPC Endpoint Serviceを作成し、NLB経由でサービスを公開します。

variable "nlb_arn" {
  description = "Network Load Balancer ARN"
  type        = string
}

resource "aws_vpc_endpoint_service" "my_endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = [var.nlb_arn]

  tags = {
    Name = "my-endpoint-service"
  }
}

output "service_name" {
  description = "VPC Endpoint Service Name"
  value       = aws_vpc_endpoint_service.my_endpoint_service.service_name
}
