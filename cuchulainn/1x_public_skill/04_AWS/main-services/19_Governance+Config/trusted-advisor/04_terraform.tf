# Trusted Advisorを確認し、AWS環境のベストプラクティスに基づく推奨事項を確認します（手動での確認が必要）。

# Note: Trusted Advisor cannot be configured via Terraform
# This template is a placeholder - Trusted Advisor is automatically available

output "note" {
  description = "Trusted Advisor is automatically available in AWS Console"
  value       = "Please check Trusted Advisor recommendations in AWS Console"
}
