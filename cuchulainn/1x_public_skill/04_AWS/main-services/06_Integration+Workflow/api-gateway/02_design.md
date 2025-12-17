# Amazon API Gateway：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **Lambda**：バックエンド処理（最も一般的）
  - **IAM**：認証・認可
  - **CloudWatch**：ログ・メトリクス
  - **Cognito（オプション）**：ユーザー認証
  - **WAF（オプション）**：セキュリティ

## 内部的な仕組み（ざっくり）
- **なぜAPI Gatewayが必要なのか**：マネージドAPI、認証、レート制限、スケール
- **REST API vs HTTP API**：
  - **REST API**：機能豊富（API キー、リクエスト変換等）
  - **HTTP API**：シンプル、低コスト（70%安）
- **統合タイプ**：
  - Lambda：関数実行
  - HTTP：外部エンドポイント
  - AWS サービス：DynamoDB、S3等直接統合
- **制約**：
  - タイムアウト：最大29秒
  - ペイロード：最大10MB

## よくある構成パターン
### パターン1：サーバーレスAPI
- 構成概要：
  - API Gateway（REST API）
  - Lambda：ビジネスロジック
  - DynamoDB：データストア
  - Cognito：ユーザー認証
- 使う場面：標準的なサーバーレス

### パターン2：マイクロサービスAPI
- 構成概要：
  - API Gateway
  - Lambda：複数関数（各マイクロサービス）
  - RDS / DynamoDB
  - EventBridge：サービス間連携
- 使う場面：マイクロサービスアーキテクチャ

### パターン3：既存APIのフロント
- 構成概要：
  - API Gateway（HTTP統合）
  - EC2 / ECS：既存API
  - WAF：DDoS対策
  - CloudFront：CDN
- 使う場面：既存APIの保護・拡張

### パターン4：WebSocket API
- 構成概要：
  - API Gateway（WebSocket）
  - Lambda：接続管理、メッセージ処理
  - DynamoDB：接続ID管理
- 使う場面：リアルタイム通信（チャット等）

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：API Gatewayは高可用性（マネージド）
- **セキュリティ**：
  - 認証：API キー、IAM、Cognito、Lambda Authorizer
  - CORS設定
  - WAF統合
  - カスタムドメイン + ACM証明書
- **コスト**：
  - REST API：$3.50/百万リクエスト
  - HTTP API：$1.00/百万リクエスト（70%安）
  - データ転送料
  - キャッシュ課金
- **拡張性**：自動スケール、無制限リクエスト

## 他サービスとの関係
- **Lambda との関係**：最も一般的な統合、サーバーレスAPI
- **Cognito との関係**：ユーザー認証、JWT検証
- **CloudWatch との関係**：ログ、メトリクス、アラーム
- **WAF との関係**：DDoS対策、レート制限

## Terraformで見るとどうなる？
```hcl
# REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "main-api"
  description = "Main REST API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# リソース（/users）
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "users"
}

# メソッド（GET /users）
resource "aws_api_gateway_method" "get_users" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambda統合
resource "aws_api_gateway_integration" "get_users_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.get_users.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_users.invoke_arn
}

# Lambda権限
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# デプロイ
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users.id,
      aws_api_gateway_method.get_users.id,
      aws_api_gateway_integration.get_users_lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ステージ
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "prod"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  xray_tracing_enabled = true

  tags = {
    Name = "prod"
  }
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.main.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.main.arn]
  identity_source = "method.request.header.Authorization"
}

# Lambda Authorizer
resource "aws_api_gateway_authorizer" "lambda" {
  name                   = "lambda-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.main.id
  authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.api_gateway_authorizer.arn
  type                   = "TOKEN"
  identity_source        = "method.request.header.Authorization"
}

# カスタムドメイン
resource "aws_api_gateway_domain_name" "main" {
  domain_name              = "api.example.com"
  regional_certificate_arn = aws_acm_certificate.api.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# ベースパスマッピング
resource "aws_api_gateway_base_path_mapping" "main" {
  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  domain_name = aws_api_gateway_domain_name.main.domain_name
}

# HTTP API（シンプル・低コスト）
resource "aws_apigatewayv2_api" "http" {
  name          = "http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://example.com"]
    allow_methods = ["GET", "POST", "PUT", "DELETE"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

# HTTP API統合
resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.http.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.handler.invoke_arn
  integration_method = "POST"
}

# HTTP APIルート
resource "aws_apigatewayv2_route" "get_users" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /users"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# HTTP APIステージ
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.http_api.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }
}
```

主要リソース：
- `aws_api_gateway_rest_api`：REST API
- `aws_apigatewayv2_api`：HTTP API / WebSocket API
- `aws_api_gateway_authorizer`：Authorizer
- `aws_api_gateway_domain_name`：カスタムドメイン
