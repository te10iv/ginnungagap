# Amazon ElastiCache：まずこれだけ（Lv1）

## このサービスの一言説明
- Amazon ElastiCache は「**インメモリキャッシュ（Redis/Memcached）をマネージドで提供する**」AWSサービス

## ゴール（ここまでできたら合格）
- ElastiCacheクラスターを **作成できる**
- **キャッシュの役割を説明できる**
- 「DB負荷軽減にはElastiCacheが必要」と判断できる

## まず覚えること（最小セット）
- **ElastiCache**：Redis または Memcached のマネージドサービス
- **インメモリキャッシュ**：メモリ上にデータ保存、高速アクセス（サブミリ秒）
- **Redis**：永続化・レプリケーション対応、機能豊富
- **Memcached**：シンプル、マルチスレッド
- **キャッシュ戦略**：Look-aside（アプリでキャッシュ制御）、Write-through等

## できるようになること
- □ マネジメントコンソールでElastiCacheクラスターを作成できる
- □ EC2からRedis/Memcachedに接続できる
- □ キーの設定・取得ができる
- □ TTL（有効期限）を設定できる

## まずやること（Hands-on）
- ElastiCacheクラスター作成（Redis、cache.t3.micro）
- Security GroupでEC2からの接続許可
- EC2からredis-cliで接続
- SET/GET操作でキャッシュ確認

## 関連するAWSサービス（名前だけ）
- **VPC / Subnet**：ElastiCache配置場所
- **Security Group**：アクセス制御
- **RDS / Aurora**：バックエンドDB
- **EC2 / Lambda**：アプリケーションサーバー
- **CloudWatch**：メトリクス監視
