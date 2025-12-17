# Amazon S3 Glacier：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **S3**：ライフサイクル管理
  - **CloudWatch**：メトリクス監視
  - **SNS（オプション）**：取り出し完了通知

## 内部的な仕組み（ざっくり）
- **なぜGlacierが必要なのか**：長期保存、低コスト（S3 Standardの1/10以下）
- **アーカイブストレージ**：即座取り出し不可、数時間待機
- **耐久性**：99.999999999%（S3と同等）
- **取り出しオプション**：
  - **Expedited**：1〜5分（高額）
  - **Standard**：3〜5時間（標準）
  - **Bulk**：5〜12時間（低コスト）
- **制約**：
  - 最低保存期間：Flexible 90日、Deep Archive 180日
  - 早期削除で違約金

## よくある構成パターン
### パターン1：ログ長期保存
- 構成概要：
  - S3バケット：アクセスログ
  - ライフサイクルポリシー：
    - 30日後 Standard-IA
    - 90日後 Glacier Flexible Retrieval
    - 365日後 Glacier Deep Archive
- 使う場面：コンプライアンス、監査

### パターン2：バックアップアーカイブ
- 構成概要：
  - AWS Backup
  - Glacier Vault
  - Vault Lock（削除禁止）
- 使う場面：災害対策、規制対応

### パターン3：動画アーカイブ
- 構成概要：
  - S3：アップロード先
  - Intelligent-Tiering：自動最適化
  - Glacier Deep Archive：長期保存
- 使う場面：メディア業界

### パターン4：データレイクアーカイブ
- 構成概要：
  - S3：生データ
  - Athena：クエリ（S3 Select対応）
  - Glacier：古いデータ移行
- 使う場面：ビッグデータ分析

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：自動Multi-AZ複製
- **セキュリティ**：
  - 暗号化（保管時）
  - Vault Lock（削除禁止）
  - アクセスポリシー
- **コスト**：
  - ストレージ：超低コスト
  - 取り出し：高額（頻度に注意）
  - 最低保存期間違約金
- **拡張性**：無制限

## 他サービスとの関係
- **S3 との関係**：ライフサイクルポリシーで自動移行
- **Backup との関係**：バックアップ保存先
- **Storage Gateway との関係**：VTL（仮想テープライブラリ）
- **Athena との関係**：S3 Select/Glacier Select

## Terraformで見るとどうなる？
```hcl
# S3バケット + Glacierライフサイクル
resource "aws_s3_bucket" "archive" {
  bucket = "archive-bucket-12345"

  tags = {
    Name = "archive-bucket"
  }
}

# ライフサイクルポリシー
resource "aws_s3_bucket_lifecycle_configuration" "archive" {
  bucket = aws_s3_bucket.archive.id

  rule {
    id     = "archive-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"  # Glacier Flexible Retrieval
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 2555  # 7年後削除
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Intelligent-Tiering（自動最適化）
resource "aws_s3_bucket_lifecycle_configuration" "intelligent" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "intelligent-tiering"
    status = "Enabled"

    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

# Intelligent-Tiering アーカイブ設定
resource "aws_s3_bucket_intelligent_tiering_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  name   = "entire-bucket"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}

# Glacier Vault（直接使用は稀）
resource "aws_glacier_vault" "backup" {
  name = "backup-vault"

  notification {
    sns_topic = aws_sns_topic.glacier_notifications.arn
    events    = ["ArchiveRetrievalCompleted"]
  }

  tags = {
    Name = "backup-vault"
  }
}

# Vault Lock（削除禁止）
resource "aws_glacier_vault_lock" "backup" {
  vault_name = aws_glacier_vault.backup.name
  complete_lock = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "deny-delete-for-7-years"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = [
          "glacier:DeleteArchive"
        ]
        Resource = aws_glacier_vault.backup.arn
        Condition = {
          DateLessThan = {
            "glacier:ArchiveAgeInDays" = "2555"  # 7年
          }
        }
      }
    ]
  })
}
```

主要リソース：
- `aws_s3_bucket_lifecycle_configuration`：ライフサイクルポリシー
- `aws_s3_bucket_intelligent_tiering_configuration`：Intelligent-Tiering
- `aws_glacier_vault`：Glacierボルト
- `aws_glacier_vault_lock`：Vault Lock
