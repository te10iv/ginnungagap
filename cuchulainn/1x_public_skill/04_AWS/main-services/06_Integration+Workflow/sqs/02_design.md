# Amazon SQS：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：アクセス制御
  - **Lambda / EC2等**：コンシューマー
  - **CloudWatch**：メトリクス監視
  - **KMS（オプション）**：暗号化

## 内部的な仕組み（ざっくり）
- **なぜSQSが必要なのか**：非同期処理、疎結合、スケーラビリティ
- **標準キュー**：At-least-once（最低1回配信）、順序保証なし、無制限スループット
- **FIFOキュー**：Exactly-once（厳密に1回配信）、順序保証、3000メッセージ/秒
- **可視性タイムアウト**：受信後、他のコンシューマーから見えなくなる時間（デフォルト30秒）
- **制約**：
  - メッセージサイズ：最大256KB
  - 保持期間：1分〜14日（デフォルト4日）
  - FIFOスループット：3000メッセージ/秒

## よくある構成パターン
### パターン1：非同期ジョブ処理
- 構成概要：
  - アプリ → SQS
  - Lambda / EC2ワーカー → SQSポーリング
  - 処理完了後メッセージ削除
- 使う場面：画像処理、レポート生成

### パターン2：SNS → SQS ファンアウト
- 構成概要：
  - SNS → 複数SQSキュー
  - 各キュー独立処理
  - マイクロサービス分離
- 使う場面：イベント駆動アーキテクチャ

### パターン3：優先度キュー
- 構成概要：
  - 高優先度キュー
  - 低優先度キュー
  - ワーカーが高優先度から優先処理
- 使う場面：優先度制御

### パターン4：デッドレターキュー
- 構成概要：
  - メインキュー
  - DLQ（処理失敗メッセージ）
  - アラーム（DLQメッセージ数監視）
- 使う場面：エラーハンドリング

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：SQSは高可用性（マネージド）
- **セキュリティ**：
  - IAMポリシー
  - キューポリシー
  - KMS暗号化
  - VPCエンドポイント
- **コスト**：
  - 標準キュー：$0.40/百万リクエスト
  - FIFOキュー：$0.50/百万リクエスト
  - データ転送料
- **拡張性**：無制限スループット（標準）、3000メッセージ/秒（FIFO）

## 他サービスとの関係
- **Lambda との関係**：イベントソース、自動ポーリング
- **SNS との関係**：ファンアウト
- **EventBridge との関係**：イベント駆動
- **EC2 / ECS との関係**：ワーカー

## Terraformで見るとどうなる？
```hcl
# 標準キュー
resource "aws_sqs_queue" "standard" {
  name                       = "standard-queue"
  delay_seconds              = 0
  max_message_size           = 262144  # 256KB
  message_retention_seconds  = 345600  # 4日
  receive_wait_time_seconds  = 20      # 長期ポーリング
  visibility_timeout_seconds = 30

  # デッドレターキュー設定
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  # KMS暗号化
  kms_master_key_id                 = aws_kms_key.sqs.id
  kms_data_key_reuse_period_seconds = 300

  tags = {
    Name = "standard-queue"
  }
}

# デッドレターキュー
resource "aws_sqs_queue" "dlq" {
  name                      = "dlq"
  message_retention_seconds = 1209600  # 14日

  tags = {
    Name = "dlq"
  }
}

# FIFOキュー
resource "aws_sqs_queue" "fifo" {
  name                        = "orders.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "messageGroup"
  fifo_throughput_limit       = "perMessageGroupId"

  tags = {
    Name = "orders-fifo"
  }
}

# キューポリシー（SNS受信許可）
resource "aws_sqs_queue_policy" "standard" {
  queue_url = aws_sqs_queue.standard.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowSNSPublish"
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.standard.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.main.arn
        }
      }
    }]
  })
}

# Lambda イベントソースマッピング
resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = aws_sqs_queue.standard.arn
  function_name    = aws_lambda_function.processor.arn
  batch_size       = 10
  enabled          = true

  # 部分バッチ失敗時の動作
  function_response_types = ["ReportBatchItemFailures"]

  scaling_config {
    maximum_concurrency = 100
  }
}

# CloudWatch Alarm（DLQメッセージ監視）
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "sqs-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }
}

# VPCエンドポイント
resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}
```

主要リソース：
- `aws_sqs_queue`：キュー
- `aws_sqs_queue_policy`：キューポリシー
- `aws_lambda_event_source_mapping`：Lambda統合
