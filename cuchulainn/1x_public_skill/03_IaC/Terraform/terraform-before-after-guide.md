# Terraform Before/After 完全ガイド

ハードコードから構造化されたコードへの進化

---

## 📋 この教材について

### 目的

Terraformの**初心者コード**（ベタ書き）から**中級者コード**（変数・モジュール活用）への進化を、実際のコードで学びます。

### 対象者

- Terraformの基本構文は理解している
- variables, locals, modules の使い方を実践で学びたい
- count / for_each の使い分けを習得したい
- 保守性の高いTerraformコードを書けるようになりたい

### AWS構成（最小構成）

```
VPC (10.0.0.0/16)
├── Public Subnet × 2 (AZ-a, AZ-c)
├── Private Subnet × 2 (AZ-a, AZ-c)
├── EC2 × 2台 (Web Server)
└── RDS × 2台 (Primary + Read Replica)
```

---

## 🔴 Before: ベタ書き版（初心者コード）

### 問題点

- ❌ すべてハードコード
- ❌ 値の重複が多い
- ❌ 環境変更が困難
- ❌ 再利用性ゼロ
- ❌ 保守性が低い
- ❌ スケールしない

### ファイル: `before/main.tf`

```hcl
# ==========================================
# ❌ 問題だらけのベタ書きコード
# ==========================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws/provider"
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
    Name = "myapp-dev-vpc"    # ❌ ハードコード（環境変更不可）
  }
}

# ==========================================
# Internet Gateway
# ==========================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "myapp-dev-igw"    # ❌ ハードコード
  }
}

# ==========================================
# Public Subnets（重複コード）
# ==========================================
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"    # ❌ ハードコード
  availability_zone       = "ap-northeast-1a"    # ❌ リージョン依存
  map_public_ip_on_launch = true

  tags = {
    Name = "myapp-dev-public-1a"    # ❌ ハードコード
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"    # ❌ ハードコード
  availability_zone       = "ap-northeast-1c"    # ❌ リージョン依存
  map_public_ip_on_launch = true

  tags = {
    Name = "myapp-dev-public-1c"    # ❌ ハードコード
  }
}

# ==========================================
# Private Subnets（重複コード）
# ==========================================
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"    # ❌ ハードコード
  availability_zone = "ap-northeast-1a"    # ❌ リージョン依存

  tags = {
    Name = "myapp-dev-private-1a"    # ❌ ハードコード
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"    # ❌ ハードコード
  availability_zone = "ap-northeast-1c"    # ❌ リージョン依存

  tags = {
    Name = "myapp-dev-private-1c"    # ❌ ハードコード
  }
}

# ==========================================
# Route Table
# ==========================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "myapp-dev-public-rt"    # ❌ ハードコード
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
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
  name        = "myapp-dev-web-sg"    # ❌ ハードコード
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
    Name = "myapp-dev-web-sg"    # ❌ ハードコード
  }
}

resource "aws_security_group" "db" {
  name        = "myapp-dev-db-sg"    # ❌ ハードコード
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
    Name = "myapp-dev-db-sg"    # ❌ ハードコード
  }
}

# ==========================================
# EC2 Instances（重複コード）
# ==========================================
resource "aws_instance" "web_1" {
  ami                    = "ami-0c3fd0f5d33134a76"    # ❌ リージョン・時期依存
  instance_type          = "t3.small"    # ❌ ハードコード
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

  tags = {
    Name = "myapp-dev-web-1"    # ❌ ハードコード
  }
}

resource "aws_instance" "web_2" {
  ami                    = "ami-0c3fd0f5d33134a76"    # ❌ 同じAMI IDを重複記述
  instance_type          = "t3.small"    # ❌ ハードコード
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

  tags = {
    Name = "myapp-dev-web-2"    # ❌ ハードコード
  }
}

# ==========================================
# RDS
# ==========================================
resource "aws_db_subnet_group" "main" {
  name       = "myapp-dev-db-subnet-group"    # ❌ ハードコード
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]

  tags = {
    Name = "myapp-dev-db-subnet-group"    # ❌ ハードコード
  }
}

resource "aws_db_instance" "primary" {
  identifier              = "myapp-dev-db-primary"    # ❌ ハードコード
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.small"    # ❌ ハードコード
  allocated_storage       = 50
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = "appdb"
  username                = "admin"
  password                = "MyPassword123!"    # ❌ 平文パスワード（超危険！）
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = {
    Name = "myapp-dev-db-primary"    # ❌ ハードコード
  }
}

resource "aws_db_instance" "replica" {
  identifier             = "myapp-dev-db-replica"    # ❌ ハードコード
  replicate_source_db    = aws_db_instance.primary.identifier
  instance_class         = "db.t3.small"    # ❌ ハードコード
  skip_final_snapshot    = true

  tags = {
    Name = "myapp-dev-db-replica"    # ❌ ハードコード
  }
}

# ==========================================
# ❌ Outputs がない
# → 他のモジュールで値を再利用できない
# ==========================================
```

