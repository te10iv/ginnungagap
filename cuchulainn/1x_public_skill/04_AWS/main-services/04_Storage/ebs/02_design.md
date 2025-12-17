# Amazon EBS：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **EC2**：アタッチ先インスタンス
  - **S3（内部）**：スナップショット保存
  - **KMS（オプション）**：暗号化
  - **CloudWatch**：メトリクス監視

## 内部的な仕組み（ざっくり）
- **なぜEBSが必要なのか**：永続化ディスク、スナップショット、サイズ変更
- **ブロックストレージ**：ファイルシステム構築可能
- **同一AZ制約**：EC2と同じAZに配置必要（レイテンシー低減）
- **スナップショット**：増分バックアップ、S3に保存
- **制約**：
  - 単一EC2にのみアタッチ（マルチアタッチ例外あり）
  - 最大サイズ64TB

## よくある構成パターン
### パターン1：ルートボリューム + データボリューム
- 構成概要：
  - ルートボリューム（gp3、30GB）：OS
  - データボリューム（gp3、100GB）：アプリデータ
  - インスタンス終了時：ルート削除、データ保持
- 使う場面：標準的なEC2構成

### パターン2：高IOPS要件（DB）
- 構成概要：
  - io2ボリューム
  - プロビジョンドIOPS（32,000〜64,000）
  - マルチアタッチ（複数EC2）
- 使う場面：データベース、高IOPS要件

### パターン3：スループット重視（ログ）
- 構成概要：
  - st1（HDD、スループット最適化）
  - 500GB以上
  - 大量の順次読み書き
- 使う場面：ログ、ビッグデータ

### パターン4：コスト最適化（アーカイブ）
- 構成概要：
  - sc1（HDD、コールドストレージ）
  - アクセス頻度低い
  - 最低コスト
- 使う場面：アーカイブ、バックアップ

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：スナップショット→別AZで復元
- **セキュリティ**：
  - 暗号化（デフォルト有効推奨）
  - KMS管理キー
  - スナップショット暗号化
- **コスト**：
  - ボリュームタイプ選択
  - プロビジョンドIOPS課金
  - スナップショット保存料
- **拡張性**：オンライン拡張（サイズ、IOPS）

## 他サービスとの関係
- **EC2 との関係**：ルートボリューム、データボリューム
- **Backup との関係**：自動バックアップ管理
- **Data Lifecycle Manager との関係**：スナップショット自動化
- **Lambda との関係**：スナップショット作成自動化

## Terraformで見るとどうなる？
```hcl
# EBSボリューム（gp3）
resource "aws_ebs_volume" "data" {
  availability_zone = "ap-northeast-1a"
  size              = 100
  type              = "gp3"
  iops              = 3000   # gp3デフォルト
  throughput        = 125    # MB/s、gp3デフォルト
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs.arn

  tags = {
    Name = "data-volume"
  }
}

# EC2にアタッチ
resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.web.id
}

# io2ボリューム（高IOPS）
resource "aws_ebs_volume" "database" {
  availability_zone = "ap-northeast-1a"
  size              = 500
  type              = "io2"
  iops              = 32000
  encrypted         = true

  tags = {
    Name = "db-volume"
  }
}

# スナップショット
resource "aws_ebs_snapshot" "backup" {
  volume_id = aws_ebs_volume.data.id

  tags = {
    Name = "data-backup"
  }
}

# Data Lifecycle Manager（自動スナップショット）
resource "aws_dlm_lifecycle_policy" "ebs_backup" {
  description        = "EBS snapshot policy"
  execution_role_arn = aws_iam_role.dlm.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = 7
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = true
    }

    target_tags = {
      Backup = "true"
    }
  }
}

# EC2起動時のルートボリューム設定
resource "aws_instance" "web" {
  ami           = "ami-xxxxx"
  instance_type = "t3.micro"

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  # 追加データボリューム
  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp3"
    volume_size           = 100
    encrypted             = true
    delete_on_termination = false
  }

  tags = {
    Name = "web-server"
  }
}
```

主要リソース：
- `aws_ebs_volume`：EBSボリューム
- `aws_volume_attachment`：EC2へのアタッチ
- `aws_ebs_snapshot`：スナップショット
- `aws_dlm_lifecycle_policy`：自動バックアップポリシー
