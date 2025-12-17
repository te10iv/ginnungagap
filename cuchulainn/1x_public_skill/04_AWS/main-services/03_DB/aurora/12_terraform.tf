# Aurora MySQLクラスターを作成し、高性能なデータベース環境を構築します。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs (at least 2 subnets in different AZs)"
  type        = list(string)
}

variable "master_username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "master_user_password" {
  description = "Master user password"
  type        = string
  sensitive   = true
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "aurora-subnet-group"
  }
}

resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg"
  description = "Security group for Aurora"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL access from VPC"
    from_port   = 3306
    to_port     = 3306
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
    Name = "aurora-sg"
  }
}

resource "aws_rds_cluster" "my_aurora_cluster" {
  cluster_identifier      = "my-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.0"
  database_name           = "mydb"
  master_username         = var.master_username
  master_password         = var.master_user_password
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = {
    Name = "my-aurora-cluster"
  }
}

resource "aws_rds_cluster_instance" "my_aurora_instance" {
  identifier         = "my-aurora-instance"
  cluster_identifier  = aws_rds_cluster.my_aurora_cluster.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.my_aurora_cluster.engine
  engine_version      = aws_rds_cluster.my_aurora_cluster.engine_version
  publicly_accessible = false
}

output "cluster_endpoint" {
  description = "Aurora Cluster Endpoint"
  value       = aws_rds_cluster.my_aurora_cluster.endpoint
}

output "reader_endpoint" {
  description = "Aurora Reader Endpoint"
  value       = aws_rds_cluster.my_aurora_cluster.reader_endpoint
}
