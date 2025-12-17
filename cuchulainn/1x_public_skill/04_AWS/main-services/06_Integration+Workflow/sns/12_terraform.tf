# SNSトピックを作成し、メールアドレスをサブスクライブします。

variable "email_address" {
  description = "Email address for subscription"
  type        = string
}

resource "aws_sns_topic" "my_notification_topic" {
  name         = "my-notification-topic"
  display_name = "My Notification Topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.my_notification_topic.arn
  protocol  = "email"
  endpoint  = var.email_address
}

output "topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.my_notification_topic.arn
}
