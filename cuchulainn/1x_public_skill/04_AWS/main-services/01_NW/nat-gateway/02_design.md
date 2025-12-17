# NAT Gateway：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + Subnet（Public）**：NAT GatewayはPublicサブネットに配置
  - **Internet Gateway**：NAT Gateway経由の通信はIGW経由でインターネットへ
  - **Elastic IP**：NAT Gatewayに1つのEIPが必要
  - **Route Table**：Privateサブネットでルート設定

## 内部的な仕組み（ざっくり）
- **なぜNAT Gatewayが必要なのか**：PrivateサブネットからのOSアップデート・外部API呼び出しに必要
- **なぜPublicサブネットに配置するのか**：Elastic IP + IGW経由でインターネット接続するため
- **なぜ片方向なのか**：セキュリティ（外部からの侵入を防ぐ）
- **制約**：1つのAZにしか配置されない（Multi-AZ対応は複数作成が必要）

## よくある構成パターン
### パターン1：シングルNAT Gateway（低コスト）
- 構成概要：1つのPublicサブネットにNAT Gateway、全PrivateサブネットがそれをターゲットにRTセット
- 使う場面：開発環境、コスト最優先、AZ障害許容
- デメリット：NAT Gateway配置AZが障害時に全Privateサブネットが影響

### パターン2：Multi-AZ NAT Gateway（推奨）
- 構成概要：
  - AZ-a: NAT Gateway (Public) ← Private サブネット（AZ-a）
  - AZ-c: NAT Gateway (Public) ← Private サブネット（AZ-c）
- 使う場面：本番環境、高可用性
- メリット：AZ障害時も他AZは影響なし
- デメリット：コストが2倍

### パターン3：VPCエンドポイント併用（コスト最適化）
- 構成概要：NAT Gateway + VPCエンドポイント（S3/DynamoDB/ECR等）
- 使う場面：AWSサービスへのアクセスが多い環境
- メリット：データ転送コスト削減、セキュリティ向上

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：Multi-AZ構成でAZ障害対策（コストは2倍）
- **セキュリティ**：外部からの侵入不可（アウトバウンドのみ）
- **コスト**：高額サービス（$0.062/時間 + $0.062/GB）、VPCエンドポイント活用
- **拡張性**：NAT Gatewayは自動スケール（最大45Gbps）

## 他サービスとの関係
- **Lambda との関係**：VPC Lambda がインターネットアクセスする場合NAT Gateway必須
- **RDS との関係**：Private配置のRDSがS3インポートする場合NAT Gateway or VPCエンドポイント
- **ECS/Fargate との関係**：Private配置でECRからイメージPullする場合NAT Gateway or VPCエンドポイント
- **VPC Endpoint との関係**：S3/DynamoDBはVPCエンドポイント経由でNAT Gateway不要

## Terraformで見るとどうなる？
```hcl
# Elastic IP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip-1a"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1a.id  # Publicサブネット

  tags = {
    Name = "nat-gateway-1a"
  }

  depends_on = [aws_internet_gateway.main]
}

# Privateサブネットのルートテーブル
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}
```

主要リソース：
- `aws_nat_gateway`：NAT Gateway本体
- `aws_eip`：Elastic IP
- `aws_route`：Privateルートテーブルへのルート追加
