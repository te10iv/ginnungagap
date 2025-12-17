# AWS Direct Connect：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **DXロケーション**：物理的な接続ポイント
  - **オンプレ側ルーター**：BGP対応ルーター
  - **VGW / Transit Gateway**：VPC接続用ゲートウェイ
  - **Direct Connect Gateway**：マルチリージョン接続時

## 内部的な仕組み（ざっくり）
- **なぜDirect Connectが必要なのか**：安定帯域、低レイテンシー、大容量データ転送
- **Private VIF**：VPC接続（プライベートIPで通信）
- **Public VIF**：AWSパブリックサービス（S3/DynamoDB等）接続
- **BGP**：Border Gateway Protocol で経路交換
- **制約**：
  - 物理配線が必要（最低1〜数ヶ月）
  - ロケーション選定が重要

## よくある構成パターン
### パターン1：基本構成（Single DX + Single VIF）
- 構成概要：
  - オンプレ → DXロケーション → Private VIF → VGW → VPC
- 使う場面：最小構成、検証環境
- デメリット：冗長化なし（障害時は全断）

### パターン2：冗長構成（Dual DX）
- 構成概要：
  - DXロケーション A → Private VIF → VGW
  - DXロケーション B → Private VIF → VGW
- 使う場面：本番環境、高可用性
- メリット：ロケーション障害に対応

### パターン3：DX + Site-to-Site VPN（ハイブリッド）
- 構成概要：
  - プライマリ：Direct Connect
  - セカンダリ：Site-to-Site VPN（バックアップ）
- 使う場面：コスト最適化、冗長性確保

### パターン4：Transit Gateway + DX Gateway
- 構成概要：
  - オンプレ → DX → DX Gateway → Transit Gateway → 複数VPC
- 使う場面：複数VPC・マルチリージョン接続

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：冗長構成（Dual DX、DX + VPN）
- **セキュリティ**：プライベート接続、MACsec暗号化
- **コスト**：ポート時間 + データ転送料（高額、月数十万〜）
- **拡張性**：帯域増強（1G→10G→100G）

## 他サービスとの関係
- **VPN との関係**：DXのバックアップとしてVPN併用
- **Transit Gateway との関係**：TGWで複数VPC接続を集約
- **Route 53 Resolver との関係**：DX経由でDNS解決
- **CloudFront / Global Accelerator との関係**：Public VIF経由でアクセス

## Terraformで見るとどうなる？
```hcl
# Direct Connect Gateway
resource "aws_dx_gateway" "main" {
  name            = "main-dx-gateway"
  amazon_side_asn = 64512
}

# Direct Connect Gateway Association（TGW）
resource "aws_dx_gateway_association" "tgw" {
  dx_gateway_id         = aws_dx_gateway.main.id
  associated_gateway_id = aws_ec2_transit_gateway.main.id
}

# Virtual Interface（Private VIF）
resource "aws_dx_private_virtual_interface" "main" {
  connection_id = "dxcon-xxxxx"  # 物理接続ID
  name          = "main-private-vif"
  vlan          = 100
  address_family = "ipv4"
  bgp_asn       = 65000
  dx_gateway_id = aws_dx_gateway.main.id
}
```

主要リソース：
- `aws_dx_connection`：物理接続（通常はAWSコンソールで作成）
- `aws_dx_private_virtual_interface`：Private VIF
- `aws_dx_public_virtual_interface`：Public VIF
- `aws_dx_gateway`：Direct Connect Gateway
- `aws_dx_gateway_association`：VGW/TGWとの関連付け
