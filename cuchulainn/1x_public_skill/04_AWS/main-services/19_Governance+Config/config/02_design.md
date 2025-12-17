# AWS Config：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **S3**：設定履歴保存
  - **SNS**：変更通知
  - **Lambda**：カスタムルール
  - **IAM**：権限管理

## 内部的な仕組み（ざっくり）
- **なぜConfigが必要なのか**：コンプライアンス監査、設定変更追跡、自動修復
- **設定レコーダー**：リソース設定変更記録
- **Config Rules**：コンプライアンスルール評価
- **評価タイミング**：
  - 設定変更時
  - 定期実行
- **Conformance Pack**：ルール集（テンプレート）
- **制約**：
  - Config Rules：最大150個/リージョン
  - リソースタイプ：100種類以上

## よくある構成パターン
### パターン1：基本コンプライアンス
- 構成概要：
  - Config有効化
  - マネージドルール（S3暗号化、ルートMFA等）
  - SNS通知
  - S3履歴保存
- 使う場面：コンプライアンス監査

### パターン2：自動修復
- 構成概要：
  - Config Rules
  - Systems Manager Automation
  - 自動修復（S3暗号化有効化等）
- 使う場面：セキュリティ自動化

### パターン3：組織全体管理
- 構成概要：
  - Organizations
  - Config Aggregator
  - 組織全体ルール
  - 集約ダッシュボード
- 使う場面：複数アカウント管理

### パターン4：カスタムルール
- 構成概要：
  - Config
  - Lambda（カスタムルール）
  - 独自コンプライアンスルール
- 使う場面：独自要件

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：
  - マネージド（Multi-AZ自動）
- **セキュリティ**：
  - S3暗号化
  - IAM最小権限
  - SNS暗号化
- **コスト**：
  - **Config Rules評価：$0.001/評価**
  - **設定項目記録：$0.003/項目**
  - **Conformance Pack評価：$0.0009/評価**
  - **S3ストレージ料金別途**
- **拡張性**：最大150ルール/リージョン

## 他サービスとの関係
- **S3 との関係**：設定履歴保存
- **SNS との関係**：変更通知
- **Lambda との関係**：カスタムルール、自動修復
- **Systems Manager との関係**：自動修復
- **Organizations との関係**：組織全体管理

## Terraformで見るとどうなる？
```hcl
# S3バケット（設定履歴）
resource "aws_s3_bucket" "config" {
  bucket = "my-config-bucket"
}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAMロール（Config）
resource "aws_iam_role" "config" {
  name = "config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/ConfigRole"
}

resource "aws_iam_role_policy" "config_s3" {
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetBucketVersioning"
      ]
      Resource = [
        aws_s3_bucket.config.arn,
        "${aws_s3_bucket.config.arn}/*"
      ]
    }]
  })
}

# Config Recorder
resource "aws_config_configuration_recorder" "main" {
  name     = "main-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# Config Delivery Channel
resource "aws_config_delivery_channel" "main" {
  name           = "main-channel"
  s3_bucket_name = aws_s3_bucket.config.bucket
  sns_topic_arn  = aws_sns_topic.config.arn

  depends_on = [aws_config_configuration_recorder.main]
}

# Config Recorder Start
resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

# SNSトピック
resource "aws_sns_topic" "config" {
  name = "config-notifications"
}

# Config Rule（マネージド：S3暗号化）
resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Config Rule（マネージド：ルートMFA）
resource "aws_config_config_rule" "root_mfa" {
  name = "root-account-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Config Rule（カスタム：Lambda）
resource "aws_config_config_rule" "custom" {
  name = "custom-compliance-rule"

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = aws_lambda_function.config_rule.arn

    source_detail {
      event_source = "aws.config"
      message_type = "ConfigurationItemChangeNotification"
    }
  }

  depends_on = [
    aws_config_configuration_recorder.main,
    aws_lambda_permission.config
  ]
}

# Lambda（カスタムルール）
resource "aws_lambda_function" "config_rule" {
  filename      = "config_rule.zip"
  function_name = "config-custom-rule"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
}

resource "aws_lambda_permission" "config" {
  statement_id  = "AllowExecutionFromConfig"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.config_rule.function_name
  principal     = "config.amazonaws.com"
}

# Config Remediation（自動修復）
resource "aws_config_remediation_configuration" "s3_encryption" {
  config_rule_name = aws_config_config_rule.s3_encryption.name

  target_type      = "SSM_DOCUMENT"
  target_identifier = "AWS-EnableS3BucketEncryption"
  target_version   = "1"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.ssm_automation.arn
  }

  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}

# Conformance Pack
resource "aws_config_conformance_pack" "security" {
  name = "security-best-practices"

  template_body = <<EOF
Resources:
  S3BucketServerSideEncryptionEnabled:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: s3-bucket-server-side-encryption-enabled
      Source:
        Owner: AWS
        SourceIdentifier: S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED
  RootAccountMfaEnabled:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: root-account-mfa-enabled
      Source:
        Owner: AWS
        SourceIdentifier: ROOT_ACCOUNT_MFA_ENABLED
EOF

  depends_on = [aws_config_configuration_recorder.main]
}

# Config Aggregator（組織全体）
resource "aws_config_configuration_aggregator" "organization" {
  name = "organization-aggregator"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config_aggregator.arn
  }

  depends_on = [aws_iam_role_policy_attachment.config_aggregator]
}
```

主要リソース：
- `aws_config_configuration_recorder`：設定レコーダー
- `aws_config_config_rule`：コンプライアンスルール
- `aws_config_remediation_configuration`：自動修復
