# AWS Organizations：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：権限管理
  - **CloudTrail**：組織ログ
  - **Config**：組織設定
  - **SSO**：シングルサインオン

## 内部的な仕組み（ざっくり）
- **なぜOrganizationsが必要なのか**：複数アカウント管理、一括請求、ガバナンス
- **組織（Organization）**：複数アカウントの集合
- **組織単位（OU）**：アカウントのグループ（階層構造）
- **管理アカウント**：組織の親アカウント
- **メンバーアカウント**：組織配下のアカウント
- **SCP（Service Control Policy）**：アカウント・OU単位の権限制限
- **一括請求**：全アカウント統合請求
- **制約**：
  - アカウント：デフォルト10個（申請で増加可能）
  - OU：最大5階層

## よくある構成パターン
### パターン1：基本組織
- 構成概要：
  - 管理アカウント
  - OU（開発、検証、本番）
  - メンバーアカウント（各OU配下）
- 使う場面：小規模組織

### パターン2：セキュリティガバナンス
- 構成概要：
  - 管理アカウント
  - セキュリティOU（CloudTrail、Config集約）
  - ワークロードOU（開発、本番）
  - SCP（リージョン制限、サービス制限）
- 使う場面：セキュリティ強化

### パターン3：マルチアカウント戦略
- 構成概要：
  - 管理アカウント
  - セキュリティOU（ログアーカイブ、監査）
  - ワークロードOU（プロジェクト別）
  - Control Tower
  - SSO
- 使う場面：大規模組織

### パターン4：環境分離
- 構成概要：
  - 開発OU（開発アカウント群、緩いSCP）
  - 本番OU（本番アカウント群、厳格なSCP）
  - 共有サービスOU（ネットワーク、DNS）
- 使う場面：環境分離

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：
  - マネージド（Multi-AZ自動）
- **セキュリティ**：
  - **管理アカウント保護**：MFA必須、最小権限
  - **SCP設計**：最小権限原則
  - **CloudTrail組織証跡**：全アカウント監査
- **コスト**：
  - **Organizations：無料**
  - **一括請求でボリュームディスカウント**
- **拡張性**：最大数千アカウント

## 他サービスとの関係
- **IAM との関係**：SCPで権限制限
- **CloudTrail との関係**：組織証跡
- **Config との関係**：組織ルール
- **SSO との関係**：シングルサインオン
- **Control Tower との関係**：ガバナンス自動化

## Terraformで見るとどうなる？
```hcl
# Organizations組織作成
resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com"
  ]

  feature_set = "ALL"  # SCP有効化

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]
}

# OU（セキュリティ）
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.main.roots[0].id
}

# OU（ワークロード）
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.main.roots[0].id
}

# OU（開発）
resource "aws_organizations_organizational_unit" "development" {
  name      = "Development"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

# OU（本番）
resource "aws_organizations_organizational_unit" "production" {
  name      = "Production"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

# アカウント作成
resource "aws_organizations_account" "dev" {
  name      = "development-account"
  email     = "aws-dev@example.com"
  parent_id = aws_organizations_organizational_unit.development.id

  role_name = "OrganizationAccountAccessRole"

  tags = {
    Environment = "development"
  }
}

resource "aws_organizations_account" "prod" {
  name      = "production-account"
  email     = "aws-prod@example.com"
  parent_id = aws_organizations_organizational_unit.production.id

  role_name = "OrganizationAccountAccessRole"

  tags = {
    Environment = "production"
  }
}

# SCP（リージョン制限）
resource "aws_organizations_policy" "region_restriction" {
  name        = "region-restriction"
  description = "Restrict to ap-northeast-1 and us-east-1"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "ap-northeast-1",
              "us-east-1"
            ]
          }
        }
      }
    ]
  })
}

# SCP（S3暗号化必須）
resource "aws_organizations_policy" "s3_encryption" {
  name        = "s3-encryption-required"
  description = "Require S3 encryption"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "s3:PutObject"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = ["AES256", "aws:kms"]
          }
        }
      }
    ]
  })
}

# SCP（ルートユーザー制限）
resource "aws_organizations_policy" "deny_root" {
  name        = "deny-root-user"
  description = "Deny root user actions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}

# SCP適用（本番OU）
resource "aws_organizations_policy_attachment" "prod_region" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = aws_organizations_organizational_unit.production.id
}

resource "aws_organizations_policy_attachment" "prod_s3_encryption" {
  policy_id = aws_organizations_policy.s3_encryption.id
  target_id = aws_organizations_organizational_unit.production.id
}

# CloudTrail組織証跡
resource "aws_cloudtrail" "organization" {
  name                          = "organization-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  is_multi_region_trail         = true
  is_organization_trail         = true
  include_global_service_events = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::*/"]
    }
  }
}
```

主要リソース：
- `aws_organizations_organization`：組織
- `aws_organizations_organizational_unit`：OU
- `aws_organizations_account`：アカウント
- `aws_organizations_policy`：SCP
