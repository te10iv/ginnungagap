# AWS Step Functions：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **実行開始**：StartExecution
- **実行履歴確認**：DescribeExecution
- **実行停止**：StopExecution
- **タスクトークン**：SendTaskSuccess / SendTaskFailure

## よくあるトラブル
### トラブル1：Lambda実行エラー
- 症状：ステートマシン実行失敗
- 原因：
  - Lambda関数エラー
  - タイムアウト
  - IAM権限不足
- 確認ポイント：
  - CloudWatch LogsでLambdaエラー確認
  - Retry設定（最大3回推奨）
  - Catch設定（エラーハンドリング）

### トラブル2：実行が止まらない
- 症状：無限ループ
- 原因：
  - Choice条件ミス
  - デフォルト遷移なし
- 確認ポイント：
  - ビジュアルワークフローで遷移確認
  - すべてのChoiceにDefault設定

### トラブル3：高額課金
- 症状：月末にStep Functions課金が高額
- 原因：
  - 大量のステート遷移
  - 不要なWaitステート
  - Express推奨箇所でStandard使用
- 確認ポイント：
  - ステート数削減
  - Express検討（高スループット）

## 監視・ログ
- **CloudWatch Metrics**：
  - `ExecutionStarted`：実行開始数
  - `ExecutionSucceeded`：成功数
  - `ExecutionFailed`：失敗数
  - `ExecutionTime`：実行時間
- **CloudWatch Logs**：実行ログ詳細
- **X-Ray**：分散トレーシング

## コストでハマりやすい点
- **Standard**：$25/百万ステート遷移
- **Express**：
  - $1/百万リクエスト
  - $0.00001667/GB秒（実行時間）
- **コスト削減策**：
  - ステート数削減（複数Lambdaを1つに統合）
  - Express採用（高スループット）
  - 不要なWaitステート削減

## 実務Tips
- **Retry必須**：一時的エラー対策
  ```json
  "Retry": [{
    "ErrorEquals": ["States.TaskFailed"],
    "IntervalSeconds": 2,
    "MaxAttempts": 3,
    "BackoffRate": 2.0
  }]
  ```
- **Catch必須**：エラーハンドリング
  ```json
  "Catch": [{
    "ErrorEquals": ["States.ALL"],
    "Next": "NotifyFailure"
  }]
  ```
- **Parallel活用**：並列処理で高速化
- **Choice活用**：条件分岐
- **タスクトークン**：人間承認フロー
- **Standard vs Express**：
  - Standard：長時間ワークフロー、監査必要
  - Express：リアルタイム、高スループット
- **ビジュアルワークフロー**：Workflow Studioで視覚的設計
- **設計時に言語化すると評価が上がるポイント**：
  - 「Step Functionsでワークフローオーケストレーション、複雑な業務ロジック可視化」
  - 「Retry設定（3回、指数バックオフ）で一時的エラー自動対応」
  - 「Catch設定でエラーハンドリング、代替処理・通知自動化」
  - 「Parallel活用で並列処理、画像処理時間を1/3に短縮」
  - 「Expressステートマシンで高スループット対応、IoTデータ処理」
  - 「タスクトークンで人間承認フロー、承認待機・再開自動化」
  - 「X-Ray統合で分散トレーシング、ボトルネック特定」

## ステートマシン実行（AWS CLI）

```bash
# 実行開始
aws stepfunctions start-execution \
  --state-machine-arn arn:aws:states:ap-northeast-1:123456789012:stateMachine:order-processing \
  --input '{"orderId":"12345","amount":10000}'

# 実行状態確認
aws stepfunctions describe-execution \
  --execution-arn arn:aws:states:ap-northeast-1:123456789012:execution:order-processing:xxx

# 実行停止
aws stepfunctions stop-execution \
  --execution-arn arn:aws:states:ap-northeast-1:123456789012:execution:order-processing:xxx

# 実行履歴取得
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:ap-northeast-1:123456789012:execution:order-processing:xxx
```

## タスクトークン（人間承認）

```python
# Lambda関数（承認リクエスト）
import boto3
import json

sns = boto3.client('sns')

def lambda_handler(event, context):
    task_token = event['taskToken']
    order_id = event['orderId']
    
    # 承認リクエスト送信（SNS）
    sns.publish(
        TopicArn='arn:aws:sns:ap-northeast-1:123456789012:approvals',
        Subject=f'Order Approval Required: {order_id}',
        Message=json.dumps({
            'orderId': order_id,
            'taskToken': task_token,
            'approvalUrl': f'https://example.com/approve?token={task_token}'
        })
    )
    
    # タスクトークンで待機
    return {'statusCode': 200}

# 承認時（別Lambda）
step_functions = boto3.client('stepfunctions')

def approve_handler(event, context):
    task_token = event['queryStringParameters']['token']
    
    # 承認完了通知
    step_functions.send_task_success(
        taskToken=task_token,
        output=json.dumps({'status': 'approved'})
    )
    
    return {'statusCode': 200, 'body': 'Approved'}

# 却下時
def reject_handler(event, context):
    task_token = event['queryStringParameters']['token']
    
    step_functions.send_task_failure(
        taskToken=task_token,
        error='ApprovalRejected',
        cause='User rejected the approval'
    )
    
    return {'statusCode': 200, 'body': 'Rejected'}
```

