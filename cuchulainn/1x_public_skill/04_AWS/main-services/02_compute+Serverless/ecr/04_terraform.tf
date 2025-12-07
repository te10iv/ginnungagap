# ECRリポジトリを作成し、Dockerコンテナイメージを保存します。

resource "aws_ecr_repository" "my_app" {
  name                 = "my-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "my_app" {
  repository = aws_ecr_repository.my_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "repository_uri" {
  description = "ECR Repository URI"
  value       = aws_ecr_repository.my_app.repository_url
}
