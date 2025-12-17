# AWS Global Accelerator：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **AWSグローバルネットワーク**：エッジロケーション→リージョン間の高速ネットワーク
  - **エンドポイント（ALB/NLB/EC2/EIP）**：トラフィックの振り分け先
  - **Route 53（オプション）**：固定IPへのDNS設定
  - **Shield（オプション）**：DDoS対策

## 内部的な仕組み（ざっくり）
- **なぜGlobal Acceleratorが必要なのか**：インターネット経由は遅延・不安定、AWSネットワーク経由で高速化
- **Anycast IP**：2つの固定IPが世界中のエッジロケーションでアドバタイズ、最寄りエッジに接続
- **AWSネットワーク経由**：エッジ→リージョン間はAWS専用ネットワーク（高速・安定）
- **自動フェイルオーバー**：ヘルスチェックでエンドポイント障害時に自動切り替え
- **制約**：
  - 固定IPは2つのみ
  - HTTP/HTTPSだけでなく、TCP/UDP全対応

## よくある構成パターン
### パターン1：グローバルWebアプリケーション（ALB）
- 構成概要：
  - Global Accelerator（固定IP×2）
  - エンドポイント：東京リージョンのALB
  - 世界中からのアクセスを高速化
- 使う場面：グローバルユーザー向けWebアプリ

### パターン2：マルチリージョン構成（ALB×2）
- 構成概要：
  - Global Accelerator
  - エンドポイントグループ1：東京リージョンのALB（重み100%）
  - エンドポイントグループ2：バージニアリージョンのALB（重み0%、障害時100%）
- 使う場面：DR構成、フェイルオーバー

### パターン3：非HTTPトラフィック（NLB）
- 構成概要：
  - Global Accelerator
  - エンドポイント：NLB（TCP/UDP通信）
- 使う場面：ゲームサーバー、VoIP、IoT

### パターン4：固定IP要件
- 構成概要：
  - Global Accelerator（固定IP×2）
  - エンドポイント：ALB/NLB
  - ホワイトリスト登録用
- 使う場面：外部連携、ファイアウォールルール

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：エンドポイント側で冗長化、Global Acceleratorは自動冗長化
- **セキュリティ**：
  - 固定IP（Anycast）でDDoS対策
  - Shield Advanced統合
  - Security Group（エンドポイント側）で制御
- **コスト**：$0.025/時間（月$18）+ データ転送料$0.015/GB
- **拡張性**：トラフィックダイアルでリージョン間トラフィック調整

## 他サービスとの関係
- **CloudFront との関係**：
  - CloudFront：キャッシュ、HTTP/HTTPS、静的コンテンツ
  - Global Accelerator：キャッシュなし、全プロトコル、動的コンテンツ
- **ALB/NLB との関係**：エンドポイントとして使用
- **Route 53 との関係**：固定IPにDNS設定
- **Shield Advanced との関係**：DDoS対策強化

## Terraformで見るとどうなる？
```hcl
# Global Accelerator
resource "aws_globalaccelerator_accelerator" "main" {
  name            = "main-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = aws_s3_bucket.logs.id
    flow_logs_s3_prefix = "global-accelerator/"
  }
}

# Listener
resource "aws_globalaccelerator_listener" "main" {
  accelerator_arn = aws_globalaccelerator_accelerator.main.id
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }

  port_range {
    from_port = 443
    to_port   = 443
  }
}

# Endpoint Group（東京リージョン）
resource "aws_globalaccelerator_endpoint_group" "tokyo" {
  listener_arn = aws_globalaccelerator_listener.main.id
  endpoint_group_region = "ap-northeast-1"
  traffic_dial_percentage = 100  # トラフィック100%

  endpoint_configuration {
    endpoint_id = aws_lb.tokyo_alb.arn
    weight      = 100
  }

  health_check_interval_seconds = 30
  health_check_path             = "/health"
  health_check_protocol         = "HTTP"
  threshold_count               = 3
}
```

主要リソース：
- `aws_globalaccelerator_accelerator`：Global Accelerator本体
- `aws_globalaccelerator_listener`：リスナー（ポート設定）
- `aws_globalaccelerator_endpoint_group`：エンドポイントグループ（リージョン単位）
- `endpoint_configuration`：エンドポイント（ALB/NLB/EC2/EIP）
