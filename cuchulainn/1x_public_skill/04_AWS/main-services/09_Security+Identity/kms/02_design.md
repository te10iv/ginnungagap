# AWS KMS：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：キーポリシー
  - **CloudTrail**：操作ログ
  - **すべてのAWSサービス**：暗号化統合

## 内部的な仕組み（ざっくり）
- **なぜKMSが必要なのか**：データ保護、コンプライアンス、キー管理の簡素化
- **エンベロープ暗号化**：
  1. データキー生成（CMKから）
  2. データキーでデータ暗号化
  3. CMKでデータキー暗号化
  4. 暗号化データ + 暗号化データキー保存
- **キータイプ**：
  - **AWS管理キー**：`aws/s3`等、無料
  - **カスタマー管理キー**：自分で作成、$1/月
  - **AWS所有キー**：AWS内部使用
- **制約**：
  - 暗号化データサイズ：最大4KB（直接暗号化）
  - リクエスト制限：リージョンごとにクォータあり

## よくある構成パターン
### パターン1：S3暗号化
- 構成概要：
  - KMSカスタマー管理キー
  - S3バケット暗号化（SSE-KMS）
  - 自動暗号化・復号化
- 使う場面：機密データ保存

### パターン2：RDS暗号化
- 構成概要：
  - KMSキー
  - RDS暗号化有効化（作成時）
  - 自動バックアップも暗号化
- 使う場面：データベース保護

### パターン3：クロスアカウント暗号化
- 構成概要：
  - アカウントAのKMSキー
  - キーポリシーでアカウントB許可
  - アカウントBから暗号化・復号化
- 使う場面：マルチアカウント環境

### パターン4：Lambda環境変数暗号化
- 構成概要：
  - KMSキー
  - Lambda環境変数暗号化
  - 実行時に自動復号化
- 使う場面：APIキー等の保護

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：KMSはリージョンサービス、高可用性
- **セキュリティ**：
  - キーポリシー（最小権限）
  - 自動ローテーション有効化
  - CloudTrailで監査
  - キー削除保護（7〜30日待機期間）
- **コスト**：
  - カスタマー管理キー：$1/月
  - リクエスト：$0.03/10,000リクエスト
  - AWS管理キー：無料
- **拡張性**：無制限キー

## 他サービスとの関係
- **S3 / EBS / RDS との関係**：データ暗号化
- **Secrets Manager との関係**：シークレット暗号化
- **CloudTrail との関係**：KMS操作監査
- **Lambda との関係**：環境変数暗号化

## Terraformで見るとどうなる？
```hcl
# KMSキー（対称キー）
resource "aws_kms_key" "main" {
  description             = "Main encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "main-key"
  }
}

# KMSエイリアス
resource "aws_kms_alias" "main" {
  name          = "alias/main-key"
  target_key_id = aws_kms_key.main.key_id
}

# キーポリシー
resource "aws_kms_key" "custom_policy" {
  description = "Key with custom policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# S3暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }
}

# RDS暗号化
resource "aws_db_instance" "main" {
  # ... 他の設定 ...
  storage_encrypted = true
  kms_key_id        = aws_kms_key.main.arn
}

# EBS暗号化
resource "aws_ebs_volume" "main" {
  # ... 他の設定 ...
  encrypted  = true
  kms_key_id = aws_kms_key.main.arn
}

# クロスアカウントキーポリシー
resource "aws_kms_key" "cross_account" {
  description = "Cross-account key"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow use from another account"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::987654321098:root"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda環境変数暗号化
resource "aws_lambda_function" "main" {
  # ... 他の設定 ...
  kms_key_arn = aws_kms_key.main.arn

  environment {
    variables = {
      DB_PASSWORD = "encrypted-value"
    }
  }
}

# CloudWatch Logs暗号化
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/main"
  kms_key_id        = aws_kms_key.main.arn
  retention_in_days = 30
}

# Secrets Manager暗号化
resource "aws_secretsmanager_secret" "main" {
  name       = "db-password"
  kms_key_id = aws_kms_key.main.id
}

# KMSグラント（一時的権限）
resource "aws_kms_grant" "lambda" {
  name              = "lambda-grant"
  key_id            = aws_kms_key.main.key_id
  grantee_principal = aws_iam_role.lambda.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}
```

主要リソース：
- `aws_kms_key`：KMSキー
- `aws_kms_alias`：エイリアス
- `aws_kms_grant`：グラント（一時的権限）
