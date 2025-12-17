# Amazon RDS：まずこれだけ（Lv1）

## このサービスの一言説明
- Amazon RDS は「**リレーショナルデータベースをマネージドで提供する**」AWSサービス

## ゴール（ここまでできたら合格）
- RDSインスタンスを **作成できる**
- **マネージドDBのメリットを説明できる**
- 「このアプリにはRDSが必要」と判断できる

## まず覚えること（最小セット）
- **RDS**：MySQL、PostgreSQL、MariaDB、Oracle、SQL Server、Aurora対応
- **マネージドサービス**：OS・ミドルウェア管理不要、自動バックアップ
- **DBインスタンス**：データベースサーバー
- **Multi-AZ配置**：自動フェイルオーバー、高可用性
- **リードレプリカ**：読み取り専用レプリカ、負荷分散

## できるようになること
- □ マネジメントコンソールでRDSインスタンスを作成できる
- □ EC2からRDSに接続できる
- □ バックアップ設定ができる
- □ Multi-AZ配置を設定できる

## まずやること（Hands-on）
- RDSインスタンス作成（MySQL、db.t3.micro、Single-AZ）
- Security GroupでEC2からの接続許可
- EC2からmysqlコマンドで接続
- データベース作成、テーブル作成

## 関連するAWSサービス（名前だけ）
- **VPC / Subnet**：RDS配置場所（Privateサブネット推奨）
- **Security Group**：アクセス制御
- **EC2**：アプリケーションサーバー
- **CloudWatch**：メトリクス監視
- **Secrets Manager**：認証情報管理
- **Backup**：自動バックアップ管理
