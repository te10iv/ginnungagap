# Step Functionsステートマシンを作成し、複数のLambda関数を順次実行するワークフローを構築します。

variable "lambda_function_arn" {
  description = "Lambda Function ARN"
  type        = string
}

resource "aws_iam_role" "step_functions_role" {
  name = "StepFunctionsExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_invoke_policy" {
  name = "LambdaInvokePolicy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = var.lambda_function_arn
      }
    ]
  })
}

resource "aws_sfn_state_machine" "my_state_machine" {
  name     = "my-state-machine"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "A simple workflow"
    StartAt = "HelloWorld"
    States = {
      HelloWorld = {
        Type     = "Task"
        Resource = var.lambda_function_arn
        End      = true
      }
    }
  })
}

output "state_machine_arn" {
  description = "Step Functions State Machine ARN"
  value       = aws_sfn_state_machine.my_state_machine.arn
}
