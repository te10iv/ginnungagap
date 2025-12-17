# Amazon EBS：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **スナップショット作成**：バックアップ
- **ボリューム拡張**：サイズ・IOPS増加
- **スナップショットから復元**：DR、テスト環境構築
- **ボリュームタイプ変更**：gp2→gp3等

## よくあるトラブル
### トラブル1：ディスク容量不足
- 症状：「No space left on device」エラー
- 原因：
  - ディスク使用率100%
  - ボリュームサイズ不足
- 確認ポイント：
  - `df -h`でディスク使用率確認
  - ボリューム拡張（AWS側 + OS側）
  - 不要ファイル削除

### トラブル2：パフォーマンス低下
- 症状：ディスクI/Oが遅い
- 原因：
  - IOPS上限到達
  - バーストクレジット枯渇（gp3以前）
  - ボリュームタイプ不適切
- 確認ポイント：
  - CloudWatch MetricsでIOPS確認
  - gp3にアップグレード（IOPS独立設定）
  - io2検討（高IOPS）

### トラブル3：スナップショット失敗
- 症状：スナップショット作成エラー
- 原因：
  - ボリューム使用中
  - I/O負荷高い
- 確認ポイント：
  - アプリケーション停止不要（オンライン取得可能）
  - 整合性が必要な場合はファイルシステムフリーズ

## 監視・ログ
- **CloudWatch Metrics**：
  - `VolumeReadBytes / VolumeWriteBytes`：読み書きバイト数
  - `VolumeReadOps / VolumeWriteOps`：IOPS
  - `VolumeThroughputPercentage`：スループット使用率
  - `VolumeIdleTime`：アイドル時間
  - `BurstBalance`：バーストクレジット残高（gp2/st1/sc1）
- **CloudWatch Alarm**：IOPS・スループット監視

## コストでハマりやすい点
- **ボリューム課金**：
  - gp3：$0.096/GB/月 + IOPS課金（3000超過分）
  - gp2：$0.12/GB/月
  - io2：$0.142/GB/月 + IOPS課金
  - st1：$0.054/GB/月（最低500GB）
  - sc1：$0.018/GB/月（最低500GB）
- **スナップショット課金**：$0.056/GB/月（増分のみ）
- **削除忘れ**：デタッチ済みボリューム、古いスナップショット
- **コスト削減策**：
  - gp2→gp3移行（20%削減）
  - 不要なスナップショット削除
  - Data Lifecycle Managerで自動削除
  - デタッチ済みボリューム定期確認

## 実務Tips
- **gp3推奨**：gp2より20%安い、IOPS独立設定
- **暗号化必須**：デフォルト有効推奨
- **スナップショット定期取得**：Data Lifecycle Manager使用
- **ボリューム拡張手順**：
  1. AWS側：ボリュームサイズ変更（マネコン/CLI）
  2. OS側：パーティション拡張（`growpart`、`resize2fs`等）
- **ルートボリューム保護**：`delete_on_termination=false`設定
- **データボリューム分離**：OS（ルート）とデータ（別ボリューム）分離
- **スナップショットからAMI作成**：環境複製
- **クロスリージョンコピー**：DR対策
- **マルチアタッチ**：io2のみ、クラスタ構成
- **設計時に言語化すると評価が上がるポイント**：
  - 「gp3ボリューム採用でgp2より20%コスト削減、IOPS独立設定」
  - 「Data Lifecycle Managerで日次スナップショット自動化、7日保持」
  - 「ルートとデータボリューム分離、インスタンス終了時にデータ保護」
  - 「暗号化（KMS）でデータ保護、スナップショットも暗号化」
  - 「スナップショットのクロスリージョンコピーでDR対策」
  - 「io2ボリュームでプロビジョンドIOPS 32,000、DBワークロード最適化」
  - 「CloudWatch Alarmでディスク使用率監視、80%で通知」

## ボリュームタイプ比較

| タイプ | 用途 | IOPS | スループット | サイズ | 料金 |
|--------|------|------|-------------|--------|------|
| gp3 | 汎用SSD | 3,000〜16,000 | 125〜1,000 MB/s | 1GB〜16TB | $0.096/GB |
| gp2 | 汎用SSD | 100〜16,000 | 250 MB/s | 1GB〜16TB | $0.12/GB |
| io2 | 高性能SSD | 100〜64,000 | 1,000 MB/s | 4GB〜16TB | $0.142/GB + IOPS |
| st1 | スループット | 500 | 500 MB/s | 125GB〜16TB | $0.054/GB |
| sc1 | コールド | 250 | 250 MB/s | 125GB〜16TB | $0.018/GB |

## ボリューム拡張手順（Linux）

```bash
# 1. AWS側でボリュームサイズ変更（マネコンまたはCLI）
aws ec2 modify-volume --volume-id vol-xxxxx --size 200

# 2. 変更確認
aws ec2 describe-volumes-modifications --volume-id vol-xxxxx

# 3. OS側でパーティション確認
lsblk

# 4. パーティション拡張
sudo growpart /dev/nvme1n1 1

# 5. ファイルシステム拡張（ext4の場合）
sudo resize2fs /dev/nvme1n1p1

# XFSの場合
sudo xfs_growfs /mnt/data

# 6. 確認
df -h
```

## スナップショット操作（AWS CLI）

```bash
# スナップショット作成
aws ec2 create-snapshot \
  --volume-id vol-xxxxx \
  --description "Daily backup" \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=daily-backup}]'

# スナップショット一覧
aws ec2 describe-snapshots --owner-ids self

# スナップショットから復元
aws ec2 create-volume \
  --snapshot-id snap-xxxxx \
  --availability-zone ap-northeast-1a \
  --volume-type gp3

# クロスリージョンコピー
aws ec2 copy-snapshot \
  --source-region ap-northeast-1 \
  --source-snapshot-id snap-xxxxx \
  --destination-region ap-northeast-3 \
  --description "DR backup"

# 古いスナップショット削除
aws ec2 delete-snapshot --snapshot-id snap-xxxxx
```

## gp2 vs gp3 比較

| 項目 | gp2 | gp3 |
|------|-----|-----|
| 料金 | $0.12/GB | $0.096/GB（20%安） |
| ベースIOPS | 3 IOPS/GB | 3,000（固定） |
| 最大IOPS | 16,000 | 16,000 |
| スループット | 250 MB/s | 125〜1,000 MB/s |
| バーストクレジット | あり | なし（安定） |
| IOPS追加課金 | なし | 3,000超過分 |

## EBS vs Instance Store

| 項目 | EBS | Instance Store |
|------|-----|----------------|
| 永続性 | 永続化 | 一時（停止で消失） |
| スナップショット | 可能 | 不可 |
| サイズ変更 | 可能 | 不可 |
| AZ移動 | スナップショット経由 | 不可 |
| 用途 | 永続データ | キャッシュ、一時ファイル |

## マウント例（Linux）

```bash
# デバイス確認
lsblk

# ファイルシステム作成（初回のみ）
sudo mkfs -t ext4 /dev/nvme1n1

# マウントポイント作成
sudo mkdir /mnt/data

# マウント
sudo mount /dev/nvme1n1 /mnt/data

# 自動マウント設定（/etc/fstab）
echo '/dev/nvme1n1 /mnt/data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# UUID使用（推奨）
sudo blkid /dev/nvme1n1
echo 'UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /mnt/data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
```
