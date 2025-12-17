# Amazon EFS：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **ライフサイクル管理**：自動的にIA移行
- **バックアップ**：AWS Backup統合
- **Access Points**：アプリケーション単位のアクセス制御
- **パフォーマンスモード変更**：汎用⇔Max I/O

## よくあるトラブル
### トラブル1：マウントできない
- 症状：「mount.nfs: Connection timed out」エラー
- 原因：
  - Security GroupでNFS（2049）が許可されていない
  - マウントターゲットが存在しない
  - サブネット異なる
- 確認ポイント：
  - Security GroupでEC2のSG許可
  - マウントターゲット確認
  - DNS名正しいか確認

### トラブル2：パフォーマンス低下
- 症状：ファイルアクセスが遅い
- 原因：
  - バーストクレジット枯渇
  - 汎用モードで高IOPS要件
  - 小さいファイル大量アクセス
- 確認ポイント：
  - CloudWatch MetricsでBurstCreditBalance確認
  - プロビジョンドスループット検討
  - Max I/Oモード検討

### トラブル3：高額課金
- 症状：月末にEFS課金が数万円
- 原因：
  - Standard クラスに大量データ
  - IA移行未設定
  - 不要ファイル削除未実施
- 確認ポイント：
  - ライフサイクル管理有効化（30日でIA移行）
  - 不要ファイル削除
  - ストレージクラス確認

## 監視・ログ
- **CloudWatch Metrics**：
  - `DataReadIOBytes / DataWriteIOBytes`：読み書きバイト数
  - `TotalIOBytes`：合計I/O
  - `PermittedThroughput`：許可スループット
  - `BurstCreditBalance`：バーストクレジット
  - `ClientConnections`：接続数
  - `StorageBytes`：ストレージ使用量
- **CloudWatch Alarm**：バーストクレジット・スループット監視

## コストでハマりやすい点
- **ストレージ課金**：
  - Standard：$0.36/GB/月
  - IA（Infrequent Access）：$0.023/GB/月
  - IAアクセス料：$0.01/GB
- **スループット課金**（プロビジョンド）：$6.48/MiB/s/月
- **リクエスト課金**：IA アクセス時
- **コスト削減策**：
  - ライフサイクル管理有効化（30日でIA移行）
  - 不要ファイル削除
  - バーストモード（固定費なし）
  - IA移行で最大93%削減

## 実務Tips
- **ライフサイクル管理必須**：30日でIA移行推奨
- **汎用モード推奨**：ほとんどのユースケース
- **Max I/Oモード**：数百〜数千のクライアント、高並列
- **バーストモード推奨**：固定費なし、多くのケースで十分
- **プロビジョンドスループット**：常に高スループット必要な場合
- **暗号化必須**：保管時暗号化（作成時設定）
- **転送時暗号化**：NFSマウント時にTLS使用
- **Access Points活用**：
  - アプリケーション単位の分離
  - POSIX権限強制
  - Lambda統合
- **Security Group設計**：
  - NFS（2049）のみ許可
  - EC2のSGから許可
- **マウントターゲット**：各AZに配置（可用性・レイテンシー）
- **設計時に言語化すると評価が上がるポイント**：
  - 「EFSで複数EC2から共有ストレージアクセス、スケールアウト構成」
  - 「ライフサイクル管理で30日後IA移行、ストレージコスト93%削減」
  - 「自動Multi-AZ複製で高可用性、単一障害点なし」
  - 「Access Pointsでアプリケーション単位のアクセス制御、セキュリティ強化」
  - 「LambdaにEFS統合、MLモデル・共有設定ファイル永続化」
  - 「保管時・転送時暗号化でデータ保護」
  - 「AWS Backup統合で自動バックアップ、ポイントインタイム復元」

## パフォーマンスモード比較

| モード | 用途 | レイテンシー | スループット | 接続数 |
|--------|------|-------------|-------------|--------|
| 汎用 | 標準ワークロード | 低い | 標準 | 数百台 |
| Max I/O | 高並列 | 高い | 高い | 数千台 |

## スループットモード比較

| モード | 料金 | スループット | 用途 |
|--------|------|-------------|------|
| バースト | 無料 | ストレージ量に応じて | 標準（推奨） |
| プロビジョンド | $6.48/MiB/s/月 | 固定確保 | 常に高スループット |

## マウント手順（Linux）

```bash
# EFS utilities インストール（Amazon Linux 2）
sudo yum install -y amazon-efs-utils

# マウントポイント作成
sudo mkdir /mnt/efs

# NFSマウント（DNS使用）
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-xxxxx.efs.ap-northeast-1.amazonaws.com:/ /mnt/efs

# EFS utilities使用（推奨）
sudo mount -t efs fs-xxxxx:/ /mnt/efs

# 転送時暗号化（TLS）
sudo mount -t efs -o tls fs-xxxxx:/ /mnt/efs

# Access Point使用
sudo mount -t efs -o tls,accesspoint=fsap-xxxxx fs-xxxxx:/ /mnt/efs

# 自動マウント設定（/etc/fstab）
echo 'fs-xxxxx:/ /mnt/efs efs _netdev,tls 0 0' | sudo tee -a /etc/fstab

# マウント確認
df -h | grep efs
```

## ライフサイクル管理設定

```bash
# AWS CLI でライフサイクル管理設定
aws efs put-lifecycle-configuration \
  --file-system-id fs-xxxxx \
  --lifecycle-policies TransitionToIA=AFTER_30_DAYS

# 確認
aws efs describe-lifecycle-configuration --file-system-id fs-xxxxx
```

## Lambda統合例（Python）

```python
import os

def lambda_handler(event, context):
    # EFS マウントパス
    efs_path = '/mnt/efs'
    
    # ファイル読み書き
    file_path = os.path.join(efs_path, 'data.txt')
    
    # 書き込み
    with open(file_path, 'w') as f:
        f.write('Hello from Lambda!')
    
    # 読み込み
    with open(file_path, 'r') as f:
        content = f.read()
    
    return {
        'statusCode': 200,
        'body': content
    }
```

## EFS vs EBS vs S3

| 項目 | EFS | EBS | S3 |
|------|-----|-----|-----|
| タイプ | ファイル | ブロック | オブジェクト |
| 同時アクセス | 複数EC2 | 単一EC2 | 無制限 |
| プロトコル | NFS | ブロックデバイス | HTTP API |
| スケール | 自動、ペタバイト | 手動、64TB | 無制限 |
| 料金 | $0.36/GB（Standard） | $0.096/GB（gp3） | $0.025/GB |
| 用途 | 共有ファイル | EC2ディスク | 静的ファイル、ログ |

## ストレージクラス比較

| クラス | 料金 | アクセス料 | 用途 |
|--------|------|----------|------|
| Standard | $0.36/GB/月 | なし | 頻繁アクセス |
| IA | $0.023/GB/月 | $0.01/GB | 低頻度アクセス |

**試算例**：
- 100GB、月10GBアクセス
  - Standard：$36/月
  - IA：$2.3 + $0.1 = $2.4/月
  - **削減率：93%**

## コスト最適化例

```terraform
# ライフサイクル管理
resource "aws_efs_file_system" "main" {
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"   # 7日でIA移行
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"  # 1回アクセスでStandard復帰
  }
}
```
