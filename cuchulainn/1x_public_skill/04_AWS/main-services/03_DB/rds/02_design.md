# Amazon RDS：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + Subnet**：RDS配置場所
  - **Security Group**：アクセス制御
  - **EBS**：ストレージ（SSD、プロビジョンドIOPS）
  - **CloudWatch**：メトリクス監視

## 内部的な仕組み（ざっくり）
- **なぜRDSが必要なのか**：DB管理の自動化、バックアップ、パッチ適用、高可用性
- **Multi-AZ配置**：プライマリ・スタンバイ構成、自動フェイルオーバー（数分）
- **リードレプリカ**：非同期レプリケーション、読み取り負荷分散
- **自動バックアップ**：7〜35日保持、ポイントインタイムリカバリ
- **制約**：
  - インスタンスタイプ上限あり
  - ストレージ最大64TB（MySQL/PostgreSQL）

## よくある構成パターン
### パターン1：基本構成（Single-AZ）
- 構成概要：
  - RDSインスタンス（Privateサブネット、Single-AZ）
  - EC2アプリケーションサーバー
  - 自動バックアップ有効
- 使う場面：開発環境、検証環境

### パターン2：Multi-AZ構成（本番推奨）
- 構成概要：
  - RDSインスタンス（Multi-AZ、Privateサブネット）
  - プライマリ（AZ-a）、スタンバイ（AZ-c）
  - 自動フェイルオーバー
- 使う場面：本番環境、高可用性

### パターン3：リードレプリカ構成
- 構成概要：
  - プライマリ：書き込み専用
  - リードレプリカ：読み取り専用（1〜15台）
  - 読み取り負荷分散
- 使う場面：読み取り負荷が高いシステム

### パターン4：クロスリージョンレプリカ（DR）
- 構成概要：
  - プライマリ：東京リージョン
  - リードレプリカ：大阪リージョン
  - DR対策
- 使う場面：災害対策、グローバル展開

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：本番環境は必ずMulti-AZ
- **セキュリティ**：
  - Privateサブネット配置
  - Security Group最小権限
  - 暗号化（保管時・転送時）
  - Secrets Managerで認証情報管理
- **コスト**：
  - インスタンスタイプ選定
  - Multi-AZは2倍課金
  - ストレージタイプ（gp3推奨）
- **拡張性**：リードレプリカ、垂直スケール（インスタンスタイプ変更）

## 他サービスとの関係
- **EC2 との関係**：アプリケーションサーバーからDB接続
- **Lambda との関係**：RDS Proxyでコネクション管理
- **ElastiCache との関係**：キャッシュ層でDB負荷軽減
- **DMS との関係**：データ移行、CDC（Change Data Capture）

## Terraformで見るとどうなる？
```hcl
# DBサブネットグループ
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]

  tags = {
    Name = "main-db-subnet-group"
  }
}

# RDSインスタンス（Multi-AZ）
resource "aws_db_instance" "main" {
  identifier             = "main-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  storage_encrypted      = true
  
  db_name  = "mydb"
  username = "admin"
  password = "change-me"  # 実際はSecrets Manager使用
  
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  skip_final_snapshot    = true
  deletion_protection    = true

  tags = {
    Name = "main-db"
  }
}

# リードレプリカ
resource "aws_db_instance" "replica" {
  identifier             = "main-db-replica"
  replicate_source_db    = aws_db_instance.main.identifier
  instance_class         = "db.t3.micro"
  storage_encrypted      = true
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  skip_final_snapshot    = true

  tags = {
    Name = "main-db-replica"
  }
}
```

主要リソース：
- `aws_db_instance`：RDSインスタンス
- `aws_db_subnet_group`：DBサブネットグループ
- `aws_db_parameter_group`：パラメータグループ
- `aws_db_option_group`：オプショングループ
