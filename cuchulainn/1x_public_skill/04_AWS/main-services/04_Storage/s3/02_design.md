# Amazon S3：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：アクセス制御
  - **KMS（オプション）**：暗号化
  - **CloudWatch**：メトリクス監視

## 内部的な仕組み（ざっくり）
- **なぜS3が必要なのか**：無制限ストレージ、高耐久性、スケーラブル
- **オブジェクトストレージ**：フラット構造、キー・バリュー
- **耐久性**：99.999999999%（複数AZに自動複製）
- **結果整合性**：最終的に整合（2020年12月以降は強い整合性）
- **制約**：
  - オブジェクトサイズ：5TB上限
  - バケット名：グローバル一意、DNS準拠

## よくある構成パターン
### パターン1：静的Webホスティング
- 構成概要：
  - S3バケット：Webサイトホスティング有効化
  - CloudFront：CDN
  - Route53：独自ドメイン
- 使う場面：静的サイト、SPA

### パターン2：ログ保存
- 構成概要：
  - S3バケット：アクセスログ、アプリケーションログ
  - ライフサイクルポリシー：古いログをGlacier移動
  - Athena：ログ分析
- 使う場面：ログ長期保存

### パターン3：データレイク
- 構成概要：
  - S3バケット：生データ保存
  - Glue：ETL
  - Athena：SQLクエリ
  - QuickSight：可視化
- 使う場面：ビッグデータ分析

### パターン4：バックアップ
- 構成概要：
  - S3バケット：バックアップ先
  - バージョニング有効化
  - MFA Delete有効化
  - クロスリージョンレプリケーション
- 使う場面：災害対策

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：自動Multi-AZ複製
- **セキュリティ**：
  - パブリックアクセスブロック（デフォルト有効）
  - バケットポリシー最小権限
  - IAMロール活用
  - 暗号化（SSE-S3、SSE-KMS、SSE-C）
  - VPCエンドポイント経由接続
- **コスト**：
  - ストレージクラス選択
  - ライフサイクルポリシー
  - リクエスト課金
  - データ転送料
- **拡張性**：無制限、自動スケール

## 他サービスとの関係
- **CloudFront との関係**：CDN、配信高速化、キャッシュ
- **Lambda との関係**：S3イベントトリガー（ファイルアップロード時）
- **Athena との関係**：S3データをSQLクエリ
- **Glue との関係**：ETL、データカタログ

## Terraformで見るとどうなる？
```hcl
# S3バケット
resource "aws_s3_bucket" "main" {
  bucket = "my-unique-bucket-name-12345"

  tags = {
    Name = "main-bucket"
  }
}

# バージョニング
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# パブリックアクセスブロック
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ライフサイクルポリシー
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "log-lifecycle"
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
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# バケットポリシー（CloudFront OAI）
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAI"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.main.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.main.arn}/*"
      }
    ]
  })
}

# クロスリージョンレプリケーション
resource "aws_s3_bucket_replication_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "replica-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = "STANDARD_IA"
    }
  }
}
```

主要リソース：
- `aws_s3_bucket`：S3バケット
- `aws_s3_bucket_versioning`：バージョニング
- `aws_s3_bucket_lifecycle_configuration`：ライフサイクルポリシー
- `aws_s3_bucket_policy`：バケットポリシー
