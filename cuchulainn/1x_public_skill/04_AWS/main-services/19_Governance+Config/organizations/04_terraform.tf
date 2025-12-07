# AWS Organizationsを有効化し、複数のAWSアカウントを一元管理します（手動での有効化が必要な場合があります）。

# Note: Organizations cannot be fully created via Terraform
# This template shows the structure but may require manual setup

resource "aws_organizations_organization" "my_organization" {
  feature_set = "ALL"
}

output "organization_id" {
  description = "Organizations ID"
  value       = aws_organizations_organization.my_organization.id
}
