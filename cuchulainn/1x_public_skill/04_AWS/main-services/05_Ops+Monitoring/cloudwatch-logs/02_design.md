# Amazon CloudWatch Logs：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：ログ送信権限
  - **CloudWatch**：メトリクス連携
  - **S3（オプション）**：エクスポート先
  - **Lambda（オプション）**：ログ処理

## 内部的な仕組み（ざっくり）
- **なぜCloudWatch Logsが必要なのか**：集約ログ管理、検索、分析
- **ロググループ**：ログの論理的なグループ（/aws/lambda/function-name等）
- **ログストリーム**：個別のログソース（インスタンスID、コンテナID等）
- **保存期間**：1日〜無期限（無期限はコスト高）
- **制約**：
  - 1イベント最大256KB
  - 1リクエスト最大1MB

## よくある構成パターン
### パターン1：EC2アプリログ収集
- 構成概要：
  - CloudWatch Agent：ログ送信
  - ロググループ：/var/log/app.log
  - メトリクスフィルター：ERROR件数
  - アラーム：ERROR > 10件/分
- 使う場面：アプリケーション監視

### パターン2：Lambda統合
- 構成概要：
  - Lambda：自動的にCloudWatch Logsへ
  - ロググループ：/aws/lambda/{function-name}
  - Logs Insights：エラー分析
- 使う場面：サーバーレス

### パターン3：VPCフローログ
- 構成概要：
  - VPCフローログ → CloudWatch Logs
  - Logs Insights：通信分析
  - アラーム：不審なアクセス検知
- 使う場面：セキュリティ監視

### パターン4：ログ長期保存（S3エクスポート）
- 構成概要：
  - CloudWatch Logs：直近30日
  - S3エクスポート：長期保存
  - Athena：S3データクエリ
- 使う場面：コンプライアンス

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：CloudWatch Logsは高可用性（マネージド）
- **セキュリティ**：
  - IAMロール最小権限
  - 暗号化（KMS）
  - ログデータマスキング
- **コスト**：
  - データ取り込み：$0.57/GB
  - 保存：$0.033/GB/月
  - Logs Insights：$0.0057/GB（スキャン量）
- **拡張性**：無制限ログ

## 他サービスとの関係
- **CloudWatch との関係**：メトリクスフィルター、アラーム
- **Lambda との関係**：サブスクリプションフィルター、ログ処理
- **Kinesis との関係**：リアルタイムストリーミング
- **S3 との関係**：エクスポート、長期保存

## Terraformで見るとどうなる？
```hcl
# ロググループ
resource "aws_cloudwatch_log_group" "app" {
  name              = "/var/log/app"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.logs.arn

  tags = {
    Name = "app-logs"
  }
}

# メトリクスフィルター
resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "error-count"
  log_group_name = aws_cloudwatch_log_group.app.name
  pattern        = "[time, request_id, level = ERROR*, ...]"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "MyApp"
    value     = "1"
  }
}

# アラーム（メトリクスフィルター連携）
resource "aws_cloudwatch_metric_alarm" "high_errors" {
  alarm_name          = "high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorCount"
  namespace           = "MyApp"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# サブスクリプションフィルター（Lambda）
resource "aws_cloudwatch_log_subscription_filter" "lambda" {
  name            = "lambda-processor"
  log_group_name  = aws_cloudwatch_log_group.app.name
  filter_pattern  = "[level = ERROR*]"
  destination_arn = aws_lambda_function.log_processor.arn
}

# Lambda権限
resource "aws_lambda_permission" "cloudwatch_logs" {
  statement_id  = "AllowCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_processor.function_name
  principal     = "logs.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.app.arn}:*"
}

# Kinesis Data Firehose（リアルタイム転送）
resource "aws_cloudwatch_log_subscription_filter" "kinesis" {
  name            = "kinesis-stream"
  log_group_name  = aws_cloudwatch_log_group.app.name
  filter_pattern  = ""  # 全ログ
  destination_arn = aws_kinesis_firehose_delivery_stream.logs.arn
  role_arn        = aws_iam_role.cloudwatch_logs_kinesis.arn
}

# VPCフローログ
resource "aws_flow_log" "vpc" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination = aws_cloudwatch_log_group.vpc_flow.arn
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn

  tags = {
    Name = "vpc-flow-log"
  }
}
```

主要リソース：
- `aws_cloudwatch_log_group`：ロググループ
- `aws_cloudwatch_log_metric_filter`：メトリクスフィルター
- `aws_cloudwatch_log_subscription_filter`：サブスクリプションフィルター
- `aws_flow_log`：VPCフローログ
