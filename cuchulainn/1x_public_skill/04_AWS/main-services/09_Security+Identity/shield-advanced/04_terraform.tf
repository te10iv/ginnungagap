# Shield Advancedを有効化し、リソースを保護します（有料サービス、年間契約が必要）。

# Note: Shield Advanced subscription cannot be created via Terraform
# This template shows the structure but requires manual subscription activation

variable "resource_arn" {
  description = "Resource ARN to protect (e.g., CloudFront distribution)"
  type        = string
}

resource "aws_shield_protection" "my_shield_protection" {
  name         = "my-shield-protection"
  resource_arn = var.resource_arn

  tags = {
    Name = "my-shield-protection"
  }
}

output "protection_id" {
  description = "Shield Protection ID"
  value       = aws_shield_protection.my_shield_protection.id
}
