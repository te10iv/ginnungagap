# Lambda関数を作成し、S3バケットへのファイルアップロード時に自動実行される関数を設定します。

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "s3_access" {
  name = "s3-access-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::/*"
      }
    ]
  })
}

resource "aws_lambda_function" "my_lambda_function" {
  filename         = "lambda_function.zip"
  function_name    = "my-lambda-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "index.lambda_handler"
  runtime         = "python3.11"
  timeout         = 30
  memory_size     = 128

  source_code_hash = filebase64sha256("lambda_function.zip")
}

# インラインコードの場合は以下のように記述
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "lambda_function.zip"
  source {
    content = <<EOF
import json

def lambda_handler(event, context):
    print("Event: " + json.dumps(event))
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
EOF
    filename = "index.py"
  }
}

output "lambda_function_arn" {
  description = "Lambda Function ARN"
  value       = aws_lambda_function.my_lambda_function.arn
}