**行数**: 約240行
**問題**: 環境変更時に全箇所を手動修正、重複コード多数、再利用不可

---

## 🟢 After: 構造化版（中級者コード）

### 改善点

- ✅ variables によるパラメータ化
- ✅ locals による共通値の集約
- ✅ for_each による動的リソース生成
- ✅ count による複数インスタンス作成
- ✅ outputs による値の公開
- ✅ data source による動的AMI取得
- ✅ タグ戦略の統一
- ✅ モジュール化（VPC）

### ディレクトリ構成

```
after/
├── main.tf              # メインリソース定義
├── variables.tf         # 変数定義
├── locals.tf            # ローカル変数
├── outputs.tf           # 出力値
├── terraform.tfvars     # 変数値（dev環境）
├── terraform-prod.tfvars    # 変数値（本番環境）
└── modules/
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### ファイル: `after/variables.tf`

```hcl
# ==========================================
# Variables - 入力パラメータ定義
# ==========================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment name (dev, stg, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "Environment must be dev, stg, or prod."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = map(string)
  default = {
    "ap-northeast-1a" = "10.0.1.0/24"
    "ap-northeast-1c" = "10.0.2.0/24"
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = map(string)
  default = {
    "ap-northeast-1a" = "10.0.11.0/24"
    "ap-northeast-1c" = "10.0.12.0/24"
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "create_read_replica" {
  description = "Create RDS read replica"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
```

### ファイル: `after/locals.tf`

```hcl
# ==========================================
# Locals - ローカル変数（計算・集約）
# ==========================================

locals {
  # ✅ 共通の命名規則
  name_prefix = "${var.project_name}-${var.environment}"

  # ✅ 共通タグ（全リソースに適用）
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  # ✅ AZ情報を整理
  azs = {
    for idx, az in var.availability_zones : az => {
      short_name = replace(az, "${var.region}", "")
      index      = idx
    }
  }

  # ✅ サブネット情報を整理
  public_subnets = {
    for az in var.availability_zones :
    az => {
      cidr_block = var.public_subnet_cidrs[az]
      az         = az
      type       = "public"
    }
  }

  private_subnets = {
    for az in var.availability_zones :
    az => {
      cidr_block = var.private_subnet_cidrs[az]
      az         = az
      type       = "private"
    }
  }
}
```

### ファイル: `after/main.tf`

```hcl
# ==========================================
# ✅ 構造化されたTerraformコード
# ==========================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ✅ State管理（本番では必須）
  backend "s3" {
    bucket = "myapp-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = var.region    # ✅ 変数から取得

  default_tags {
    tags = local.common_tags    # ✅ 全リソースに共通タグ自動適用
  }
}

# ==========================================
# Data Source - 最新AMI自動取得
# ==========================================
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==========================================
# VPC Module
# ==========================================
module "vpc" {
  source = "./modules/vpc"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr

  tags = local.common_tags
}

# ==========================================
# Internet Gateway
# ==========================================
resource "aws_internet_gateway" "main" {
  vpc_id = module.vpc.vpc_id    # ✅ モジュールから取得

  tags = {
    Name = "${local.name_prefix}-igw"    # ✅ locals使用
  }
}

# ==========================================
# Public Subnets - for_each で動的生成
# ==========================================
resource "aws_subnet" "public" {
  for_each = local.public_subnets    # ✅ for_each で複数作成

  vpc_id                  = module.vpc.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-${each.key}"
    Type = "public"
  }
}

# ==========================================
# Private Subnets - for_each で動的生成
# ==========================================
resource "aws_subnet" "private" {
  for_each = local.private_subnets    # ✅ for_each で複数作成

  vpc_id            = module.vpc.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "${local.name_prefix}-private-${each.key}"
    Type = "private"
  }
}

# ==========================================
# Route Table
# ==========================================
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

# ✅ for_each で動的にアソシエーション
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ==========================================
# Security Groups
# ==========================================
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Web server security group"
  vpc_id      = module.vpc.vpc_id

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
    Name = "${local.name_prefix}-web-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "Database security group"
  vpc_id      = module.vpc.vpc_id

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
    Name = "${local.name_prefix}-db-sg"
  }
}

