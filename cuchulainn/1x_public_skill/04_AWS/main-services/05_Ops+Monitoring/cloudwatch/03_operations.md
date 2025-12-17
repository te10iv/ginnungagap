# Amazon CloudWatch：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **アラーム設定**：閾値監視
- **ダッシュボード作成**：可視化
- **カスタムメトリクス送信**：独自監視
- **複合アラーム**：複数条件の組み合わせ

## よくあるトラブル
### トラブル1：アラームが通知されない
- 症状：閾値超えているのに通知なし
- 原因：
  - SNSトピック未購読
  - evaluation_periods設定ミス
  - メトリクスデータ欠損
- 確認ポイント：
  - SNSサブスクリプション確認済みか
  - アラーム履歴確認
  - メトリクス実データ確認

### トラブル2：誤検知アラーム多発
- 症状：毎日何度もアラーム通知
- 原因：
  - 閾値設定が厳しすぎる
  - evaluation_periods短い
  - スパイク的な変動
- 確認ポイント：
  - 閾値調整
  - evaluation_periods延長（2〜3回連続）
  - datapoints_to_alarm使用

### トラブル3：高額課金
- 症状：月末にCloudWatch課金が数千円
- 原因：
  - 大量のカスタムメトリクス
  - 高解像度メトリクス
  - API呼び出し過多
- 確認ポイント：
  - 不要なカスタムメトリクス削除
  - 解像度見直し（1秒→1分）
  - メトリクス集約

## 監視・ログ
- **主要メトリクス**（EC2例）：
  - `CPUUtilization`：CPU使用率
  - `NetworkIn / NetworkOut`：ネットワーク転送量
  - `DiskReadBytes / DiskWriteBytes`：ディスクI/O
  - `StatusCheckFailed`：ステータスチェック失敗
- **カスタムメトリクス**：
  - メモリ使用率（CloudWatch Agent）
  - ディスク使用率（CloudWatch Agent）
  - アプリケーションメトリクス
- **アラーム状態**：OK、ALARM、INSUFFICIENT_DATA

## コストでハマりやすい点
- **標準メトリクス**：無料（AWS提供）
- **カスタムメトリクス**：$0.30/メトリクス/月
  - 高解像度（< 1分）：$0.30 + $0.02/メトリクス/月
- **アラーム**：
  - 標準：$0.10/アラーム/月
  - 高解像度：$0.30/アラーム/月
  - 複合アラーム：$0.50/アラーム/月
- **API呼び出し**：$0.01/1000リクエスト（GetMetricData等）
- **ダッシュボード**：$3/ダッシュボード/月
- **ログインサイト**：クエリ課金
- **コスト削減策**：
  - 不要なカスタムメトリクス削除
  - メトリクス解像度見直し
  - API呼び出し頻度削減

## 実務Tips
- **evaluation_periods**：2〜3回連続で閾値超過時にアラーム
- **datapoints_to_alarm**：evaluation_periods中、X回超過で発火
- **treat_missing_data**：
  - `notBreaching`：欠損データを正常扱い（推奨）
  - `breaching`：欠損データを異常扱い
  - `ignore`：評価対象外
- **複合アラーム**：複数条件組み合わせ（CPU高 AND メモリ高）
- **カスタムメトリクス送信**：CloudWatch Agent or API
- **ダッシュボード共有**：読み取り専用リンク
- **クロスアカウント監視**：IAMロール連携
- **設計時に言語化すると評価が上がるポイント**：
  - 「CloudWatchアラームで閾値監視、evaluation_periods=2で誤検知防止」
  - 「SNS連携でメール・Slack通知、Lambda自動対応」
  - 「カスタムメトリクスでメモリ・ディスク使用率監視」
  - 「ダッシュボードで複数サービスのメトリクス統合可視化」
  - 「複合アラームで複数条件組み合わせ、誤検知削減」
  - 「Auto Scalingトリガー設定でCPU > 70%時にスケールアウト」
  - 「EventBridge連携で定期的なヘルスチェック自動化」

## アラーム設定のベストプラクティス

### evaluation_periods と datapoints_to_alarm

```hcl
# 5分間隔で2回連続超過時にアラーム
resource "aws_cloudwatch_metric_alarm" "example" {
  evaluation_periods  = 2
  datapoints_to_alarm = 2  # 2回中2回超過
  period              = 300
  threshold           = 80
}

# 5分間隔、過去3回中2回超過でアラーム（誤検知削減）
resource "aws_cloudwatch_metric_alarm" "reduced_false_positive" {
  evaluation_periods  = 3
  datapoints_to_alarm = 2  # 3回中2回超過
  period              = 300
  threshold           = 80
}
```

## カスタムメトリクス送信（AWS CLI）

```bash
# カスタムメトリクス送信
aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "ErrorRate" \
  --value 5.0 \
  --timestamp $(date -u +"%Y-%m-%dT%H:%M:%S") \
  --dimensions Environment=production,Region=ap-northeast-1

# 複数メトリクス送信（バッチ）
aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-data \
    file://metrics.json
```

**metrics.json**:
```json
[
  {
    "MetricName": "ErrorRate",
    "Value": 5.0,
    "Timestamp": "2024-01-15T12:00:00Z",
    "Dimensions": [
      {
        "Name": "Environment",
        "Value": "production"
      }
    ]
  },
  {
    "MetricName": "RequestCount",
    "Value": 1000,
    "Timestamp": "2024-01-15T12:00:00Z"
  }
]
```

## CloudWatch Agent設定（メモリ・ディスク監視）

```json
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MemoryUtilization",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {
            "name": "disk_used_percent",
            "rename": "DiskUtilization",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      }
    }
  }
}
```

## 複合アラーム例

```hcl
# CPU高 AND メモリ高でアラーム
resource "aws_cloudwatch_composite_alarm" "high_resource" {
  alarm_name          = "high-resource-usage"
  alarm_description   = "CPU and Memory both high"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.cpu_high.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.memory_high.alarm_name})"
}
```

## 主要なAWSサービスのメトリクス

### EC2
- `CPUUtilization`：CPU使用率
- `NetworkIn / NetworkOut`：ネットワーク
- `StatusCheckFailed`：ヘルスチェック

### RDS
- `CPUUtilization`：CPU使用率
- `DatabaseConnections`：接続数
- `FreeStorageSpace`：空きストレージ
- `ReadLatency / WriteLatency`：レイテンシー

### ALB
- `TargetResponseTime`：レスポンス時間
- `RequestCount`：リクエスト数
- `HealthyHostCount`：正常ホスト数
- `HTTPCode_Target_4XX_Count / 5XX_Count`：エラー数

### Lambda
- `Invocations`：実行回数
- `Duration`：実行時間
- `Errors`：エラー数
- `Throttles`：スロットリング数

### DynamoDB
- `ConsumedReadCapacityUnits`：読み取りユニット
- `ConsumedWriteCapacityUnits`：書き込みユニット
- `ThrottledRequests`：スロットリング

## アラーム通知先の選択肢

- **SNS → メール**：基本的な通知
- **SNS → Slack**：Lambda経由でSlack通知
- **Lambda**：自動対応（再起動、スケール等）
- **EventBridge**：複雑なワークフロー
- **Auto Scaling**：スケーリングアクション
- **Systems Manager**：自動パッチ適用等
