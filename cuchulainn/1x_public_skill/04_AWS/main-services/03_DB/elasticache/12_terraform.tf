# ElastiCache Redisクラスターを作成し、アプリケーションのキャッシュ層として使用します。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs (at least 2 subnets in different AZs)"
  type        = list(string)
}

resource "aws_elasticache_subnet_group" "my_cache_subnet_group" {
  name       = "my-cache-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-sg"
  description = "Security group for ElastiCache"
  vpc_id      = var.vpc_id

  ingress {
    description = "Redis access from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elasticache-sg"
  }
}

resource "aws_elasticache_replication_group" "my_redis_cluster" {
  replication_group_id       = "my-redis-cluster"
  description                = "Redis cluster for caching"
  engine                     = "redis"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 1
  port                       = 6379
  parameter_group_name       = "default.redis7"
  subnet_group_name          = aws_elasticache_subnet_group.my_cache_subnet_group.name
  security_group_ids         = [aws_security_group.elasticache_sg.id]
  automatic_failover_enabled = false
  multi_az_enabled           = false
}

output "redis_endpoint" {
  description = "Redis Endpoint"
  value       = aws_elasticache_replication_group.my_redis_cluster.configuration_endpoint_address
}

output "redis_port" {
  description = "Redis Port"
  value       = aws_elasticache_replication_group.my_redis_cluster.port
}
