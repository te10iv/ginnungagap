# CodeDeployアプリケーションとデプロイメントグループを作成し、EC2インスタンスにアプリケーションをデプロイします。

variable "instance_tag_key" {
  description = "EC2 Instance Tag Key"
  type        = string
  default     = "Name"
}

variable "instance_tag_value" {
  description = "EC2 Instance Tag Value"
  type        = string
  default     = "my-instance"
}

resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_role" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "my_app" {
  name             = "my-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "my_deployment_group" {
  app_name              = aws_codedeploy_app.my_app.name
  deployment_group_name = "my-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_filter {
    key   = var.instance_tag_key
    type  = "KEY_AND_VALUE"
    value = var.instance_tag_value
  }

  deployment_config_name = "CodeDeployDefault.AllAtOnce"
}

output "application_name" {
  description = "CodeDeploy Application Name"
  value       = aws_codedeploy_app.my_app.name
}
