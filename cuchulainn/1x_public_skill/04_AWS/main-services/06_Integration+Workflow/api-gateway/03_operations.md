# Amazon API Gateway：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **ステージ管理**：dev、stg、prod環境分離
- **CloudWatch Logs**：アクセスログ・実行ログ
- **X-Ray**：分散トレーシング
- **使用量プラン**：レート制限・クォータ

## よくあるトラブル
### トラブル1：Lambda統合エラー（500エラー）
- 症状：「Internal server error」
- 原因：
  - Lambda権限不足
  - Lambda関数エラー
  - タイムアウト（29秒超過）
  - レスポンス形式不正
- 確認ポイント：
  - Lambda権限確認（API Gateway invoke許可）
  - CloudWatch LogsでLambdaエラー確認
  - Lambda Proxy統合のレスポンス形式確認

### トラブル2：CORS エラー
- 症状：ブラウザで「CORS policy blocked」
- 原因：
  - CORSヘッダー未設定
  - OPTIONSメソッド未実装
  - Authorization ヘッダー許可不足
- 確認ポイント：
  - CORS設定確認
  - OPTIONSメソッド実装
  - `Access-Control-Allow-*` ヘッダー確認

### トラブル3：認証エラー（403 Forbidden）
- 症状：「User is not authorized」
- 原因：
  - Cognito JWTトークン期限切れ
  - Lambda Authorizerエラー
  - IAMロール権限不足
- 確認ポイント：
  - トークン有効期限確認
  - Lambda Authorizerログ確認
  - IAMポリシー確認

## 監視・ログ
- **CloudWatch Metrics**：
  - `Count`：リクエスト数
  - `IntegrationLatency`：バックエンド処理時間
  - `Latency`：全体レスポンス時間
  - `4XXError / 5XXError`：エラー数
- **アクセスログ**：詳細なリクエスト情報
- **実行ログ**：デバッグ情報（dev環境推奨）
- **X-Ray**：分散トレーシング

## コストでハマりやすい点
- **リクエスト課金**：
  - REST API：$3.50/百万リクエスト
  - HTTP API：$1.00/百万リクエスト（推奨）
  - WebSocket API：$1.00/百万接続分、$0.25/百万メッセージ
- **データ転送料**：$0.09/GB〜
- **キャッシュ**：$0.02/時〜（サイズ別）
- **カスタムドメイン**：無料
- **コスト削減策**：
  - HTTP API採用（70%削減）
  - キャッシュ活用（リクエスト削減）
  - CloudFront併用

## 実務Tips
- **HTTP API推奨**：機能がシンプルで十分なら70%コスト削減
- **Lambda Proxy統合**：レスポンス形式統一
  ```json
  {
    "statusCode": 200,
    "headers": {"Content-Type": "application/json"},
    "body": "{\"message\":\"success\"}"
  }
  ```
- **CORS設定**：SPAからのアクセス必須
- **ステージ変数**：環境別設定（Lambda ARN等）
- **使用量プラン**：
  - レート制限（例：1000リクエスト/秒）
  - クォータ（例：100万リクエスト/月）
  - API キー発行
- **カスタムドメイン**：`api.example.com`
- **CloudWatch Logs統合**：アクセスログ必須
- **X-Ray有効化**：本番環境推奨
- **WAF統合**：DDoS対策、SQLインジェクション対策
- **設計時に言語化すると評価が上がるポイント**：
  - 「API GatewayでマネージドAPI、認証・レート制限・ロギング統合」
  - 「HTTP API採用でREST APIより70%コスト削減、シンプルな要件に最適」
  - 「Lambda Proxy統合でサーバーレスAPI、スケーラビリティ確保」
  - 「Cognito Authorizerで JWT検証、ユーザー認証統合」
  - 「使用量プランでレート制限・クォータ管理、悪意あるリクエスト対策」
  - 「X-Ray統合で分散トレーシング、パフォーマンスボトルネック特定」
  - 「CloudWatch Logs統合でアクセスログ記録、監査証跡確保」

