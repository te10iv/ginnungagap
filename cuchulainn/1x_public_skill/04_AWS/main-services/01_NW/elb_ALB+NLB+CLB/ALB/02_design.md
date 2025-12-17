# Application Load Balancer (ALB)：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + Subnet（2つ以上のAZ）**：ALBは最低2つのAZのサブネットが必要
  - **Security Group**：ALBへのアクセス制御
  - **ターゲット（EC2/ECS/Lambda）**：振り分け先リソース
  - **ACM**：HTTPS化の証明書

## 内部的な仕組み（ざっくり）
- **なぜALBが必要なのか**：複数サーバーへの負荷分散、ヘルスチェック、Auto Scaling連携
- **L7ロードバランサー**：HTTP/HTTPSレベルで振り分け（パス、ホスト、ヘッダー）
- **なぜ2つ以上のAZが必要なのか**：高可用性確保（1AZ障害でも稼働継続）
- **制約**：
  - 最低2つのAZ（サブネット）が必要
  - IPv4/IPv6対応
  - WebSocket、HTTP/2、gRPC対応

## よくある構成パターン
### パターン1：基本的なWeb3層構成
- 構成概要：
  - Internet-facing ALB（Publicサブネット）
  - ターゲット：PrivateサブネットのEC2（Auto Scaling）
  - RDS（Privateサブネット）
- 使う場面：Webアプリケーションの基本構成

### パターン2：パスベースルーティング
- 構成概要：
  - `/api/*` → APIサーバーのターゲットグループ
  - `/admin/*` → 管理画面サーバーのターゲットグループ
  - デフォルト → フロントエンドサーバーのターゲットグループ
- 使う場面：マイクロサービス、機能別サーバー分離

### パターン3：ホストベースルーティング
- 構成概要：
  - `api.example.com` → APIターゲットグループ
  - `www.example.com` → Webターゲットグループ
- 使う場面：複数ドメイン、サブドメイン別振り分け

### パターン4：Blue/Greenデプロイ
- 構成概要：
  - ターゲットグループBlue：現行バージョン（重み80%）
  - ターゲットグループGreen：新バージョン（重み20%）
  - 徐々にGreenの重みを増やす
- 使う場面：無停止デプロイ、カナリアリリース

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：必ず2つ以上のAZ配置、ターゲットも各AZに分散
- **セキュリティ**：
  - Internet-facing（インターネット向け）vs Internal（VPC内）
  - Security Group設計（ALB→EC2、インターネット→ALB）
  - WAF統合
- **コスト**：$0.0243/時間（月$18）+ LCU課金（接続数・リクエスト数・転送量）
- **拡張性**：Auto Scalingとの連携、ターゲット自動登録/削除

## 他サービスとの関係
- **Auto Scaling との関係**：ターゲットグループに自動登録、スケールイン時は自動削除
- **ECS/Fargate との関係**：サービス作成時にALBとターゲットグループを指定
- **Lambda との関係**：HTTP APIとしてLambdaをターゲット登録可能
- **CloudFront との関係**：ALBをオリジンに設定し、グローバル高速化
- **WAF との関係**：ALBにWAFを関連付けてセキュリティ強化

## Terraformで見るとどうなる？
```hcl
# ALB本体
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false  # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

  enable_deletion_protection = false
  enable_http2               = true
}

# ターゲットグループ
resource "aws_lb_target_group" "main" {
  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}

# リスナー（HTTP）
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# リスナー（HTTPS）
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
```

主要リソース：
- `aws_lb`：ALB本体
- `aws_lb_target_group`：ターゲットグループ
- `aws_lb_listener`：リスナー（ポート・プロトコル）
- `aws_lb_listener_rule`：リスナールール（パス・ホストベースルーティング）
- `aws_lb_target_group_attachment`：ターゲット登録
