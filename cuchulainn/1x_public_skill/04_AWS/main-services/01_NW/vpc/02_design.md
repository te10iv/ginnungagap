# Amazon VPC：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **AWS リージョン**：VPCはリージョンごとに作成
  - **Availability Zone (AZ)**：サブネットは1つのAZに配置
  - **Route 53 Resolver**：VPC内のDNS解決

## 内部的な仕組み（ざっくり）
- **なぜCIDR設定が必要なのか**：VPC内で使えるIPアドレス範囲を予め確保するため
- **なぜサブネットを分けるのか**：Public/Private、用途別、AZ分散のため
- **なぜルートテーブルが必要なのか**：どの通信をどこに転送するかを制御するため
- **制約**：VPCのCIDRは/16〜/28、重複するCIDRのVPC同士はピアリング不可

## よくある構成パターン
### パターン1：最小構成（シングルAZ）
- 構成概要：1VPC + 1 Public Subnet + IGW
- 使う場面：開発環境、検証環境、コスト最小化

### パターン2：実務で多い構成（Multi-AZ）
- 構成概要：1VPC + Public Subnet×2 + Private Subnet×2 + IGW + NAT Gateway×2
- 使う場面：本番環境、高可用性が必要なシステム

### パターン3：3層アーキテクチャ
- 構成概要：Public（ALB）+ Private（App）+ Private（DB）の3層構成
- 使う場面：Webアプリケーション、セキュリティ重視

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：複数AZにサブネットを配置して冗長化
- **セキュリティ**：Public/Private分離、Security Group・NACLの設計
- **コスト**：NAT Gatewayは高額（Multi-AZで2倍）、代替案検討
- **拡張性**：CIDR範囲は広めに取る（後から拡張は面倒）

## 他サービスとの関係
- **EC2・RDS との関係**：必ずVPC内のサブネットに配置される
- **ALB・NLB との関係**：複数サブネット（Multi-AZ）指定が必須
- **Direct Connect・VPN との関係**：オンプレとVPCを接続
- **VPC Peering・Transit Gateway との関係**：複数VPC間の通信を実現

## Terraformで見るとどうなる？
```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```

主要リソース：
- `aws_vpc`：VPC本体
- `aws_subnet`：サブネット
- `aws_internet_gateway`：IGW
- `aws_route_table`：ルートテーブル
- `aws_route_table_association`：サブネットとの関連付け
