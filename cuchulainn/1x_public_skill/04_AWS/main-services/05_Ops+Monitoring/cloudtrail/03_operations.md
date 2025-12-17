# AWS CloudTrail：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **イベント履歴検索**：過去90日のAPI操作確認
- **ログファイル検証**：改ざん検知
- **Athena分析**：SQLクエリでログ分析
- **EventBridge統合**：特定イベント検知、自動対応

## よくあるトラブル
### トラブル1：ログが記録されない
- 症状：CloudTrailイベントが表示されない
- 原因：
  - 証跡が停止している
  - S3バケットポリシー不足
  - IAMロール権限不足
- 確認ポイント：
  - 証跡ステータス確認
  - S3バケットポリシー確認
  - CloudWatch Logsロール確認

### トラブル2：S3ストレージ肥大化
- 症状：CloudTrail S3バケットが数百GB
- 原因：
  - データイベント大量記録
  - ライフサイクルポリシー未設定
- 確認ポイント：
  - データイベント必要性確認
  - ライフサイクルポリシー設定（90日後Glacier）
  - 不要な証跡削除

### トラブル3：セキュリティインシデント調査
- 症状：不審なAPI操作を調査したい
- 原因：セキュリティ侵害の疑い
- 確認ポイント：
  - CloudWatch Logs Insightsで検索
  - Athenaで横断分析
  - 時系列で操作追跡

## 監視・ログ
- **重要なメトリクスフィルター**：
  - ルートユーザー使用
  - IAMポリシー変更
  - Security Group変更
  - S3バケットポリシー変更
  - CloudTrail設定変更
  - KMSキー削除
  - 認証失敗

## コストでハマりやすい点
- **管理イベント**：
  - 最初の証跡：無料
  - 2つ目以降：$2/10万イベント
- **データイベント**：$0.10/10万イベント
- **Insightsイベント**：$0.35/10万書き込みイベント
- **S3保存料**：ログファイル保存
- **CloudWatch Logs**：データ取り込み・保存
- **コスト削減策**：
  - 必要最小限の証跡
  - データイベント選択的有効化
  - S3ライフサイクルポリシー
  - ログ保存期間最適化

## 実務Tips
- **全リージョン証跡推奨**：`is_multi_region_trail = true`
- **ログファイル検証必須**：改ざん検知
- **CloudWatch Logs統合**：リアルタイム分析
- **重要なメトリクスフィルター設定**：
  - ルートユーザー使用
  - IAM変更
  - ネットワーク変更
- **Organizations証跡**：全アカウント監査（マルチアカウント）
- **S3ライフサイクルポリシー**：
  - 30日：Standard
  - 90日：Glacier
  - 7年：コンプライアンス保持
- **Athena活用**：SQLクエリでログ横断分析
- **EventBridge連携**：特定イベント検知、自動対応
- **設計時に言語化すると評価が上がるポイント**：
  - 「CloudTrail全リージョン証跡で全API操作記録、監査証跡確保」
  - 「ログファイル検証で改ざん検知、コンプライアンス対応」
  - 「CloudWatch Logs統合でリアルタイム分析、ルートユーザー使用を即座検知」
  - 「メトリクスフィルターでIAMポリシー変更検知、セキュリティアラート」
  - 「Organizations証跡で全アカウント監査、中央管理」
  - 「Athenaで横断ログ分析、セキュリティインシデント調査」
  - 「S3ライフサイクルポリシーで90日後Glacier移行、ストレージコスト削減」

## 重要なメトリクスフィルターパターン

### 1. ルートユーザー使用
```json
{ $.userIdentity.type = "Root" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != "AwsServiceEvent" }
```

### 2. IAMポリシー変更
```json
{ ($.eventName = CreatePolicy) || ($.eventName = DeletePolicy) || ($.eventName = CreatePolicyVersion) || ($.eventName = DeletePolicyVersion) || ($.eventName = AttachRolePolicy) || ($.eventName = DetachRolePolicy) }
```

### 3. Security Group変更
```json
{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup) }
```

### 4. S3バケットポリシー変更
```json
{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }
```

### 5. 認証失敗
```json
{ ($.errorCode = "*UnauthorizedOperation") || ($.errorCode = "AccessDenied*") }
```

