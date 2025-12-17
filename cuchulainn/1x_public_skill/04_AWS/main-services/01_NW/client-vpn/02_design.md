# AWS Client VPN：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + Subnet**：エンドポイントの配置先
  - **ACM**：サーバー・クライアント証明書
  - **Active Directory / Cognito**：ユーザー認証（オプション）
  - **Security Group**：VPN経由のアクセス制御

## 内部的な仕組み（ざっくり）
- **なぜClient VPNが必要なのか**：リモートワーク、外部ユーザーのVPCアクセス
- **OpenVPN互換**：汎用OpenVPNクライアントで接続可能
- **相互TLS認証**：サーバー証明書・クライアント証明書で認証
- **スプリットトンネル**：VPC向けトラフィックのみVPN経由（インターネットは直接）
- **制約**：
  - 最大接続数はエンドポイント設定による
  - 認証方式は証明書またはActive Directory/Cognito

## よくある構成パターン
### パターン1：証明書認証（基本構成）
- 構成概要：
  - Client VPNエンドポイント（Privateサブネット）
  - 相互TLS認証（サーバー・クライアント証明書）
  - VPC内リソース（EC2/RDS）にアクセス
- 使う場面：小規模チーム、シンプルな認証

### パターン2：Active Directory認証
- 構成概要：
  - Client VPNエンドポイント
  - AWS Managed Microsoft AD または AD Connector
  - 既存のADユーザー・パスワードで認証
- 使う場面：企業環境、既存AD統合

### パターン3：Multi-AZ構成
- 構成概要：
  - 複数AZのサブネットをターゲットネットワークに設定
  - 冗長性確保
- 使う場面：本番環境、高可用性

### パターン4：スプリットトンネル
- 構成概要：
  - VPC向けトラフィック：VPN経由
  - インターネット向けトラフィック：直接接続
- 使う場面：帯域節約、パフォーマンス向上

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：複数AZのサブネットに配置
- **セキュリティ**：
  - 認証方式（証明書/AD/Cognito）
  - 認可ルール（ユーザー・グループ別アクセス制御）
  - Security Group設計
- **コスト**：$0.15/時間/エンドポイント + $0.05/時間/接続
- **拡張性**：最大接続数の設計

## 他サービスとの関係
- **EC2 / RDS との関係**：リモートアクセス先
- **Active Directory との関係**：ユーザー認証統合
- **Systems Manager との関係**：セッションマネージャーの代替手段
- **Transit Gateway との関係**：複数VPCへのアクセス（TGW経由）

## Terraformで見るとどうなる？
```hcl
# Client VPNエンドポイント
resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "Main Client VPN"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = "10.100.0.0/22"  # クライアント用CIDR

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client.arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }

  split_tunnel = true  # スプリットトンネル有効化
}

# ターゲットネットワーク関連付け
resource "aws_ec2_client_vpn_network_association" "main" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = aws_subnet.private_1a.id
}

# 認可ルール
resource "aws_ec2_client_vpn_authorization_rule" "main" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = "10.0.0.0/16"  # VPC CIDR
  authorize_all_groups   = true
}
```

主要リソース：
- `aws_ec2_client_vpn_endpoint`：エンドポイント本体
- `aws_ec2_client_vpn_network_association`：サブネット関連付け
- `aws_ec2_client_vpn_authorization_rule`：認可ルール
- `aws_acm_certificate`：証明書
