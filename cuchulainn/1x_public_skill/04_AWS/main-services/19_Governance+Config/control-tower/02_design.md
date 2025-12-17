# AWS Control Tower：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **Organizations**：マルチアカウント基盤
  - **Config**：ガードレール
  - **CloudTrail**：組織トレイル
  - **SSO**：ID管理
  - **Service Catalog**：Account Factory
  - **Lambda**：ライフサイクルイベント

## 内部的な仕組み（ざっくり）
- **なぜControl Towerが必要なのか**：AWSベストプラクティス自動適用、マルチアカウント管理簡素化
- **ランディングゾーン**：
  - Security OU（Log Archive、Audit アカウント）
  - Sandbox OU（実験用）
  - Workloads OU（本番・開発）
- **ガードレール**：
  - **必須**：変更不可（MFA有効化等）
  - **強く推奨**：AWS推奨（S3暗号化等）
  - **選択**：任意（リージョン制限等）
- **制約**：
  - 既存Organizations上に構築可能
  - 一度セットアップ後の削除は複雑

## よくある構成パターン
### パターン1：標準ランディングゾーン
- 構成概要：
  - Management Account（請求）
  - Security OU
    - Log Archive（ログ集約）
    - Audit（監査）
  - Workloads OU
    - Development、Staging、Production
- 使う場面：AWS推奨標準構成

### パターン2：プロジェクト別OU追加
- 構成概要：
  - Management Account
  - Security OU
  - ProjectA OU
  - ProjectB OU
- 使う場面：複数プロジェクト並行

### パターン3：カスタムガードレール
- 構成概要：
  - 標準ランディングゾーン
  - カスタムガードレール（Config Rules）
  - 組織全体統一ポリシー
- 使う場面：独自コンプライアンス要件

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：Control Tower自体は高可用性
- **セキュリティ**：
  - ガードレール必須有効
  - SSO統合
  - CloudTrail組織トレイル
  - Config組織ルール
- **コスト**：
  - Control Tower：**無料**
  - 依存サービス（Config、CloudTrail等）：有料
  - Log Archiveアカウント：S3ストレージ
- **拡張性**：アカウント数無制限

## 他サービスとの関係
- **Organizations との関係**：基盤サービス
- **Config との関係**：ガードレール実装
- **Service Catalog との関係**：Account Factory
- **SSO との関係**：ユーザー管理

## Terraformで見るとどうなる？
```hcl
# Control Towerは手動セットアップ推奨
# 以下はAccount Factory経由アカウント作成例

# Service Catalog製品（Account Factory）
data "aws_servicecatalog_portfolio" "account_factory" {
  provider = aws.management

  filter {
    name  = "name"
    value = "AWS Control Tower Account Factory Portfolio"
  }
}

data "aws_servicecatalog_product" "account_factory" {
  provider = aws.management

  filter {
    name  = "name"
    value = "AWS Control Tower Account Factory"
  }
}

# アカウント作成（Account Factory）
resource "aws_servicecatalog_provisioned_product" "new_account" {
  provider = aws.management

  name                     = "development-account"
  product_id               = data.aws_servicecatalog_product.account_factory.id
  provisioning_artifact_id = data.aws_servicecatalog_product.account_factory.provisioning_artifact_ids[0]

  provisioning_parameters {
    key   = "AccountEmail"
    value = "aws-dev@example.com"
  }

  provisioning_parameters {
    key   = "AccountName"
    value = "Development Account"
  }

  provisioning_parameters {
    key   = "ManagedOrganizationalUnit"
    value = "Workloads (ou-xxxx-xxxxx)"
  }

  provisioning_parameters {
    key   = "SSOUserEmail"
    value = "admin@example.com"
  }

  provisioning_parameters {
    key   = "SSOUserFirstName"
    value = "Admin"
  }

  provisioning_parameters {
    key   = "SSOUserLastName"
    value = "User"
  }
}

# ガードレール有効化（Config Rule経由）
resource "aws_config_organization_managed_rule" "s3_encryption" {
  provider = aws.management

  name            = "ct-s3-encryption"
  rule_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"

  depends_on = [aws_organizations_organization.main]
}

# カスタムガードレール（Lambda）
resource "aws_lambda_function" "custom_guardrail" {
  provider = aws.management

  filename      = "custom-guardrail.zip"
  function_name = "custom-guardrail"
  role          = aws_iam_role.custom_guardrail.arn
  handler       = "index.handler"
  runtime       = "python3.11"
}

# ライフサイクルイベント（新アカウント作成時）
resource "aws_cloudwatch_event_rule" "account_created" {
  provider = aws.management

  name        = "control-tower-account-created"
  description = "Trigger on Control Tower account creation"

  event_pattern = jsonencode({
    source      = ["aws.controltower"]
    detail-type = ["AWS Service Event via CloudTrail"]
    detail = {
      eventName = ["CreateManagedAccount"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  provider = aws.management

  rule      = aws_cloudwatch_event_rule.account_created.name
  target_id = "lambda"
  arn       = aws_lambda_function.account_setup.arn
}
```

主要リソース：
- `aws_servicecatalog_provisioned_product`：Account Factory
- `aws_config_organization_managed_rule`：ガードレール
