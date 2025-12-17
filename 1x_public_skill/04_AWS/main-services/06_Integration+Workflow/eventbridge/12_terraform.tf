# EventBridgeルールを作成し、スケジュール実行でLambda関数を定期的に実行します。

variable "lambda_function_arn" {
  description = "Lambda Function ARN"
  type        = string
}

resource "aws_cloudwatch_event_rule" "my_scheduled_rule" {
  name                = "my-scheduled-rule"
  description         = "Scheduled rule to invoke Lambda"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.my_scheduled_rule.name
  target_id = "TargetFunctionV1"
  arn       = var.lambda_function_arn
}

resource "aws_lambda_permission" "eventbridge_invoke" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.my_scheduled_rule.arn
}

output "rule_name" {
  description = "EventBridge Rule Name"
  value       = aws_cloudwatch_event_rule.my_scheduled_rule.name
}
