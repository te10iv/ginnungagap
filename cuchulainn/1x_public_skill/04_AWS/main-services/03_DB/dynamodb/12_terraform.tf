# DynamoDBテーブルを作成し、NoSQLデータベースとして使用します。

resource "aws_dynamodb_table" "users_table" {
  name         = "Users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  tags = {
    Name = "Users"
  }
}

output "table_name" {
  description = "DynamoDB Table Name"
  value       = aws_dynamodb_table.users_table.name
}

output "table_arn" {
  description = "DynamoDB Table ARN"
  value       = aws_dynamodb_table.users_table.arn
}
