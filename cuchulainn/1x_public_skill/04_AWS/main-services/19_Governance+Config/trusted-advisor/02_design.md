# AWS Trusted Advisor：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **CloudWatch Events**：定期チェック・通知
  - **SNS**：アラート通知
  - **Lambda**：自動対応
  - **Organizations**：組織全体レポート

## 内部的な仕組み（ざっくり）
- **なぜTrusted Advisorが必要なのか**：AWSベストプラクティス自動チェック、コスト削減、セキュリティ向上
- **5つのカテゴリ**：
  1. **コスト最適化**：未使用リソース、RIアップグレード等
  2. **セキュリティ**：SG設定、IAMアクセスキーローテーション等
  3. **耐障害性**：バックアップ、Multi-AZ等
  4. **パフォーマンス**：高使用率インスタンス、スループット最適化等
  5. **サービスクォータ**：上限到達警告
- **更新頻度**：週1回（手動リフレッシュ：5分に1回）
- **制約**：
  - 無料：7項目のみ
  - 有料（Business / Enterprise）：全項目

## よくある構成パターン
### パターン1：基本監視
- 構成概要：
  - Trusted Advisor（無料）
  - 週次手動確認
  - 推奨事項対応
- 使う場面：小規模環境

### パターン2：自動通知
- 構成概要：
  - Trusted Advisor（有料）
  - CloudWatch Events
  - SNS通知
  - 週次レポート
- 使う場面：中規模環境

### パターン3：自動対応
- 構成概要：
  - Trusted Advisor
  - CloudWatch Events
  - Lambda（自動修復）
  - 未使用EIPリリース等
- 使う場面：大規模環境

### パターン4：組織全体監視
- 構成概要：
  - Organizations統合
  - 全アカウントTrusted Advisor
  - 集約レポート
- 使う場面：マルチアカウント

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：Trusted Advisor自体は高可用性
- **セキュリティ**：
  - IAM権限（ReadOnlyAccess推奨）
  - セキュリティチェック定期確認
- **コスト**：
  - Trusted Advisor：無料（7項目）
  - Business / Enterprise：全項目無料（サポートプラン料金）
- **拡張性**：全リソース自動チェック

## 他サービスとの関係
- **Cost Explorer との関係**：コスト最適化補完
- **Config との関係**：コンプライアンス補完
- **Security Hub との関係**：セキュリティチェック統合
- **CloudWatch との関係**：チェック結果イベント

## Terraformで見るとどうなる？
```hcl
# Trusted AdvisorはAWS管理サービス（Terraformリソースなし）
# 以下はCloudWatch Events統合例

# CloudWatch Events（Trusted Advisorチェック完了）
resource "aws_cloudwatch_event_rule" "trusted_advisor_check" {
  name        = "trusted-advisor-check-complete"
  description = "Trigger on Trusted Advisor check completion"

  event_pattern = jsonencode({
    source      = ["aws.trustedadvisor"]
    detail-type = ["Trusted Advisor Check Item Refresh Notification"]
    detail = {
      status = ["ERROR", "WARN"]
      check-name = [
        "Security Groups - Unrestricted Access",
        "IAM Access Key Rotation",
        "Unassociated Elastic IP Addresses"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.trusted_advisor_check.name
  target_id = "sns"
  arn       = aws_sns_topic.trusted_advisor_alerts.arn
}

resource "aws_sns_topic" "trusted_advisor_alerts" {
  name = "trusted-advisor-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.trusted_advisor_alerts.arn
  protocol  = "email"
  endpoint  = "ops@example.com"
}

# Lambda自動対応（未使用EIPリリース）
resource "aws_lambda_function" "release_eip" {
  filename      = "release-eip.zip"
  function_name = "trusted-advisor-release-eip"
  role          = aws_iam_role.lambda_trusted_advisor.arn
  handler       = "index.handler"
  runtime       = "python3.11"
}

resource "aws_cloudwatch_event_rule" "unused_eip" {
  name        = "trusted-advisor-unused-eip"
  description = "Trigger on unused EIP detection"

  event_pattern = jsonencode({
    source      = ["aws.trustedadvisor"]
    detail-type = ["Trusted Advisor Check Item Refresh Notification"]
    detail = {
      check-name = ["Unassociated Elastic IP Addresses"]
      status     = ["WARN"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_eip" {
  rule      = aws_cloudwatch_event_rule.unused_eip.name
  target_id = "lambda"
  arn       = aws_lambda_function.release_eip.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.release_eip.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.unused_eip.arn
}

# IAMロール（Lambda）
resource "aws_iam_role" "lambda_trusted_advisor" {
  name = "lambda-trusted-advisor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_trusted_advisor" {
  role = aws_iam_role.lambda_trusted_advisor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAddresses",
          "ec2:ReleaseAddress"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "trustedadvisor:Describe*",
          "trustedadvisor:RefreshCheck"
        ]
        Resource = "*"
      }
    ]
  })
}
```

主要リソース：
- `aws_cloudwatch_event_rule`：Trusted Advisorイベント
