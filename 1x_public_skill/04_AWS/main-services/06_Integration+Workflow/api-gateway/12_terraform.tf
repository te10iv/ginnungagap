# REST APIを作成し、Lambda関数をバックエンドとして設定します。

variable "lambda_function_arn" {
  description = "Lambda Function ARN"
  type        = string
}

data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my-api"
  description = "REST API with Lambda integration"
}

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id    = aws_api_gateway_resource.hello.id
  http_method    = "GET"
  authorization  = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

resource "aws_api_gateway_deployment" "my_api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*"
}

output "api_url" {
  description = "API URL"
  value       = "${aws_api_gateway_deployment.my_api_deployment.invoke_url}/hello"
}
