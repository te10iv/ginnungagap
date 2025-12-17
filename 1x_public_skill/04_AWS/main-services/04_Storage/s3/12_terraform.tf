# S3バケットを作成し、静的ウェブサイトをホスティングできるようにします。

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "my_website_bucket" {
  bucket = "my-website-bucket-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "my_website_bucket" {
  bucket = aws_s3_bucket.my_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "my_website_bucket" {
  bucket = aws_s3_bucket.my_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "my_website_bucket" {
  bucket = aws_s3_bucket.my_website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.my_website_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.my_website_bucket]
}

output "bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.my_website_bucket.id
}

output "website_url" {
  description = "Website URL"
  value       = aws_s3_bucket_website_configuration.my_website_bucket.website_endpoint
}
