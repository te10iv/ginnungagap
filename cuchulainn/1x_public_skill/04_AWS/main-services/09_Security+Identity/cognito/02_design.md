# Amazon Cognito：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **Lambda**：トリガー（Pre SignUp、Post Confirmation等）
  - **SNS / SES**：MFA・メール通知
  - **API Gateway / ALB**：認証統合
  - **IAM**：一時的認証情報

## 内部的な仕組み（ざっくり）
- **なぜCognitoが必要なのか**：ユーザー管理の簡素化、スケーラビリティ、セキュリティ
- **ユーザープール**：
  - ユーザーディレクトリ
  - サインアップ・サインイン
  - JWT トークン発行
- **アイデンティティプール**：
  - 一時的AWS認証情報
  - S3、DynamoDB直接アクセス
- **制約**：
  - ユーザープール：最大4,000万ユーザー
  - トークン有効期限：最大1日

## よくある構成パターン
### パターン1：API認証
- 構成概要：
  - Cognito ユーザープール
  - API Gateway Authorizer
  - Lambda バックエンド
- 使う場面：モバイル・Webアプリ

### パターン2：S3直接アクセス
- 構成概要：
  - Cognito アイデンティティプール
  - 一時的AWS認証情報
  - S3バケット直接アップロード
- 使う場面：クライアント直接アクセス

### パターン3：ソーシャルログイン
- 構成概要：
  - Cognito ユーザープール
  - Google / Facebook / Apple連携
  - 統合ログイン
- 使う場面：ソーシャル認証

### パターン4：ALB認証
- 構成概要：
  - ALB Cognito認証
  - 認証済みリクエストのみ転送
  - セッション管理
- 使う場面：Webアプリケーション

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：Cognitoは高可用性
- **セキュリティ**：
  - MFA有効化
  - 強力なパスワードポリシー
  - アカウント乗っ取り保護
  - トークン有効期限
- **コスト**：
  - MAU（月間アクティブユーザー）課金
  - 最初50,000 MAU：無料
  - 50,001〜100,000：$0.0055/MAU
- **拡張性**：最大4,000万ユーザー

## 他サービスとの関係
- **API Gateway との関係**：Cognito Authorizer
- **ALB との関係**：認証統合
- **Lambda との関係**：トリガー、カスタマイズ
- **S3 / DynamoDB との関係**：アイデンティティプール経由

## Terraformで見るとどうなる？
```hcl
# Cognito ユーザープール
resource "aws_cognito_user_pool" "main" {
  name = "main-user-pool"

  # パスワードポリシー
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  # MFA設定
  mfa_configuration = "OPTIONAL"
  
  software_token_mfa_configuration {
    enabled = true
  }

  # アカウント乗っ取り保護
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  # 属性
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = false
  }

  # 自動検証
  auto_verified_attributes = ["email"]

  # Lambdaトリガー
  lambda_config {
    pre_sign_up          = aws_lambda_function.pre_signup.arn
    post_confirmation    = aws_lambda_function.post_confirmation.arn
    pre_authentication   = aws_lambda_function.pre_authentication.arn
  }

  tags = {
    Name = "main-user-pool"
  }
}

# ユーザープールクライアント
resource "aws_cognito_user_pool_client" "web" {
  name         = "web-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = ["https://example.com/callback"]
  logout_urls                          = ["https://example.com/logout"]

  # トークン有効期限
  refresh_token_validity = 30  # 日
  access_token_validity  = 60  # 分
  id_token_validity      = 60  # 分
}

# ユーザープールドメイン
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "my-app-auth"
  user_pool_id = aws_cognito_user_pool.main.id
}

# アイデンティティプール
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "main-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.web.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = true
  }
}

# アイデンティティプール IAMロール（認証済み）
resource "aws_iam_role" "authenticated" {
  name = "cognito-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
        }
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "authenticated"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "authenticated" {
  role = aws_iam_role.authenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "arn:aws:s3:::my-bucket/$${cognito-identity.amazonaws.com:sub}/*"
    }]
  })
}

# アイデンティティプールロール紐付け
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    authenticated = aws_iam_role.authenticated.arn
  }
}

# API Gateway Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.main.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.main.arn]
  identity_source = "method.request.header.Authorization"
}

# ALB認証
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.main.arn
      user_pool_client_id = aws_cognito_user_pool_client.web.id
      user_pool_domain    = aws_cognito_user_pool_domain.main.domain
    }
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
```

主要リソース：
- `aws_cognito_user_pool`：ユーザープール
- `aws_cognito_user_pool_client`：クライアント
- `aws_cognito_identity_pool`：アイデンティティプール
- `aws_cognito_user_pool_domain`：ホストされたUI
