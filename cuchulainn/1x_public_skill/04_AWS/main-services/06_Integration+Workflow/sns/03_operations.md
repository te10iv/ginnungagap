# Amazon SNS：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **メッセージパブリッシュ**：通知送信
- **サブスクリプション管理**：通知先追加・削除
- **配信ステータス確認**：成功・失敗
- **メッセージフィルタリング**：条件付き配信

## よくあるトラブル
### トラブル1：メールが届かない
- 症状：サブスクリプション追加後、通知なし
- 原因：
  - サブスクリプション未確認
  - 迷惑メール判定
  - メールアドレス誤り
- 確認ポイント：
  - サブスクリプション状態確認（Pending Confirmation）
  - 迷惑メールフォルダ確認
  - 確認メール再送信

### トラブル2：Lambda配信エラー
- 症状：Lambdaが実行されない
- 原因：
  - Lambda権限不足
  - Lambda関数エラー
  - タイムアウト
- 確認ポイント：
  - Lambda権限確認（SNS invoke許可）
  - CloudWatch LogsでLambdaエラー確認
  - 配信失敗ログ確認

### トラブル3：高額なSMS課金
- 症状：月末にSMS課金が数万円
- 原因：
  - 大量SMS送信
  - 国際SMS
  - 不要な通知
- 確認ポイント：
  - SMS送信数確認
  - 必要最小限の通知に制限
  - メール併用検討

## 監視・ログ
- **CloudWatch Metrics**：
  - `NumberOfMessagesPublished`：パブリッシュ数
  - `NumberOfNotificationsDelivered`：配信成功数
  - `NumberOfNotificationsFailed`：配信失敗数
- **配信ステータスログ**：
  - CloudWatch Logsに配信結果記録
  - HTTP/S、Lambda配信のステータス
- **CloudWatch Alarm**：配信失敗率監視

## コストでハマりやすい点
- **パブリッシュ**：$0.50/百万リクエスト
- **配信**：
  - HTTP/S：$0.60/百万リクエスト
  - SMS：$0.074/件〜（国別、高額）
  - メール：$2/10万件
  - モバイルプッシュ：無料
  - Lambda / SQS：無料
- **データ転送料**：リージョン外は課金
- **コスト削減策**：
  - SMS → メール移行
  - 不要な通知削減
  - メッセージフィルタリング活用

## 実務Tips
- **ファンアウトパターン**：SNS → 複数SQS、マイクロサービス分離
- **メッセージフィルタリング**：サブスクリプション別に条件設定
- **配信リトライ**：HTTP/S配信は自動リトライ（最大100回、23日間）
- **デッドレターキュー**：配信失敗メッセージをSQSに保存
- **KMS暗号化**：機密情報含む場合
- **FIFO トピック**：順序保証、重複排除（SQS FIFOと組み合わせ）
- **Lambdaでメール整形**：CloudWatch Alarm → SNS → Lambda → Slack
- **設計時に言語化すると評価が上がるポイント**：
  - 「SNSでファンアウト、1メッセージを複数SQSキューに配信、マイクロサービス疎結合」
  - 「CloudWatch Alarm → SNS → Lambda → Slack、リアルタイム通知自動化」
  - 「メッセージフィルタリングで条件付き配信、不要な通知削減」
  - 「デッドレターキュー設定で配信失敗メッセージ保存、エラー調査」
  - 「KMS暗号化でメッセージ保護、機密情報対応」
  - 「FIFO トピックで順序保証、金融取引等の厳密な順序要件対応」

## メッセージパブリッシュ（AWS CLI）

```bash
# シンプルなメッセージ
aws sns publish \
  --topic-arn arn:aws:sns:ap-northeast-1:123456789012:alerts \
  --message "Test message" \
  --subject "Test Alert"

# 構造化メッセージ（プロトコル別）
aws sns publish \
  --topic-arn arn:aws:sns:ap-northeast-1:123456789012:alerts \
  --message-structure json \
  --message '{
    "default": "Default message",
    "email": "Email: Test alert occurred",
    "sms": "SMS: Alert",
    "lambda": "{\"event\":\"test\",\"severity\":\"high\"}"
  }'

# メッセージ属性付き
aws sns publish \
  --topic-arn arn:aws:sns:ap-northeast-1:123456789012:orders \
  --message "New order received" \
  --message-attributes '{
    "event_type": {"DataType":"String", "StringValue":"order_created"},
    "priority": {"DataType":"Number", "StringValue":"1"}
  }'
```

