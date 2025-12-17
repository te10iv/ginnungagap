# SQSキューを作成し、メッセージを送受信できるようにします。

resource "aws_sqs_queue" "my_queue" {
  name                      = "my-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 0
}

output "queue_url" {
  description = "SQS Queue URL"
  value       = aws_sqs_queue.my_queue.url
}

output "queue_arn" {
  description = "SQS Queue ARN"
  value       = aws_sqs_queue.my_queue.arn
}
