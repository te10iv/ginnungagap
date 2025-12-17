# Amazon SQS：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **メッセージ送信**：SendMessage
- **メッセージ受信**：ReceiveMessage
- **メッセージ削除**：DeleteMessage
- **可視性タイムアウト変更**：ChangeMessageVisibility

## よくあるトラブル
### トラブル1：メッセージ重複処理
- 症状：同じメッセージが複数回処理される
- 原因：
  - 標準キューの特性（At-least-once）
  - 可視性タイムアウト不足
  - メッセージ削除失敗
- 確認ポイント：
  - FIFOキュー検討（Exactly-once）
  - 可視性タイムアウト延長
  - 冪等性実装（アプリ側）
  - 処理後必ずメッセージ削除

### トラブル2：メッセージ滞留
- 症状：キューにメッセージが大量蓄積
- 原因：
  - コンシューマー処理遅延
  - コンシューマー停止
  - 処理エラー
- 確認ポイント：
  - CloudWatch Metricsで滞留数確認
  - コンシューマースケールアウト
  - DLQ移動メッセージ確認

### トラブル3：処理失敗ループ
- 症状：同じメッセージが繰り返しエラー
- 原因：
  - バグ（修正不可能なエラー）
  - データ不正
  - DLQ未設定
- 確認ポイント：
  - DLQ設定（maxReceiveCount = 3推奨）
  - DLQメッセージ分析
  - エラーハンドリング改善

## 監視・ログ
- **CloudWatch Metrics**：
  - `ApproximateNumberOfMessagesVisible`：キュー内メッセージ数
  - `ApproximateAgeOfOldestMessage`：最古メッセージ経過時間
  - `NumberOfMessagesSent`：送信数
  - `NumberOfMessagesReceived`：受信数
  - `NumberOfMessagesDeleted`：削除数
- **DLQ監視**：メッセージ蓄積アラート
- **CloudWatch Alarm**：メッセージ滞留監視

## コストでハマりやすい点
- **リクエスト課金**：
  - 標準キュー：$0.40/百万リクエスト
  - FIFOキュー：$0.50/百万リクエスト
- **データ転送料**：リージョン外は課金
- **コスト削減策**：
  - 長期ポーリング使用（短期ポーリングより削減）
  - バッチ処理（最大10メッセージ/リクエスト）
  - 不要なポーリング削減

## 実務Tips
- **長期ポーリング推奨**：`receive_wait_time_seconds = 20`、空ポーリング削減
- **可視性タイムアウト**：処理時間 × 6倍推奨（リトライ考慮）
- **DLQ必須**：maxReceiveCount = 3推奨
- **Lambda統合**：イベントソースマッピング、自動スケール
- **バッチ処理**：最大10メッセージ同時受信・削除
- **メッセージ属性**：メタデータ（タイムスタンプ、ユーザーID等）
- **FIFOキュー**：
  - 順序保証必要な場合
  - メッセージグループID活用
  - 重複排除ID（または content_based_deduplication）
- **標準 vs FIFO選択**：
  - 標準：高スループット、順序不要
  - FIFO：順序・厳密性重要
- **設計時に言語化すると評価が上がるポイント**：
  - 「SQSで非同期処理、疎結合アーキテクチャ、スケーラビリティ確保」
  - 「Lambda統合で自動ポーリング、サーバーレス処理」
  - 「DLQ設定（maxReceiveCount=3）で処理失敗メッセージ分離、エラー分析」
  - 「長期ポーリング（20秒）で空ポーリング削減、コスト最適化」
  - 「FIFOキュー + メッセージグループIDで順序保証、金融取引対応」
  - 「可視性タイムアウト180秒設定、処理時間30秒 × 6倍で安全マージン」
  - 「SNS → SQS ファンアウトでマイクロサービス疎結合、独立スケール」

## メッセージ操作（AWS CLI）

```bash
# メッセージ送信
aws sqs send-message \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/123456789012/standard-queue \
  --message-body "Test message"

# メッセージ属性付き送信
aws sqs send-message \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/123456789012/standard-queue \
  --message-body "Order created" \
  --message-attributes '{
    "orderId": {"DataType":"String", "StringValue":"12345"},
    "timestamp": {"DataType":"Number", "StringValue":"1705305600"}
  }'

# バッチ送信（最大10件）
aws sqs send-message-batch \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/123456789012/standard-queue \
  --entries '[
    {"Id":"1", "MessageBody":"Message 1"},
    {"Id":"2", "MessageBody":"Message 2"}
  ]'

# メッセージ受信
aws sqs receive-message \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/123456789012/standard-queue \
  --max-number-of-messages 10 \
  --wait-time-seconds 20 \
  --attribute-names All \
  --message-attribute-names All

# メッセージ削除
aws sqs delete-message \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/123456789012/standard-queue \
  --receipt-handle "AQEBxxxx..."

# 可視性タイムアウト変更
aws sqs change-message-visibility \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/123456789012/standard-queue \
  --receipt-handle "AQEBxxxx..." \
  --visibility-timeout 600
```

