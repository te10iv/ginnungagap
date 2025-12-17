# Amazon EventBridge：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：アクセス制御
  - **Lambda / Step Functions等**：ターゲット
  - **CloudWatch**：メトリクス監視
  - **SaaS統合**：Salesforce、Zendesk等

## 内部的な仕組み（ざっくり）
- **なぜEventBridgeが必要なのか**：イベント駆動、疎結合、SaaS統合
- **イベントバス**：default、カスタム、パートナー
- **イベントパターンマッチング**：JSONパスでフィルタリング
- **最大20ターゲット**：1ルールから複数ターゲット
- **制約**：
  - イベントサイズ：最大256KB
  - ターゲット：最大5個/ルール（標準）、最大20個/ルール（設定変更可）

## よくある構成パターン
### パターン1：スケジュール実行
- 構成概要：
  - EventBridgeルール（cron：毎日2時）
  - Lambda：バッチ処理
  - SNS：実行結果通知
- 使う場面：定期バッチ

### パターン2：AWSサービスイベント
- 構成概要：
  - EC2状態変更 → EventBridge
  - Lambda：通知処理
  - Slack通知
- 使う場面：インフライベント監視

### パターン3：マイクロサービス連携
- 構成概要：
  - カスタムイベントバス
  - サービスA → イベント送信
  - EventBridge → 複数サービスに配信
- 使う場面：イベント駆動アーキテクチャ

### パターン4：SaaS統合
- 構成概要：
  - Salesforce → EventBridge（パートナーイベントバス）
  - Lambda：データ同期
  - DynamoDB：データ保存
- 使う場面：SaaS連携

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：EventBridgeは高可用性（マネージド）
- **セキュリティ**：
  - IAMロール最小権限
  - イベントバスポリシー
  - クロスアカウントイベント
- **コスト**：
  - カスタムイベント：$1.00/百万イベント
  - サードパーティーイベント：$1.00/百万イベント
  - AWSサービスイベント：無料
  - ターゲット実行課金なし
- **拡張性**：無制限イベント

## 他サービスとの関係
- **Lambda との関係**：イベントハンドラー
- **Step Functions との関係**：ワークフロートリガー
- **SNS / SQS との関係**：イベント配信
- **CloudTrail との関係**：API操作イベント

## Terraformで見るとどうなる？
```hcl
# イベントルール（スケジュール）
resource "aws_cloudwatch_event_rule" "daily_batch" {
  name                = "daily-batch"
  description         = "Daily batch at 2:00 AM JST"
  schedule_expression = "cron(0 17 * * ? *)"  # UTC 17:00 = JST 02:00

  tags = {
    Name = "daily-batch"
  }
}

# ターゲット（Lambda）
resource "aws_cloudwatch_event_target" "daily_batch_lambda" {
  rule      = aws_cloudwatch_event_rule.daily_batch.name
  target_id = "lambda"
  arn       = aws_lambda_function.batch_processor.arn
}

# Lambda権限
resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.batch_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_batch.arn
}

# イベントパターン（EC2状態変更）
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "ec2-state-change"
  description = "Capture EC2 state changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["stopped", "terminated"]
    }
  })
}

# カスタムイベントバス
resource "aws_cloudwatch_event_bus" "custom" {
  name = "custom-event-bus"

  tags = {
    Name = "custom-event-bus"
  }
}

# カスタムイベントバスルール
resource "aws_cloudwatch_event_rule" "custom_events" {
  name           = "order-events"
  event_bus_name = aws_cloudwatch_event_bus.custom.name

  event_pattern = jsonencode({
    source      = ["myapp.orders"]
    detail-type = ["Order Created", "Order Updated"]
  })
}

# 複数ターゲット
resource "aws_cloudwatch_event_target" "lambda1" {
  rule      = aws_cloudwatch_event_rule.custom_events.name
  target_id = "lambda1"
  arn       = aws_lambda_function.order_processor.arn
}

resource "aws_cloudwatch_event_target" "lambda2" {
  rule      = aws_cloudwatch_event_rule.custom_events.name
  target_id = "lambda2"
  arn       = aws_lambda_function.notification_sender.arn
}

resource "aws_cloudwatch_event_target" "sqs" {
  rule      = aws_cloudwatch_event_rule.custom_events.name
  target_id = "sqs"
  arn       = aws_sqs_queue.orders.arn
}

# Step Functions統合
resource "aws_cloudwatch_event_target" "step_functions" {
  rule      = aws_cloudwatch_event_rule.workflow_trigger.name
  target_id = "step-functions"
  arn       = aws_sfn_state_machine.main.arn
  role_arn  = aws_iam_role.eventbridge_step_functions.arn
}

# SNS統合
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.alerts.name
  target_id = "sns"
  arn       = aws_sns_topic.alerts.arn
}

# デッドレターキュー
resource "aws_cloudwatch_event_target" "lambda_with_dlq" {
  rule      = aws_cloudwatch_event_rule.processing.name
  target_id = "lambda"
  arn       = aws_lambda_function.processor.arn

  dead_letter_config {
    arn = aws_sqs_queue.eventbridge_dlq.arn
  }

  retry_policy {
    maximum_event_age       = 3600  # 1時間
    maximum_retry_attempts  = 2
  }
}

# クロスアカウントイベント
resource "aws_cloudwatch_event_bus_policy" "cross_account" {
  event_bus_name = aws_cloudwatch_event_bus.custom.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCrossAccountPut"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::987654321098:root"
      }
      Action   = "events:PutEvents"
      Resource = aws_cloudwatch_event_bus.custom.arn
    }]
  })
}

# API Destination（HTTP エンドポイント）
resource "aws_cloudwatch_event_connection" "webhook" {
  name               = "webhook-connection"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "X-API-Key"
      value = "your-api-key"
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "webhook" {
  name                             = "webhook-destination"
  invocation_endpoint              = "https://example.com/webhook"
  http_method                      = "POST"
  invocation_rate_limit_per_second = 10
  connection_arn                   = aws_cloudwatch_event_connection.webhook.arn
}

resource "aws_cloudwatch_event_target" "api_destination" {
  rule      = aws_cloudwatch_event_rule.webhooks.name
  target_id = "api-destination"
  arn       = aws_cloudwatch_event_api_destination.webhook.arn
  role_arn  = aws_iam_role.eventbridge_api_destination.arn
}
```

主要リソース：
- `aws_cloudwatch_event_rule`：ルール
- `aws_cloudwatch_event_target`：ターゲット
- `aws_cloudwatch_event_bus`：カスタムイベントバス
- `aws_cloudwatch_event_api_destination`：API Destination
