# AWS Lambda：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS Lambda は「**サーバーレスでコードを実行する**」サービス

## ゴール（ここまでできたら合格）
- Lambda関数を **作成できる**
- **イベントトリガーの概念を説明できる**
- 「このユースケースにはLambdaが必要」と判断できる

## まず覚えること（最小セット）
- **Lambda関数**：イベント駆動で実行されるコード
- **トリガー**：Lambda実行のきっかけ（API Gateway、S3、EventBridge等）
- **ランタイム**：実行環境（Python、Node.js、Java等）
- **IAM Role（実行ロール）**：Lambda関数が持つ権限
- **従量課金**：実行時間とメモリで課金（100万リクエスト/月まで無料）

## できるようになること
- □ マネジメントコンソールでLambda関数を作成できる
- □ イベントトリガーを設定できる（API Gateway、S3等）
- □ CloudWatch Logsでログを確認できる
- □ 環境変数を設定できる

## まずやること（Hands-on）
- マネコンでLambda関数作成（Python 3.x）
- Hello Worldコードを実行
- CloudWatch Logsでログ確認
- API Gatewayと連携してHTTP APIを作成

## 関連するAWSサービス（名前だけ）
- **API Gateway**：HTTP APIのトリガー
- **S3**：ファイルアップロードのトリガー
- **DynamoDB**：データ保存先
- **EventBridge**：スケジュール実行・イベント連携
- **SNS / SQS**：非同期処理
- **VPC**：プライベートリソースへのアクセス
