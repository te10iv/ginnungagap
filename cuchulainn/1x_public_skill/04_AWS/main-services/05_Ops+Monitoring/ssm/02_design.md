# AWS Systems Manager（SSM）：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **EC2**：管理対象インスタンス
  - **IAM**：権限管理
  - **CloudWatch Logs（オプション）**：セッションログ
  - **S3（オプション）**：出力保存

## 内部的な仕組み（ざっくり）
- **なぜSSMが必要なのか**：SSH不要、セキュア接続、一括管理
- **SSMエージェント**：EC2上で稼働、Systems Managerと通信
- **マネージドインスタンス**：SSM管理対象（EC2、オンプレ）
- **Session Manager**：IAM認証、CloudTrail記録
- **制約**：
  - SSMエージェント必要
  - IAMロール必要

## よくある構成パターン
### パターン1：セキュアアクセス（Session Manager）
- 構成概要：
  - EC2（Private Subnet）
  - Session Manager：SSH不要、ブラウザアクセス
  - CloudWatch Logs：セッションログ記録
  - 踏み台サーバー不要
- 使う場面：セキュアな運用

### パターン2：パッチ自動適用
- 構成概要：
  - Patch Manager：自動パッチ適用
  - Maintenance Windows：定期実行
  - SNS：適用結果通知
- 使う場面：パッチ運用自動化

### パターン3：設定管理（Parameter Store）
- 構成概要：
  - Parameter Store：DB接続文字列、API キー
  - 暗号化（KMS）
  - アプリケーション起動時に取得
- 使う場面：設定の中央管理

### パターン4：大規模運用（Run Command）
- 構成概要：
  - Run Command：複数サーバーに一括コマンド
  - ターゲット：タグ指定
  - S3：出力保存
- 使う場面：大規模環境

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：SSMはマネージド、高可用性
- **セキュリティ**：
  - IAMロール最小権限
  - Session Manager：SSH鍵不要
  - CloudWatch Logsでセッション記録
  - Parameter Store：KMS暗号化
- **コスト**：
  - Session Manager：無料
  - Run Command：無料
  - Parameter Store：Standard無料、Advanced $0.05/パラメータ/月
  - Automation：無料
- **拡張性**：無制限インスタンス

## 他サービスとの関係
- **EC2 との関係**：管理対象
- **EventBridge との関係**：自動化トリガー
- **Lambda との関係**：カスタム自動化
- **CloudWatch との関係**：セッションログ

## Terraformで見るとどうなる？
```hcl
# IAMロール（EC2用）
resource "aws_iam_role" "ssm" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# SSM管理ポリシーアタッチ
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAMインスタンスプロファイル
resource "aws_iam_instance_profile" "ssm" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ssm.name
}

# EC2インスタンス（SSM有効）
resource "aws_instance" "web" {
  ami                  = "ami-xxxxx"
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm.name

  tags = {
    Name = "web-server"
  }
}

# Parameter Store（String）
resource "aws_ssm_parameter" "db_host" {
  name  = "/myapp/db/host"
  type  = "String"
  value = "db.example.com"

  tags = {
    Environment = "production"
  }
}

# Parameter Store（SecureString）
resource "aws_ssm_parameter" "db_password" {
  name   = "/myapp/db/password"
  type   = "SecureString"
  value  = "change-me"  # 実際はSecrets Manager推奨
  key_id = aws_kms_key.ssm.id

  tags = {
    Environment = "production"
  }
}

# SSMドキュメント（カスタムコマンド）
resource "aws_ssm_document" "restart_app" {
  name          = "RestartApplication"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Restart application service"
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "restartService"
      inputs = {
        runCommand = [
          "sudo systemctl restart myapp"
        ]
      }
    }]
  })
}

# Maintenance Window
resource "aws_ssm_maintenance_window" "weekly" {
  name     = "weekly-patching"
  schedule = "cron(0 2 ? * SUN *)"  # 毎週日曜 02:00
  duration = 3
  cutoff   = 1

  tags = {
    Name = "weekly-patching"
  }
}

# Maintenance Window Target
resource "aws_ssm_maintenance_window_target" "web_servers" {
  window_id     = aws_ssm_maintenance_window.weekly.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Environment"
    values = ["production"]
  }
}

# Maintenance Window Task（パッチ適用）
resource "aws_ssm_maintenance_window_task" "patch" {
  window_id        = aws_ssm_maintenance_window.weekly.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = aws_iam_role.ssm_maintenance.arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.web_servers.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}

# CloudWatch Logsロググループ（Session Manager）
resource "aws_cloudwatch_log_group" "session_manager" {
  name              = "/aws/ssm/session-manager"
  retention_in_days = 30
}

# Session Manager設定
resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Session Manager preferences"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = aws_s3_bucket.session_logs.id
      s3KeyPrefix                 = "session-logs/"
      s3EncryptionEnabled         = true
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.session_manager.name
      cloudWatchEncryptionEnabled = true
    }
  })
}
```

主要リソース：
- `aws_iam_role`：SSMロール
- `aws_ssm_parameter`：Parameter Store
- `aws_ssm_document`：カスタムドキュメント
- `aws_ssm_maintenance_window`：メンテナンスウィンドウ