## メッセージフィルタリング

```hcl
# サブスクリプションフィルタ
resource "aws_sns_topic_subscription" "high_priority_only" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "oncall@example.com"

  filter_policy = jsonencode({
    priority = ["high", "critical"]
  })
}

resource "aws_sns_topic_subscription" "order_events_only" {
  topic_arn = aws_sns_topic.events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.order_processing.arn

  filter_policy = jsonencode({
    event_type = ["order_created", "order_updated"]
  })
}
```

## Lambda統合例（Slack通知）

```python
import json
import urllib.request

SLACK_WEBHOOK_URL = 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'

def lambda_handler(event, context):
    # SNSメッセージ取得
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])
    
    # Slackメッセージ作成
    slack_message = {
        'text': f"🚨 CloudWatch Alarm",
        'attachments': [{
            'color': 'danger',
            'fields': [
                {'title': 'Alarm Name', 'value': sns_message.get('AlarmName', 'N/A'), 'short': True},
                {'title': 'State', 'value': sns_message.get('NewStateValue', 'N/A'), 'short': True},
                {'title': 'Reason', 'value': sns_message.get('NewStateReason', 'N/A')}
            ]
        }]
    }
    
    # Slack送信
    req = urllib.request.Request(
        SLACK_WEBHOOK_URL,
        data=json.dumps(slack_message).encode('utf-8'),
        headers={'Content-Type': 'application/json'}
    )
    urllib.request.urlopen(req)
    
    return {'statusCode': 200}
```

## デッドレターキュー設定

```hcl
# デッドレターキュー
resource "aws_sqs_queue" "dlq" {
  name = "sns-dlq"
}

# SNSトピックにDLQ設定
resource "aws_sns_topic_subscription" "lambda_with_dlq" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.processor.arn

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
  })
}
```

## FIFOトピック + SQS FIFOキュー

```hcl
# FIFOトピック
resource "aws_sns_topic" "orders_fifo" {
  name                        = "orders.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
}

# FIFOキュー
resource "aws_sqs_queue" "orders_fifo" {
  name                        = "orders.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

# サブスクリプション
resource "aws_sns_topic_subscription" "orders_fifo" {
  topic_arn = aws_sns_topic.orders_fifo.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.orders_fifo.arn
}
```

## 配信ステータスログ設定

```hcl
# IAMロール
resource "aws_iam_role" "sns_logging" {
  name = "sns-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "sns_logging" {
  role = aws_iam_role.sns_logging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

# SNSトピックに配信ログ設定（AWS CLIで設定）
# aws sns set-topic-attributes \
#   --topic-arn arn:aws:sns:ap-northeast-1:123456789012:alerts \
#   --attribute-name LambdaSuccessFeedbackRoleArn \
#   --attribute-value arn:aws:iam::123456789012:role/sns-logging-role
```

## SNS vs SQS vs EventBridge

| 項目 | SNS | SQS | EventBridge |
|------|-----|-----|-------------|
| タイプ | Pub/Sub | Queue | Event Bus |
| 配信 | プッシュ | プル | ルール駆動 |
| 永続化 | なし | あり | なし |
| 複数宛先 | ファンアウト | 単一コンシューマー | ルール多数 |
| 順序保証 | FIFO限定 | FIFO限定 | なし |
| 用途 | 通知、ファンアウト | 非同期処理 | イベント駆動 |

## メッセージフィルタポリシー例

```json
{
  "event_type": ["order_created", "order_updated"],
  "amount": [{"numeric": [">=", 10000]}],
  "region": ["us-east-1", "ap-northeast-1"]
}
```

## SMS送信例

```bash
# 単一SMS送信
aws sns publish \
  --phone-number "+81-90-1234-5678" \
  --message "Your verification code: 123456"

# SMSトピック経由
aws sns publish \
  --topic-arn arn:aws:sns:ap-northeast-1:123456789012:critical-alerts \
  --message "Critical alert occurred"
```

## プロトコル別配信料金

| プロトコル | 料金 | 備考 |
|----------|------|------|
| Lambda | 無料 | おすすめ |
| SQS | 無料 | おすすめ |
| HTTP/S | $0.60/百万 | リトライあり |
| メール | $2/10万件 | SMTP推奨 |
| SMS | $0.074/件〜 | 国別、高額 |
| モバイルプッシュ | 無料 | おすすめ |
