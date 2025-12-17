# WAF Web ACLを作成し、CloudFrontディストリビューションを保護します。

variable "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  type        = string
}

resource "aws_wafv2_web_acl" "my_web_acl" {
  name  = "my-web-acl"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "my-web-acl-metric"
    sampled_requests_enabled   = true
  }
}

output "web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.my_web_acl.arn
}
