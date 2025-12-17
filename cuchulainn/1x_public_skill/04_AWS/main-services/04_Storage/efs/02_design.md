# Amazon EFS：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + Subnet**：マウントターゲット配置
  - **Security Group**：アクセス制御（NFS:2049）
  - **KMS（オプション）**：暗号化
  - **CloudWatch**：メトリクス監視

## 内部的な仕組み（ざっくり）
- **なぜEFSが必要なのか**：複数EC2からの共有アクセス、自動スケール
- **NFSプロトコル**：NFSv4.1、POSIX準拠
- **マルチAZ**：自動的に複数AZに複製
- **自動スケール**：ペタバイト規模まで自動拡張
- **制約**：
  - リージョン内のみ（クロスリージョン不可）
  - NFSプロトコルのみ

## よくある構成パターン
### パターン1：Webサーバー共有ストレージ
- 構成概要：
  - ALB + 複数EC2
  - EFS：静的コンテンツ、アップロードファイル
  - 全サーバーで同一ファイル共有
- 使う場面：スケールアウト構成

### パターン2：コンテナ永続化ストレージ
- 構成概要：
  - ECS / EKS
  - EFSボリューム：永続化データ
  - 複数タスクから共有アクセス
- 使う場面：コンテナ環境

### パターン3：Lambda永続化ストレージ
- 構成概要：
  - Lambda関数
  - EFS：ML モデル、共有設定ファイル
  - VPC Lambda
- 使う場面：サーバーレス + 永続化

### パターン4：ホームディレクトリ
- 構成概要：
  - 複数EC2
  - EFS：ユーザーホームディレクトリ
  - どのサーバーでも同じ環境
- 使う場面：開発環境、ジャンプサーバー

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：自動Multi-AZ複製
- **セキュリティ**：
  - Security Group（NFS:2049許可）
  - EFS Access Points（アプリケーション単位制御）
  - 暗号化（保管時・転送時）
- **コスト**：
  - Standard：頻繁アクセス
  - IA（Infrequent Access）：低頻度アクセス（自動移行）
  - ライフサイクル管理
- **拡張性**：自動スケール、無制限

## 他サービスとの関係
- **EC2 との関係**：NFSマウント、共有ストレージ
- **Lambda との関係**：永続化ストレージ（VPC Lambda）
- **ECS/EKS との関係**：コンテナボリューム
- **DataSync との関係**：オンプレミスからデータ移行

## Terraformで見るとどうなる？
```hcl
# EFSファイルシステム
resource "aws_efs_file_system" "main" {
  creation_token   = "main-efs"
  encrypted        = true
  kms_key_id       = aws_kms_key.efs.arn
  performance_mode = "generalPurpose"  # or "maxIO"
  throughput_mode  = "bursting"        # or "provisioned"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "main-efs"
  }
}

# マウントターゲット（各AZ）
resource "aws_efs_mount_target" "az_a" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.private_1a.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "az_c" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.private_1c.id
  security_groups = [aws_security_group.efs.id]
}

# Security Group（NFS）
resource "aws_security_group" "efs" {
  name        = "efs-sg"
  description = "Allow NFS from EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-sg"
  }
}

# EFS Access Point
resource "aws_efs_access_point" "app" {
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/app"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = "app-access-point"
  }
}

# Lambdaファイルシステム設定
resource "aws_lambda_function" "processor" {
  # ... 他の設定 ...

  file_system_config {
    arn              = aws_efs_access_point.app.arn
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
    security_group_ids = [aws_security_group.lambda.id]
  }
}

# プロビジョンドスループット
resource "aws_efs_file_system" "high_throughput" {
  creation_token  = "high-throughput-efs"
  throughput_mode = "provisioned"
  provisioned_throughput_in_mibps = 100  # 100 MiB/s

  tags = {
    Name = "high-throughput-efs"
  }
}
```

主要リソース：
- `aws_efs_file_system`：ファイルシステム
- `aws_efs_mount_target`：マウントターゲット
- `aws_efs_access_point`：アクセスポイント
- `aws_efs_backup_policy`：バックアップポリシー
