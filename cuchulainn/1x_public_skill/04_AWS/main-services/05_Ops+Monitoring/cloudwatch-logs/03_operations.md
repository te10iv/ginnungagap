# Amazon CloudWatch Logs：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **Logs Insights**：高速ログ検索
- **メトリクスフィルター**：ログからメトリクス生成
- **サブスクリプションフィルター**：ログ転送（Lambda、Kinesis）
- **エクスポート**：S3へのログエクスポート

## よくあるトラブル
### トラブル1：ログが送信されない
- 症状：CloudWatch Logsにログが表示されない
- 原因：
  - IAMロール権限不足
  - CloudWatch Agentが停止
  - ロググループ名ミス
- 確認ポイント：
  - IAMロールで `logs:CreateLogGroup`、`logs:CreateLogStream`、`logs:PutLogEvents` 許可
  - CloudWatch Agent ステータス確認
  - ロググループ名確認

### トラブル2：高額課金
- 症状：月末にCloudWatch Logs課金が数万円
- 原因：
  - 大量ログ送信
  - 保存期間未設定（無期限）
  - Logs Insightsクエリ過多
- 確認ポイント：
  - 不要なログ削減
  - 保存期間設定（30日推奨）
  - S3エクスポート検討
  - ログレベル調整（DEBUG→INFO）

### トラブル3：Logs Insightsが遅い
- 症状：クエリに数分かかる
- 原因：
  - スキャン範囲が広い
  - 複雑なクエリ
- 確認ポイント：
  - 検索期間を狭める
  - ロググループを分割
  - フィールド指定でスキャン量削減

## 監視・ログ
- **データ取り込み量**：Cost Explorerで確認
- **保存量**：ロググループ別に確認
- **Logs Insightsクエリスキャン量**：課金対象

## コストでハマりやすい点
- **データ取り込み**：$0.57/GB
- **保存**：$0.033/GB/月
- **Logs Insights**：$0.0057/GB（スキャン量）
- **データ転送**：
  - 同一リージョン内：無料
  - クロスリージョン：課金
- **コスト削減策**：
  - 保存期間設定（30日推奨、無期限は高額）
  - S3エクスポート（$0.025/GB、長期保存）
  - ログレベル調整
  - 不要なログ削減

## 実務Tips
- **保存期間設定必須**：30日推奨（無期限は高額）
- **ロググループ設計**：
  - アプリケーション別
  - 環境別（dev/stg/prod）
  - 例：`/aws/lambda/{function-name}`、`/var/log/app`
- **メトリクスフィルター活用**：
  - ERRORカウント
  - 特定パターン検知
  - カスタムメトリクス生成
- **Logs Insights**：
  - SQLライククエリ
  - 統計・集計可能
  - 保存クエリで再利用
- **サブスクリプションフィルター**：
  - Lambda：リアルタイム処理
  - Kinesis：大量ログ転送
  - 別アカウント：クロスアカウントログ集約
- **構造化ログ推奨**：JSON形式（Logs Insightsで高速検索）
- **VPCフローログ**：不審なアクセス検知
- **設計時に言語化すると評価が上がるポイント**：
  - 「CloudWatch Logsで集約ログ管理、Logs Insightsで高速検索」
  - 「メトリクスフィルターでERROR件数をメトリクス化、アラーム連携」
  - 「保存期間30日設定、S3エクスポートで長期保存、コスト最適化」
  - 「サブスクリプションフィルターでLambda連携、リアルタイムログ処理」
  - 「構造化ログ（JSON）でLogs Insightsクエリ高速化」
  - 「VPCフローログで通信分析、セキュリティ監視」
  - 「KMS暗号化でログデータ保護」

## Logs Insights クエリ例

### エラーログ検索
```
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100
```

### 統計（エラー件数）
```
fields @timestamp
| filter @message like /ERROR/
| stats count() as error_count by bin(5m)
```

### レスポンス時間分析
```
fields @timestamp, responseTime
| filter @type = "REQUEST"
| stats avg(responseTime), max(responseTime), min(responseTime) by bin(5m)
```

### 特定ユーザーの行動追跡
```
fields @timestamp, userId, action
| filter userId = "user-12345"
| sort @timestamp asc
```

### エラー率計算
```
stats sum(@message like /ERROR/) / count(*) * 100 as error_rate by bin(5m)
```

## メトリクスフィルターパターン例

### ERRORカウント
```
[time, request_id, level = ERROR*, ...]
```

### 特定エラーコード
```
[..., status_code = 500, ...]
```

### レスポンス時間（> 1秒）
```
[time, request_id, ..., response_time > 1000]
```

### JSONログ
```
{ $.level = "ERROR" }
```

## CloudWatch Agent設定例

```json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/app/application.log",
            "log_group_name": "/var/log/app",
            "log_stream_name": "{instance_id}",
            "timezone": "Local"
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/var/log/nginx/access",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
```

## Lambda統合例（エラー通知）

```python
import json
import boto3
import gzip
import base64

sns = boto3.client('sns')
SNS_TOPIC_ARN = 'arn:aws:sns:ap-northeast-1:123456789012:alerts'

def lambda_handler(event, context):
    # CloudWatch Logsデータ展開
    compressed_data = base64.b64decode(event['awslogs']['data'])
    log_data = json.loads(gzip.decompress(compressed_data))
    
    # ログイベント処理
    for log_event in log_data['logEvents']:
        message = log_event['message']
        
        # ERRORログの場合、SNS通知
        if 'ERROR' in message:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject='Application Error Detected',
                Message=f"Error Log:\n{message}"
            )
    
    return {'statusCode': 200}
```

## S3エクスポート（AWS CLI）

```bash
# ログエクスポート
aws logs create-export-task \
  --log-group-name "/var/log/app" \
  --from $(date -d '30 days ago' +%s)000 \
  --to $(date +%s)000 \
  --destination "my-log-bucket" \
  --destination-prefix "logs/app/"

# エクスポート状態確認
aws logs describe-export-tasks \
  --task-id export-task-id
```

## コスト試算例

**シナリオ**：1日10GBのログ、30日保存

| 項目 | 月額コスト |
|------|-----------|
| データ取り込み（300GB） | $171 |
| 保存（300GB × 15日平均） | $14.85 |
| Logs Insights（10GB/月スキャン） | $0.057 |
| **合計** | **$186** |

**S3エクスポート戦略**：
- CloudWatch Logs：7日保存（$34）
- S3：23日分保存（300GB × $0.025 = $7.5）
- **合計：$41.5（78%削減）**

## ログ保存期間の選択肢

- **1日**：デバッグ用
- **3日**：最小限
- **7日**：標準
- **14日**：一般的
- **30日**：推奨
- **90日**：コンプライアンス
- **1年〜無期限**：長期保存（S3推奨）

## 構造化ログ例（JSON）

```json
{
  "timestamp": "2024-01-15T12:00:00Z",
  "level": "ERROR",
  "requestId": "abc-123",
  "userId": "user-456",
  "message": "Database connection failed",
  "error": {
    "code": "ECONNREFUSED",
    "stack": "..."
  },
  "metadata": {
    "host": "i-0123456789abcdef",
    "environment": "production"
  }
}
```

Logs Insightsでのクエリ：
```
fields @timestamp, level, message, error.code
| filter level = "ERROR"
| stats count() by error.code
```
