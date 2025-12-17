# AWS Secrets Manager：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **KMS**：シークレット暗号化
  - **IAM**：アクセス制御
  - **Lambda**：ローテーション関数
  - **CloudTrail**：操作ログ

## 内部的な仕組み（ざっくり）
- **なぜSecrets Managerが必要なのか**：ハードコード排除、自動ローテーション、監査
- **自動ローテーション**：Lambda関数でRDS/Redshiftパスワード更新
- **バージョン管理**：AWSCURRENT、AWSPENDING、AWSPREVIOUS
- **VPCエンドポイント**：プライベート接続可能
- **制約**：
  - シークレットサイズ：最大64KB
  - 同時ローテーション：リージョンごと制限あり

## よくある構成パターン
### パターン1：RDS自動ローテーション
- 構成概要：
  - Secrets Manager：DBパスワード
  - 自動ローテーション（30日ごと）
  - Lambda：パスワード更新
  - RDS：自動更新
- 使う場面：データベース認証情報管理

### パターン2：API キー管理
- 構成概要：
  - Secrets Manager：外部APIキー
  - Lambda：APIキー取得
  - 手動ローテーション
- 使う場面：サードパーティー統合

### パターン3：マルチアカウント
- 構成概要：
  - アカウントA：Secrets Manager
  - アカウントB：クロスアカウントアクセス
  - リソースポリシー
- 使う場面：マルチアカウント環境

### パターン4：Lambda環境変数代替
- 構成概要：
  - Lambda：起動時にSecrets Manager取得
  - 環境変数にハードコード不要
  - セキュリティ強化
- 使う場面：サーバーレス

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：Secrets Managerは高可用性
- **セキュリティ**：
  - IAM最小権限
  - リソースベースポリシー
  - VPCエンドポイント
  - KMS暗号化
- **コスト**：
  - シークレット：$0.40/月
  - API呼び出し：$0.05/10,000リクエスト
- **拡張性**：無制限シークレット

## 他サービスとの関係
- **RDS / Aurora との関係**：自動ローテーション
- **Lambda との関係**：ローテーション関数、シークレット取得
- **KMS との関係**：暗号化
- **Parameter Store との関係**：用途分け（Secrets Managerはパスワード）

## Terraformで見るとどうなる？
```hcl
# Secrets Manager シークレット
resource "aws_secretsmanager_secret" "db_password" {
  name        = "db-password"
  description = "Database password"
  kms_key_id  = aws_kms_key.secrets.id

  tags = {
    Name = "db-password"
  }
}

# シークレット値
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "admin"
    password = "change-me"
    engine   = "mysql"
    host     = aws_db_instance.main.endpoint
    port     = 3306
    dbname   = "mydb"
  })
}

# RDS自動ローテーション
resource "aws_secretsmanager_secret_rotation" "db_password" {
  secret_id           = aws_secretsmanager_secret.db_password.id
  rotation_lambda_arn = aws_lambda_function.rotate_secret.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

# ローテーションLambda（RDS用、AWS提供テンプレート使用）
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rotate_secret" {
  name = "rotate-secret"

  application_id   = "arn:aws:serverlessrepo:us-east-1:297356227924:applications/SecretsManagerRDSMySQLRotationSingleUser"
  capabilities     = ["CAPABILITY_IAM", "CAPABILITY_RESOURCE_POLICY"]
  
  parameters = {
    endpoint            = "https://secretsmanager.ap-northeast-1.amazonaws.com"
    functionName        = "rotate-rds-mysql"
    vpcSubnetIds        = join(",", [aws_subnet.private_1a.id, aws_subnet.private_1c.id])
    vpcSecurityGroupIds = aws_security_group.lambda.id
  }
}

# リソースベースポリシー
resource "aws_secretsmanager_secret_policy" "db_password" {
  secret_arn = aws_secretsmanager_secret.db_password.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = aws_iam_role.lambda.arn
      }
      Action   = "secretsmanager:GetSecretValue"
      Resource = "*"
    }]
  })
}

# VPCエンドポイント
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

# Lambda統合
resource "aws_lambda_function" "app" {
  # ... 他の設定 ...

  environment {
    variables = {
      DB_SECRET_ARN = aws_secretsmanager_secret.db_password.arn
    }
  }
}

# IAMロール（Lambda用）
resource "aws_iam_role_policy" "lambda_secrets" {
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = aws_secretsmanager_secret.db_password.arn
    }]
  })
}
```

主要リソース：
- `aws_secretsmanager_secret`：シークレット
- `aws_secretsmanager_secret_version`：シークレット値
- `aws_secretsmanager_secret_rotation`：ローテーション設定
- `aws_secretsmanager_secret_policy`：リソースポリシー
