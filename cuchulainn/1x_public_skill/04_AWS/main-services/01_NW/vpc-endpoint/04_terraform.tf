# VPC Endpoint（Gateway型）を作成し、プライベートサブネットからS3にプライベート接続できるようにします。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "route_table_id" {
  description = "Private Route Table ID"
  type        = string
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_id]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "s3-endpoint"
  }
}

output "vpc_endpoint_id" {
  description = "VPC Endpoint ID"
  value       = aws_vpc_endpoint.s3_endpoint.id
}
