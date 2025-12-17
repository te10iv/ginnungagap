# Amazon ElastiCache：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + Subnet**：クラスター配置場所
  - **Security Group**：アクセス制御
  - **CloudWatch**：メトリクス監視
  - **RDS / Aurora（通常）**：バックエンドDB

## 内部的な仕組み（ざっくり）
- **なぜElastiCacheが必要なのか**：DB負荷軽減、レスポンス高速化（サブミリ秒）
- **インメモリ**：メモリ上にデータ保存、ディスクI/O不要
- **キャッシュ戦略**：
  - **Look-aside（Lazy Loading）**：キャッシュミス時にDBから取得
  - **Write-through**：書き込み時にキャッシュ更新
- **Redis vs Memcached**：
  - **Redis**：永続化、レプリケーション、Pub/Sub、Sorted Set等
  - **Memcached**：シンプル、マルチスレッド、水平スケール
- **制約**：
  - ノードサイズ上限あり
  - Redisは最大500ノード

## よくある構成パターン
### パターン1：DB負荷軽減（Look-aside）
- 構成概要：
  - アプリ → ElastiCache確認 → ヒット時返却
  - ミス時 → RDS/Aurora取得 → キャッシュ保存
- 使う場面：読み取り負荷が高いシステム

### パターン2：セッション管理（Redis）
- 構成概要：
  - Webアプリ複数台
  - Redisでセッション共有
  - スティッキーセッション不要
- 使う場面：マルチサーバー環境

### パターン3：リーダーボード（Redis Sorted Set）
- 構成概要：
  - Redis Sorted Set
  - スコアランキング
  - リアルタイム更新
- 使う場面：ゲーム、リアルタイムランキング

### パターン4：Pub/Sub（Redis）
- 構成概要：
  - Redis Pub/Sub
  - リアルタイムメッセージング
  - チャット、通知
- 使う場面：リアルタイム通信

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：Redis Cluster Modeでマルチノード
- **セキュリティ**：
  - Privateサブネット配置
  - Security Group最小権限
  - Redis AUTH（パスワード認証）
  - 転送時暗号化（TLS）
- **コスト**：
  - ノードタイプ × ノード数 × 稼働時間
  - リザーブドノード（1年契約で40%削減）
- **拡張性**：
  - Redis Cluster Mode：水平スケール
  - Memcached：水平スケール

## 他サービスとの関係
- **RDS/Aurora との関係**：キャッシュ層でDB負荷軽減
- **Lambda との関係**：Lambda→ElastiCache接続（VPC Lambda）
- **CloudWatch との関係**：メトリクス監視、キャッシュヒット率

## Terraformで見るとどうなる？
```hcl
# ElastiCacheサブネットグループ
resource "aws_elasticache_subnet_group" "main" {
  name       = "main-cache-subnet-group"
  subnet_ids = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]

  tags = {
    Name = "main-cache-subnet-group"
  }
}

# Redis（Cluster Mode無効）
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "main-redis"
  replication_group_description = "Main Redis Cluster"
  engine                     = "redis"
  engine_version             = "7.0"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 2  # プライマリ + レプリカ
  parameter_group_name       = "default.redis7"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.elasticache.id]
  
  automatic_failover_enabled = true
  multi_az_enabled           = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = "change-me-long-password"  # Redis AUTH

  tags = {
    Name = "main-redis"
  }
}

# Memcached
resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "main-memcached"
  engine               = "memcached"
  engine_version       = "1.6.17"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.elasticache.id]

  tags = {
    Name = "main-memcached"
  }
}

# Redis Cluster Mode有効
resource "aws_elasticache_replication_group" "redis_cluster" {
  replication_group_id       = "main-redis-cluster"
  replication_group_description = "Redis Cluster Mode"
  engine                     = "redis"
  engine_version             = "7.0"
  node_type                  = "cache.r6g.large"
  parameter_group_name       = "default.redis7.cluster.on"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.elasticache.id]

  cluster_mode {
    num_node_groups         = 3  # シャード数
    replicas_per_node_group = 1  # レプリカ数
  }

  automatic_failover_enabled = true
  multi_az_enabled           = true

  tags = {
    Name = "main-redis-cluster"
  }
}
```

主要リソース：
- `aws_elasticache_replication_group`：Redis（レプリケーション）
- `aws_elasticache_cluster`：Memcached or Redis（単一ノード）
- `aws_elasticache_subnet_group`：サブネットグループ
- `aws_elasticache_parameter_group`：パラメータグループ
