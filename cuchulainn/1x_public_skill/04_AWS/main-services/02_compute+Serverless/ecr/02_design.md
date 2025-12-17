# Amazon ECR：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：リポジトリアクセス制御
  - **S3（内部）**：イメージ保存先
  - **VPCエンドポイント（オプション）**：プライベート接続
  - **KMS（オプション）**：イメージ暗号化

## 内部的な仕組み（ざっくり）
- **なぜECRが必要なのか**：AWSネイティブ、IAM統合、高速プル、セキュアな保存
- **プライベートレジストリ**：IAMで厳密なアクセス制御
- **イメージレイヤー**：差分管理で効率的な保存・転送
- **イメージスキャン**：脆弱性検出（push時 or 手動）
- **制約**：
  - イメージサイズ上限：10GB
  - リポジトリ数上限：10,000/リージョン

## よくある構成パターン
### パターン1：ECS/Fargate基本構成
- 構成概要：
  - ECRリポジトリ（アプリイメージ保存）
  - ECS/Fargateタスク定義（イメージ指定）
  - タスク起動時にイメージpull
- 使う場面：コンテナアプリケーション基本構成

### パターン2：CI/CD統合
- 構成概要：
  - CodeCommit（ソースコード）
  - CodeBuild（イメージビルド・ECR push）
  - CodePipeline（自動デプロイ）
  - ECS/Fargate（アプリ実行）
- 使う場面：継続的デリバリー

### パターン3：マルチアカウント共有
- 構成概要：
  - アカウントA：ECRリポジトリ（共有設定）
  - アカウントB：ECS/Fargate（イメージpull）
  - リポジトリポリシーでクロスアカウント許可
- 使う場面：組織全体でイメージ共有

### パターン4：VPCエンドポイント経由
- 構成概要：
  - ECR VPCエンドポイント（api + dkr）
  - S3 VPCエンドポイント（イメージレイヤー取得）
  - Privateサブネット配置、NAT Gateway不要
- 使う場面：セキュリティ重視、コスト削減

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：ECR自体は自動Multi-AZ冗長化
- **セキュリティ**：
  - IAMポリシー最小権限
  - イメージスキャン有効化
  - 暗号化（デフォルトAES-256）
  - VPCエンドポイント経由接続
- **コスト**：
  - ストレージ：$0.10/GB/月
  - データ転送：インターネット向けは課金
- **拡張性**：ライフサイクルポリシーで古いイメージ自動削除

## 他サービスとの関係
- **ECS/Fargate との関係**：タスク定義でイメージ指定
- **CodeBuild との関係**：CI/CDでイメージビルド・push
- **Lambda との関係**：コンテナイメージのLambda関数
- **VPCエンドポイント との関係**：プライベート接続

## Terraformで見るとどうなる？
```hcl
# ECRリポジトリ
resource "aws_ecr_repository" "app" {
  name                 = "my-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true  # push時に脆弱性スキャン
  }

  encryption_configuration {
    encryption_type = "AES256"  # デフォルト暗号化
  }

  tags = {
    Name = "my-app"
  }
}

# ライフサイクルポリシー（古いイメージ削除）
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# リポジトリポリシー（クロスアカウント共有）
resource "aws_ecr_repository_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCrossAccountPull"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::123456789012:root"
      }
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }]
  })
}
```

主要リソース：
- `aws_ecr_repository`：ECRリポジトリ
- `aws_ecr_lifecycle_policy`：ライフサイクルポリシー
- `aws_ecr_repository_policy`：リポジトリポリシー
- `aws_ecr_replication_configuration`：リージョン間レプリケーション