## エラーハンドリングパターン

### パターン1：Retry（一時的エラー）
```json
{
  "ValidateOrder": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:...",
    "Retry": [
      {
        "ErrorEquals": ["Lambda.ServiceException", "Lambda.TooManyRequestsException"],
        "IntervalSeconds": 2,
        "MaxAttempts": 3,
        "BackoffRate": 2.0
      }
    ],
    "Next": "ProcessOrder"
  }
}
```

### パターン2：Catch（恒久的エラー）
```json
{
  "ProcessPayment": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:...",
    "Catch": [
      {
        "ErrorEquals": ["PaymentFailed"],
        "Next": "RefundOrder"
      },
      {
        "ErrorEquals": ["States.ALL"],
        "Next": "NotifyFailure"
      }
    ],
    "Next": "SendConfirmation"
  }
}
```

## Parallel（並列処理）例

```json
{
  "ProcessImage": {
    "Type": "Parallel",
    "Branches": [
      {
        "StartAt": "Resize",
        "States": {
          "Resize": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:...",
            "End": true
          }
        }
      },
      {
        "StartAt": "Thumbnail",
        "States": {
          "Thumbnail": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:...",
            "End": true
          }
        }
      }
    ],
    "Next": "SaveResults"
  }
}
```

## Choice（条件分岐）例

```json
{
  "CheckInventory": {
    "Type": "Choice",
    "Choices": [
      {
        "Variable": "$.inventory.inStock",
        "BooleanEquals": true,
        "Next": "ProcessOrder"
      },
      {
        "Variable": "$.inventory.inStock",
        "BooleanEquals": false,
        "Next": "BackorderNotification"
      }
    ],
    "Default": "ErrorState"
  }
}
```

## Wait（待機）例

```json
{
  "WaitForApproval": {
    "Type": "Wait",
    "Seconds": 300,
    "Next": "CheckApprovalStatus"
  },
  "WaitUntilTimestamp": {
    "Type": "Wait",
    "Timestamp": "2024-01-15T12:00:00Z",
    "Next": "ProcessOrder"
  }
}
```

## Standard vs Express比較

| 項目 | Standard | Express |
|------|---------|---------|
| 実行時間 | 最大1年 | 最大5分 |
| 実行保証 | Exactly-once | At-least-once |
| 実行履歴 | 90日保持 | CloudWatch Logs |
| 料金 | $25/百万遷移 | $1/百万リクエスト + 実行時間 |
| スループット | 2,000/秒（リージョン） | 100,000/秒（リージョン） |
| 用途 | 長時間ワークフロー | リアルタイム処理 |

## AWS SDK統合（Direct Integration）

```json
{
  "SaveToDynamoDB": {
    "Type": "Task",
    "Resource": "arn:aws:states:::dynamodb:putItem",
    "Parameters": {
      "TableName": "Orders",
      "Item": {
        "orderId": {"S.$": "$.orderId"},
        "amount": {"N.$": "$.amount"}
      }
    },
    "Next": "SendConfirmation"
  },
  "PublishToSNS": {
    "Type": "Task",
    "Resource": "arn:aws:states:::sns:publish",
    "Parameters": {
      "TopicArn": "arn:aws:sns:ap-northeast-1:123456789012:alerts",
      "Message.$": "$.message"
    },
    "End": true
  }
}
```

## Map（ループ処理）

```json
{
  "ProcessOrders": {
    "Type": "Map",
    "ItemsPath": "$.orders",
    "Iterator": {
      "StartAt": "ProcessOrder",
      "States": {
        "ProcessOrder": {
          "Type": "Task",
          "Resource": "arn:aws:lambda:...",
          "End": true
        }
      }
    },
    "MaxConcurrency": 10,
    "Next": "SendSummary"
  }
}
```

## ビジュアルワークフロー活用

- **Workflow Studio**：GUIでワークフロー設計
- **ドラッグ&ドロップ**：ステート配置
- **自動JSON生成**：ASL自動生成
- **実行可視化**：リアルタイム進捗確認

## ベストプラクティス

1. **Retry設定**：すべてのTaskにRetry設定
2. **Catch設定**：エラーハンドリング必須
3. **タイムアウト設定**：無限待機防止
4. **CloudWatch Logs統合**：デバッグ容易化
5. **X-Ray有効化**：パフォーマンス分析
6. **ステート名**：わかりやすい命名
7. **入力検証**：Choice で事前チェック
8. **冪等性**：同じ入力で同じ結果
9. **Standard / Express選択**：要件に応じて
10. **コスト最適化**：ステート数削減
