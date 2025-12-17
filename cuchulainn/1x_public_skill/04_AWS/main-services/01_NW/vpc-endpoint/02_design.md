# VPC Endpoint：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC**：VPCエンドポイントはVPC内に作成
  - **Subnet（インターフェース型）**：ENIを配置するサブネット
  - **Route Table（ゲートウェイ型）**：S3/DynamoDBへのルート追加
  - **Security Group（インターフェース型）**：通信制御

## 内部的な仕組み（ざっくり）
- **なぜVPCエンドポイントが必要なのか**：NAT Gatewayコスト削減、セキュリティ向上
- **ゲートウェイ型の仕組み**：ルートテーブルにS3/DynamoDB向けのルートを追加
- **インターフェース型の仕組み**：ENI（Elastic Network Interface）をサブネットに配置
- **制約**：
  - ゲートウェイ型はS3・DynamoDB専用（無料）
  - インターフェース型は有料（$0.01/時間/AZ + データ処理料）

## よくある構成パターン
### パターン1：S3/DynamoDBアクセス（ゲートウェイ型）
- 構成概要：
  - S3用ゲートウェイエンドポイント
  - DynamoDB用ゲートウェイエンドポイント
  - ルートテーブルに自動でルート追加
- 使う場面：すべての環境（無料なので作成推奨）
- メリット：NAT Gateway不要、無料

### パターン2：ECRアクセス（インターフェース型 + S3ゲートウェイ型）
- 構成概要：
  - ECR API用インターフェースエンドポイント
  - ECR DKR用インターフェースエンドポイント
  - S3用ゲートウェイエンドポイント（イメージレイヤー保存先）
- 使う場面：ECS/Fargate環境、Private配置
- メリット：NAT Gateway不要でコスト削減

### パターン3：Systems Manager（SSM）用
- 構成概要：
  - ssm、ssmmessages、ec2messages の3つのインターフェースエンドポイント
- 使う場面：Privateサブネットからセッションマネージャー接続
- メリット：インターネット不要でSSM利用可能

### パターン4：Multi-AZ構成
- 構成概要：
  - 各AZのPrivateサブネットにインターフェース型エンドポイント配置
- 使う場面：本番環境、高可用性
- コスト：AZごとに課金（2AZで2倍）

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：インターフェース型は各AZに配置推奨
- **セキュリティ**：プライベート接続でインターネット経由不要
- **コスト**：
  - ゲートウェイ型：無料
  - インターフェース型：$0.01/時間/AZ（月$7/AZ）+ データ処理料
  - NAT Gatewayとのコスト比較が重要
- **拡張性**：必要なAWSサービス分だけエンドポイント作成

## 他サービスとの関係
- **S3 との関係**：ゲートウェイ型エンドポイントで無料アクセス
- **ECR との関係**：インターフェース型エンドポイント（api + dkr）+ S3ゲートウェイ型
- **Lambda との関係**：VPC Lambdaが外部AWSサービス呼び出しに使用
- **ECS/Fargate との関係**：ECRイメージPullにエンドポイント推奨
- **NAT Gateway との関係**：VPCエンドポイント使用でNAT Gateway不要に

## Terraformで見るとどうなる？
```hcl
# S3用ゲートウェイ型エンドポイント
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}

# ECR API用インターフェース型エンドポイント
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name = "ecr-api-interface-endpoint"
  }
}
```

主要リソース：
- `aws_vpc_endpoint`：VPCエンドポイント本体
- `vpc_endpoint_type`：Gateway または Interface
- `route_table_ids`：ゲートウェイ型で指定
- `subnet_ids` + `security_group_ids`：インターフェース型で指定
