# AWS Lambda：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **IAM Role**：実行ロール（権限管理）
  - **CloudWatch Logs**：ログ記録
  - **トリガー**：API Gateway、S3、EventBridge等
  - **VPC（オプション）**：プライベートリソースアクセス

## 内部的な仕組み（ざっくり）
- **なぜLambdaが必要なのか**：サーバー管理不要、自動スケール、従量課金
- **イベント駆動**：トリガーイベント発生時に自動実行
- **コールドスタート**：初回実行時の起動遅延（数秒）
- **実行時間制限**：最大15分
- **制約**：
  - メモリ：128MB〜10GB
  - ディスク容量（/tmp）：最大10GB
  - 同時実行数：リージョンごとに1,000（上限緩和可能）

## よくある構成パターン
### パターン1：API Gateway + Lambda（REST API）
- 構成概要：
  - API Gateway（REST API or HTTP API）
  - Lambda関数（ビジネスロジック）
  - DynamoDB（データ保存）
- 使う場面：サーバーレスAPI、マイクロサービス

### パターン2：S3イベント処理
- 構成概要：
  - S3バケット（画像アップロード）
  - Lambda関数（画像リサイズ）
  - S3バケット（リサイズ後画像保存）
- 使う場面：画像処理、ファイル変換

### パターン3：スケジュール実行
- 構成概要：
  - EventBridge（cron式）
  - Lambda関数（バッチ処理）
  - DynamoDB / RDS（データ処理）
- 使う場面：定期バッチ、レポート生成

### パターン4：SQSキュー処理
- 構成概要：
  - SQS（メッセージキュー）
  - Lambda関数（非同期処理）
  - 複数Lambda同時実行
- 使う場面：非同期処理、メッセージ処理

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：Lambda自体は自動Multi-AZ冗長化
- **セキュリティ**：
  - IAM Role最小権限
  - 環境変数は暗号化（KMS）
  - VPC Lambda時のVPCエンドポイント活用
- **コスト**：
  - 実行時間とメモリで課金
  - 無料枠：100万リクエスト/月
- **拡張性**：自動スケール、同時実行数制御

## 他サービスとの関係
- **API Gateway との関係**：HTTP APIのバックエンド
- **S3 との関係**：イベントトリガー（オブジェクト作成/削除）
- **DynamoDB との関係**：データ保存、Streams連携
- **EventBridge との関係**：スケジュール実行、イベントルーティング
- **SQS との関係**：非同期メッセージ処理

## Terraformで見るとどうなる？
```hcl
# Lambda関数
resource "aws_lambda_function" "main" {
  filename      = "lambda.zip"
  function_name = "my-lambda-function"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.main.name
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
    security_group_ids = [aws_security_group.lambda.id]
  }
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

# Lambda権限（API Gateway呼び出し）
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}
```

主要リソース：
- `aws_lambda_function`：Lambda関数
- `aws_iam_role`：実行ロール
- `aws_lambda_permission`：他サービスからの呼び出し許可
- `aws_lambda_event_source_mapping`：イベントソース設定（SQS/Kinesis/DynamoDB Streams）
