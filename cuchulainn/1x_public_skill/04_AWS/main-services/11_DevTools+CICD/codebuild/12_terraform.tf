# CodeBuildプロジェクトを作成し、ソースコードをビルドします。

variable "repository_name" {
  description = "CodeCommit Repository Name"
  type        = string
}

data "aws_region" "current" {}

resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy" "s3_access" {
  name = "S3Access"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::/*"
      }
    ]
  })
}

resource "aws_codebuild_project" "my_build_project" {
  name          = "my-build-project"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 5

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODECOMMIT"
    location  = "https://git-codecommit.${data.aws_region.current.name}.amazonaws.com/v1/repos/${var.repository_name}"
    buildspec = "buildspec.yml"
  }
}

output "project_name" {
  description = "CodeBuild Project Name"
  value       = aws_codebuild_project.my_build_project.name
}
