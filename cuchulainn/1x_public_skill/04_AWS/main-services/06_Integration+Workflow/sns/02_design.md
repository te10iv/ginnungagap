# Amazon SNS：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：アクセス制御
  - **Lambda / SQS / HTTP等**：サブスクライバー
  - **CloudWatch**：メトリクス監視
  - **KMS（オプション）**：暗号化

## 内部的な仕組み（ざっくり）
- **なぜSNSが必要なのか**：非同期通知、ファンアウト、疎結合
- **Pub/Sub型**：1パブリッシャー、複数サブスクライバー
- **ファンアウト**：1メッセージを複数宛先に同時配信
- **配信保証**：At-least-once（最低1回配信）
- **制約**：
  - メッセージサイズ：最大256KB
  - SMS：国・リージョン制限あり

## よくある構成パターン
### パターン1：CloudWatchアラーム通知
- 構成概要：
  - CloudWatch Alarm → SNS
  - SNS → メール、Slack（Lambda経由）
  - アラーム即時通知
- 使う場面：運用監視

### パターン2：ファンアウト（SNS → SQS）
- 構成概要：
  - アプリ → SNS
  - SNS → 複数SQSキュー（注文処理、在庫更新、通知）
  - 各キューを独立処理
- 使う場面：マイクロサービス

### パターン3：イベント駆動（S3 → SNS → Lambda）
- 構成概要：
  - S3イベント → SNS
  - SNS → 複数Lambda（画像リサイズ、サムネイル生成）
  - 並列処理
- 使う場面：イベント駆動アーキテクチャ

### パターン4：モバイルプッシュ通知
- 構成概要：
  - アプリ → SNS
  - SNS → APNs / FCM
  - モバイル端末にプッシュ通知
- 使う場面：モバイルアプリ

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：SNSは高可用性（マネージド）
- **セキュリティ**：
  - IAMポリシー
  - トピックポリシー
  - KMS暗号化
  - HTTPS エンドポイント
- **コスト**：
  - パブリッシュ：$0.50/百万リクエスト
  - HTTP/S配信：$0.60/百万リクエスト
  - SMS：$0.074/件〜（国別）
  - モバイルプッシュ：無料
- **拡張性**：無制限スループット

## 他サービスとの関係
- **CloudWatch との関係**：アラーム通知先
- **Lambda との関係**：イベント駆動処理
- **SQS との関係**：ファンアウト、メッセージ永続化
- **EventBridge との関係**：イベントルーティング

## Terraformで見るとどうなる？
```hcl
# SNSトピック
resource "aws_sns_topic" "alerts" {
  name              = "cloudwatch-alerts"
  display_name      = "CloudWatch Alerts"
  kms_master_key_id = aws_kms_key.sns.id

  tags = {
    Name = "cloudwatch-alerts"
  }
}

# メールサブスクリプション
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "alerts@example.com"
}

# Lambdaサブスクリプション
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notify_slack.arn
}

# Lambda権限
resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_slack.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

# SQSサブスクリプション（ファンアウト）
resource "aws_sns_topic_subscription" "order_queue" {
  topic_arn = aws_sns_topic.orders.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.order_processing.arn
}

resource "aws_sns_topic_subscription" "inventory_queue" {
  topic_arn = aws_sns_topic.orders.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.inventory_update.arn
}

# SQSキューポリシー（SNS受信許可）
resource "aws_sqs_queue_policy" "order_queue" {
  queue_url = aws_sqs_queue.order_processing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.order_processing.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.orders.arn
        }
      }
    }]
  })
}

# トピックポリシー
resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudWatchAlarms"
      Effect = "Allow"
      Principal = {
        Service = "cloudwatch.amazonaws.com"
      }
      Action   = "SNS:Publish"
      Resource = aws_sns_topic.alerts.arn
    }]
  })
}

# SMSサブスクリプション
resource "aws_sns_topic_subscription" "sms" {
  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "sms"
  endpoint  = "+81-90-1234-5678"
}

# HTTPSサブスクリプション
resource "aws_sns_topic_subscription" "webhook" {
  topic_arn = aws_sns_topic.events.arn
  protocol  = "https"
  endpoint  = "https://example.com/webhook"
}

# FIFOトピック（順序保証）
resource "aws_sns_topic" "orders_fifo" {
  name                        = "orders.fifo"
  fifo_topic                  = true
  content_based_deduplication = true

  tags = {
    Name = "orders-fifo"
  }
}

# データ保護ポリシー（PII削除）
resource "aws_sns_data_protection_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Name    = "DenyInboundEmailAddress"
    Version = "2021-06-01"
    Statement = [{
      DataDirection = "Inbound"
      DataIdentifier = [
        "arn:aws:dataprotection::aws:data-identifier/EmailAddress"
      ]
      Operation = {
        Deny = {}
      }
      Principal = ["*"]
      Sid       = "DenyEmailAddress"
    }]
  })
}
```

主要リソース：
- `aws_sns_topic`：トピック
- `aws_sns_topic_subscription`：サブスクリプション
- `aws_sns_topic_policy`：トピックポリシー
