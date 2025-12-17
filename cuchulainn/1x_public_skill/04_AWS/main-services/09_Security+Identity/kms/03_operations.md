# AWS KMS：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **キー作成**：カスタマー管理キー
- **暗号化・復号化**：Encrypt / Decrypt
- **キーローテーション**：自動ローテーション
- **キー削除スケジュール**：7〜30日待機期間

## よくあるトラブル
### トラブル1：復号化エラー
- 症状：「AccessDeniedException」
- 原因：
  - キーポリシー権限不足
  - IAMロール権限不足
  - キー削除済み
- 確認ポイント：
  - キーポリシー確認
  - IAMロールに `kms:Decrypt` 権限付与
  - キーステータス確認

### トラブル2：S3暗号化エラー
- 症状：S3アップロードエラー
- 原因：
  - KMSキーポリシーでS3許可不足
  - IAMロールに `kms:GenerateDataKey` 権限不足
- 確認ポイント：
  - キーポリシーでS3サービス許可
  - IAMロールに必要な権限付与

### トラブル3：高額課金
- 症状：月末にKMS課金が高額
- 原因：
  - 大量のリクエスト
  - 不要なキー作成
- 確認ポイント：
  - AWS管理キー使用（無料）
  - リクエスト削減
  - 未使用キー削除

## 監視・ログ
- **CloudTrail**：KMS操作ログ
- **CloudWatch Metrics**：
  - リクエスト数
  - エラー数
- **キーステータス**：Enabled / Disabled / PendingDeletion

## コストでハマりやすい点
- **カスタマー管理キー**：$1/月
- **リクエスト**：$0.03/10,000リクエスト
- **AWS管理キー**：無料（リクエスト課金なし）
- **コスト削減策**：
  - AWS管理キー使用（細かい制御不要なら）
  - 不要なキー削除
  - キャッシュ活用（データキー再利用）

## 実務Tips
- **自動ローテーション有効化**：年1回自動ローテーション
- **キー削除保護**：削除待機期間30日推奨
- **エイリアス使用**：キーIDではなくエイリアス使用
- **キーポリシー設計**：
  - ルートアカウント許可
  - サービス別に最小権限
  - クロスアカウント許可（必要に応じて）
- **AWS管理キー vs カスタマー管理キー**：
  - AWS管理キー：簡単、無料、制御不可
  - カスタマー管理キー：細かい制御、監査、$1/月
- **エンベロープ暗号化**：大きいデータはエンベロープ暗号化
- **設計時に言語化すると評価が上がるポイント**：
  - 「KMSカスタマー管理キーでデータ暗号化、キーポリシーで細かいアクセス制御」
  - 「自動ローテーション有効化で年1回キー更新、セキュリティ強化」
  - 「CloudTrail統合でKMS操作監査、暗号化・復号化ログ記録」
  - 「エンベロープ暗号化で大容量データ暗号化、パフォーマンス最適化」
  - 「クロスアカウントキーポリシーでマルチアカウント環境の暗号化統合」
  - 「キー削除待機期間30日設定で誤削除防止」
  - 「S3/EBS/RDS暗号化でデータ保護、コンプライアンス対応」

## 暗号化・復号化（AWS CLI）

```bash
# データ暗号化
aws kms encrypt \
  --key-id alias/main-key \
  --plaintext "Hello World" \
  --output text \
  --query CiphertextBlob | base64 --decode > encrypted.dat

# データ復号化
aws kms decrypt \
  --ciphertext-blob fileb://encrypted.dat \
  --output text \
  --query Plaintext | base64 --decode

# データキー生成（エンベロープ暗号化）
aws kms generate-data-key \
  --key-id alias/main-key \
  --key-spec AES_256

# データキー生成（暗号化済みのみ）
aws kms generate-data-key-without-plaintext \
  --key-id alias/main-key \
  --key-spec AES_256
```

## キー管理操作

```bash
# キー一覧
aws kms list-keys

# キー詳細
aws kms describe-key --key-id alias/main-key

# キーローテーション有効化
aws kms enable-key-rotation --key-id xxxxx

# キーローテーション状態確認
aws kms get-key-rotation-status --key-id xxxxx

# キー無効化
aws kms disable-key --key-id xxxxx

# キー削除スケジュール（30日後）
aws kms schedule-key-deletion \
  --key-id xxxxx \
  --pending-window-in-days 30

# キー削除キャンセル
aws kms cancel-key-deletion --key-id xxxxx
```

## エンベロープ暗号化（Python）