## REST API vs HTTP API

| 項目 | REST API | HTTP API |
|------|---------|---------|
| 料金 | $3.50/百万 | $1.00/百万（70%安） |
| 認証 | API キー、IAM、Cognito、Lambda | IAM、Cognito、Lambda |
| CORS | 手動設定 | 簡単設定 |
| リクエスト変換 | あり | なし |
| レスポンス変換 | あり | なし |
| キャッシュ | あり | なし |
| API キー | あり | なし |
| 用途 | 機能豊富 | シンプル、低コスト |

## Lambda Proxy統合レスポンス形式

```python
# Lambda関数例（Python）
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': 'Hello from Lambda!',
            'input': event
        })
    }
```

## CORS設定例

```hcl
# REST API CORS
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
```

## Lambda Authorizer例

```python
# Lambda Authorizer（Python）
def lambda_handler(event, context):
    token = event['authorizationToken']
    
    # トークン検証ロジック
    if token == 'valid-token':
        return generate_policy('user', 'Allow', event['methodArn'])
    else:
        return generate_policy('user', 'Deny', event['methodArn'])

def generate_policy(principal_id, effect, resource):
    return {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': resource
            }]
        }
    }
```

## 使用量プラン設定

```hcl
# 使用量プラン
resource "aws_api_gateway_usage_plan" "basic" {
  name = "basic-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.prod.stage_name
  }

  quota_settings {
    limit  = 1000000  # 100万リクエスト/月
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = 5000    # バースト上限
    rate_limit  = 1000    # 1000リクエスト/秒
  }
}

# API キー
resource "aws_api_gateway_api_key" "client" {
  name = "client-api-key"
}

# 使用量プランとAPI キー紐付け
resource "aws_api_gateway_usage_plan_key" "client" {
  key_id        = aws_api_gateway_api_key.client.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.basic.id
}
```

## CloudWatch メトリクス活用

```bash
# AWS CLI でメトリクス取得
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name Count \
  --dimensions Name=ApiName,Value=main-api \
  --start-time 2024-01-15T00:00:00Z \
  --end-time 2024-01-15T23:59:59Z \
  --period 3600 \
  --statistics Sum

# エラー率計算
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name 5XXError \
  --dimensions Name=ApiName,Value=main-api \
  --start-time 2024-01-15T00:00:00Z \
  --end-time 2024-01-15T23:59:59Z \
  --period 300 \
  --statistics Sum
```

## アクセスログ形式（推奨）

```json
{
  "requestId": "$context.requestId",
  "ip": "$context.identity.sourceIp",
  "requestTime": "$context.requestTime",
  "httpMethod": "$context.httpMethod",
  "resourcePath": "$context.resourcePath",
  "status": "$context.status",
  "protocol": "$context.protocol",
  "responseLength": "$context.responseLength",
  "integrationLatency": "$context.integrationLatency",
  "responseLatency": "$context.responseLatency",
  "errorMessage": "$context.error.message"
}
```

## ステージ変数活用例

```hcl
# ステージ変数設定
resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.main.id

  variables = {
    lambdaAlias = "dev"
    environment = "development"
  }
}

resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.main.id

  variables = {
    lambdaAlias = "prod"
    environment = "production"
  }
}

# Lambda統合でステージ変数使用
resource "aws_api_gateway_integration" "lambda" {
  # ...
  uri = "arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/${aws_lambda_function.main.arn}:$${stageVariables.lambdaAlias}/invocations"
}
```

## カスタムドメイン + Route53設定

```hcl
# ACM証明書
resource "aws_acm_certificate" "api" {
  domain_name       = "api.example.com"
  validation_method = "DNS"
}

# カスタムドメイン
resource "aws_api_gateway_domain_name" "main" {
  domain_name              = "api.example.com"
  regional_certificate_arn = aws_acm_certificate.api.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Route53レコード
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.example.com"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.main.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.main.regional_zone_id
    evaluate_target_health = true
  }
}
```
