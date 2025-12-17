# CloudFrontディストリビューションを作成し、S3バケットのコンテンツを高速配信できるようにします。

variable "s3_bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}

data "aws_region" "current" {}

resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = "${var.s3_bucket_name}.s3.${data.aws_region.current.name}.amazonaws.com"
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "CloudFront distribution for S3"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "distribution_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.my_distribution.domain_name
}
