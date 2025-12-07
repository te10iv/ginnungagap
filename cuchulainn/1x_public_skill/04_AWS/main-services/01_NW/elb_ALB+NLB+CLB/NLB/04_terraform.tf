# Network Load Balancerを作成し、TCP/UDPトラフィックを複数のターゲットに分散します。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs (at least 2 subnets in different AZs)"
  type        = list(string)
}

resource "aws_lb" "my_nlb" {
  name               = "my-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  tags = {
    Name = "my-nlb"
  }
}

resource "aws_lb_target_group" "my_nlb_target_group" {
  name     = "my-nlb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = 80
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "my_nlb_listener" {
  load_balancer_arn = aws_lb.my_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_nlb_target_group.arn
  }
}

output "load_balancer_dns" {
  description = "Network Load Balancer DNS Name"
  value       = aws_lb.my_nlb.dns_name
}
