# Amazon CloudWatch：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **各AWSサービス**：メトリクス送信元
  - **SNS**：アラーム通知
  - **Lambda**：自動対応
  - **EventBridge**：イベント駆動

## 内部的な仕組み（ざっくり）
- **なぜCloudWatchが必要なのか**：リソース監視、異常検知、自動対応
- **メトリクスデータ**：時系列データ、最大15ヶ月保持
- **名前空間**：AWS/EC2、AWS/RDS等
- **ディメンション**：メトリクス識別（InstanceId等）
- **制約**：
  - 標準メトリクス：5分間隔（詳細は1分）
  - カスタムメトリクス：最高解像度1秒

## よくある構成パターン
### パターン1：基本監視（EC2）
- 構成概要：
  - EC2標準メトリクス：CPU、ネットワーク
  - アラーム：CPU > 80%
  - SNS：メール通知
- 使う場面：標準的な監視

### パターン2：詳細監視 + 自動対応
- 構成概要：
  - 詳細監視（1分間隔）
  - アラーム：ディスク使用率 > 90%
  - Lambda：自動ログ削除
- 使う場面：自動運用

### パターン3：複合メトリクス
- 構成概要：
  - メトリクス演算
  - 例：リクエスト成功率 = 成功数 / 総数
  - アラーム：成功率 < 95%
- 使う場面：SLI/SLO監視

### パターン4：統合ダッシュボード
- 構成概要：
  - 複数リージョン
  - 複数アカウント
  - クロスアカウントダッシュボード
- 使う場面：マルチアカウント環境

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：CloudWatchは高可用性（マネージド）
- **セキュリティ**：
  - IAMロール最小権限
  - カスタムメトリクスの認証
- **コスト**：
  - 標準メトリクス：無料（AWS提供）
  - カスタムメトリクス：$0.30/メトリクス/月
  - アラーム：$0.10/アラーム/月（標準）
  - API呼び出し課金
- **拡張性**：無制限メトリクス

## 他サービスとの関係
- **SNS との関係**：アラーム通知先
- **Lambda との関係**：アラーム時の自動対応
- **EventBridge との関係**：イベントルール
- **Auto Scaling との関係**：スケーリングトリガー

## Terraformで見るとどうなる？
```hcl
# CloudWatchアラーム（CPU）
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5分
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU usage is above 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.web.id
  }
}

# SNSトピック
resource "aws_sns_topic" "alerts" {
  name = "cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "alerts@example.com"
}

# カスタムメトリクス（Lambda統合）
resource "aws_cloudwatch_metric_alarm" "custom_metric" {
  alarm_name          = "custom-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorRate"
  namespace           = "MyApp"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_actions       = [aws_lambda_function.auto_remediate.arn]

  dimensions = {
    Environment = "production"
  }
}

# 複合メトリクス（メトリクス演算）
resource "aws_cloudwatch_metric_alarm" "success_rate" {
  alarm_name          = "api-success-rate-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 95

  metric_query {
    id          = "success_rate"
    expression  = "success / total * 100"
    label       = "Success Rate"
    return_data = true
  }

  metric_query {
    id = "success"
    metric {
      metric_name = "2xxCount"
      namespace   = "AWS/ApiGateway"
      period      = 300
      stat        = "Sum"
      dimensions = {
        ApiName = "my-api"
      }
    }
  }

  metric_query {
    id = "total"
    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = 300
      stat        = "Sum"
      dimensions = {
        ApiName = "my-api"
      }
    }
  }
}

# ダッシュボード
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "main-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average" }]
          ]
          period = 300
          region = "ap-northeast-1"
          title  = "EC2 CPU Utilization"
        }
      }
    ]
  })
}
```

主要リソース：
- `aws_cloudwatch_metric_alarm`：アラーム
- `aws_cloudwatch_dashboard`：ダッシュボード
- `aws_cloudwatch_log_metric_filter`：ログメトリクス
