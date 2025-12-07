# AthenaでS3のログファイルをクエリできるようにします。

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "athena_query_results" {
  bucket = "athena-query-results-${data.aws_caller_identity.current.account_id}"
}

resource "aws_glue_catalog_database" "my_database" {
  name        = "my_database"
  description = "Athena database"
}

output "database_name" {
  description = "Athena Database Name"
  value       = aws_glue_catalog_database.my_database.name
}
