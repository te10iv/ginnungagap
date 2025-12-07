# S3バケットにライフサイクルポリシーを設定し、古いオブジェクトを自動的にGlacierに移行します。

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "archive_bucket" {
  bucket = "my-archive-bucket-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_lifecycle_configuration" "archive_bucket" {
  bucket = aws_s3_bucket.archive_bucket.id

  rule {
    id     = "glacier-archive-rule"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}

output "bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.archive_bucket.id
}
