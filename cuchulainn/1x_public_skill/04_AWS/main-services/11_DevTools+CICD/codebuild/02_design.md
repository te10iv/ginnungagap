# AWS CodeBuild：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **S3**：アーティファクト保存、キャッシュ
  - **ECR**：コンテナイメージ
  - **CodeCommit / GitHub**：ソース
  - **IAM**：権限管理
  - **VPC**：VPC内リソースアクセス
  - **CloudWatch Logs**：ログ保存

## 内部的な仕組み（ざっくり）
- **なぜCodeBuildが必要なのか**：ビルド自動化、インフラ管理不要、従量課金
- **ビルド環境**：Dockerコンテナ
- **buildspec.yml**：ビルド手順定義（phases、artifacts等）
- **phases**：
  - `install`：依存関係インストール
  - `pre_build`：ビルド前処理
  - `build`：ビルド
  - `post_build`：ビルド後処理
- **アーティファクト**：S3保存
- **キャッシュ**：S3 / ローカル
- **制約**：
  - ビルドタイムアウト：最大8時間
  - 同時ビルド：デフォルト60個

## よくある構成パターン
### パターン1：基本ビルド
- 構成概要：
  - CodeCommit
  - CodeBuild
  - S3（アーティファクト）
- 使う場面：小規模アプリ

### パターン2：コンテナイメージビルド
- 構成概要：
  - CodeCommit
  - CodeBuild
  - ECR
  - ECS / Fargate
- 使う場面：コンテナアプリ

### パターン3：VPC内ビルド
- 構成概要：
  - CodeBuild（VPC設定）
  - VPC（プライベートサブネット）
  - NAT Gateway
  - RDS / ElastiCache（テスト用）
- 使う場面：プライベートリソース接続

### パターン4：並列ビルド
- 構成概要：
  - CodePipeline
  - CodeBuild（並列アクション）
  - テスト / ビルド並列実行
- 使う場面：高速CI/CD

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：
  - マネージド（Multi-AZ自動）
- **セキュリティ**：
  - IAM最小権限
  - S3暗号化
  - VPC配置（プライベートリソースアクセス）
  - Secrets Manager（認証情報）
- **コスト**：
  - **Linux：$0.005/分（一般）**
  - **Linux：$0.01/分（大容量）**
  - **キャッシュでビルド時間短縮**
- **拡張性**：最大60同時ビルド

## 他サービスとの関係
- **CodePipeline との関係**：ビルドステージ
- **CodeCommit / GitHub との関係**：ソース
- **S3 との関係**：アーティファクト保存
- **ECR との関係**：コンテナイメージ保存
- **CloudWatch Logs との関係**：ログ保存

## Terraformで見るとどうなる？
```hcl
# S3バケット（アーティファクト）
resource "aws_s3_bucket" "artifacts" {
  bucket = "my-codebuild-artifacts"
}

# IAMロール（CodeBuild）
resource "aws_iam_role" "codebuild" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.artifacts.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GitPull"
        ]
        Resource = aws_codecommit_repository.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

# CodeBuildプロジェクト（基本）
resource "aws_codebuild_project" "main" {
  name          = "my-project"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 60

  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.artifacts.bucket}/cache"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"  # small/medium/large
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true  # Docker build用

    environment_variable {
      name  = "ENVIRONMENT"
      value = "production"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.main.clone_url_http
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/my-project"
      stream_name = "build-log"
    }
  }

  tags = {
    Environment = "production"
  }
}

# CodeBuildプロジェクト（VPC内）
resource "aws_codebuild_project" "vpc" {
  name         = "my-vpc-project"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type     = "CODECOMMIT"
    location = aws_codecommit_repository.main.clone_url_http
  }

  vpc_config {
    vpc_id             = aws_vpc.main.id
    subnets            = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.codebuild.id]
  }
}

# CodeBuildプロジェクト（Docker build）
resource "aws_codebuild_project" "docker" {
  name         = "my-docker-project"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true  # Docker build必須

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = aws_ecr_repository.main.repository_url
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  source {
    type      = "CODECOMMIT"
    location  = aws_codecommit_repository.main.clone_url_http
    buildspec = "buildspec-docker.yml"
  }
}

# CloudWatch Logsグループ
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/my-project"
  retention_in_days = 7
}
```

主要リソース：
- `aws_codebuild_project`：ビルドプロジェクト
