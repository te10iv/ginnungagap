# Amazon EC2：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **VPC + Subnet**：EC2の配置場所
  - **AMI**：起動テンプレート
  - **EBS**：ストレージ
  - **Security Group**：ファイアウォール
  - **IAM Role**：権限管理

## 内部的な仕組み（ざっくり）
- **なぜEC2が必要なのか**：柔軟なコンピューティングリソース、様々なアプリケーション実行
- **仮想化技術**：Nitro System（AWS独自のハイパーバイザー）
- **インスタンスタイプ**：CPU/メモリ/ネットワーク/ストレージの組み合わせ
- **課金モデル**：オンデマンド、リザーブド、スポット、Savings Plans
- **制約**：リージョン・AZ単位、インスタンスタイプごとの上限あり

## よくある構成パターン
### パターン1：基本的なWeb3層構成
- 構成概要：
  - ALB（Publicサブネット）
  - Webサーバー EC2（Privateサブネット、Auto Scaling）
  - Appサーバー EC2（Privateサブネット）
  - RDS（Privateサブネット）
- 使う場面：Webアプリケーションの基本構成

### パターン2：Auto Scaling構成
- 構成概要：
  - 起動テンプレート（AMI、インスタンスタイプ、User Data）
  - Auto Scaling Group（最小/希望/最大台数）
  - ターゲット追跡スケーリング（CPU 70%）
- 使う場面：負荷変動が大きいシステム

### パターン3：スポットインスタンス活用
- 構成概要：
  - オンデマンド：2台（最小保証）
  - スポット：0〜10台（コスト削減）
  - Spot Fleet（複数インスタンスタイプ指定）
- 使う場面：バッチ処理、開発環境、コスト最優先

### パターン4：Nitro System活用
- 構成概要：
  - ENA（Elastic Network Adapter）：ネットワーク高速化
  - NVMe SSD：ストレージ高速化
  - Nitro Enclaves：機密データ処理
- 使う場面：高性能要件、セキュリティ重視

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：複数AZに分散配置、Auto Scaling
- **セキュリティ**：
  - Privateサブネット配置
  - Security Group最小権限
  - IAM Role使用（アクセスキー不要）
  - Systems Manager Session Manager（SSH不要）
- **コスト**：
  - インスタンスタイプ選定
  - リザーブド/スポット活用
  - 停止・削除タイミング
- **拡張性**：Auto Scaling、スケールアウト設計

## 他サービスとの関係
- **EBS との関係**：ルートボリューム・データボリューム
- **Auto Scaling との関係**：動的なEC2増減
- **ALB との関係**：複数EC2への負荷分散
- **CloudWatch との関係**：メトリクス監視、Auto Scaling トリガー
- **Systems Manager との関係**：パッチ管理、セッションマネージャー

## Terraformで見るとどうなる？
```hcl
# EC2インスタンス
resource "aws_instance" "web" {
  ami           = "ami-0c3fd0f5d33134a76"  # Amazon Linux 2
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_1a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = {
    Name = "web-server"
  }
}

# 起動テンプレート（Auto Scaling用）
resource "aws_launch_template" "web" {
  name          = "web-launch-template"
  image_id      = "ami-0c3fd0f5d33134a76"
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              EOF)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-server-asg"
    }
  }
}
```

主要リソース：
- `aws_instance`：EC2インスタンス
- `aws_launch_template`：起動テンプレート（Auto Scaling用）
- `aws_ami`：カスタムAMI
- `aws_ebs_volume`：EBSボリューム
- `aws_eip`：Elastic IP