# ==========================================
# EC2 Instances - count で動的生成
# ==========================================
resource "aws_instance" "web" {
  count = var.instance_count    # ✅ count で複数作成

  ami                    = data.aws_ami.amazon_linux_2023.id    # ✅ data sourceから取得
  instance_type          = var.instance_type
  subnet_id              = element(values(aws_subnet.public)[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    server_number = count.index + 1
    project_name  = var.project_name
    environment   = var.environment
  })

  tags = {
    Name = "${local.name_prefix}-web-${count.index + 1}"
  }
}

# ==========================================
# RDS
# ==========================================
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.private : s.id]    # ✅ for式でリスト化

  tags = {
    Name = "${local.name_prefix}-db-subnet-group"
  }
}

resource "aws_db_instance" "primary" {
  identifier              = "${local.name_prefix}-db-primary"
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = var.db_instance_class
  allocated_storage       = 50
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = "appdb"
  username                = var.db_username    # ✅ 変数（sensitive）
  password                = var.db_password    # ✅ 変数（sensitive）
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  backup_retention_period = var.environment == "prod" ? 30 : 7    # ✅ 条件式
  skip_final_snapshot     = var.environment != "prod"

  tags = {
    Name = "${local.name_prefix}-db-primary"
  }
}

# ✅ count で条件付き作成
resource "aws_db_instance" "replica" {
  count = var.create_read_replica ? 1 : 0    # ✅ 条件付き作成

  identifier          = "${local.name_prefix}-db-replica"
  replicate_source_db = aws_db_instance.primary.identifier
  instance_class      = var.db_instance_class
  skip_final_snapshot = var.environment != "prod"

  tags = {
    Name = "${local.name_prefix}-db-replica"
  }
}
```

### ファイル: `after/outputs.tf`

```hcl
# ==========================================
# Outputs - 他モジュールで再利用可能
# ==========================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "web_instance_ids" {
  description = "Web server instance IDs"
  value       = aws_instance.web[*].id    # ✅ splat expression
}

output "web_public_ips" {
  description = "Web server public IPs"
  value       = aws_instance.web[*].public_ip
}

output "db_primary_endpoint" {
  description = "Primary database endpoint"
  value       = aws_db_instance.primary.endpoint
  sensitive   = true
}

output "db_replica_endpoint" {
  description = "Read replica endpoint"
  value       = var.create_read_replica ? aws_db_instance.replica[0].endpoint : null
  sensitive   = true
}
```

### ファイル: `after/modules/vpc/main.tf`

```hcl
# ==========================================
# VPC Module
# ==========================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-vpc"
    }
  )
}
```

### ファイル: `after/modules/vpc/variables.tf`

```hcl
variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

### ファイル: `after/modules/vpc/outputs.tf`

```hcl
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}
```

### ファイル: `after/terraform.tfvars` (開発環境)

```hcl
project_name         = "myapp"
environment          = "dev"
instance_type        = "t3.small"
db_instance_class    = "db.t3.small"
create_read_replica  = false
```

### ファイル: `after/terraform-prod.tfvars` (本番環境)

