# Amazon EventBridge：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **イベント送信**：PutEvents
- **ルール有効化・無効化**：一時停止
- **テストイベント**：動作確認
- **デッドレターキュー**：失敗イベント保存

## よくあるトラブル
### トラブル1：ターゲットが実行されない
- 症状：イベントは発生するがターゲット未実行
- 原因：
  - イベントパターンミスマッチ
  - IAM権限不足
  - ターゲット設定ミス
- 確認ポイント：
  - イベントパターン確認（CloudWatch Logsでテスト）
  - Lambda / Step Functions権限確認
  - ターゲットARN確認

### トラブル2：スケジュール実行時刻ずれ
- 症状：想定時刻に実行されない
- 原因：
  - UTC / JSTの勘違い
  - cron式ミス
- 確認ポイント：
  - cron式はUTC基準
  - JST 02:00 = UTC 17:00（前日）
  - オンラインcron式ジェネレーター使用

### トラブル3：高額課金
- 症状：月末にEventBridge課金が高額
- 原因：
  - 大量カスタムイベント
  - 不要なイベント送信
- 確認ポイント：
  - AWSサービスイベントは無料
  - カスタムイベント削減
  - イベント集約

## 監視・ログ
- **CloudWatch Metrics**：
  - `Invocations`：ルール実行数
  - `TriggeredRules`：マッチしたルール数
  - `FailedInvocations`：失敗数
- **CloudWatch Logs**：イベント詳細ログ（オプション）
- **DLQ**：失敗イベント保存

## コストでハマりやすい点
- **カスタムイベント**：$1.00/百万イベント
- **サードパーティー**：$1.00/百万イベント
- **AWSサービスイベント**：無料
- **ターゲット実行**：無料
- **コスト削減策**：
  - AWSサービスイベント活用（無料）
  - 不要なカスタムイベント削減
  - イベントバッチ化

## 実務Tips
- **イベントパターン設計**：JSONパスで柔軟なフィルタリング
- **スケジュール設定**：
  - cron式（柔軟）：`cron(0 17 * * ? *)`
  - rate式（シンプル）：`rate(1 hour)`
  - **注意**：UTC基準
- **複数ターゲット**：1イベントで複数処理（最大20）
- **デッドレターキュー**：失敗イベント分析
- **リトライポリシー**：最大2回リトライ推奨
- **カスタムイベントバス**：マイクロサービス分離
- **API Destination**：外部HTTPエンドポイント統合
- **設計時に言語化すると評価が上がるポイント**：
  - 「EventBridgeでイベント駆動アーキテクチャ、マイクロサービス疎結合」
  - 「スケジュールルールで定期バッチ実行、cron式で柔軟な時刻設定」
  - 「1イベントで複数ターゲット実行、並列処理で効率化」
  - 「デッドレターキュー設定で失敗イベント保存、エラー分析」
  - 「カスタムイベントバスでサービス分離、マルチテナント対応」
  - 「API Destinationで外部Webhook統合、SaaS連携」
  - 「AWSサービスイベント活用で無料イベント駆動、コスト最適化」

## イベント送信（AWS CLI）

```bash
# カスタムイベント送信
aws events put-events \
  --entries '[
    {
      "Source": "myapp.orders",
      "DetailType": "Order Created",
      "Detail": "{\"orderId\":\"12345\",\"amount\":10000}",
      "EventBusName": "custom-event-bus"
    }
  ]'

# 複数イベント送信（最大10件）
aws events put-events \
  --entries '[
    {
      "Source": "myapp.orders",
      "DetailType": "Order Created",
      "Detail": "{\"orderId\":\"1\"}"
    },
    {
      "Source": "myapp.orders",
      "DetailType": "Order Updated",
      "Detail": "{\"orderId\":\"2\"}"
    }
  ]'
```

## イベントパターン例

### EC2インスタンス状態変更
```json
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["stopped", "terminated"]
  }
}
```

### S3オブジェクト作成
```json
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["my-bucket"]
    }
  }
}
```

### CloudTrail API呼び出し
```json
{
  "source": ["aws.cloudtrail"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["StopInstance", "TerminateInstances"],
    "userIdentity": {
      "type": ["Root"]
    }
  }
}
```

