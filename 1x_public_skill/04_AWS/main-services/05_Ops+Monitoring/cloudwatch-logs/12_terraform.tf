# CloudWatch Logsのロググループを作成し、EC2インスタンスからアプリケーションログを送信します。

resource "aws_cloudwatch_log_group" "my_app" {
  name              = "/aws/ec2/my-app"
  retention_in_days = 7
}

output "log_group_name" {
  description = "CloudWatch Logs Group Name"
  value       = aws_cloudwatch_log_group.my_app.name
}
