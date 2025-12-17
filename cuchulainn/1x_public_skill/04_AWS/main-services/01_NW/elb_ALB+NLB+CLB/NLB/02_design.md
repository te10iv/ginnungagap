# Network Load Balancer (NLB)：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + Subnet（2つ以上のAZ推奨）**：NLBは各AZのサブネットに配置
  - **Elastic IP（オプション）**：固定IPが必要な場合
  - **ターゲット（EC2/IP/ALB）**：振り分け先リソース

## 内部的な仕組み（ざっくり）
- **なぜNLBが必要なのか**：超高速・低レイテンシー、TCP/UDP、固定IP、クライアントIP保持
- **L4ロードバランサー**：TCP/UDPレベルで振り分け（IPアドレス・ポート）
- **Connection Tracking**：フローハッシュでターゲット選択（同じクライアントは同じターゲットへ）
- **制約**：
  - Security Group設定不可（ターゲット側で制御）
  - パスベースルーティング不可（L7機能はなし）

## よくある構成パターン
### パターン1：高速TCP/UDP通信
- 構成概要：
  - NLB（Publicサブネット）
  - ターゲット：PrivateサブネットのEC2（ゲームサーバー、IoT等）
- 使う場面：低レイテンシー要件、TCP/UDP通信、非HTTP

### パターン2：固定IP要件
- 構成概要：
  - NLB + Elastic IP（各AZ）
  - ホワイトリスト登録用に固定IP公開
- 使う場面：外部連携、ファイアウォールルール、IP制限

### パターン3：NLB → ALB（2段構成）
- 構成概要：
  - NLB（固定IP + WAF統合）
  - ALB（HTTP/HTTPSルーティング）
- 使う場面：固定IP + HTTP機能（パスルーティング）が必要

### パターン4：PrivateLink（サービス公開）
- 構成概要：
  - NLB（Internal）
  - VPC Endpoint Service
  - 他AWSアカウントからプライベート接続
- 使う場面：SaaS提供、マルチアカウント接続

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：最低2つのAZ配置、ターゲットも各AZに分散
- **セキュリティ**：
  - NLB自体にSecurity Group不可
  - ターゲットのSecurity Groupで制御（ソースIPで制限）
- **コスト**：$0.0225/時間（月$16）+ NLCU課金（ALBよりやや安い）
- **拡張性**：100万リクエスト/秒、自動スケール

## 他サービスとの関係
- **Global Accelerator との関係**：NLBをエンドポイントに設定し、グローバル高速化
- **PrivateLink との関係**：NLBベースでVPC Endpoint Serviceを作成
- **Auto Scaling との関係**：ターゲットグループに自動登録/削除
- **ECS/Fargate との関係**：gRPC、TCP通信でNLBを使用

## Terraformで見るとどうなる？
```hcl
# Elastic IP（各AZ）
resource "aws_eip" "nlb_1a" {
  domain = "vpc"
}

# NLB本体
resource "aws_lb" "main" {
  name               = "main-nlb"
  internal           = false  # Internet-facing
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  subnet_mapping {
    subnet_id     = aws_subnet.public_1a.id
    allocation_id = aws_eip.nlb_1a.id
  }
}

# ターゲットグループ
resource "aws_lb_target_group" "main" {
  name     = "main-nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }
}

# リスナー
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
```

主要リソース：
- `aws_lb`（type: network）：NLB本体
- `aws_lb_target_group`（protocol: TCP/UDP/TLS）：ターゲットグループ
- `aws_lb_listener`：リスナー
- `aws_eip`：Elastic IP（固定IP要件）
