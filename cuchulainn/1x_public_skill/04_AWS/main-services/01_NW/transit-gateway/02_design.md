# AWS Transit Gateway：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC**：アタッチメント対象
  - **Route Table（VPC側・TGW側）**：双方向のルーティング設定
  - **Direct Connect / VPN Gateway**：オンプレ接続
  - **RAM**：マルチアカウント共有

## 内部的な仕組み（ざっくり）
- **なぜTransit Gatewayが必要なのか**：VPC Peeringはフルメッシュ接続（N*(N-1)/2本）が必要、TGWは中央ハブで管理簡素化
- **アタッチメント**：VPC・VPN・DX・TGW Peeringを接続する単位
- **ルートテーブル**：TGW内で宛先VPC/オンプレを制御
- **制約**：
  - リージョンごとに作成（マルチリージョンはTGW Peering）
  - 5,000 VPC/アカウント（上限緩和可能）

## よくある構成パターン
### パターン1：基本的なHub-Spoke構成
- 構成概要：
  - Transit Gateway（Hub）
  - VPC A, B, C（Spoke）
  - 全VPC間で相互通信可能
- 使う場面：複数VPC管理、マイクロサービス

### パターン2：セグメント分離構成
- 構成概要：
  - 本番環境TGWルートテーブル → 本番VPC群
  - 開発環境TGWルートテーブル → 開発VPC群
  - 環境間通信は不可
- 使う場面：セキュリティ境界、環境分離

### パターン3：オンプレミス接続
- 構成概要：
  - Transit Gateway
  - VPCアタッチメント（複数VPC）
  - Direct Connect Gateway or VPN アタッチメント
  - オンプレ ↔ 全VPC間通信
- 使う場面：ハイブリッドクラウド

### パターン4：マルチリージョン構成
- 構成概要：
  - 東京リージョンTGW
  - バージニアリージョンTGW
  - TGW Peeringで接続
- 使う場面：グローバル展開、DR構成

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：TGW自体は自動Multi-AZ冗長化
- **セキュリティ**：ルートテーブルでセグメント分離、Appliance Mode（ファイアウォール経由）
- **コスト**：$0.05/時間（月$36）+ データ処理料$0.02/GB
- **拡張性**：数千VPC接続可能、50Gbps/VPCアタッチメント

## 他サービスとの関係
- **VPC Peering との関係**：2〜3 VPCならPeering、4つ以上ならTGW推奨
- **Direct Connect との関係**：DX Gateway経由でTGWに接続
- **Network Firewall との関係**：Appliance Modeで全トラフィックをファイアウォール経由
- **RAM との関係**：マルチアカウント環境でTGWを共有

## Terraformで見るとどうなる？
```hcl
# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description = "Main TGW"
  
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "main-tgw"
  }
}

# VPCアタッチメント
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_a" {
  subnet_ids         = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.vpc_a.id

  tags = {
    Name = "vpc-a-attachment"
  }
}

# TGWルートテーブル
resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "main-tgw-rt"
  }
}

# VPC側のルートテーブル
resource "aws_route" "to_vpc_b" {
  route_table_id         = aws_route_table.vpc_a_private.id
  destination_cidr_block = "10.1.0.0/16"  # VPC BのCIDR
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}
```

主要リソース：
- `aws_ec2_transit_gateway`：TGW本体
- `aws_ec2_transit_gateway_vpc_attachment`：VPCアタッチメント
- `aws_ec2_transit_gateway_route_table`：TGWルートテーブル
- `aws_route`：VPC側ルートテーブルにTGW向けルート追加
