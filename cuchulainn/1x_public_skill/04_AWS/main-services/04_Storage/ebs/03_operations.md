# Amazon EBS：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **スナップショット作成**：手動・自動バックアップ
- **ボリューム拡張**：サイズ・IOPS・スループット増加
- **スナップショットからボリューム復元**：バックアップから復元
- **ボリュームタイプ変更**：gp2→gp3等

## よくあるトラブル
### トラブル1：ディスク容量不足
- 症状：「No space left on device」エラー
- 原因：
  - EBSボリュームサイズ不足
  - ファイルシステム拡張未実施
- 確認ポイント：
  - `df -h` でディスク使用率確認
  - AWSコンソールでボリューム拡張
  - EC2内でファイルシステム拡張（`growpart`、`resize2fs`）

### トラブル2：IOPS不足でパフォーマンス低下
- 症状：ディスクI/Oが遅い
- 原因：
  - gp3のIOPS不足（デフォルト3000）
  - ボリュームタイプ不適切（gp2でバーストクレジット枯渇）
- 確認ポイント：
  - CloudWatch MetricsでIOPS確認
  - gp3でIOPS増加（最大16000）
  - io2へ変更検討

### トラブル3：スナップショット削除でコスト削減失敗
- 症状：古いスナップショット大量、コスト高い
- 原因：
  - スナップショット自動削除未設定
  - 手動削除忘れ
- 確認ポイント：
  - 不要なスナップショット特定・削除
  - Data Lifecycle Managerで自動削除
  - スナップショット保持ポリシー設定

## 監視・ログ
- **CloudWatch Metrics**：
  - `VolumeReadBytes / VolumeWriteBytes`：読み取り・書き込みバイト数
  - `VolumeReadOps / VolumeWriteOps`：IOPS
  - `VolumeThroughputPercentage`：スループット使用率
  - `VolumeIdleTime`：アイドル時間
  - `BurstBalance`：バーストクレジット残量（gp2）
- **CloudWatch Alarm**：IOPS・スループット・容量監視

## コストでハマりやすい点
- **ボリューム課金**：
  - gp3：$0.096/GB/月（東京）
  - gp2：$0.12/GB/月
  - io2：$0.142/GB/月 + IOPS課金
  - st1：$0.054/GB/月
  - sc1：$0.018/GB/月
- **IOPS課金**：io2は追加IOPS課金
- **スナップショット**：$0.05/GB/月（増分バックアップ）
- **削除忘れ**：デタッチ後もボリューム課金継続
- **コスト削減策**：
  - gp3推奨（gp2より20%安い）
  - 不要ボリューム・スナップショット削除
  - st1/sc1検討（Big Data、ログ等）
  - スナップショット保持期間最適化

## 実務Tips
- **gp3推奨**：コスパ最良、gp2より20%安い
- **暗号化必須**：作成時に設定（後から変更不可）
- **スナップショット自動化**：Data Lifecycle Manager
- **ボリューム拡張**：
  - AWSコンソールでサイズ拡張
  - EC2内でファイルシステム拡張必須
  ```bash
  # パーティション拡張
  sudo growpart /dev/nvme1n1 1
  
  # ファイルシステム拡張（ext4）
  sudo resize2fs /dev/nvme1n1p1
  
  # ファイルシステム拡張（xfs）
  sudo xfs_growfs -d /mnt/data
  ```
- **ルートボリューム削除**：デフォルトでEC2削除時に削除（変更可能）
- **データボリューム削除**：デフォルトでEC2削除時に保持
- **スナップショット活用**：
  - AMI作成（ルートボリュームスナップショット）
  - クロスリージョンコピー（DR対策）
- **io2 Block Express**：最大64000 IOPS、超高性能
- **Multi-Attach**：io2のみ、複数EC2に同時アタッチ可能（要注意）
- **設計時に言語化すると評価が上がるポイント**：
  - 「gp3採用でgp2比20%コスト削減、IOPS・スループット独立調整可能」
  - 「Data Lifecycle Managerで日次スナップショット自動作成、7日保持」
  - 「暗号化有効化でデータ保護、KMS管理」
  - 「ルートボリュームとデータボリューム分離、OS再構築時のデータ保護」
  - 「CloudWatch Alarmで容量・IOPS監視、閾値超過時通知」
  - 「スナップショットをクロスリージョンコピー、DR対策」

## ボリュームタイプ比較

| タイプ | 用途 | IOPS | スループット | 料金（/GB/月） |
|--------|------|------|--------------|----------------|
| gp3 | 汎用 | 3000〜16000 | 125〜1000 MB/s | $0.096 |
| gp2 | 汎用（旧） | 100〜16000 | 最大250 MB/s | $0.12 |
| io2 | 高IOPS | 100〜64000 | 最大1000 MB/s | $0.142 + IOPS |
| st1 | スループット | 最大500 | 最大500 MB/s | $0.054 |
| sc1 | コールド | 最大250 | 最大250 MB/s | $0.018 |

## ボリューム拡張手順（Linux）

```bash
# 1. 現在のサイズ確認
df -h
lsblk

# 2. AWSコンソールでボリューム拡張（例：100GB → 200GB）

# 3. パーティション拡張
sudo growpart /dev/nvme1n1 1

# 4. ファイルシステム拡張（ext4の場合）
sudo resize2fs /dev/nvme1n1p1

# 4. ファイルシステム拡張（xfsの場合）
sudo xfs_growfs -d /mnt/data

# 5. 確認
df -h
```

## スナップショット作成・復元（AWS CLI）

```bash
# スナップショット作成
aws ec2 create-snapshot \
  --volume-id vol-1234567890abcdef0 \
  --description "Daily backup" \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=daily-backup}]'

# スナップショット一覧
aws ec2 describe-snapshots --owner-ids self

# スナップショットからボリューム作成
aws ec2 create-volume \
  --snapshot-id snap-1234567890abcdef0 \
  --availability-zone ap-northeast-1a \
  --volume-type gp3 \
  --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=restored-volume}]'

# ボリュームをEC2にアタッチ
aws ec2 attach-volume \
  --volume-id vol-abcdef1234567890 \
  --instance-id i-1234567890abcdef0 \
  --device /dev/sdf
```

## EC2でのマウント手順

```bash
# 1. デバイス確認
lsblk

# 2. ファイルシステム作成（初回のみ）
sudo mkfs -t ext4 /dev/nvme1n1

# 3. マウントポイント作成
sudo mkdir /mnt/data

# 4. マウント
sudo mount /dev/nvme1n1 /mnt/data

# 5. 自動マウント設定（/etc/fstab）
echo '/dev/nvme1n1 /mnt/data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# 6. 確認
df -h
```

## gp2 → gp3 移行

```bash
# ボリュームタイプ変更
aws ec2 modify-volume \
  --volume-id vol-1234567890abcdef0 \
  --volume-type gp3 \
  --iops 3000 \
  --throughput 125

# 変更状況確認
aws ec2 describe-volumes-modifications \
  --volume-id vol-1234567890abcdef0
```

## EBS最適化インスタンス

- **EBS最適化**：EC2とEBS間の専用帯域確保
- **M5、C5、R5等**：デフォルトでEBS最適化
- **T3**：追加料金でEBS最適化可能
- **推奨**：本番環境は必ずEBS最適化インスタンス使用
