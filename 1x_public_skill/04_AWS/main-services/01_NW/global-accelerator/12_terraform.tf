# Global Acceleratorを作成し、複数リージョンのエンドポイントにグローバルにアクセスできるようにします。

variable "alb_arn" {
  description = "Application Load Balancer ARN"
  type        = string
}

resource "aws_globalaccelerator_accelerator" "my_accelerator" {
  name            = "my-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

  tags = {
    Name = "my-accelerator"
  }
}

resource "aws_globalaccelerator_listener" "my_listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.my_accelerator.id
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "my_endpoint_group" {
  listener_arn = aws_globalaccelerator_listener.my_listener.id

  endpoint_configuration {
    endpoint_id = var.alb_arn
    weight      = 100
  }

  health_check_protocol            = "TCP"
  health_check_port                = 80
  health_check_interval_seconds    = 30
  health_check_path                = "/"
  threshold_count                  = 3
}

output "accelerator_dns_name" {
  description = "Global Accelerator DNS Name"
  value       = aws_globalaccelerator_accelerator.my_accelerator.dns_name
}
