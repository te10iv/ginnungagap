# AWS CodePipeline：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **S3**：アーティファクト保存
  - **IAM**：権限管理
  - **CodeCommit / GitHub**：ソース
  - **CodeBuild**：ビルド
  - **CodeDeploy**：デプロイ
  - **CloudWatch Events**：トリガー

## 内部的な仕組み（ざっくり）
- **なぜCodePipelineが必要なのか**：CI/CD自動化、手動作業削減
- **ステージ**：Source、Build、Deploy等
- **アクション**：各ステージの処理単位
- **アーティファクト**：S3経由でステージ間受け渡し
- **実行**：
  - 自動：コミット時
  - 手動：コンソール/CLI
- **制約**：
  - パイプライン：最大1,000個/リージョン
  - ステージ：最大50個/パイプライン
  - アクション：最大50個/ステージ

## よくある構成パターン
### パターン1：基本CI/CD
- 構成概要：
  - Source：CodeCommit
  - Build：CodeBuild
  - Deploy：CodeDeploy（In-place）
- 使う場面：小規模アプリ

### パターン2：本番環境（承認付き）
- 構成概要：
  - Source：CodeCommit
  - Build：CodeBuild
  - Test：CodeBuild（テスト）
  - Manual Approval：手動承認
  - Deploy：CodeDeploy（Blue/Green）
- 使う場面：本番環境

### パターン3：マルチリージョンデプロイ
- 構成概要：
  - Source：CodeCommit
  - Build：CodeBuild
  - Deploy（us-east-1）：CodeDeploy
  - Deploy（ap-northeast-1）：CodeDeploy
- 使う場面：グローバルアプリ

### パターン4：Lambda/ECS
- 構成概要：
  - Source：CodeCommit
  - Build：CodeBuild（コンテナイメージ）
  - Deploy：CodeDeploy（Lambda/ECS）
- 使う場面：サーバーレス・コンテナ

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：
  - マネージド（Multi-AZ自動）
- **セキュリティ**：
  - IAM最小権限
  - S3暗号化
  - 手動承認ステージ
- **コスト**：
  - **$1/アクティブパイプライン/月**
  - **非アクティブ（30日以上）：無料**
- **拡張性**：最大1,000パイプライン

## 他サービスとの関係
- **CodeCommit / GitHub との関係**：ソースステージ
- **CodeBuild との関係**：ビルドステージ
- **CodeDeploy との関係**：デプロイステージ
- **SNS との関係**：通知
- **Lambda との関係**：カスタムアクション

## Terraformで見るとどうなる？
```hcl
# S3バケット（アーティファクト）
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "my-pipeline-artifacts"
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAMロール（CodePipeline）
resource "aws_iam_role" "codepipeline" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.pipeline_artifacts.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus"
        ]
        Resource = aws_codecommit_repository.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
      }
    ]
  })
}

# CodePipeline（基本）
resource "aws_codepipeline" "main" {
  name     = "my-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.main.repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.main.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ApplicationName     = aws_codedeploy_app.main.name
        DeploymentGroupName = aws_codedeploy_deployment_group.main.deployment_group_name
      }
    }
  }
}

# CodePipeline（手動承認付き）
resource "aws_codepipeline" "with_approval" {
  name     = "my-pipeline-with-approval"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        RepositoryName = aws_codecommit_repository.main.repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.main.name
      }
    }
  }

  stage {
    name = "Approval"
    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = aws_sns_topic.pipeline_approval.arn
        CustomData      = "Please approve deployment to production"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        ApplicationName     = aws_codedeploy_app.main.name
        DeploymentGroupName = aws_codedeploy_deployment_group.main.deployment_group_name
      }
    }
  }
}

# SNSトピック（承認通知）
resource "aws_sns_topic" "pipeline_approval" {
  name = "pipeline-approval"
}

# CloudWatch Eventsルール（パイプライン失敗）
resource "aws_cloudwatch_event_rule" "pipeline_failure" {
  name        = "pipeline-failure"
  description = "Triggered when pipeline fails"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      state = ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_failure_sns" {
  rule      = aws_cloudwatch_event_rule.pipeline_failure.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.pipeline_notifications.arn
}
```

主要リソース：
- `aws_codepipeline`：パイプライン
- `aws_s3_bucket`：アーティファクト保存
