# AWS CodeCommit：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM**：認証・認可
  - **S3**：内部データ保存（透過的）
  - **KMS**：暗号化
  - **CloudWatch Events**：トリガー

## 内部的な仕組み（ざっくり）
- **なぜCodeCommitが必要なのか**：マネージドGitリポジトリ、セキュア、AWS統合
- **Git互換**：標準Git操作使用可能
- **認証方式**：
  - **HTTPS（Git認証情報）**：IAMユーザーごと
  - **SSH**：公開鍵認証
  - **HTTPS（一時認証情報）**：MFA対応
- **暗号化**：
  - **転送中**：HTTPS / SSH
  - **保管時**：デフォルトAWS管理キー
- **制約**：
  - リポジトリサイズ：推奨2GB以下
  - ファイルサイズ：2GB以下

## よくある構成パターン
### パターン1：開発チーム（小規模）
- 構成概要：
  - CodeCommit
  - IAM（Git認証情報）
  - プルリクエスト
  - 承認ルール
- 使う場面：小規模開発

### パターン2：CI/CD統合
- 構成概要：
  - CodeCommit
  - CodePipeline（自動トリガー）
  - CodeBuild
  - CodeDeploy
- 使う場面：自動化

### パターン3：セキュア開発
- 構成概要：
  - CodeCommit
  - MFA必須
  - 承認ルール（2名承認）
  - ブランチ保護
  - CloudTrail監査
- 使う場面：本番環境

### パターン4：通知・Lambda統合
- 構成概要：
  - CodeCommit
  - CloudWatch Events
  - SNS通知
  - Lambda（カスタム処理）
- 使う場面：自動化・通知

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：
  - マネージド（Multi-AZ自動）
- **セキュリティ**：
  - IAM最小権限
  - MFA必須推奨
  - 承認ルール設定
  - ブランチ保護
- **コスト**：
  - **5ユーザー/月：無料**
  - **5ユーザー超過：$1/ユーザー/月**
  - **ストレージ：$0.06/GB/月**
  - **リクエスト：$0.001/リクエスト**
- **拡張性**：リポジトリ数無制限

## 他サービスとの関係
- **CodePipeline との関係**：ソースステージ
- **CodeBuild との関係**：ビルドトリガー
- **Lambda との関係**：イベントトリガー
- **SNS との関係**：通知

## Terraformで見るとどうなる？
```hcl
# CodeCommitリポジトリ
resource "aws_codecommit_repository" "main" {
  repository_name = "my-repo"
  description     = "My application repository"

  tags = {
    Environment = "production"
  }
}

# IAMポリシー（ReadOnly）
resource "aws_iam_policy" "codecommit_readonly" {
  name        = "codecommit-readonly"
  description = "CodeCommit read-only access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "codecommit:GitPull",
        "codecommit:GetBranch",
        "codecommit:GetCommit"
      ]
      Resource = aws_codecommit_repository.main.arn
    }]
  })
}

# IAMポリシー（FullAccess）
resource "aws_iam_policy" "codecommit_fullaccess" {
  name        = "codecommit-fullaccess"
  description = "CodeCommit full access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "codecommit:*"
      ]
      Resource = aws_codecommit_repository.main.arn
    }]
  })
}

# 承認ルールテンプレート
resource "aws_codecommit_approval_rule_template" "main" {
  name        = "require-two-approvers"
  description = "Require 2 approvers for main branch"

  content = jsonencode({
    Version               = "2018-11-08"
    DestinationReferences = ["refs/heads/main"]
    Statements = [{
      Type                    = "Approvers"
      NumberOfApprovalsNeeded = 2
      ApprovalPoolMembers     = ["arn:aws:sts::123456789012:assumed-role/Approvers/*"]
    }]
  })
}

# 承認ルールテンプレート関連付け
resource "aws_codecommit_approval_rule_template_association" "main" {
  approval_rule_template_name = aws_codecommit_approval_rule_template.main.name
  repository_name             = aws_codecommit_repository.main.repository_name
}

# CloudWatch Eventsルール（main push）
resource "aws_cloudwatch_event_rule" "codecommit_main_push" {
  name        = "codecommit-main-push"
  description = "Triggered when code is pushed to main branch"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    detail = {
      event         = ["referenceCreated", "referenceUpdated"]
      repositoryName = [aws_codecommit_repository.main.repository_name]
      referenceName = ["main"]
    }
  })
}

# CloudWatch Eventsターゲット（SNS）
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.codecommit_main_push.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.codecommit_notifications.arn
}

# CloudWatch Eventsターゲット（Lambda）
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.codecommit_main_push.name
  target_id = "InvokeLambda"
  arn       = aws_lambda_function.process_commit.arn
}

# SNSトピック
resource "aws_sns_topic" "codecommit_notifications" {
  name = "codecommit-notifications"
}

# SNSトピックポリシー
resource "aws_sns_topic_policy" "codecommit_notifications" {
  arn = aws_sns_topic.codecommit_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action   = "SNS:Publish"
      Resource = aws_sns_topic.codecommit_notifications.arn
    }]
  })
}
```

主要リソース：
- `aws_codecommit_repository`：リポジトリ
- `aws_codecommit_approval_rule_template`：承認ルール
