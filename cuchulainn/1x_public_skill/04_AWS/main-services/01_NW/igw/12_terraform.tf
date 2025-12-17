# インターネットゲートウェイを作成し、VPCにアタッチします。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "my-igw"
  }
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.my_igw.id
}
