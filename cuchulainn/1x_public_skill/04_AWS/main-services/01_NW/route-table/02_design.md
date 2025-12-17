# Route Table：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC**：ルートテーブルはVPC内に作成
  - **Subnet**：ルートテーブルはサブネットに関連付け
  - **Gateway/Endpoint**：ルートのターゲットとして使用

## 内部的な仕組み（ざっくり）
- **なぜルートテーブルが必要なのか**：VPC内の通信をどこに転送するか制御するため
- **ルート評価順序**：最も具体的なCIDR（プレフィックス長が長い）が優先
- **ローカルルート**：VPC内通信は自動的にローカルルートで処理（削除不可）
- **制約**：1サブネットに1ルートテーブル、1ルートテーブルに複数サブネット可能

## よくある構成パターン
### パターン1：Public サブネット用
- 構成概要：
  - 10.0.0.0/16 → local（VPC内）
  - 0.0.0.0/0 → IGW（インターネット）
- 使う場面：Publicサブネット（ALB、NAT Gateway配置用）

### パターン2：Private サブネット用（NAT Gateway経由）
- 構成概要：
  - 10.0.0.0/16 → local
  - 0.0.0.0/0 → NAT Gateway
- 使う場面：Privateサブネット（App、DB配置用）でインターネット必要

### パターン3：完全Private（インターネット不要）
- 構成概要：
  - 10.0.0.0/16 → local のみ
- 使う場面：DB専用サブネット、セキュリティ最重視

### パターン4：VPC Peering / Transit Gateway 経由
- 構成概要：
  - 10.0.0.0/16 → local
  - 10.1.0.0/16 → VPC Peering or Transit Gateway
  - 0.0.0.0/0 → NAT Gateway
- 使う場面：複数VPC間通信が必要な環境

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：NAT Gateway が複数AZにある場合、AZごとにルートテーブルを分ける
- **セキュリティ**：不要なルートは追加しない（最小権限の原則）
- **コスト**：NAT Gateway経由を減らす（VPCエンドポイント活用）
- **拡張性**：将来のVPC Peering/TGWを考慮したCIDR設計

## 他サービスとの関係
- **NAT Gateway との関係**：PrivateサブネットのルートテーブルでNAT Gatewayをターゲット指定
- **VPC Endpoint との関係**：S3/DynamoDB向けルートをVPCエンドポイント経由に変更可能
- **Transit Gateway との関係**：複数VPC/オンプレ向けルートのターゲット
- **VPN Gateway との関係**：オンプレ向けルートのターゲット

## Terraformで見るとどうなる？
```hcl
# Public用ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Private用ルートテーブル
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-rt"
  }
}

# サブネット関連付け
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

主要リソース：
- `aws_route_table`：ルートテーブル本体
- `aws_route`：個別ルート追加
- `aws_route_table_association`：サブネットとの関連付け
