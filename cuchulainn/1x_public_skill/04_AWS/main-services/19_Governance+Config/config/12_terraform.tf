# AWS Configを有効化し、AWSリソースの設定変更を記録・監査します。

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "config-bucket-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_sns_topic" "config_notifications" {
  name = "config-notifications"
}

resource "aws_iam_role" "config_role" {
  name = "ConfigRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_role" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/ConfigRole"
}

resource "aws_config_configuration_recorder" "default" {
  name     = "default"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "default" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_bucket.id
  sns_topic_arn  = aws_sns_topic.config_notifications.arn

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.default]
}

output "configuration_recorder_name" {
  description = "Config Configuration Recorder Name"
  value       = aws_config_configuration_recorder.default.name
}
