# KMSカスタマーマネージドキー（CMK）を作成し、S3バケットの暗号化に使用します。

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "my_encryption_key" {
  description             = "Encryption key for S3"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "my-encryption-key"
  }
}

resource "aws_kms_alias" "my_encryption_key" {
  name          = "alias/my-encryption-key"
  target_key_id = aws_kms_key.my_encryption_key.key_id
}

output "key_id" {
  description = "KMS Key ID"
  value       = aws_kms_key.my_encryption_key.id
}

output "key_arn" {
  description = "KMS Key ARN"
  value       = aws_kms_key.my_encryption_key.arn
}
