# AWS Global Accelerator：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS Global Accelerator は「**AWSグローバルネットワークを使って世界中からのアクセスを高速化・安定化する**」サービス

## ゴール（ここまでできたら合格）
- Global Acceleratorを **作成できる**
- **CloudFrontとの違いを説明できる**
- 「このユースケースにはGlobal Acceleratorが必要」と判断できる

## まず覚えること（最小セット）
- **Global Accelerator**：AWSグローバルネットワーク経由でアクセス高速化
- **Anycast IP**：2つの固定グローバルIPアドレス（地理的に最適なエッジから接続）
- **エンドポイント**：ALB / NLB / EC2 / Elastic IP
- **ヘルスチェック**：エンドポイント監視、自動フェイルオーバー
- **TCP/UDPトラフィック**：全プロトコル対応（CloudFrontはHTTP/HTTPS）

## できるようになること
- □ マネジメントコンソールでGlobal Acceleratorを作成できる
- □ エンドポイントグループにALB/NLBを追加できる
- □ 固定IPアドレスを取得できる
- □ トラフィックダイアルでトラフィック割合を調整できる

## まずやること（Hands-on）
- ALBを作成（または既存ALBを使用）
- Global Acceleratorを作成
- エンドポイントグループにALB追加
- 固定IPアドレスを取得
- 固定IPでアクセス確認

## 関連するAWSサービス（名前だけ）
- **ALB / NLB**：エンドポイント
- **EC2 / Elastic IP**：エンドポイント
- **Route 53**：DNS設定（固定IP向け）
- **CloudWatch**：ヘルスチェック・メトリクス
- **Shield Advanced**：DDoS対策強化
