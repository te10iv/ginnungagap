# RDSデータベースインスタンス（MySQL）を作成し、アプリケーションから接続できるようにします。

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

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "my-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS"
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
    Name = "rds-sg"
  }
}

resource "aws_db_instance" "my_rds_instance" {
  identifier             = "my-rds-instance"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  db_name                = "mydb"
  username               = var.master_username
  password               = var.master_user_password
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  backup_retention_period = 7

  tags = {
    Name = "my-rds-instance"
  }
}

output "db_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.my_rds_instance.endpoint
}

output "db_port" {
  description = "RDS Port"
  value       = aws_db_instance.my_rds_instance.port
}
