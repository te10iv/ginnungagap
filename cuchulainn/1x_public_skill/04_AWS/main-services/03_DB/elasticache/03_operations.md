# Amazon ElastiCache：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **フェイルオーバー**：自動フェイルオーバー（Redis Multi-AZ）
- **スケーリング**：ノード追加・削除、ノードタイプ変更
- **バックアップ**：Redisスナップショット（手動・自動）
- **パラメータグループ変更**：メモリポリシー等

## よくあるトラブル
### トラブル1：接続できない
- 症状：「Connection refused」エラー
- 原因：
  - Security Groupで接続元が許可されていない
  - VPC外からの接続試行（Public IPなし）
  - エンドポイントが間違っている
- 確認ポイント：
  - Security GroupでEC2のSGまたはIP許可
  - ポート確認（Redis:6379、Memcached:11211）
  - エンドポイント確認（マネコンで取得）

### トラブル2：メモリ不足
- 症状：エビクション（eviction）発生、キャッシュミス増加
- 原因：
  - ノードサイズ不足
  - TTL未設定でデータ蓄積
  - メモリポリシー設定ミス
- 確認ポイント：
  - CloudWatch Metricsでメモリ使用率確認
  - Evictions数確認
  - ノードタイプ変更またはノード追加
  - TTL設定でデータ自動削除

### トラブル3：パフォーマンス低下
- 症状：レスポンスが遅い
- 原因：
  - ネットワークレイテンシー
  - CPU負荷高い
  - キャッシュミス多い
- 確認ポイント：
  - CloudWatch MetricsでCPU使用率確認
  - キャッシュヒット率確認
  - ノードタイプ変更（CPUコア増強）

## 監視・ログ
- **CloudWatch Metrics**：
  - `CPUUtilization`：CPU使用率
  - `DatabaseMemoryUsagePercentage`：メモリ使用率
  - `CacheHits / CacheMisses`：キャッシュヒット・ミス
  - `Evictions`：エビクション数
  - `NetworkBytesIn / NetworkBytesOut`：ネットワーク転送量
  - `ReplicationLag`：レプリケーション遅延（Redis）
- **CloudWatch Alarm**：メモリ・CPU・エビクション閾値監視

## コストでハマりやすい点
- **ノード課金**：ノードタイプ × ノード数 × 稼働時間
  - cache.t3.micro：$0.017/時（月$12）
  - cache.r6g.large：$0.226/時（月$163）
- **データ転送料**：リージョン間、AZ間
- **バックアップ保存**：Redisスナップショット（S3保存）
- **削除忘れ**：開発環境のクラスターが稼働継続
- **コスト削減策**：
  - 適切なノードタイプ選定
  - リザーブドノード（1年契約で40%削減）
  - 開発環境は営業時間外に削除
  - TTL設定でメモリ効率化

## 実務Tips
- **Redis推奨**：永続化、レプリケーション、機能豊富
- **Memcached**：シンプルなキャッシュ、マルチスレッド
- **Privateサブネット配置**：セキュリティ強化
- **Multi-AZ必須**：本番環境（Redis）
- **Redis Cluster Mode**：大規模データ、水平スケール
- **Redis AUTH有効化**：パスワード認証
- **転送時暗号化（TLS）**：セキュリティ要件高い場合
- **キャッシュ戦略**：
  - **Look-aside（Lazy Loading）**：最も一般的、キャッシュミス時にDB取得
  - **Write-through**：書き込み時にキャッシュ更新、データ整合性高い
  - **TTL設定**：データ鮮度維持、メモリ効率化
- **キャッシュキー設計**：
  - 階層構造：`user:123:profile`
  - プレフィックス統一：`cache:product:456`
- **エビクションポリシー**：
  - `volatile-lru`：TTL付きキーから最も古いものを削除（推奨）
  - `allkeys-lru`：全キーから最も古いものを削除
- **設計時に言語化すると評価が上がるポイント**：
  - 「ElastiCacheでDB読み取り負荷を80%削減、レスポンス時間短縮」
  - 「Redis Multi-AZ構成で自動フェイルオーバー、高可用性確保」
  - 「Look-aside戦略でキャッシュミス時のみDB取得、効率的なキャッシュ」
  - 「TTL設定でデータ鮮度維持、メモリ効率化」
  - 「Redis Cluster Modeで水平スケール、大規模データ対応」
  - 「Redis AUTHと転送時暗号化でセキュリティ強化」
  - 「セッション管理にRedis使用、マルチサーバー環境でセッション共有」

## Redis vs Memcached

| 項目 | Redis | Memcached |
|------|-------|-----------|
| データ型 | String, List, Set, Sorted Set, Hash | String のみ |
| 永続化 | 対応（スナップショット） | 非対応 |
| レプリケーション | 対応（Multi-AZ） | 非対応 |
| Pub/Sub | 対応 | 非対応 |
| トランザクション | 対応 | 非対応 |
| マルチスレッド | 非対応（シングルスレッド） | 対応 |
| スケール | 垂直 + 水平（Cluster Mode） | 水平 |
| 用途 | 高機能、永続化必要 | シンプル、高スループット |

## キャッシュ戦略比較

### Look-aside（Lazy Loading）
```python
# キャッシュ確認 → ミス時DB取得
data = cache.get(key)
if data is None:
    data = db.query(key)
    cache.set(key, data, ttl=3600)
return data
```

**メリット**：必要なデータのみキャッシュ  
**デメリット**：キャッシュミス時に遅延

### Write-through
```python
# 書き込み時にキャッシュ更新
db.update(key, data)
cache.set(key, data, ttl=3600)
```

**メリット**：データ整合性高い  
**デメリット**：全書き込みでキャッシュ更新（無駄あり）

## 接続例（Python + Redis）

```python
import redis

# Redis接続
r = redis.Redis(
    host='main-redis.xxxxx.cache.amazonaws.com',
    port=6379,
    password='your-auth-token',
    ssl=True,
    decode_responses=True
)

# SET/GET
r.set('user:123', 'John Doe', ex=3600)  # TTL 3600秒
value = r.get('user:123')

# Hash
r.hset('user:123:profile', mapping={
    'name': 'John',
    'email': 'john@example.com'
})
profile = r.hgetall('user:123:profile')

# Sorted Set（ランキング）
r.zadd('leaderboard', {'user1': 100, 'user2': 200})
ranking = r.zrevrange('leaderboard', 0, 9, withscores=True)
```

## Redis主要コマンド

```bash
# 接続
redis-cli -h main-redis.xxxxx.cache.amazonaws.com -p 6379 --tls -a your-auth-token

# 基本操作
SET key value EX 3600  # TTL 3600秒
GET key
DEL key
EXISTS key
TTL key

# Hash
HSET user:123 name "John"
HGET user:123 name
HGETALL user:123

# List
LPUSH queue task1
RPOP queue

# Set
SADD tags "redis" "cache"
SMEMBERS tags

# Sorted Set
ZADD leaderboard 100 user1
ZREVRANGE leaderboard 0 9 WITHSCORES
```