```hcl
project_name         = "myapp"
environment          = "prod"
instance_type        = "m5.large"
db_instance_class    = "db.r6i.large"
create_read_replica  = true
```

---

## 📊 Before/After 比較表

| 項目 | Before | After | 改善効果 |
|------|--------|-------|---------|
| **行数** | ~240行 | ~400行（分割） | コード整理 |
| **環境変更** | 全箇所修正 | tfvars変更のみ | **10倍以上効率化** |
| **リソース追加** | コピペ | count/for_each | **自動化** |
| **保守性** | 低い | 高い | **大幅向上** |
| **再利用性** | ゼロ | モジュール化 | **完全再利用可能** |
| **タグ管理** | 手動 | 自動適用 | **ミス防止** |
| **パスワード** | 平文 | sensitive変数 | **セキュア** |
| **AMI** | ハードコード | data source | **常に最新** |
| **命名規則** | バラバラ | 統一 | **一貫性** |

---

## 🎯 Terraform中級者が理解すべき概念

### 1. Variables（変数）

**用途**: 入力パラメータの定義

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
  
  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Instance type must be t3 family."
  }
}
```

**types**:
- `string`, `number`, `bool`
- `list(string)`, `map(string)`
- `object({ ... })`

**使い分け**:
- 環境ごとに変わる値 → variables
- コード内で計算する値 → locals

---

### 2. Locals（ローカル変数）

**用途**: 計算結果の保持、共通値の集約

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

**variables との違い**:
- variables: 外部から入力
- locals: コード内で計算

---

### 3. Outputs（出力値）

**用途**: 他モジュールへの値の受け渡し

```hcl
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
```

**使い方**:
```bash
terraform output vpc_id
terraform output -json
```

---

### 4. Count（カウント）

**用途**: 同じリソースを複数作成

```hcl
resource "aws_instance" "web" {
  count = 3
  
  # count.index を使用（0, 1, 2）
  tags = {
    Name = "web-${count.index + 1}"
  }
}

# 参照: aws_instance.web[0].id
```

**条件付き作成**:
```hcl
resource "aws_db_instance" "replica" {
  count = var.create_replica ? 1 : 0
  # ...
}

# 参照: aws_db_instance.replica[0].id
```

---

### 5. For_each（反復処理）

**用途**: マップやセットから動的にリソース作成

```hcl
resource "aws_subnet" "public" {
  for_each = {
    "1a" = "10.0.1.0/24"
    "1c" = "10.0.2.0/24"
  }
  
  cidr_block = each.value
  
  tags = {
    Name = "public-${each.key}"
  }
}

# 参照: aws_subnet.public["1a"].id
```

**count vs for_each**:
- count: 順序が重要、リスト的
- for_each: キーで識別、マップ的（推奨）

---

### 6. Module（モジュール）

**用途**: コードの再利用・整理

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr = "10.0.0.0/16"
}

# 参照: module.vpc.vpc_id
```

**ディレクトリ構成**:
```
modules/
└── vpc/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

### 7. Data Source（データソース）

**用途**: 既存リソース情報の取得

```hcl
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}

