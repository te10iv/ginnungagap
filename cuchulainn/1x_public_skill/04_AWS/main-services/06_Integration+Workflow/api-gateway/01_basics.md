# Amazon API Gateway：まずこれだけ（Lv1）

## このサービスの一言説明
- Amazon API Gateway は「**REST/WebSocket APIの作成・管理**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- REST APIを **作成できる**
- **Lambdaと統合できる**
- 「API公開にはAPI Gatewayが必要」と判断できる

## まず覚えること（最小セット）
- **REST API**：HTTPメソッド（GET/POST等）でリソース操作
- **統合タイプ**：Lambda、HTTP、AWS サービス
- **ステージ**：dev、stg、prod等の環境
- **デプロイ**：APIの公開
- **認証**：API キー、IAM、Cognito、Lambda Authorizer

## できるようになること
- □ REST APIを作成できる
- □ Lambda関数と統合できる
- □ ステージを作成・デプロイできる
- □ API キー認証を設定できる

## まずやること（Hands-on）
- REST API作成
- Lambda関数作成（Hello World）
- API Gateway → Lambda統合
- テスト実行
- デプロイ（dev ステージ）

## 関連するAWSサービス（名前だけ）
- **Lambda**：バックエンド処理
- **Cognito**：ユーザー認証
- **DynamoDB**：データストア
- **CloudWatch**：ログ・メトリクス
- **WAF**：DDoS対策、レート制限
