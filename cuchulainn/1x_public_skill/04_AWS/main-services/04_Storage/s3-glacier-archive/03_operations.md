# Amazon S3 Glacier：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **ライフサイクルポリシー**：自動移行・削除
- **取り出しリクエスト**：アーカイブデータ復元
- **Vault Lock**：削除禁止（コンプライアンス）
- **取り出しティア選択**：Expedited/Standard/Bulk

## よくあるトラブル
### トラブル1：取り出し時間が長い
- 症状：データ取り出しに数時間かかる
- 原因：
  - Glacier Flexible Retrieval使用
  - Standardティア選択
- 確認ポイント：
  - Expedited（1〜5分）検討
  - 頻繁アクセスならStandard-IA推奨
  - 取り出し計画的に実施

### トラブル2：高額な取り出し料金
- 症状：月末に取り出し料金が数万円
- 原因：
  - Expedited使用
  - 大量データ取り出し
  - 頻繁な取り出し
- 確認ポイント：
  - Bulkティア使用（低コスト）
  - Standard-IA検討（即座アクセス可能）
  - 取り出し計画

### トラブル3：早期削除違約金
- 症状：削除時に高額請求
- 原因：
  - 最低保存期間前に削除
  - Glacier Flexible：90日未満
  - Deep Archive：180日未満
- 確認ポイント：
  - 最低保存期間経過後に削除
  - テストデータは慎重に

## 監視・ログ
- **CloudWatch Metrics**：
  - `NumberOfObjects`：オブジェクト数
  - `BucketSizeBytes`：ストレージ使用量（クラス別）
- **S3 Inventory**：ストレージクラス別レポート
- **Cost Explorer**：ストレージクラス別コスト

## コストでハマりやすい点
- **ストレージ課金**：
  - Glacier Flexible Retrieval：$0.0045/GB/月
  - Glacier Deep Archive：$0.00099/GB/月
  - S3 Standard：$0.025/GB/月（比較）
- **取り出し課金**：
  - Expedited：$0.033/GB + $0.011/リクエスト
  - Standard：$0.011/GB + $0.00055/リクエスト
  - Bulk：$0.0028/GB + $0.000028/リクエスト
- **最低保存期間違約金**：
  - Flexible：90日未満で削除時、残日数分課金
  - Deep Archive：180日未満で削除時、残日数分課金
- **リクエスト課金**：PUT/LIST等
- **コスト削減策**：
  - Intelligent-Tiering（自動最適化）
  - Bulk取り出し使用
  - 最低保存期間順守
  - 頻繁アクセスならStandard-IA

## 実務Tips
- **Intelligent-Tiering推奨**：アクセスパターン不明時、自動最適化
- **Glacier vs Deep Archive**：
  - Flexible：年数回取り出し、数時間OK
  - Deep Archive：ほぼ取り出さない、12時間OK
- **最低保存期間注意**：テストは別バケット
- **Vault Lock活用**：コンプライアンス（7年保存等）
- **取り出しティア**：
  - Expedited：緊急（1〜5分）
  - Standard：標準（3〜5時間）
  - Bulk：大量・計画的（5〜12時間）
- **S3統合**：直接Glacier API使用は稀、S3経由推奨
- **クロスリージョンレプリケーション**：DR対策
- **設計時に言語化すると評価が上がるポイント**：
  - 「ライフサイクルポリシーで90日後Glacier移行、ストレージコスト82%削減」
  - 「Glacier Deep Archiveで最安ストレージ、7年保存要件対応」
  - 「Intelligent-Tieringで自動最適化、運用負荷軽減」
  - 「Vault Lockで削除禁止、コンプライアンス対応（金融・医療）」
  - 「Bulk取り出しで低コスト復元、計画的なデータ取り出し」
  - 「最低保存期間順守で違約金回避、コスト最適化」

## Glacierクラス比較