# 使用: data.aws_ami.latest.id
```

---

### 8. State管理

**ローカル state**:
```hcl
# terraform.tfstate（自動生成）
```

**リモート state（推奨）**:
```hcl
terraform {
  backend "s3" {
    bucket = "myapp-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
    
    # ロック用
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**重要ポイント**:
- state はチーム共有必須
- S3 + DynamoDB でロック
- モジュールごとに state 分離推奨

---

## 🗂️ ディレクトリ構成パターン

### パターン1: シンプル構成

```
project/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── .gitignore
```

### パターン2: 環境別構成

```
project/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── stg/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       └── terraform.tfvars
└── modules/
    ├── vpc/
    ├── compute/
    └── database/
```

### パターン3: モジュール分割構成（推奨）

```
project/
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
├── terraform.tfvars
├── terraform-prod.tfvars
└── modules/
    ├── networking/
    │   ├── vpc/
    │   ├── subnet/
    │   └── security_group/
    ├── compute/
    │   ├── ec2/
    │   └── asg/
    └── database/
        └── rds/
```

---

## 🔧 実務ベストプラクティス

### 1. terraform plan の読み方

```bash
terraform plan

# 出力例:
# Terraform will perform the following actions:
#
#   # aws_instance.web[0] will be created
#   + resource "aws_instance" "web" {
#       + ami                    = "ami-xxxxx"
#       + instance_type          = "t3.small"
#       # ...
#     }
#
# Plan: 10 to add, 0 to change, 0 to destroy.
```

**記号の意味**:
- `+` : 作成
- `-` : 削除
- `~` : 変更
- `-/+` : 置換（削除→作成）

**注意すべきポイント**:
- `-/+` は要注意（データ消失の可能性）
- RDS, EBSの削除は特に注意
- `known after apply` は実行後に決まる値

---

### 2. State の扱い

**DO**:
- ✅ S3 などリモートバックエンド使用
- ✅ DynamoDB でロック有効化
- ✅ モジュールごとに state 分離
- ✅ state のバックアップ取得
- ✅ `.gitignore` に state 追加

**DON'T**:
- ❌ state を Git にコミット
- ❌ 手動で state 編集
- ❌ state を削除（terraform state rm 以外）

---

### 3. 命名規則

```hcl
# リソース名
resource "aws_vpc" "main" {  # ← スネークケース
  # ...
}

# 変数名
variable "instance_type" {  # ← スネークケース
  # ...
}

# Tag Name
tags = {
  Name = "myapp-dev-vpc"  # ← ケバブケース
}
```

---

### 4. タグ戦略

```hcl
# 全リソースに自動適用
provider "aws" {
  default_tags {
    tags = {
      Project     = "myapp"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
```

---

### 5. Sensitive 情報の扱い

```hcl
variable "db_password" {
  type      = string
  sensitive = true  # ← 必須
}

output "db_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = true  # ← パスワード含む場合
}
```

**環境変数で渡す**:
```bash
export TF_VAR_db_password="SecurePassword123!"
terraform apply
```

---

### 6. コマンドフロー

```bash
# 1. 初期化
terraform init

# 2. フォーマット
terraform fmt -recursive

# 3. バリデーション
terraform validate

# 4. プラン確認
terraform plan -out=tfplan

# 5. 適用
terraform apply tfplan

# 6. 出力確認
terraform output

# 7. 削除（開発環境のみ）
terraform destroy
```

---

## 💡 よくある質問

### Q1: count と for_each どちらを使うべき？

**A**: 基本的に **for_each 推奨**

- count: リスト順序に依存（途中削除で再作成発生）
- for_each: キーで識別（安定）

### Q2: Module はいつ使う？

**A**: 以下の場合に使用：
- 同じパターンを複数環境で使う
- コードを論理的に分割したい
- チーム内で再利用したい

### Q3: State を分けるべき？

**A**: **Yes**。環境・サービスごとに分離推奨：
```
s3://bucket/dev/network/terraform.tfstate
s3://bucket/dev/compute/terraform.tfstate
s3://bucket/prod/network/terraform.tfstate
```

---

## 🎓 学習チェックリスト

### 基礎
- [ ] variables の定義・使用ができる
- [ ] locals の使い分けができる
- [ ] outputs で値を公開できる
- [ ] data source で既存リソース取得できる

### 中級
- [ ] count で複数リソース作成できる
- [ ] for_each で動的リソース作成できる
- [ ] module を作成・使用できる
- [ ] terraform plan の読み方を理解した
- [ ] リモート state を設定できる

### 上級
- [ ] for 式, splat 式を使いこなせる
- [ ] 条件式（? :）を使える
- [ ] モジュール間の依存関係を理解した
- [ ] state の運用戦略を設計できる
- [ ] 実務レベルのディレクトリ構成を作れる

---

## 📚 次のステップ

1. ✅ Before版を読んで問題点理解
2. ✅ After版を実行して効果実感
3. ✅ 自分のプロジェクトに適用
4. ✅ チーム内で命名規則・ディレクトリ構成を統一
5. ✅ CI/CD統合（GitHub Actions等）

---

**このガイドで、Terraform中級者へステップアップ！🚀**