### 6. CloudTrail設定変更
```json
{ ($.eventName = StopLogging) || ($.eventName = DeleteTrail) || ($.eventName = UpdateTrail) }
```

## Athena分析例

### CloudTrailテーブル作成
```sql
CREATE EXTERNAL TABLE cloudtrail_logs (
  eventversion STRING,
  useridentity STRUCT<
    type:STRING,
    principalid:STRING,
    arn:STRING,
    accountid:STRING,
    userName:STRING>,
  eventtime STRING,
  eventsource STRING,
  eventname STRING,
  awsregion STRING,
  sourceipaddress STRING,
  useragent STRING,
  errorcode STRING,
  errormessage STRING,
  requestparameters STRING,
  responseelements STRING
)
PARTITIONED BY (year STRING, month STRING, day STRING)
ROW FORMAT SERDE 'com.amazon.emr.hive.serde.CloudTrailSerde'
STORED AS INPUTFORMAT 'com.amazon.emr.cloudtrail.CloudTrailInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://cloudtrail-logs-12345/AWSLogs/123456789012/CloudTrail/';
```

### クエリ例

**特定ユーザーの操作履歴**
```sql
SELECT eventtime, eventname, eventsource, sourceipaddress
FROM cloudtrail_logs
WHERE useridentity.username = 'john.doe'
  AND year = '2024' AND month = '01'
ORDER BY eventtime DESC
LIMIT 100;
```

**エラー発生API**
```sql
SELECT eventname, errorcode, COUNT(*) as error_count
FROM cloudtrail_logs
WHERE errorcode IS NOT NULL
  AND year = '2024' AND month = '01'
GROUP BY eventname, errorcode
ORDER BY error_count DESC;
```

**特定IPからのアクセス**
```sql
SELECT eventtime, eventname, useridentity.username
FROM cloudtrail_logs
WHERE sourceipaddress = '1.2.3.4'
  AND year = '2024' AND month = '01'
ORDER BY eventtime DESC;
```

**リソース削除操作**
```sql
SELECT eventtime, eventname, useridentity.username, requestparameters
FROM cloudtrail_logs
WHERE eventname LIKE '%Delete%'
  AND year = '2024' AND month = '01'
ORDER BY eventtime DESC;
```

## EventBridge連携例（自動対応）

```hcl
# EventBridgeルール（Security Group変更検知）
resource "aws_cloudwatch_event_rule" "security_group_changes" {
  name        = "detect-security-group-changes"
  description = "Detect Security Group changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["ec2.amazonaws.com"]
      eventName = [
        "AuthorizeSecurityGroupIngress",
        "AuthorizeSecurityGroupEgress",
        "RevokeSecurityGroupIngress",
        "RevokeSecurityGroupEgress"
      ]
    }
  })
}

# Lambda起動
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.security_group_changes.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.notify_security_change.arn
}
```

## ログファイル検証

```bash
# ログファイル検証
aws cloudtrail validate-logs \
  --trail-arn arn:aws:cloudtrail:ap-northeast-1:123456789012:trail/main-trail \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-15T23:59:59Z

# 出力例：
# Validating log files for trail arn:aws:cloudtrail:ap-northeast-1:123456789012:trail/main-trail...
# Results requested for 2024-01-01T00:00:00Z to 2024-01-15T23:59:59Z
# Results found for 2024-01-01T00:05:00Z to 2024-01-15T23:55:00Z:
# 15000/15000 digest files valid
# 0/15000 digest files invalid
```

## S3ライフサイクルポリシー例

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "cloudtrail-lifecycle"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 2555  # 7年後削除（コンプライアンス）
    }
  }
}
```

## セキュリティベストプラクティス

1. **全リージョン証跡**：`is_multi_region_trail = true`
2. **ログファイル検証**：`enable_log_file_validation = true`
3. **KMS暗号化**：保管時暗号化
4. **MFA Delete**：S3バケット削除保護
5. **CloudWatch Logs統合**：リアルタイム分析
6. **メトリクスフィルター**：重要イベント検知
7. **Organizations証跡**：全アカウント監査
8. **S3バケットポリシー**：最小権限
9. **定期監査**：Athenaで横断分析
10. **EventBridge連携**：自動対応