```python
import boto3
import base64

kms = boto3.client('kms')
KEY_ID = 'alias/main-key'

# 暗号化
def encrypt_file(input_file, output_file):
    # データキー生成
    response = kms.generate_data_key(
        KeyId=KEY_ID,
        KeySpec='AES_256'
    )
    
    plaintext_key = response['Plaintext']
    encrypted_key = response['CiphertextBlob']
    
    # ファイル読み込み
    with open(input_file, 'rb') as f:
        data = f.read()
    
    # データキーでデータ暗号化（実際はAESライブラリ使用）
    from cryptography.fernet import Fernet
    cipher = Fernet(base64.urlsafe_b64encode(plaintext_key[:32]))
    encrypted_data = cipher.encrypt(data)
    
    # 保存（暗号化データ + 暗号化データキー）
    with open(output_file, 'wb') as f:
        f.write(len(encrypted_key).to_bytes(4, 'big'))
        f.write(encrypted_key)
        f.write(encrypted_data)

# 復号化
def decrypt_file(input_file, output_file):
    with open(input_file, 'rb') as f:
        # 暗号化データキー取得
        key_length = int.from_bytes(f.read(4), 'big')
        encrypted_key = f.read(key_length)
        encrypted_data = f.read()
    
    # データキー復号化
    response = kms.decrypt(CiphertextBlob=encrypted_key)
    plaintext_key = response['Plaintext']
    
    # データ復号化
    from cryptography.fernet import Fernet
    cipher = Fernet(base64.urlsafe_b64encode(plaintext_key[:32]))
    data = cipher.decrypt(encrypted_data)
    
    # 保存
    with open(output_file, 'wb') as f:
        f.write(data)
```

## キーポリシー例

### 基本ポリシー
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM policies",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow use by specific role",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/app-role"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "*"
    }
  ]
}
```

### クロスアカウントポリシー
```json
{
  "Sid": "Allow cross-account use",
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::987654321098:root"
  },
  "Action": [
    "kms:Encrypt",
    "kms:Decrypt",
    "kms:GenerateDataKey"
  ],
  "Resource": "*",
  "Condition": {
    "StringEquals": {
      "kms:ViaService": "s3.ap-northeast-1.amazonaws.com"
    }
  }
}
```

## KMS vs CloudHSM

| 項目 | KMS | CloudHSM |
|------|-----|----------|
| タイプ | マネージド | 専用HSM |
| 管理 | AWS | ユーザー |
| 可用性 | マルチAZ自動 | ユーザー構築 |
| 料金 | $1/月 + リクエスト | $1.45/時 |
| FIPS 140-2 | Level 2 | Level 3 |
| 用途 | 標準的な暗号化 | 厳格なコンプライアンス |

## AWS管理キー vs カスタマー管理キー

| 項目 | AWS管理キー | カスタマー管理キー |
|------|-----------|-----------------|
| 料金 | 無料 | $1/月 |
| ローテーション | 3年ごと自動 | 1年ごと自動（設定可） |
| キーポリシー | 変更不可 | 変更可 |
| 削除 | 不可 | 可（7〜30日待機） |
| CloudTrail | 限定的 | 詳細 |
| 用途 | 簡単な暗号化 | 細かい制御 |

## 必要なIAM権限

### 暗号化
```json
{
  "Effect": "Allow",
  "Action": [
    "kms:Encrypt",
    "kms:GenerateDataKey",
    "kms:GenerateDataKeyWithoutPlaintext"
  ],
  "Resource": "arn:aws:kms:ap-northeast-1:123456789012:key/xxxxx"
}
```

### 復号化
```json
{
  "Effect": "Allow",
  "Action": [
    "kms:Decrypt"
  ],
  "Resource": "arn:aws:kms:ap-northeast-1:123456789012:key/xxxxx"
}
```

### S3暗号化（SSE-KMS）
```json
{
  "Effect": "Allow",
  "Action": [
    "kms:Decrypt",
    "kms:GenerateDataKey"
  ],
  "Resource": "arn:aws:kms:ap-northeast-1:123456789012:key/xxxxx"
}
```

## キーローテーション戦略

- **自動ローテーション**：
  - 有効化推奨
  - 年1回自動
  - 古いキーバージョンは保持（復号化可能）
  - 新規暗号化は新キー使用

- **手動ローテーション**：
  - より厳格な要件
  - エイリアス更新
  - アプリケーション変更不要

## ベストプラクティス

1. **自動ローテーション有効化**：年1回自動更新
2. **キー削除保護**：30日待機期間
3. **最小権限の原則**：キーポリシーで制限
4. **CloudTrail有効化**：KMS操作監査
5. **エイリアス使用**：キーID直接指定避ける
6. **クロスリージョンコピー**：DR対策
7. **タグ活用**：コスト配分、管理
8. **定期的な権限レビュー**：不要な権限削除
9. **マルチリージョン対応**：グローバルアプリ
10. **カスタマー管理キー優先**：監査・制御必要時
