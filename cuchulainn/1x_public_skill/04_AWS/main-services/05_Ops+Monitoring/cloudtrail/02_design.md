# AWS CloudTrail：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **S3**：ログ保存先
  - **CloudWatch Logs（オプション）**：リアルタイム分析
  - **KMS（オプション）**：ログ暗号化
  - **SNS（オプション）**：ログ配信通知

## 内部的な仕組み（ざっくり）
- **なぜCloudTrailが必要なのか**：監査、コンプライアンス、セキュリティ分析
- **API操作記録**：誰が（IAMユーザー）、いつ（timestamp）、何を（API呼び出し）
- **イベントタイプ**：
  - **管理イベント**：リソース操作（EC2起動、S3バケット作成等）
  - **データイベント**：S3オブジェクト操作、Lambda実行
  - **Insightsイベント**：異常なAPI活動検知
- **制約**：
  - イベント履歴：過去90日まで無料
  - 証跡作成で長期保存

## よくある構成パターン
### パターン1：基本監査
- 構成概要：
  - 証跡作成（全リージョン）
  - S3：ログ長期保存
  - 管理イベントのみ
- 使う場面：標準的な監査

### パターン2：セキュリティ監視
- 構成概要：
  - CloudWatch Logs統合
  - メトリクスフィルター：不審な操作検知
  - アラーム：ルートユーザー使用、IAMポリシー変更
  - EventBridge：自動対応
- 使う場面：セキュリティ強化

### パターン3：データイベント監視
- 構成概要：
  - データイベント有効化
  - S3オブジェクト操作記録
  - Lambda実行記録
  - 機密データアクセス監査
- 使う場面：コンプライアンス

### パターン4：マルチアカウント集約
- 構成概要：
  - Organizations統合
  - 組織証跡（全アカウント）
  - 中央S3バケット
  - Athena：横断分析
- 使う場面：大規模環境

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：CloudTrailは高可用性（マネージド）
- **セキュリティ**：
  - S3バケットポリシー
  - ログファイル検証
  - KMS暗号化
  - MFA Delete（S3バケット）
- **コスト**：
  - 管理イベント：最初の証跡無料、2つ目以降 $2/10万イベント
  - データイベント：$0.10/10万イベント
  - Insightsイベント：$0.35/10万書き込みイベント
  - S3保存料
- **拡張性**：全API記録、無制限

## 他サービスとの関係
- **CloudWatch Logs との関係**：リアルタイム分析、メトリクスフィルター
- **EventBridge との関係**：特定イベント検知、自動対応
- **Athena との関係**：SQLクエリでログ分析
- **GuardDuty との関係**：脅威検知

## Terraformで見るとどうなる？
```hcl
# S3バケット（ログ保存先）
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "cloudtrail-logs-12345"

  tags = {
    Name = "cloudtrail-logs"
  }
}

# S3バケットポリシー
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail証跡
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  # KMS暗号化
  kms_key_id = aws_kms_key.cloudtrail.arn

  # CloudWatch Logs統合
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch.arn

  # データイベント（S3）
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.sensitive.arn}/*"]
    }
  }

  # データイベント（Lambda）
  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda:*:*:function/*"]
    }
  }

  # Insightsイベント
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  tags = {
    Name = "main-trail"
  }
}

# CloudWatch Logsロググループ
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/main"
  retention_in_days = 30
}

# メトリクスフィルター（ルートユーザー使用検知）
resource "aws_cloudwatch_log_metric_filter" "root_usage" {
  name           = "root-user-usage"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = '{ $.userIdentity.type = "Root" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != "AwsServiceEvent" }'

  metric_transformation {
    name      = "RootUserUsageCount"
    namespace = "CloudTrail"
    value     = "1"
  }
}

# アラーム（ルートユーザー使用）
resource "aws_cloudwatch_metric_alarm" "root_usage" {
  alarm_name          = "root-user-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RootUserUsageCount"
  namespace           = "CloudTrail"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}

# Organizations証跡（全アカウント）
resource "aws_cloudtrail" "organization" {
  name                          = "organization-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
}
```

主要リソース：
- `aws_cloudtrail`：証跡
- `aws_cloudwatch_log_metric_filter`：メトリクスフィルター
- `aws_s3_bucket`：ログ保存先
