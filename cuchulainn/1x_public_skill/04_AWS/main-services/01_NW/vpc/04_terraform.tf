# 基本的なVPCを作成します。プライベートなネットワーク環境を構築します。

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my-vpc"
  }
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my_vpc.id
}
