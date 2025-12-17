# Amazon S3：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **バージョニング**：ファイル履歴管理
- **ライフサイクルポリシー**：自動的にストレージクラス移行・削除
- **レプリケーション**：クロスリージョン/同一リージョン
- **イベント通知**：Lambda、SNS、SQSにイベント送信

## よくあるトラブル
### トラブル1：アクセス拒否（403 Forbidden）
- 症状：「Access Denied」エラー
- 原因：
  - パブリックアクセスブロック有効
  - バケットポリシー未設定
  - IAMロール権限不足
  - 暗号化KMSキーの権限不足
- 確認ポイント：
  - パブリックアクセスブロック設定確認
  - バケットポリシー確認
  - IAMロール/ユーザーポリシー確認
  - KMSキーポリシー確認

### トラブル2：高額課金
- 症状：月末にS3課金が数万円
- 原因：
  - 大量の小さいファイル（リクエスト課金）
  - 不要なバージョン蓄積
  - データ転送料
  - ストレージクラス未最適化
- 確認ポイント：
  - Cost ExplorerでS3課金内訳確認
  - ライフサイクルポリシーで古いバージョン削除
  - ストレージクラス最適化（Intelligent-Tiering）
  - CloudFront使用でデータ転送料削減

### トラブル3：パフォーマンス低下
- 症状：アップロード/ダウンロードが遅い
- 原因：
  - 同一プレフィックスへの集中（旧仕様）
  - マルチパートアップロード未使用
  - Transfer Acceleration未使用
- 確認ポイント：
  - マルチパートアップロード使用（100MB以上）
  - Transfer Acceleration有効化（遠隔地）
  - CloudFront使用（ダウンロード高速化）

## 監視・ログ
- **CloudWatch Metrics**：
  - `BucketSizeBytes`：バケットサイズ
  - `NumberOfObjects`：オブジェクト数
  - `AllRequests`：リクエスト数
  - `4xxErrors / 5xxErrors`：エラー数
- **S3サーバーアクセスログ**：詳細なアクセスログ
- **CloudTrail**：API操作ログ
- **CloudWatch Alarm**：エラー率、リクエスト数監視

## コストでハマりやすい点
- **ストレージ課金**：
  - Standard：$0.025/GB/月
  - Standard-IA：$0.0138/GB/月（最低保存期間30日）
  - Glacier Flexible Retrieval：$0.0045/GB/月（最低90日）
  - Glacier Deep Archive：$0.00099/GB/月（最低180日）
- **リクエスト課金**：
  - PUT/POST：$0.0047/1000リクエスト
  - GET：$0.00037/1000リクエスト
- **データ転送料**：
  - インターネット向けアウト：$0.114/GB〜
  - CloudFront経由：削減可能
- **バージョニング**：全バージョン分課金
- **コスト削減策**：
  - Intelligent-Tiering（自動最適化）
  - ライフサイクルポリシー
  - 古いバージョン削除
  - CloudFront使用
  - S3 Select（必要なデータのみ取得）

## 実務Tips
- **パブリックアクセスブロック必須**：誤公開防止
- **バージョニング有効化**：誤削除対策
- **MFA Delete**：重要データの削除保護
- **暗号化必須**：SSE-S3（デフォルト）またはSSE-KMS
- **ライフサイクルポリシー**：コスト最適化
- **Intelligent-Tiering推奨**：アクセスパターン不明時
- **マルチパートアップロード**：100MB以上のファイル
- **Transfer Acceleration**：遠隔地からのアップロード高速化
- **CloudFront併用**：
  - ダウンロード高速化
  - データ転送料削減
  - DDoS対策
- **VPCエンドポイント**：プライベート接続、データ転送料無料
- **S3 Select / Glacier Select**：必要なデータのみ取得
- **バケット名規約**：`<環境>-<アプリ>-<用途>-<リージョン>-<識別子>`
- **プレフィックス設計**：
  - 日付：`logs/2024/01/15/`
  - カテゴリ：`images/products/`
- **設計時に言語化すると評価が上がるポイント**：
  - 「バージョニング有効化で誤削除対策、ポイントインタイム復元可能」
  - 「ライフサイクルポリシーで30日後IA、90日後Glacierに自動移行、コスト最適化」
  - 「CloudFront併用でエッジロケーションからの配信、レイテンシー削減」
  - 「パブリックアクセスブロックで誤公開防止、セキュリティ強化」
  - 「SSE-KMS暗号化で保管時暗号化、CloudTrailで操作監査」
  - 「クロスリージョンレプリケーションでDR対策、RPO数秒」
  - 「VPCエンドポイント経由でプライベート接続、データ転送料削減」

## ストレージクラス比較

| クラス | 用途 | 料金 | 最低保存期間 | 取り出し料金 |
|--------|------|------|-------------|-------------|
| Standard | 頻繁アクセス | $0.025/GB | なし | なし |
| Intelligent-Tiering | 不明 | $0.025/GB〜 | なし | なし |
| Standard-IA | 月1回程度 | $0.0138/GB | 30日 | $0.01/GB |
| One Zone-IA | 非重要 | $0.011/GB | 30日 | $0.01/GB |
| Glacier Flexible | アーカイブ | $0.0045/GB | 90日 | $0.03/GB |
| Glacier Deep Archive | 長期保管 | $0.00099/GB | 180日 | $0.02/GB |

## ライフサイクルポリシー例

```json
{
  "Rules": [
    {
      "Id": "log-lifecycle",
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
        }
      ],
      "Expiration": {
        "Days": 365
      },
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 7
      }
    }
  ]
}
```

## AWS CLI操作例

```bash
# バケット作成
aws s3 mb s3://my-bucket

# ファイルアップロード
aws s3 cp file.txt s3://my-bucket/

# ファイルダウンロード
aws s3 cp s3://my-bucket/file.txt ./

# ディレクトリ同期
aws s3 sync ./local-dir s3://my-bucket/remote-dir/

# バケット内容一覧
aws s3 ls s3://my-bucket/

# マルチパートアップロード（大きいファイル自動判定）
aws s3 cp large-file.zip s3://my-bucket/ --storage-class INTELLIGENT_TIERING

# プレサインドURL生成（一時的なアクセス許可）
aws s3 presign s3://my-bucket/file.txt --expires-in 3600
```

## バケットポリシー例（CloudFront OAI）

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontOAI",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity XXXXX"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

## イベント通知設定例

```hcl
# Lambda関数トリガー
resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".jpg"
  }
}
```

## S3 vs EFS vs EBS

| 項目 | S3 | EFS | EBS |
|------|----|----|-----|
| タイプ | オブジェクト | ファイル | ブロック |
| アクセス | HTTP API | NFSマウント | EC2直接接続 |
| 容量 | 無制限 | 無制限 | 最大64TB |
| 用途 | 静的ファイル、ログ | 共有ファイル | OSディスク、DB |
| 同時接続 | 無制限 | 複数EC2 | 単一EC2 |
