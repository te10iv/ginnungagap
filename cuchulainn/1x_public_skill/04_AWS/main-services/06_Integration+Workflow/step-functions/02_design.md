# AWS Step Functions：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **Lambda**：タスク実行
  - **IAM**：サービス統合権限
  - **CloudWatch**：ログ・メトリクス
  - **X-Ray**：トレーシング

## 内部的な仕組み（ざっくり）
- **なぜStep Functionsが必要なのか**：複雑ワークフロー、エラーハンドリング、可視化
- **ステートタイプ**：
  - **Task**：Lambda、AWS サービス呼び出し
  - **Choice**：条件分岐
  - **Parallel**：並列実行
  - **Wait**：待機
  - **Pass**：データ変換
  - **Succeed / Fail**：終了
- **Standard vs Express**：
  - **Standard**：最大1年実行、厳密に1回実行、監査ログ
  - **Express**：最大5分、最低1回実行、高スループット
- **制約**：
  - 実行履歴：25,000イベント
  - ペイロード：最大256KB

## よくある構成パターン
### パターン1：順次処理
- 構成概要：
  - Lambda1：データ取得
  - Lambda2：データ加工
  - Lambda3：保存
  - SNS：完了通知
- 使う場面：ETL処理

### パターン2：並列処理
- 構成概要：
  - Parallel：複数Lambda同時実行
  - 画像リサイズ、サムネイル生成、メタデータ抽出
  - すべて完了後に次ステップ
- 使う場面：並列処理

### パターン3：条件分岐
- 構成概要：
  - Choice：金額で分岐
  - 1万円未満：自動承認
  - 1万円以上：人間承認（タスクトークン）
- 使う場面：承認フロー

### パターン4：リトライ・エラーハンドリング
- 構成概要：
  - Task：API呼び出し
  - Retry：最大3回リトライ
  - Catch：エラー時の代替処理
  - SNS：エラー通知
- 使う場面：外部API統合

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：Step Functionsは高可用性（マネージド）
- **セキュリティ**：
  - IAMロール最小権限
  - タスクトークン（人間承認）
  - VPC統合（Lambda）
- **コスト**：
  - Standard：$25/百万ステート遷移
  - Express：$1/百万リクエスト + 実行時間課金
- **拡張性**：無制限同時実行

## 他サービスとの関係
- **Lambda との関係**：タスク実行
- **EventBridge との関係**：ワークフロートリガー
- **DynamoDB との関係**：直接統合（SDK統合）
- **SNS / SQS との関係**：非同期統合

## Terraformで見るとどうなる？
```hcl
# IAMロール
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

resource "aws_iam_role_policy" "step_functions" {
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# ステートマシン（Standard）
resource "aws_sfn_state_machine" "order_processing" {
  name     = "order-processing"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "Order processing workflow"
    StartAt = "ValidateOrder"
    States = {
      ValidateOrder = {
        Type     = "Task"
        Resource = aws_lambda_function.validate_order.arn
        Next     = "CheckInventory"
        Retry = [{
          ErrorEquals     = ["States.TaskFailed"]
          IntervalSeconds = 2
          MaxAttempts     = 3
          BackoffRate     = 2.0
        }]
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "NotifyFailure"
        }]
      }
      CheckInventory = {
        Type     = "Task"
        Resource = aws_lambda_function.check_inventory.arn
        Next     = "ProcessPayment"
      }
      ProcessPayment = {
        Type     = "Task"
        Resource = aws_lambda_function.process_payment.arn
        Next     = "SendConfirmation"
      }
      SendConfirmation = {
        Type     = "Task"
        Resource = aws_lambda_function.send_confirmation.arn
        End      = true
      }
      NotifyFailure = {
        Type     = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = aws_sns_topic.alerts.arn
          Message  = "Order processing failed"
        }
        End = true
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tracing_configuration {
    enabled = true
  }

  tags = {
    Name = "order-processing"
  }
}

# Expressステートマシン
resource "aws_sfn_state_machine" "realtime_processing" {
  name     = "realtime-processing"
  role_arn = aws_iam_role.step_functions.arn
  type     = "EXPRESS"

  definition = jsonencode({
    Comment = "Realtime data processing"
    StartAt = "ProcessData"
    States = {
      ProcessData = {
        Type     = "Task"
        Resource = aws_lambda_function.process_data.arn
        End      = true
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions.arn}:*"
    include_execution_data = false
    level                  = "ERROR"
  }
}

# 並列処理
resource "aws_sfn_state_machine" "parallel_processing" {
  name     = "parallel-processing"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "Parallel image processing"
    StartAt = "ProcessImage"
    States = {
      ProcessImage = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "Resize"
            States = {
              Resize = {
                Type     = "Task"
                Resource = aws_lambda_function.resize.arn
                End      = true
              }
            }
          },
          {
            StartAt = "Thumbnail"
            States = {
              Thumbnail = {
                Type     = "Task"
                Resource = aws_lambda_function.thumbnail.arn
                End      = true
              }
            }
          },
          {
            StartAt = "ExtractMetadata"
            States = {
              ExtractMetadata = {
                Type     = "Task"
                Resource = aws_lambda_function.extract_metadata.arn
                End      = true
              }
            }
          }
        ]
        Next = "SaveResults"
      }
      SaveResults = {
        Type     = "Task"
        Resource = aws_lambda_function.save_results.arn
        End      = true
      }
    }
  })
}

# 条件分岐
resource "aws_sfn_state_machine" "approval_workflow" {
  name     = "approval-workflow"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "Approval workflow with choice"
    StartAt = "CheckAmount"
    States = {
      CheckAmount = {
        Type    = "Choice"
        Choices = [
          {
            Variable      = "$.amount"
            NumericLessThan = 10000
            Next          = "AutoApprove"
          }
        ]
        Default = "RequestApproval"
      }
      AutoApprove = {
        Type = "Pass"
        Result = {
          status = "approved"
        }
        Next = "ProcessOrder"
      }
      RequestApproval = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke.waitForTaskToken"
        Parameters = {
          FunctionName = aws_lambda_function.request_approval.arn
          Payload = {
            "taskToken.$" = "$$.Task.Token"
            "orderId.$"   = "$.orderId"
          }
        }
        Next = "ProcessOrder"
      }
      ProcessOrder = {
        Type     = "Task"
        Resource = aws_lambda_function.process_order.arn
        End      = true
      }
    }
  })
}

# CloudWatch Logsロググループ
resource "aws_cloudwatch_log_group" "step_functions" {
  name              = "/aws/step-functions/order-processing"
  retention_in_days = 30
}

# EventBridge統合（トリガー）
resource "aws_cloudwatch_event_rule" "trigger_workflow" {
  name        = "trigger-step-functions"
  description = "Trigger Step Functions workflow"

  event_pattern = jsonencode({
    source      = ["myapp.orders"]
    detail-type = ["Order Created"]
  })
}

resource "aws_cloudwatch_event_target" "step_functions" {
  rule      = aws_cloudwatch_event_rule.trigger_workflow.name
  target_id = "step-functions"
  arn       = aws_sfn_state_machine.order_processing.arn
  role_arn  = aws_iam_role.eventbridge_step_functions.arn
}
```

主要リソース：
- `aws_sfn_state_machine`：ステートマシン
- `aws_sfn_activity`：アクティビティ（手動タスク）
