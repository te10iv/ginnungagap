# Network Load Balancer (NLB)：まずこれだけ（Lv1）

## このサービスの一言説明
- Network Load Balancer (NLB) は「**TCP/UDP/TLSトラフィックを超高速・低レイテンシーで振り分けるロードバランサー**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- NLBを **作成できる**
- **ALBとNLBの違いを説明できる**
- 「このユースケースにはNLBが必要」と判断できる

## まず覚えること（最小セット）
- **NLB（Network Load Balancer）**：L4ロードバランサー（TCP/UDP）
- **静的IP**：NLBは各AZに固定IP（Elastic IP割り当て可能）
- **超高速・低レイテンシー**：100万リクエスト/秒、マイクロ秒単位のレイテンシー
- **ターゲットグループ**：EC2/IPアドレス/ALB（NLB → ALB も可能）
- **Connection Tracking**：クライアントIPを保持（X-Forwarded-For 不要）

## できるようになること
- □ マネジメントコンソールでNLBを作成できる
- □ ターゲットグループにEC2を登録できる
- □ Elastic IPを割り当てられる
- □ TCP/UDPリスナーを設定できる

## まずやること（Hands-on）
- 2つのEC2インスタンス（異なるAZ）を起動
- ターゲットグループを作成（Protocol: TCP）
- NLBを作成（Internet-facing、2つのPublicサブネット）
- リスナー（TCP:80）を設定してアクセス確認

## 関連するAWSサービス（名前だけ）
- **EC2**：NLBのターゲット
- **ECS / Fargate**：NLBのターゲット（gRPC、TCP通信）
- **Route 53**：NLBにエイリアスレコード設定
- **Global Accelerator**：NLBの前段でグローバル高速化
- **PrivateLink**：NLBベースのプライベートサービス公開
