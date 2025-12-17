# Route 53でホストゾーンを作成し、ドメイン名のDNSレコードを設定します。

variable "domain_name" {
  description = "Domain name (e.g., example.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB Hosted Zone ID"
  type        = string
}

resource "aws_route53_zone" "my_hosted_zone" {
  name = var.domain_name

  tags = {
    Name = var.domain_name
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.my_hosted_zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

output "hosted_zone_id" {
  description = "Hosted Zone ID"
  value       = aws_route53_zone.my_hosted_zone.zone_id
}

output "name_servers" {
  description = "Name Servers"
  value       = aws_route53_zone.my_hosted_zone.name_servers
}
