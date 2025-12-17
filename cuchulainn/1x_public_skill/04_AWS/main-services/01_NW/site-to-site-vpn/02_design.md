# Site-to-Site VPN：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + VGW / Transit Gateway**：AWS側VPNエンドポイント
  - **オンプレ側VPNルーター**：IPsec対応、固定パブリックIP
  - **インターネット接続**：VPN通信に必要
  - **Route Table**：VPC側・オンプレ側のルーティング設定

## 内部的な仕組み（ざっくり）
- **なぜSite-to-Site VPNが必要なのか**：低コスト・短期間でオンプレ↔AWS接続
- **IPsec VPN**：インターネット経由で暗号化トンネル構築
- **冗長構成**：2つのVPNトンネル（異なるAWS側エンドポイント）が自動作成
- **BGP / Static Routing**：動的経路（BGP）または静的経路
- **制約**：
  - 最大1.25Gbps/トンネル
  - レイテンシーはインターネット品質に依存
  - オンプレ側ルーターがIPsec対応必須

## よくある構成パターン
### パターン1：基本構成（VGW）
- 構成概要：
  - オンプレ → VPN Connection → VGW → VPC
  - 2つのトンネル（冗長化）
- 使う場面：シンプルなハイブリッド接続

### パターン2：Transit Gateway + VPN
- 構成概要：
  - オンプレ → VPN Connection → Transit Gateway → 複数VPC
- 使う場面：複数VPC接続、マルチリージョン

### パターン3：Direct Connect + VPN（ハイブリッド）
- 構成概要：
  - プライマリ：Direct Connect
  - セカンダリ：Site-to-Site VPN（バックアップ）
- 使う場面：高可用性、コスト最適化

### パターン4：マルチVPN（冗長化）
- 構成概要：
  - オンプレ側に2台のVPNルーター
  - 各ルーターから個別のVPN Connection
  - 合計4トンネル
- 使う場面：最高レベルの可用性

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：デフォルトで2トンネル（異なるAZのエンドポイント）
- **セキュリティ**：IPsec暗号化、事前共有鍵（PSK）管理
- **コスト**：$0.05/時間（月$36）+ データ転送料
- **拡張性**：最大1.25Gbps/トンネル、帯域要件が高い場合はDirect Connect

## 他サービスとの関係
- **Direct Connect との関係**：DXのバックアップとしてVPN併用
- **Transit Gateway との関係**：TGWで複数VPC接続を集約
- **VGW との関係**：シンプルな1VPC接続時はVGW
- **Accelerated VPN との関係**：Global Acceleratorで高速化・安定化

## Terraformで見るとどうなる？
```hcl
# Virtual Private Gateway
resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-vgw"
  }
}

# Customer Gateway
resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = "203.0.113.1"  # オンプレ側VPNルーターのパブリックIP
  type       = "ipsec.1"

  tags = {
    Name = "onprem-cgw"
  }
}

# VPN Connection
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = false  # BGP使用

  tags = {
    Name = "main-vpn"
  }
}

# VPC Route Propagation
resource "aws_vpn_gateway_route_propagation" "main" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.private.id
}
```

主要リソース：
- `aws_vpn_gateway`：VGW（VPC側VPNエンドポイント）
- `aws_customer_gateway`：CGW（オンプレ側情報）
- `aws_vpn_connection`：VPN Connection（トンネル）
- `aws_vpn_gateway_route_propagation`：BGP経路伝播
