# CodeCommitリポジトリを作成し、ソースコードを管理します。

resource "aws_codecommit_repository" "my_repository" {
  repository_name = "my-repository"
  description     = "My source code repository"
}

output "repository_name" {
  description = "CodeCommit Repository Name"
  value       = aws_codecommit_repository.my_repository.repository_name
}

output "clone_url_http" {
  description = "Clone URL (HTTP)"
  value       = aws_codecommit_repository.my_repository.clone_url_http
}
