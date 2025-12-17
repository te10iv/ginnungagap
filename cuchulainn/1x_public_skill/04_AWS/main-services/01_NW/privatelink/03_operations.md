# AWS PrivateLink：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **接続承認管理**：サービス提供側で接続リクエスト承認
- **エンドポイント状態監視**：available/pending/failed確認
- **Private DNS管理**：カスタムドメイン設定
- **Security Group管理**：エンドポイントのアクセス制御

## よくあるトラブル
### トラブル1：VPC Endpointで接続できない
- 症状：エンドポイント作成後もサービスにアクセス不可
- 原因：
  - サービス提供側が接続を承認していない
  - Security Groupでブロック
  - Private DNS未設定
  - エンドポイント状態が「failed」
- 確認ポイント：
  - サービス提供側で接続承認確認
  - エンドポイント状態確認（available）
  - Security Groupで443ポート許可
  - Private DNS有効化確認

### トラブル2：DNS解決できない
- 症状：サービス名でDNS解決できない
- 原因：
  - Private DNS無効化
  - Route 53 Resolver設定ミス
  - VPCのDNS設定（enableDnsSupport/enableDnsHostnames）が無効
- 確認ポイント：
  - VPC EndpointでPrivate DNS有効化確認
  - VPCのDNS設定確認
  - nslookup/digでDNS解決テスト

### トラブル3：特定AWSアカウントから接続できない
- 症状：マルチアカウント環境で特定アカウントから接続不可
- 原因：
  - サービス提供側で接続許可プリンシパルが設定されていない
  - IAMロールARNではなくアカウントARNで許可が必要
- 確認ポイント：
  - VPC Endpoint Serviceで許可プリンシパル確認
  - 接続リクエスト承認状況確認

## 監視・ログ
- **CloudWatch Metrics**：
  - エンドポイント固有のメトリクスは少ない
  - ENIのメトリクスで確認
- **VPC Flow Logs**：エンドポイントENI経由の通信ログ
- **CloudWatch Logs**：接続ログ記録（オプション）
- **CloudTrail**：エンドポイント作成/削除の記録

## コストでハマりやすい点
- **VPC Endpoint（Interface型）**：$0.01/時間/AZ（月$7/AZ）+ データ処理料$0.01/GB
  - Multi-AZ（2AZ）で月$14
  - 複数サービス（5個）で月$35〜
- **データ処理料**：$0.01/GB（PrivateLink経由のデータ）
- **NLB課金**：サービス提供側でNLB課金（$0.0225/h）
- **削除忘れ**：不要なエンドポイントは削除
- **コスト削減策**：
  - 開発環境は使用時のみ作成
  - 必要なサービスのみエンドポイント作成

## 実務Tips
- **NLBベース必須**：サービス提供側はNLBが必須（ALB不可）
- **Multi-AZ推奨**：本番環境は各AZにエンドポイント配置
- **接続承認フロー**：
  1. サービス利用側：VPC Endpoint作成
  2. サービス提供側：接続リクエスト承認
  3. 接続確立
- **Security Group設計**：
  - エンドポイントSG：ソースVPC CIDRから443許可
  - NLB（サービス提供側）：エンドポイントからの通信許可
- **Private DNS**：有効化推奨（標準サービス名で接続可能）
- **マルチアカウント共有**：
  - サービス提供側で許可プリンシパル設定
  - アカウントARN: `arn:aws:iam::123456789012:root`
- **AWSサービス接続**：ECR/SSM/Secrets Manager等はPrivateLink経由推奨（NAT Gateway不要）
- **VPC Peeringとの使い分け**：
  - **Peering**：VPC全体接続、低コスト
  - **PrivateLink**：特定サービスのみ接続、セキュリティ重視
- **設計時に言語化すると評価が上がるポイント**：
  - 「PrivateLinkでマルチアカウント環境をプライベート接続、インターネット経由不要」
  - 「NLBベースでVPC Endpoint Service作成、他アカウントにサービス提供」
  - 「Multi-AZ構成で各AZにエンドポイント配置、冗長性確保」
  - 「Private DNS有効化で標準サービス名で接続、アプリケーション変更不要」
  - 「ECR/SSMエンドポイント作成でNAT Gateway不要、コスト削減」
  - 「Security Groupでエンドポイント経由の通信を制御、セキュリティ強化」

## PrivateLink vs VPC Peering vs Transit Gateway

| 項目 | PrivateLink | VPC Peering | Transit Gateway |
|------|-------------|-------------|-----------------|
| 接続範囲 | 特定サービス | VPC全体 | VPC全体 |
| 接続元 | 多対1 | 1対1 | 多対多 |
| マルチアカウント | 簡単 | 可能 | 可能（RAM） |
| ベース | NLB | - | - |
| コスト | $0.01/h/AZ + データ処理 | データ転送のみ | $0.05/h + データ処理 |
| 用途 | SaaS提供、特定サービス公開 | 2VPC接続 | 複数VPC集約 |
| セキュリティ | 高（サービス単位） | 中（VPC全体） | 中（VPC全体） |
