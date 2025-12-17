# Amazon DynamoDB：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：アクセス制御
  - **CloudWatch**：メトリクス監視
  - **KMS（オプション）**：暗号化
  - **S3（内部）**：バックアップ保存

## 内部的な仕組み（ざっくり）
- **なぜDynamoDBが必要なのか**：低レイテンシー（ミリ秒）、無制限スケール、完全マネージド
- **パーティション分散**：パーティションキーでデータ分散
- **読み取り整合性**：結果整合性（デフォルト）or 強い整合性
- **オンデマンド vs プロビジョンド**：従量課金 or キャパシティ予約
- **制約**：
  - アイテムサイズ最大400KB
  - パーティションキーの値は均等分散が重要

## よくある構成パターン
### パターン1：キー・バリューストア
- 構成概要：
  - テーブル：Sessions
  - パーティションキー：session_id
  - 用途：セッション管理
- 使う場面：高速な単純なキー検索

### パターン2：時系列データ（ソートキー活用）
- 構成概要：
  - テーブル：UserEvents
  - パーティションキー：user_id
  - ソートキー：timestamp
  - 用途：ユーザーアクティビティログ
- 使う場面：時系列データ、ログ

### パターン3：GSI活用
- 構成概要：
  - テーブル：Orders
  - プライマリキー：order_id
  - GSI：customer_id（別の軸でクエリ）
- 使う場面：複数の検索パターン

### パターン4：DynamoDB Streams + Lambda
- 構成概要：
  - テーブル変更をStreamsでキャプチャ
  - Lambda でリアルタイム処理
  - 用途：監査ログ、通知、ETL
- 使う場面：イベント駆動アーキテクチャ

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：自動Multi-AZ冗長化、グローバルテーブル
- **セキュリティ**：
  - IAMポリシー最小権限
  - 暗号化（保管時・転送時）
  - VPCエンドポイント経由接続
- **コスト**：
  - オンデマンド：読み取り・書き込み単位で課金
  - プロビジョンド：事前キャパシティ確保
  - ストレージ：$0.283/GB/月
- **拡張性**：無制限スケール、パーティションキー設計が重要

## 他サービスとの関係
- **Lambda との関係**：DynamoDB Streamsでイベントトリガー
- **API Gateway との関係**：REST APIバックエンド
- **DAX との関係**：インメモリキャッシュで読み取り高速化
- **S3 との関係**：データエクスポート・インポート

## Terraformで見るとどうなる？
```hcl
# DynamoDBテーブル（オンデマンド）
resource "aws_dynamodb_table" "users" {
  name           = "Users"
  billing_mode   = "PAY_PER_REQUEST"  # オンデマンド
  hash_key       = "user_id"
  range_key      = "timestamp"  # ソートキー（オプション）

  attribute {
    name = "user_id"
    type = "S"  # String
  }

  attribute {
    name = "timestamp"
    type = "N"  # Number
  }

  attribute {
    name = "email"
    type = "S"
  }

  # GSI（Global Secondary Index）
  global_secondary_index {
    name            = "EmailIndex"
    hash_key        = "email"
    projection_type = "ALL"
  }

  # DynamoDB Streams
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # ポイントインタイムリカバリ
  point_in_time_recovery {
    enabled = true
  }

  # 暗号化
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "Users"
  }
}

# プロビジョンドキャパシティ
resource "aws_dynamodb_table" "orders" {
  name           = "Orders"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  # Auto Scaling
  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }
}

# Auto Scaling設定
resource "aws_appautoscaling_target" "dynamodb_read" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.orders.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}
```

主要リソース：
- `aws_dynamodb_table`：テーブル
- `aws_appautoscaling_target`：Auto Scaling
- `aws_dynamodb_global_table`：グローバルテーブル
