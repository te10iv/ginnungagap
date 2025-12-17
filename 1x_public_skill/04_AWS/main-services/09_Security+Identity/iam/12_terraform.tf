# IAMユーザーを作成し、S3への読み取り専用アクセス権限を付与します。

resource "aws_iam_user" "s3_readonly_user" {
  name = "s3-readonly-user"
}

resource "aws_iam_user_policy" "s3_readonly_policy" {
  name = "S3ReadOnlyAccess"
  user = aws_iam_user.s3_readonly_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::/*",
          "arn:aws:s3:::*"
        ]
      }
    ]
  })
}

output "user_name" {
  description = "IAM User Name"
  value       = aws_iam_user.s3_readonly_user.name
}
