# Internet Gateway (IGW)：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC**：IGWはVPCにアタッチして使用
  - **Route Table**：IGWへのルーティング設定
  - **パブリックIP**：IGW経由通信にはパブリックIPが必須

## 内部的な仕組み（ざっくり）
- **なぜIGWが必要なのか**：プライベートIPをパブリックIPに変換（NAT機能）してインターネット通信を実現
- **なぜVPCに1つだけなのか**：IGW自体が冗長化・スケール済みの完全マネージドサービス
- **なぜルートテーブル設定が必要なのか**：VPC内の通信をIGW経由にするための経路指定
- **制約**：1VPCに1IGWのみアタッチ可能、削除時はデタッチが必要

## よくある構成パターン
### パターン1：基本構成
- 構成概要：1 VPC + 1 IGW + Public Subnet + Route Table (0.0.0.0/0 → IGW)
- 使う場面：すべてのインターネット接続VPC

### パターン2：Public/Private混在
- 構成概要：
  - Public Subnet：IGW経由で直接インターネット接続
  - Private Subnet：NAT Gateway（PublicにあるがIGW経由）で間接的に接続
- 使う場面：実務のほとんど

### パターン3：Egress-Only Internet Gateway（IPv6）
- 構成概要：IPv6の場合はEgress-Only IGWを使用（アウトバウンドのみ）
- 使う場面：IPv6対応が必要な環境

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：IGW自体は冗長化済み（AZ障害の影響を受けない）
- **セキュリティ**：Security Groupでインバウンドを制限
- **コスト**：IGW自体は無料（データ転送料のみ）
- **拡張性**：IGWは自動スケール（帯域上限なし）

## 他サービスとの関係
- **NAT Gateway との関係**：NAT GatewayはPublicサブネット配置でIGW経由通信
- **ALB との関係**：Internet-facing ALBはIGW経由でクライアントと通信
- **EC2 との関係**：パブリックIPを持つEC2はIGW経由でインターネット通信
- **VPN Gateway との関係**：オンプレ接続はIGWではなくVPN Gateway

## Terraformで見るとどうなる？
```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

主要リソース：
- `aws_internet_gateway`：IGW本体
- `aws_route`：ルートテーブルへのルート追加