### カスタムイベント
```json
{
  "source": ["myapp.orders"],
  "detail-type": ["Order Created", "Order Updated"],
  "detail": {
    "amount": [{"numeric": [">=", 10000]}],
    "status": ["confirmed"]
  }
}
```

## cron式例

| 説明 | cron式 |
|------|--------|
| 毎日2時（JST） | `cron(0 17 * * ? *)` |
| 毎時0分 | `cron(0 * * * ? *)` |
| 平日9時（JST） | `cron(0 0 ? * MON-FRI *)` |
| 毎月1日0時 | `cron(0 0 1 * ? *)` |
| 毎週日曜2時 | `cron(0 17 ? * SUN *)` |

**rate式例**：
- 1時間ごと：`rate(1 hour)`
- 30分ごと：`rate(30 minutes)`
- 1日ごと：`rate(1 day)`

## Lambda統合例（Python）

```python
def lambda_handler(event, context):
    # EventBridgeイベント取得
    print(f"Event: {event}")
    
    source = event.get('source')
    detail_type = event.get('detail-type')
    detail = event.get('detail')
    
    if source == 'myapp.orders':
        if detail_type == 'Order Created':
            process_order_created(detail)
        elif detail_type == 'Order Updated':
            process_order_updated(detail)
    
    return {'statusCode': 200}

def process_order_created(detail):
    order_id = detail['orderId']
    print(f"Processing new order: {order_id}")
```

## カスタムイベント送信例（Python）

```python
import boto3
import json

events = boto3.client('events')

def send_order_event(order_id, amount):
    response = events.put_events(
        Entries=[
            {
                'Source': 'myapp.orders',
                'DetailType': 'Order Created',
                'Detail': json.dumps({
                    'orderId': order_id,
                    'amount': amount,
                    'timestamp': '2024-01-15T12:00:00Z'
                }),
                'EventBusName': 'custom-event-bus'
            }
        ]
    )
    print(f"Event sent: {response}")
```

## ルール有効化・無効化

```bash
# ルール無効化（一時停止）
aws events disable-rule --name daily-batch

# ルール有効化
aws events enable-rule --name daily-batch

# ルール削除
aws events remove-targets --rule daily-batch --ids lambda
aws events delete-rule --name daily-batch
```

## EventBridge vs SNS vs SQS

| 項目 | EventBridge | SNS | SQS |
|------|------------|-----|-----|
| タイプ | Event Bus | Pub/Sub | Queue |
| フィルタリング | イベントパターン | メッセージ属性 | なし |
| ターゲット | 20個 | 無制限 | 1個 |
| スケジュール | あり | なし | なし |
| AWSサービス統合 | 強力 | 限定的 | 限定的 |
| 料金 | $1/百万（カスタム） | $0.50/百万 | $0.40/百万 |
| 用途 | イベント駆動 | 通知・ファンアウト | 非同期処理 |

## スケジュール vs Lambda cron

| 項目 | EventBridge | Lambda cron |
|------|------------|------------|
| 設定場所 | EventBridge | CloudFormation/Terraform |
| 変更 | GUIで簡単 | デプロイ必要 |
| 複雑なスケジュール | 対応 | 対応 |
| コスト | 無料 | 無料 |
| 推奨 | ✓ | △ |

## クロスアカウントイベント送信

```bash
# 送信側（アカウントA）
aws events put-events \
  --entries '[
    {
      "Source": "myapp.orders",
      "DetailType": "Order Created",
      "Detail": "{\"orderId\":\"12345\"}",
      "EventBusName": "arn:aws:events:ap-northeast-1:123456789012:event-bus/custom-event-bus"
    }
  ]'
```

## API Destination設定例

```hcl
# 接続（認証情報）
resource "aws_cloudwatch_event_connection" "slack" {
  name               = "slack-connection"
  authorization_type = "OAUTH_CLIENT_CREDENTIALS"

  auth_parameters {
    oauth {
      authorization_endpoint = "https://slack.com/oauth/authorize"
      http_method           = "POST"
      
      client_parameters {
        client_id     = "your-client-id"
        client_secret = "your-client-secret"
      }
    }
  }
}

# API Destination
resource "aws_cloudwatch_event_api_destination" "slack" {
  name                             = "slack-destination"
  invocation_endpoint              = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  http_method                      = "POST"
  invocation_rate_limit_per_second = 10
  connection_arn                   = aws_cloudwatch_event_connection.slack.arn
}
```
