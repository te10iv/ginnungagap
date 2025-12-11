# ==========================================
# Before: ベタ書きTerraformコード（初心者版）
# ==========================================
# ⚠️ このコードは実行不可（学習用）
# 
# 問題点:
# - すべてハードコード
# - 値の重複が多い
# - 環境変更が困難
# - 再利用性ゼロ
# ==========================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"    # ❌ ハードコード
}

# ==========================================
# VPC
# ==========================================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"    # ❌ ハードコード
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "myapp-dev-vpc"    # ❌ ハードコード
    Environment = "dev"               # ❌ ハードコード
    Project     = "myapp"             # ❌ ハードコード
  }
}

# ==========================================
# Internet Gateway
# ==========================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "myapp-dev-igw"
    Environment = "dev"
    Project     = "myapp"
  }
}

# ==========================================
# Public Subnets（重複コード）
# ==========================================
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"           # ❌ ハードコード
  availability_zone       = "ap-northeast-1a"       # ❌ リージョン依存
  map_public_ip_on_launch = true

  tags = {
    Name        = "myapp-dev-public-1a"
    Environment = "dev"
    Project     = "myapp"
    Type        = "public"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"           # ❌ ハードコード
  availability_zone       = "ap-northeast-1c"       # ❌ リージョン依存
  map_public_ip_on_launch = true

  tags = {
    Name        = "myapp-dev-public-1c"             # ❌ 同じコードの繰り返し
    Environment = "dev"
    Project     = "myapp"
    Type        = "public"
  }
}

# ==========================================
# Private Subnets（重複コード）
# ==========================================
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"                # ❌ ハードコード
  availability_zone = "ap-northeast-1a"             # ❌ リージョン依存

  tags = {
    Name        = "myapp-dev-private-1a"
    Environment = "dev"
    Project     = "myapp"
    Type        = "private"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"                # ❌ ハードコード
  availability_zone = "ap-northeast-1c"             # ❌ リージョン依存

  tags = {
    Name        = "myapp-dev-private-1c"
    Environment = "dev"
    Project     = "myapp"
    Type        = "private"
  }
}

# ==========================================
# Route Table & Routes
# ==========================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "myapp-dev-public-rt"
    Environment = "dev"
    Project     = "myapp"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id          # ❌ 手動で各Subnetに関連付け
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

# ==========================================
# Security Groups
# ==========================================
resource "aws_security_group" "web" {
  name        = "myapp-dev-web-sg"                  # ❌ ハードコード
  description = "Web server security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "myapp-dev-web-sg"
    Environment = "dev"
    Project     = "myapp"
  }
}

resource "aws_security_group" "db" {
  name        = "myapp-dev-db-sg"
  description = "Database security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "myapp-dev-db-sg"
    Environment = "dev"
    Project     = "myapp"
  }
}

# ==========================================
# EC2 Instances（重複コード）
# ==========================================
resource "aws_instance" "web_1" {
  ami                    = "ami-0c3fd0f5d33134a76"   # ❌ 古いAMI ID（時期・リージョン依存）
  instance_type          = "t3.small"                # ❌ ハードコード
  subnet_id              = aws_subnet.public_1a.id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Web Server 1 - myapp-dev</h1>" > /var/www/html/index.html
              EOF
              # ❌ 環境名がハードコード、テンプレート化されていない

  tags = {
    Name        = "myapp-dev-web-1"                  # ❌ ハードコード
    Environment = "dev"
    Project     = "myapp"
  }
}

resource "aws_instance" "web_2" {
  ami                    = "ami-0c3fd0f5d33134a76"   # ❌ 同じAMI IDを重複記述
  instance_type          = "t3.small"                # ❌ ハードコード
  subnet_id              = aws_subnet.public_1c.id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Web Server 2 - myapp-dev</h1>" > /var/www/html/index.html
              EOF
              # ❌ ほぼ同じコードを2回記述

  tags = {
    Name        = "myapp-dev-web-2"
    Environment = "dev"
    Project     = "myapp"
  }
}

# ==========================================
# RDS Subnet Group
# ==========================================
resource "aws_db_subnet_group" "main" {
  name       = "myapp-dev-db-subnet-group"           # ❌ ハードコード
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]                                                   # ❌ 手動で列挙

  tags = {
    Name        = "myapp-dev-db-subnet-group"
    Environment = "dev"
    Project     = "myapp"
  }
}

# ==========================================
# RDS Primary Database
# ==========================================
resource "aws_db_instance" "primary" {
  identifier              = "myapp-dev-db-primary"   # ❌ ハードコード
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.small"            # ❌ ハードコード
  allocated_storage       = 50
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = "appdb"
  username                = "admin"                   # ❌ ハードコード
  password                = "MyPassword123!"          # ❌ 平文パスワード（超危険！）
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  backup_retention_period = 7                        # ❌ ハードコード
  skip_final_snapshot     = true

  tags = {
    Name        = "myapp-dev-db-primary"
    Environment = "dev"
    Project     = "myapp"
  }
}

# ==========================================
# RDS Read Replica
# ==========================================
resource "aws_db_instance" "replica" {
  identifier             = "myapp-dev-db-replica"    # ❌ ハードコード
  replicate_source_db    = aws_db_instance.primary.identifier
  instance_class         = "db.t3.small"             # ❌ ハードコード（同じ値を重複）
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name        = "myapp-dev-db-replica"
    Environment = "dev"
    Project     = "myapp"
  }
}

# ==========================================
# ❌ Outputs がない
# → 他のモジュールやチームメンバーが
#   値を参照できない
# ==========================================

# ==========================================
# 問題のまとめ:
# 
# 1. 環境変更（dev→prod）時に全箇所を手動修正
# 2. AMI IDがハードコード（リージョン変更不可）
# 3. パスワードが平文（セキュリティリスク）
# 4. タグが重複記述（保守性低い）
# 5. Subnet作成が重複（for_each不使用）
# 6. EC2作成が重複（count不使用）
# 7. モジュール化されていない（再利用不可）
# 8. Outputsがない（他リソースから参照不可）
# 
# 行数: 約240行
# 保守性: ★☆☆☆☆
# 再利用性: ★☆☆☆☆
# ==========================================
