# Amazon Athena：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **S3**：データソース
  - **Glue**：データカタログ
  - **IAM**：アクセス制御

## 内部的な仕組み（ざっくり）
- **なぜAthenaが必要なのか**：S3データSQL分析、サーバーレス、低コスト
- **Presto / Trino**：分散SQLエンジン
- **スキーマオンリード**：データ読み取り時にスキーマ適用
- **課金**：スキャンしたデータ量（$5/TB）
- **パーティショニング**：スキャン量削減
- **データ形式**：CSV、JSON、Parquet、ORC等
- **制約**：
  - クエリタイムアウト：30分
  - 同時クエリ：最大20個

## よくある構成パターン
### パターン1：ログ分析
- 構成概要：
  - S3（CloudTrail / VPC Flow Logs / ALB Logs）
  - Athena
  - Glue Data Catalog
  - QuickSight（可視化）
- 使う場面：ログ分析

### パターン2：データレイク分析
- 構成概要：
  - S3（Parquet / ORC）
  - Glue（ETL）
  - Athena
  - パーティショニング（年/月/日）
- 使う場面：大規模データ分析

### パターン3：Lambda統合
- 構成概要：
  - S3
  - Lambda（クエリ実行）
  - Athena
  - SNS（結果通知）
- 使う場面：自動レポート

### パターン4：Federated Query
- 構成概要：
  - Athena
  - Data Source Connector（RDS、DynamoDB等）
  - Lambda（コネクタ）
- 使う場面：複数データソース統合分析

## 設計でよく考えるポイント
- **パフォーマンス**：
  - **パーティショニング**：年/月/日等
  - **Parquet / ORC**：列指向フォーマット
  - **圧縮**：Snappy、Gzip等
- **セキュリティ**：
  - IAM最小権限
  - S3暗号化
  - クエリ結果暗号化
- **コスト**：
  - **$5/TBスキャン**
  - パーティショニングでコスト削減
  - Parquet/ORCでコスト削減
- **拡張性**：スキャン量無制限

## 他サービスとの関係
- **S3 との関係**：データソース
- **Glue との関係**：データカタログ、ETL
- **QuickSight との関係**：可視化
- **Lambda との関係**：クエリ自動化

## Terraformで見るとどうなる？
```hcl
# S3バケット（データ）
resource "aws_s3_bucket" "data" {
  bucket = "my-athena-data"
}

# S3バケット（クエリ結果）
resource "aws_s3_bucket" "query_results" {
  bucket = "my-athena-query-results"
}

# Glueデータベース
resource "aws_glue_catalog_database" "main" {
  name = "my_database"
}

# Glueテーブル（Parquet）
resource "aws_glue_catalog_table" "parquet_table" {
  name          = "my_table"
  database_name = aws_glue_catalog_database.main.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data.bucket}/data/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name = "id"
      type = "int"
    }

    columns {
      name = "name"
      type = "string"
    }

    columns {
      name = "created_at"
      type = "timestamp"
    }
  }

  partition_keys {
    name = "year"
    type = "int"
  }

  partition_keys {
    name = "month"
    type = "int"
  }

  partition_keys {
    name = "day"
    type = "int"
  }
}

# Athena Workgroup
resource "aws_athena_workgroup" "main" {
  name = "primary"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.query_results.bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    engine_version {
      selected_engine_version = "AUTO"
    }
  }

  tags = {
    Environment = "production"
  }
}

# Athena Named Query（サンプル）
resource "aws_athena_named_query" "example" {
  name      = "example_query"
  workgroup = aws_athena_workgroup.main.id
  database  = aws_glue_catalog_database.main.name
  query     = <<EOF
SELECT *
FROM ${aws_glue_catalog_table.parquet_table.name}
WHERE year = 2024 AND month = 12
LIMIT 100;
EOF
}

# IAMポリシー（Athena実行）
resource "aws_iam_policy" "athena_execution" {
  name        = "athena-execution"
  description = "Athena execution policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StopQueryExecution"
        ]
        Resource = aws_athena_workgroup.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetPartitions"
        ]
        Resource = [
          aws_glue_catalog_database.main.arn,
          "${aws_glue_catalog_database.main.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.data.arn,
          "${aws_s3_bucket.data.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.query_results.arn}/*"
      }
    ]
  })
}
```

主要リソース：
- `aws_athena_workgroup`：ワークグループ
- `aws_glue_catalog_database`：データベース
- `aws_glue_catalog_table`：テーブル
