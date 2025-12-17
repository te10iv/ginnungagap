# Amazon DynamoDB：まずこれだけ（Lv1）

## このサービスの一言説明
- Amazon DynamoDB は「**高速・スケーラブルなNoSQLデータベース**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- DynamoDBテーブルを **作成できる**
- **RDBとNoSQLの違いを説明できる**
- 「このユースケースにはDynamoDBが必要」と判断できる

## まず覚えること（最小セット）
- **DynamoDB**：フルマネージドNoSQLデータベース
- **テーブル**：データ保存の単位
- **プライマリキー**：パーティションキー（必須）+ ソートキー（オプション）
- **キー・バリュー型**：スキーマレス、柔軟なデータ構造
- **自動スケール**：読み取り・書き込みキャパシティの自動調整

## できるようになること
- □ マネジメントコンソールでテーブルを作成できる
- □ プライマリキーを設計できる
- □ アイテムの追加・取得・更新・削除ができる
- □ GSI（Global Secondary Index）を理解できる

## まずやること（Hands-on）
- テーブル作成（Users、パーティションキー: user_id）
- アイテム追加（user_id, name, email）
- GetItem、PutItem、UpdateItem操作
- GSI作成（email でクエリ可能に）

## 関連するAWSサービス（名前だけ）
- **Lambda**：DynamoDB Streams でイベント駆動処理
- **API Gateway**：REST API バックエンド
- **S3**：エクスポート・インポート
- **DynamoDB Accelerator (DAX)**：インメモリキャッシュ
- **CloudWatch**：メトリクス監視
- **Backup**：自動バックアップ
