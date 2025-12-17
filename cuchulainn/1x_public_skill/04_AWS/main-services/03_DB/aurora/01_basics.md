# Amazon Aurora：まずこれだけ（Lv1）

## このサービスの一言説明
- Amazon Aurora は「**MySQL/PostgreSQL互換の高性能クラウドネイティブRDB**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- Auroraクラスターを **作成できる**
- **RDSとの違いを説明できる**
- 「高性能・高可用性が必要ならAurora」と判断できる

## まず覚えること（最小セット）
- **Aurora**：MySQL/PostgreSQL互換、標準RDSより最大5倍高速
- **クラスター構成**：プライマリ + リードレプリカ（最大15台）
- **ストレージ自動拡張**：10GB〜128TB、自動スケール
- **6コピー**：3AZに2コピーずつ保存、自動修復
- **高可用性**：フェイルオーバー時間 < 30秒

## できるようになること
- □ マネジメントコンソールでAuroraクラスターを作成できる
- □ リードレプリカを追加できる
- □ エンドポイント（Writer/Reader）の使い分けができる
- □ バックアップ設定ができる

## まずやること（Hands-on）
- Auroraクラスター作成（MySQL互換、db.t3.medium）
- リードレプリカ1台追加
- Writer Endpoint（書き込み）とReader Endpoint（読み取り）を確認
- EC2から接続してデータ投入・取得

## 関連するAWSサービス（名前だけ）
- **VPC / Subnet**：クラスター配置場所
- **Security Group**：アクセス制御
- **CloudWatch**：メトリクス監視
- **RDS Proxy**：接続プーリング
- **Database Migration Service**：データ移行
- **Lambda**：Aurora Serverless v2 と連携