| クラス | 料金 | 最低保存 | 取り出し時間 | 取り出し料 | 用途 |
|--------|------|---------|-------------|----------|------|
| Standard | $0.025/GB | なし | 即座 | なし | 頻繁アクセス |
| Standard-IA | $0.0138/GB | 30日 | 即座 | $0.01/GB | 月1回程度 |
| Glacier Flexible | $0.0045/GB | 90日 | 分〜時間 | $0.011/GB | 年数回 |
| Deep Archive | $0.00099/GB | 180日 | 12〜48時間 | $0.02/GB | ほぼなし |

## 取り出しティア比較（Glacier Flexible Retrieval）

| ティア | 時間 | 料金 | 用途 |
|--------|------|------|------|
| Expedited | 1〜5分 | $0.033/GB | 緊急 |
| Standard | 3〜5時間 | $0.011/GB | 標準 |
| Bulk | 5〜12時間 | $0.0028/GB | 大量・低コスト |

## コスト試算例

**シナリオ**：100TBのログを7年保存

| ストレージクラス | 月額 | 年額 | 7年合計 |
|----------------|------|------|---------|
| S3 Standard | $2,560 | $30,720 | $215,040 |
| Glacier Flexible | $461 | $5,532 | $38,724 |
| Deep Archive | $101 | $1,212 | $8,484 |

**削減率**：Deep Archive で **96%削減**

## ライフサイクルポリシー例

```json
{
  "Rules": [
    {
      "Id": "archive-policy",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "logs/"
      },
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        },
        {
          "Days": 365,
          "StorageClass": "DEEP_ARCHIVE"
        }
      ],
      "Expiration": {
        "Days": 2555
      }
    }
  ]
}
```

## 取り出し操作（AWS CLI）

```bash
# Glacier取り出しリクエスト（Standard）
aws s3api restore-object \
  --bucket my-bucket \
  --key logs/archive.zip \
  --restore-request '{"Days":7,"GlacierJobParameters":{"Tier":"Standard"}}'

# Expedited取り出し
aws s3api restore-object \
  --bucket my-bucket \
  --key logs/archive.zip \
  --restore-request '{"Days":1,"GlacierJobParameters":{"Tier":"Expedited"}}'

# Bulk取り出し
aws s3api restore-object \
  --bucket my-bucket \
  --key logs/archive.zip \
  --restore-request '{"Days":7,"GlacierJobParameters":{"Tier":"Bulk"}}'

# 取り出し状態確認
aws s3api head-object \
  --bucket my-bucket \
  --key logs/archive.zip

# 取り出し完了後、一時的にS3 Standardで利用可能（Days指定期間）
aws s3 cp s3://my-bucket/logs/archive.zip ./
```

## Intelligent-Tiering設定例

```bash
# Intelligent-Tiering アーカイブ設定
aws s3api put-bucket-intelligent-tiering-configuration \
  --bucket my-bucket \
  --id entire-bucket \
  --intelligent-tiering-configuration '{
    "Id": "entire-bucket",
    "Status": "Enabled",
    "Tierings": [
      {
        "Days": 90,
        "AccessTier": "ARCHIVE_ACCESS"
      },
      {
        "Days": 180,
        "AccessTier": "DEEP_ARCHIVE_ACCESS"
      }
    ]
  }'
```

## Vault Lock設定例（コンプライアンス）

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "deny-delete-for-7-years",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "glacier:DeleteArchive"
      ],
      "Resource": "arn:aws:glacier:ap-northeast-1:123456789012:vaults/backup-vault",
      "Condition": {
        "DateLessThan": {
          "glacier:ArchiveAgeInDays": "2555"
        }
      }
    }
  ]
}
```

## 主要ユースケース

1. **コンプライアンス**：金融・医療の長期保存要件（7〜10年）
2. **バックアップアーカイブ**：災害対策、年次バックアップ
3. **メディアアーカイブ**：動画・画像の長期保存
4. **ログ保存**：監査ログ、アクセスログ
5. **データレイク**：古いデータの低コスト保存

## S3 ストレージクラス選択フローチャート

```
アクセス頻度は？
├─ 頻繁（日次）→ S3 Standard
├─ 月1回程度 → Standard-IA
├─ 年数回 → Glacier Flexible Retrieval
├─ ほぼなし → Glacier Deep Archive
└─ 不明 → Intelligent-Tiering（自動最適化）
```
