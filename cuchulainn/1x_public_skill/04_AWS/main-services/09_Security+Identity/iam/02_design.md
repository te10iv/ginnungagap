# AWS IAM：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **CloudTrail**：IAM操作ログ
  - **Organizations**：マルチアカウント管理
  - **すべてのAWSサービス**：IAMで認証・認可

## 内部的な仕組み（ざっくり）
- **なぜIAMが必要なのか**：アクセス制御、セキュリティ、監査
- **認証（Authentication）**：誰か（ユーザー、ロール）
- **認可（Authorization）**：何ができるか（ポリシー）
- **ポリシー評価**：Deny優先、明示的Denyが最優先
- **制約**：
  - ポリシーサイズ：最大6,144文字（インライン）
  - アタッチ可能ポリシー：ユーザー・ロール・グループごとに10個

## よくある構成パターン
### パターン1：IAMロール（EC2用）
- 構成概要：
  - IAMロール：S3ReadOnlyAccess
  - EC2インスタンスプロファイル
  - アプリケーションからS3アクセス
- 使う場面：EC2からAWSサービスアクセス

### パターン2：IAMロール（Lambda用）
- 構成概要：
  - IAMロール：DynamoDBアクセス権限
  - Lambda実行ロール
  - Lambda関数から DynamoDB 操作
- 使う場面：サーバーレス

### パターン3：クロスアカウントアクセス
- 構成概要：
  - アカウントA：IAMユーザー
  - アカウントB：IAMロール（Trust Policy）
  - アカウントAからアカウントBのリソースアクセス
- 使う場面：マルチアカウント環境

### パターン4：IAMグループ
- 構成概要：
  - 開発者グループ：開発環境フルアクセス
  - 運用グループ：本番環境読み取り専用
  - IAMユーザーをグループに追加
- 使う場面：チーム別権限管理

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：IAMはグローバルサービス、高可用性
- **セキュリティ**：
  - 最小権限の原則
  - ルートユーザー使用禁止
  - MFA有効化
  - アクセスキー定期ローテーション
  - 未使用認証情報削除
- **コスト**：IAMは無料
- **拡張性**：無制限ユーザー・ロール

## 他サービスとの関係
- **すべてのAWSサービス との関係**：認証・認可
- **CloudTrail との関係**：IAM操作ログ記録
- **Organizations との関係**：SCP（Service Control Policy）
- **Cognito との関係**：エンドユーザー認証

## Terraformで見るとどうなる？
```hcl
# IAMロール（EC2用）
resource "aws_iam_role" "ec2" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 管理ポリシーアタッチ
resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# カスタムポリシー
resource "aws_iam_policy" "custom" {
  name        = "custom-policy"
  description = "Custom policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "arn:aws:s3:::my-bucket/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "custom" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.custom.arn
}

# インスタンスプロファイル
resource "aws_iam_instance_profile" "ec2" {
  name = "ec2-profile"
  role = aws_iam_role.ec2.name
}

# IAMユーザー
resource "aws_iam_user" "developer" {
  name = "developer"
}

# IAMグループ
resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_membership" "developers" {
  name = "developers-membership"
  users = [
    aws_iam_user.developer.name
  ]
  group = aws_iam_group.developers.name
}

resource "aws_iam_group_policy_attachment" "developers" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# クロスアカウントロール
resource "aws_iam_role" "cross_account" {
  name = "cross-account-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::123456789012:root"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "sts:ExternalId" = "unique-external-id"
        }
      }
    }]
  })
}

# Lambda実行ロール
resource "aws_iam_role" "lambda" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# インラインポリシー
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query"
      ]
      Resource = aws_dynamodb_table.main.arn
    }]
  })
}

# サービスロール（Step Functions用）
resource "aws_iam_role" "step_functions" {
  name = "step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}
```

主要リソース：
- `aws_iam_user`：IAMユーザー
- `aws_iam_role`：IAMロール
- `aws_iam_policy`：カスタムポリシー
- `aws_iam_group`：IAMグループ
