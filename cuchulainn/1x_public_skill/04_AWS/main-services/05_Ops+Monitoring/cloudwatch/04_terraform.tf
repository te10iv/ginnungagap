# CloudWatchアラームを作成し、EC2インスタンスのCPU使用率を監視します。

variable "instance_id" {
  description = "EC2 Instance ID"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN"
  type        = string
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when CPU exceeds 80%"

  dimensions = {
    InstanceId = var.instance_id
  }

  alarm_actions = [var.sns_topic_arn]
}

output "alarm_name" {
  description = "CloudWatch Alarm Name"
  value       = aws_cloudwatch_metric_alarm.cpu_alarm.alarm_name
}
