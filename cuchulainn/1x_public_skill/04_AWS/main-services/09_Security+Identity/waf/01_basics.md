# AWS WAF：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS WAF は「**Webアプリケーションファイアウォール**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- Web ACLを **作成できる**
- **ルールを設定できる**
- 「Web攻撃対策にはWAFが必要」と判断できる

## まず覚えること（最小セット）
- **Web ACL**：ルールのコレクション
- **ルール**：許可・ブロック条件
- **マネージドルール**：AWS/サードパーティー提供
- **レートベースルール**：リクエスト制限（DDoS対策）
- **統合対象**：CloudFront、ALB、API Gateway

## できるようになること
- □ Web ACLを作成できる
- □ マネージドルールを追加できる
- □ ALB/CloudFrontに関連付けできる
- □ レートベースルールを設定できる

## まずやること（Hands-on）
- Web ACL作成
- AWS管理ルール追加（Core Rule Set）
- ALBに関連付け
- テスト（SQLインジェクション等をブロック確認）

## 関連するAWSサービス（名前だけ）
- **CloudFront**：CDN保護
- **ALB**：アプリケーション保護
- **API Gateway**：API保護
- **CloudWatch**：メトリクス・ログ
- **Kinesis Data Firehose**：ログ分析
