# Amazon Aurora：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + Subnet（3AZ推奨）**：クラスター配置場所
  - **Security Group**：アクセス制御
  - **CloudWatch**：メトリクス監視
  - **S3（内部）**：自動バックアップ保存

## 内部的な仕組み（ざっくり）
- **なぜAuroraが必要なのか**：高性能（最大5倍）、高可用性（自動フェイルオーバー30秒以内）
- **ストレージアーキテクチャ**：6コピー（3AZ × 2コピー）、4/6書き込みクォーラム、3/6読み取りクォーラム
- **自動修復**：ディスク障害を自動検出・修復
- **クラスター構成**：1つのWriter（プライマリ）+ 最大15のReader（レプリカ）
- **制約**：
  - ストレージ：10GB〜128TB（自動拡張）
  - MySQL 5.6/5.7/8.0、PostgreSQL 11/12/13/14/15互換

## よくある構成パターン
### パターン1：基本構成（Writer + Reader 1台）
- 構成概要：
  - Writer 1台（書き込み・読み取り）
  - Reader 1台（読み取り専用）
  - 自動フェイルオーバー
- 使う場面：標準的な本番環境

### パターン2：高読み取り負荷構成
- 構成概要：
  - Writer 1台
  - Reader 複数台（3〜15台）
  - 読み取り負荷分散
- 使う場面：読み取り負荷が高いシステム

### パターン3：Aurora Serverless v2
- 構成概要：
  - 自動スケール（0.5〜128 ACU）
  - 使用量に応じて自動増減
  - 従量課金
- 使う場面：負荷変動が大きい、開発環境

### パターン4：Global Database（DR）
- 構成概要：
  - プライマリリージョン：東京
  - セカンダリリージョン：大阪
  - クロスリージョンレプリケーション（< 1秒）
- 使う場面：災害対策、グローバル展開

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：3AZにインスタンス配置推奨
- **セキュリティ**：
  - Privateサブネット配置
  - 暗号化（保管時・転送時）
  - IAM認証
- **コスト**：
  - インスタンス課金（RDSの1.5〜2倍）
  - ストレージ：$0.12/GB/月
  - I/O：$0.24/100万リクエスト
  - Aurora I/O-Optimized（I/O無料、ストレージ高額）
- **拡張性**：リードレプリカ追加、垂直スケール

## 他サービスとの関係
- **RDS Proxy との関係**：接続プーリング、Lambda接続最適化
- **DMS との関係**：データ移行、CDC
- **Lambda との関係**：Aurora Serverless v2 で自動スケール
- **ElastiCache との関係**：キャッシュ層で読み取り負荷軽減

## Terraformで見るとどうなる？
```hcl
# Auroraクラスター
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.0"
  database_name           = "mydb"
  master_username         = "admin"
  master_password         = "change-me"  # 実際はSecrets Manager
  
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.aurora.id]
  
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"
  preferred_maintenance_window = "mon:04:00-mon:05:00"
  
  storage_encrypted       = true
  deletion_protection     = true
  skip_final_snapshot     = true

  tags = {
    Name = "aurora-cluster"
  }
}

# Writer（プライマリ）
resource "aws_rds_cluster_instance" "writer" {
  identifier         = "aurora-instance-writer"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  tags = {
    Name = "aurora-writer"
  }
}

# Reader（レプリカ）
resource "aws_rds_cluster_instance" "reader" {
  count              = 2  # 2台のリーダー
  identifier         = "aurora-instance-reader-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  tags = {
    Name = "aurora-reader-${count.index + 1}"
  }
}

# Aurora Serverless v2
resource "aws_rds_cluster" "serverless" {
  cluster_identifier  = "aurora-serverless-cluster"
  engine              = "aurora-mysql"
  engine_mode         = "provisioned"  # v2はprovisioned
  engine_version      = "8.0.mysql_aurora.3.04.0"
  
  serverlessv2_scaling_configuration {
    min_capacity = 0.5  # 0.5 ACU
    max_capacity = 16   # 16 ACU
  }

  # 他の設定は同様
}
```

主要リソース：
- `aws_rds_cluster`：Auroraクラスター
- `aws_rds_cluster_instance`：インスタンス（Writer/Reader）
- `aws_rds_global_cluster`：Global Database
