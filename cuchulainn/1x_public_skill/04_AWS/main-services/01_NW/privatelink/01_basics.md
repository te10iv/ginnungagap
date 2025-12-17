# AWS PrivateLink：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS PrivateLink は「**VPC間やAWSサービスへのプライベート接続を提供する**」サービス

## ゴール（ここまでできたら合格）
- PrivateLinkの **概要を説明できる**
- **VPC Peeringとの違いを説明できる**
- 「このユースケースにはPrivateLinkが必要」と判断できる

## まず覚えること（最小セット）
- **PrivateLink**：VPC間をインターネット経由せずプライベート接続
- **VPC Endpoint Service**：サービス提供側が作成（NLBベース）
- **VPC Endpoint（Interface型）**：サービス利用側が作成（ENI）
- **プライベート接続**：インターネット・NAT Gateway不要
- **マルチアカウント対応**：他AWSアカウントのサービスにも接続可能

## できるようになること
- □ VPC Endpoint Serviceを作成できる（サービス提供側）
- □ VPC Endpoint（Interface型）を作成できる（サービス利用側）
- □ サービス名を使ってプライベート接続できる
- □ マルチアカウント接続を設定できる

## まずやること（Hands-on）
- サービス提供側：NLB + VPC Endpoint Service作成
- サービス利用側：VPC Endpoint（Interface型）作成
- サービス名でエンドポイント接続
- Private DNSでサービスにアクセス確認

## 関連するAWSサービス（名前だけ）
- **NLB**：VPC Endpoint Serviceのベース
- **VPC Endpoint**：サービス利用側の接続ポイント
- **Route 53**：Private DNS解決
- **RAM（Resource Access Manager）**：サービス共有
- **S3 / DynamoDB**：ゲートウェイ型VPCエンドポイント（別種）
