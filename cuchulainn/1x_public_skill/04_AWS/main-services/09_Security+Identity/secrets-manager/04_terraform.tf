# Secrets Managerでデータベースの認証情報を保存し、アプリケーションから安全に取得できるようにします。

resource "aws_secretsmanager_secret" "my_database_credentials" {
  name        = "my-database-credentials"
  description = "Database credentials"
}

resource "aws_secretsmanager_secret_version" "my_database_credentials" {
  secret_id = aws_secretsmanager_secret.my_database_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = "your-password"
  })
}

output "secret_arn" {
  description = "Secrets Manager Secret ARN"
  value       = aws_secretsmanager_secret.my_database_credentials.arn
}
