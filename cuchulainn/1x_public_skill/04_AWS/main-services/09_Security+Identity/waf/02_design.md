# AWS WAF：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **CloudFront / ALB / API Gateway**：保護対象
  - **CloudWatch**：メトリクス・ログ
  - **Kinesis Data Firehose**：ログストリーミング
  - **S3**：ログ保存

## 内部的な仕組み（ざっくり）
- **なぜWAFが必要なのか**：SQLインジェクション、XSS、DDoS等の攻撃対策
- **Web ACL**：ルールのコレクション、リソース保護
- **マネージドルール**：
  - AWS管理：Core Rule Set、Known Bad Inputs等
  - マーケットプレイス：F5、Fortinet等
- **カスタムルール**：独自の条件定義
- **制約**：
  - Web ACL：最大1,500 WCU（Web ACL Capacity Units）
  - ルール数：最大で制限あり

## よくある構成パターン
### パターン1：CloudFront保護
- 構成概要：
  - CloudFront
  - WAF Web ACL
  - AWS管理ルール（Core Rule Set）
  - レートベースルール（1,000リクエスト/5分）
- 使う場面：静的・動的コンテンツ保護

### パターン2：ALB保護
- 構成概要：
  - ALB
  - WAF Web ACL
  - SQLインジェクション対策
  - XSS対策
  - 地域ブロック
- 使う場面：Webアプリケーション保護

### パターン3：API保護
- 構成概要：
  - API Gateway
  - WAF Web ACL
  - レートベースルール
  - IP制限
- 使う場面：REST API保護

### パターン4：多層防御
- 構成概要：
  - CloudFront + WAF（エッジ）
  - ALB + WAF（リージョン）
  - Shield Advanced
- 使う場面：重要システム

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：WAFは高可用性
- **セキュリティ**：
  - マネージドルール推奨
  - レートベースルール必須
  - 地域ブロック検討
  - ログ記録・分析
- **コスト**：
  - Web ACL：$5/月
  - ルール：$1/月
  - リクエスト：$0.60/百万リクエスト
  - マネージドルール：追加料金
- **拡張性**：無制限リクエスト処理

## 他サービスとの関係
- **CloudFront との関係**：グローバル保護
- **ALB との関係**：リージョナル保護
- **Shield との関係**：DDoS対策統合
- **CloudWatch との関係**：メトリクス・アラーム

## Terraformで見るとどうなる？
```hcl
# WAF Web ACL（CloudFront用）
resource "aws_wafv2_web_acl" "cloudfront" {
  name  = "cloudfront-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # AWS管理ルール（Core Rule Set）
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # レートベースルール（DDoS対策）
  rule {
    name     = "RateLimitRule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  # 地域ブロック
  rule {
    name     = "GeoBlockRule"
    priority = 3

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["CN", "RU"]  # 中国・ロシアブロック
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoBlockRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  # IP制限
  rule {
    name     = "IPBlockRule"
    priority = 4

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPBlockRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "CloudFrontWAFMetric"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "cloudfront-waf"
  }
}

# IPセット
resource "aws_wafv2_ip_set" "blocked_ips" {
  name               = "blocked-ips"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  
  addresses = [
    "192.0.2.0/24",
    "198.51.100.0/24"
  ]
}

# CloudFront関連付け
resource "aws_wafv2_web_acl_association" "cloudfront" {
  resource_arn = aws_cloudfront_distribution.main.arn
  web_acl_arn  = aws_wafv2_web_acl.cloudfront.arn
}

# ALB用WAF
resource "aws_wafv2_web_acl" "alb" {
  name  = "alb-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # SQLインジェクション対策
  rule {
    name     = "SQLiProtection"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiProtectionMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ALBWAFMetric"
    sampled_requests_enabled   = true
  }
}

# ALB関連付け
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.alb.arn
}

# ロギング
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  resource_arn = aws_wafv2_web_acl.cloudfront.arn
  log_destination_configs = [
    aws_kinesis_firehose_delivery_stream.waf_logs.arn
  ]
}
```

主要リソース：
- `aws_wafv2_web_acl`：Web ACL
- `aws_wafv2_ip_set`：IPセット
- `aws_wafv2_web_acl_association`：リソース関連付け