## FIFOキュー操作

```bash
# FIFOメッセージ送信
aws sqs send-message \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/123456789012/orders.fifo \
  --message-body "Order 1" \
  --message-group-id "order-group-1" \
  --message-deduplication-id "unique-id-1"

# Content-based deduplication有効時（重複排除ID不要）
aws sqs send-message \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/123456789012/orders.fifo \
  --message-body "Order 2" \
  --message-group-id "order-group-1"
```

## Lambda統合例（Python）

```python
import json

def lambda_handler(event, context):
    # SQS Records処理
    for record in event['Records']:
        message_body = record['body']
        message_attributes = record.get('messageAttributes', {})
        
        print(f"Processing message: {message_body}")
        
        try:
            # ビジネスロジック
            process_order(json.loads(message_body))
            
        except Exception as e:
            print(f"Error: {e}")
            # 部分バッチ失敗時、失敗したメッセージのみリトライ
            return {
                'batchItemFailures': [{
                    'itemIdentifier': record['messageId']
                }]
            }
    
    return {'statusCode': 200}

def process_order(order):
    # 処理ロジック
    pass
```

## ワーカーパターン（Python）

```python
import boto3
import json
import time

sqs = boto3.client('sqs')
QUEUE_URL = 'https://sqs.ap-northeast-1.amazonaws.com/123456789012/standard-queue'

def worker():
    while True:
        # 長期ポーリング
        response = sqs.receive_message(
            QueueUrl=QUEUE_URL,
            MaxNumberOfMessages=10,
            WaitTimeSeconds=20,
            MessageAttributeNames=['All']
        )
        
        messages = response.get('Messages', [])
        
        for message in messages:
            try:
                # 処理
                process_message(json.loads(message['Body']))
                
                # 成功時、メッセージ削除
                sqs.delete_message(
                    QueueUrl=QUEUE_URL,
                    ReceiptHandle=message['ReceiptHandle']
                )
                
            except Exception as e:
                print(f"Error: {e}")
                # エラー時、可視性タイムアウト延長（リトライ）
                sqs.change_message_visibility(
                    QueueUrl=QUEUE_URL,
                    ReceiptHandle=message['ReceiptHandle'],
                    VisibilityTimeout=600  # 10分後に再試行
                )

def process_message(data):
    # ビジネスロジック
    pass

if __name__ == '__main__':
    worker()
```

## 標準キュー vs FIFOキュー

| 項目 | 標準キュー | FIFOキュー |
|------|---------|----------|
| スループット | 無制限 | 3,000メッセージ/秒 |
| 順序保証 | なし | あり |
| 配信保証 | At-least-once | Exactly-once |
| 重複 | 可能性あり | なし |
| 料金 | $0.40/百万 | $0.50/百万 |
| 用途 | 高スループット | 順序・厳密性重要 |

## 可視性タイムアウトの設計

- **推奨値**：処理時間 × 6倍
  - 処理時間30秒 → 180秒
  - 処理時間1分 → 6分
- **理由**：リトライ・エラー処理時間確保

## DLQ設計

```hcl
# メインキュー
resource "aws_sqs_queue" "main" {
  name = "main-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3  # 3回失敗でDLQ移動
  })
}

# DLQ
resource "aws_sqs_queue" "dlq" {
  name                      = "main-dlq"
  message_retention_seconds = 1209600  # 14日（最大）
}

# DLQアラーム
resource "aws_cloudwatch_metric_alarm" "dlq" {
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
```

## メッセージ滞留監視

```hcl
# メッセージ滞留アラーム
resource "aws_cloudwatch_metric_alarm" "queue_depth" {
  alarm_name          = "sqs-queue-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.main.name
  }
}

# 最古メッセージ経過時間アラーム
resource "aws_cloudwatch_metric_alarm" "oldest_message" {
  alarm_name          = "sqs-oldest-message"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 3600  # 1時間
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.main.name
  }
}
```

## 長期ポーリング vs 短期ポーリング

| 項目 | 長期ポーリング | 短期ポーリング |
|------|-------------|-------------|
| WaitTimeSeconds | 1〜20秒 | 0秒 |
| 空レスポンス | 少ない | 多い |
| コスト | 低い | 高い |
| レイテンシー | やや高い | 低い |
| 推奨 | ✓ | × |
