# Subnet：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC**：サブネットはVPC内に作成
  - **Availability Zone**：サブネットは1つのAZに紐づく
  - **Route Table**：サブネットの通信経路を制御

## 内部的な仕組み（ざっくり）
- **なぜサブネットに分けるのか**：役割分離（Public/Private）、AZ分散、セキュリティ境界
- **なぜAZごとにサブネットが必要なのか**：1つのサブネットは1つのAZにしか配置できない
- **Public/Privateの違い**：ルートテーブルに0.0.0.0/0 → IGWがあるかどうか
- **制約**：サブネットのCIDRは/16〜/28、VPCのCIDR内に収まる必要がある

## よくある構成パターン
### パターン1：シングルAZ構成
- 構成概要：1 Public Subnet + 1 Private Subnet（同一AZ）
- 使う場面：開発環境、コスト優先

### パターン2：Multi-AZ構成（2AZ）
- 構成概要：
  - AZ-a: Public Subnet + Private Subnet
  - AZ-c: Public Subnet + Private Subnet
- 使う場面：本番環境、高可用性が必要なシステム

### パターン3：3層アーキテクチャ（Multi-AZ）
- 構成概要：
  - Public Subnet（ALB用）×2
  - Private Subnet（App用）×2
  - Private Subnet（DB用）×2
- 使う場面：Webアプリケーション、セキュリティ重視

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：複数AZにサブネットを配置
- **セキュリティ**：Public/Privateの明確な分離、NACLの設定
- **コスト**：NAT Gateway配置AZ数（Multi-AZで2倍）
- **拡張性**：IPアドレス数を考慮したCIDR設計（/24で251個）

## 他サービスとの関係
- **EC2 との関係**：起動時に必ずサブネットを指定
- **RDS との関係**：DBサブネットグループ（複数サブネット指定）
- **ALB との関係**：最低2つのAZのサブネットが必要
- **NAT Gateway との関係**：PublicサブネットにNAT Gatewayを配置

## Terraformで見るとどうなる？
```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true  # Public Subnetの場合true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

主要リソース：
- `aws_subnet`：サブネット本体
- `aws_route_table_association`：ルートテーブルとの関連付け
