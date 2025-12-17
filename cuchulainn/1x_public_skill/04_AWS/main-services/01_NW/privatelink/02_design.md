# AWS PrivateLink：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **NLB**：サービス提供側のロードバランサー
  - **VPC + Subnet**：エンドポイントの配置先
  - **Security Group**：エンドポイントのアクセス制御
  - **Route 53**：Private DNS解決

## 内部的な仕組み（ざっくり）
- **なぜPrivateLinkが必要なのか**：VPC間接続をプライベート化、インターネット経由不要
- **VPC Endpoint Service**：NLBをベースにサービス公開
- **VPC Endpoint（Interface型）**：ENIをサブネットに配置して接続
- **Private DNS**：サービス名でDNS解決（カスタムドメイン可能）
- **制約**：
  - NLBベース必須（ALBは不可）
  - サービス提供側・利用側それぞれ設定必要

## よくある構成パターン
### パターン1：マルチアカウント接続
- 構成概要：
  - アカウントA：VPC Endpoint Service（NLB + サービス）
  - アカウントB：VPC Endpoint（Interface型）
  - プライベート接続
- 使う場面：SaaS提供、マルチアカウント環境

### パターン2：パートナーサービス接続
- 構成概要：
  - パートナー：VPC Endpoint Service
  - 自社VPC：VPC Endpoint
  - インターネット経由せずプライベート接続
- 使う場面：SaaS利用、パートナー連携

### パターン3：AWSサービス接続（Powered by PrivateLink）
- 構成概要：
  - AWSサービス（S3/DynamoDB除く）にPrivateLink経由接続
  - VPC Endpoint（Interface型）作成
- 使う場面：ECR、SSM、Secrets Manager等へのプライベート接続

### パターン4：Multi-AZ構成
- 構成概要：
  - 各AZにVPC Endpoint配置
  - 冗長性確保
- 使う場面：本番環境、高可用性

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：各AZにエンドポイント配置
- **セキュリティ**：
  - プライベート接続（インターネット経由不要）
  - エンドポイントポリシー（IAM）
  - Security Group制御
- **コスト**：$0.01/時間/AZ（月$7/AZ）+ データ処理料$0.01/GB
- **拡張性**：複数VPCから同一サービスに接続可能

## 他サービスとの関係
- **NLB との関係**：VPC Endpoint ServiceはNLBベース必須
- **VPC Peering との関係**：PeeringはVPC全体、PrivateLinkは特定サービスのみ
- **Transit Gateway との関係**：TGWは複数VPC全体接続、PrivateLinkは特定サービス
- **AWSサービス との関係**：ECR/SSM/Secrets Manager等にPrivateLink経由接続

## Terraformで見るとどうなる？
```hcl
# サービス提供側：VPC Endpoint Service
resource "aws_vpc_endpoint_service" "main" {
  acceptance_required        = true  # 接続承認が必要
  network_load_balancer_arns = [aws_lb.main.arn]

  tags = {
    Name = "main-endpoint-service"
  }
}

# サービス利用側：VPC Endpoint（Interface型）
resource "aws_vpc_endpoint" "consumer" {
  vpc_id              = aws_vpc.consumer.id
  service_name        = aws_vpc_endpoint_service.main.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = false  # カスタムDNS使用

  tags = {
    Name = "consumer-endpoint"
  }
}

# エンドポイント接続承認（サービス提供側）
resource "aws_vpc_endpoint_service_allowed_principal" "main" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.main.id
  principal_arn           = "arn:aws:iam::123456789012:root"  # 接続許可するAWSアカウント
}
```

主要リソース：
- `aws_vpc_endpoint_service`：VPC Endpoint Service（サービス提供側）
- `aws_vpc_endpoint`（type: Interface）：VPC Endpoint（サービス利用側）
- `aws_vpc_endpoint_service_allowed_principal`：接続許可
- `aws_lb`（type: network）：NLB（サービス提供側）
