# 04. S3操作の基礎

S3バケットとオブジェクトの基本操作をマスターする

---

## 🎯 学習目標

- S3バケットの一覧を取得できる
- バケットの作成・削除ができる
- ファイルのアップロード・ダウンロードができる
- s3とs3apiコマンドの違いを理解する
- syncコマンドを使いこなせる

**所要時間**: 45分

---

## 📦 S3コマンドの種類

### s3 vs s3api

AWS CLIにはS3を操作する2つのコマンドがあります：

| コマンド | 説明 | 用途 |
|---------|------|------|
| `aws s3` | 高レベルコマンド | 日常的なファイル操作 |
| `aws s3api` | 低レベルコマンド | 詳細な設定、API操作 |

**初心者は `aws s3` から始めましょう！**

---

## 🗂️ バケット操作

### バケット一覧の確認

```bash
# 自分のバケット一覧
aws s3 ls

# 出力例:
# 2024-01-15 10:30:00 my-bucket-1
# 2024-01-20 15:45:00 my-bucket-2
# 2024-02-01 09:00:00 my-logs-bucket
```

---

### バケットの作成

```bash
# バケット作成（東京リージョン）
aws s3 mb s3://my-new-bucket --region ap-northeast-1

# 出力:
# make_bucket: my-new-bucket
```

**注意点**:
- バケット名は**グローバルに一意**である必要がある
- 小文字、数字、ハイフンのみ使用可能
- 3〜63文字

---

### バケット名のルール

```bash
# ✅ 良い例
aws s3 mb s3://my-company-logs-2024

# ❌ 悪い例（大文字を含む）
aws s3 mb s3://MyCompanyLogs

# ❌ 悪い例（アンダースコア）
aws s3 mb s3://my_company_logs

# ❌ 悪い例（短すぎる）
aws s3 mb s3://ab
```

---

### バケットの削除

```bash
# 空のバケットを削除
aws s3 rb s3://my-bucket

# バケットが空でない場合はエラーになる
```

---

### バケットを中身ごと削除

```bash
# バケットの中身をすべて削除してからバケットを削除
aws s3 rb s3://my-bucket --force

# ⚠️ 警告: 復元できません！
```

---

## 📄 オブジェクト操作

### バケット内のファイル一覧

```bash
# バケット直下のファイル一覧
aws s3 ls s3://my-bucket/

# 特定のフォルダ（プレフィックス）内
aws s3 ls s3://my-bucket/logs/

# 再帰的にすべて表示
aws s3 ls s3://my-bucket/ --recursive

# 人間が読みやすい形式で表示
aws s3 ls s3://my-bucket/ --human-readable
```

---

### ファイルのアップロード

```bash
# 単一ファイルをアップロード
aws s3 cp file.txt s3://my-bucket/

# 別名で保存
aws s3 cp file.txt s3://my-bucket/renamed.txt

# フォルダを指定してアップロード
aws s3 cp file.txt s3://my-bucket/documents/

# ローカルフォルダ全体をアップロード
aws s3 cp ./local-folder s3://my-bucket/remote-folder/ --recursive
```

---

### ファイルのダウンロード

```bash
# 単一ファイルをダウンロード
aws s3 cp s3://my-bucket/file.txt ./

# 別名で保存
aws s3 cp s3://my-bucket/file.txt ./local-file.txt

# フォルダ全体をダウンロード
aws s3 cp s3://my-bucket/documents/ ./local-documents/ --recursive
```

---

### ファイルのコピー（S3間）

```bash
# 同じバケット内でコピー
aws s3 cp s3://my-bucket/file.txt s3://my-bucket/backup/file.txt

# 別のバケットにコピー
aws s3 cp s3://source-bucket/file.txt s3://dest-bucket/file.txt

# フォルダごとコピー
aws s3 cp s3://source-bucket/folder/ s3://dest-bucket/folder/ --recursive
```

---

### ファイルの移動

```bash
# ローカルからS3へ移動（ローカルファイルは削除される）
aws s3 mv file.txt s3://my-bucket/

# S3からローカルへ移動
aws s3 mv s3://my-bucket/file.txt ./

# S3間で移動
aws s3 mv s3://my-bucket/old-location/ s3://my-bucket/new-location/ --recursive
```

---

### ファイルの削除

```bash
# 単一ファイルを削除
aws s3 rm s3://my-bucket/file.txt

# フォルダ内のすべてのファイルを削除
aws s3 rm s3://my-bucket/logs/ --recursive

# 特定パターンのファイルを削除（include/exclude使用）
aws s3 rm s3://my-bucket/ --recursive --exclude "*" --include "*.log"
```

---

## 🔄 syncコマンド

### syncとは

**ローカルとS3を同期する**強力なコマンド

```bash
# ローカル → S3へ同期
aws s3 sync ./local-folder s3://my-bucket/remote-folder

# S3 → ローカルへ同期
aws s3 sync s3://my-bucket/remote-folder ./local-folder

# S3 → S3へ同期
aws s3 sync s3://source-bucket s3://dest-bucket
```

---

### syncの動作

```bash
# 初回実行（すべてアップロード）
aws s3 sync ./website s3://my-website-bucket/

# 2回目実行（変更があったファイルのみアップロード）
aws s3 sync ./website s3://my-website-bucket/
```

**ポイント**:
- ✅ 新しいファイルのみアップロード
- ✅ 更新されたファイルのみアップロード
- ✅ 削除されたファイルは同期されない（デフォルト）

---

### --delete オプション

```bash
# ローカルで削除したファイルをS3からも削除
aws s3 sync ./website s3://my-website-bucket/ --delete

# ⚠️ 注意: S3側でファイルが削除されます！
```

---

### include/exclude

```bash
# .logファイルのみ同期
aws s3 sync ./logs s3://my-logs-bucket/ --include "*.log"

# .tmpファイルを除外
aws s3 sync ./data s3://my-data-bucket/ --exclude "*.tmp"

# 複数条件
aws s3 sync ./files s3://my-bucket/ \
  --exclude "*" \
  --include "*.jpg" \
  --include "*.png"
```

---

## 🔐 アクセス制御

### プライベート vs パブリック

```bash
# プライベートでアップロード（デフォルト）
aws s3 cp file.txt s3://my-bucket/

# パブリック読み取り可能
aws s3 cp file.txt s3://my-bucket/ --acl public-read

# ⚠️ 注意: 誰でもアクセスできるようになります
```

---

### ACL一覧

| ACL | 説明 |
|-----|------|
| `private` | 所有者のみ（デフォルト） |
| `public-read` | 誰でも読み取り可能 |
| `public-read-write` | 誰でも読み書き可能（非推奨） |
| `authenticated-read` | AWS認証ユーザーのみ読み取り可能 |

---

## 📊 s3api コマンド

### バケット情報の取得

```bash
# バケットの場所（リージョン）を取得
aws s3api get-bucket-location --bucket my-bucket

# バケットのバージョニング状態を確認
aws s3api get-bucket-versioning --bucket my-bucket

# バケットのライフサイクル設定を確認
aws s3api get-bucket-lifecycle-configuration --bucket my-bucket
```

---

### オブジェクトのメタデータ取得

```bash
# オブジェクトの詳細情報を取得
aws s3api head-object --bucket my-bucket --key file.txt

# 出力例:
{
    "AcceptRanges": "bytes",
    "LastModified": "2024-01-15T10:30:00Z",
    "ContentLength": 1024,
    "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
    "ContentType": "text/plain",
    "Metadata": {}
}
```

---

### バケットポリシーの設定

```bash
# バケットポリシーを設定
aws s3api put-bucket-policy \
  --bucket my-bucket \
  --policy file://policy.json
```

**policy.json**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

---

## 🛠️ 実践例

### 例1: ウェブサイトのデプロイ

```bash
#!/bin/bash
# 静的ウェブサイトをS3にデプロイ

BUCKET="my-website-bucket"
LOCAL_DIR="./dist"

echo "Deploying website to S3..."

# 同期（削除も反映）
aws s3 sync "$LOCAL_DIR" "s3://$BUCKET/" --delete

# HTMLファイルのキャッシュを短く設定
aws s3 cp "$LOCAL_DIR" "s3://$BUCKET/" \
  --recursive \
  --exclude "*" \
  --include "*.html" \
  --cache-control "max-age=300" \
  --metadata-directive REPLACE

echo "Deployment complete!"
```

---

### 例2: バックアップスクリプト

```bash
#!/bin/bash
# ローカルファイルを毎日S3にバックアップ

BACKUP_DIR="/important/data"
BUCKET="my-backup-bucket"
DATE=$(date +%Y-%m-%d)

echo "Starting backup: $DATE"

# バックアップ
aws s3 sync "$BACKUP_DIR" "s3://$BUCKET/backups/$DATE/" \
  --storage-class STANDARD_IA

echo "Backup complete: s3://$BUCKET/backups/$DATE/"
```

---

### 例3: ログファイルの自動削除

```bash
#!/bin/bash
# 30日以上前のログファイルを削除

BUCKET="my-logs-bucket"
CUTOFF_DATE=$(date -d "30 days ago" +%Y-%m-%d)

echo "Deleting logs older than $CUTOFF_DATE..."

# 古いログを削除
aws s3 ls "s3://$BUCKET/logs/" --recursive | while read -r line; do
    file_date=$(echo "$line" | awk '{print $1}')
    file_path=$(echo "$line" | awk '{print $4}')
    
    if [[ "$file_date" < "$CUTOFF_DATE" ]]; then
        echo "Deleting: s3://$BUCKET/$file_path"
        aws s3 rm "s3://$BUCKET/$file_path"
    fi
done

echo "Done!"
```

---

## ⚠️ よくあるエラーと対処法

### エラー1: バケット名が既に使われている

```bash
$ aws s3 mb s3://myapp

make_bucket failed: s3://myapp An error occurred (BucketAlreadyExists) when calling the CreateBucket operation: 
The requested bucket name is not available.
```

**対処**: より一意な名前を使う

```bash
aws s3 mb s3://mycompany-myapp-prod-2024
```

---

### エラー2: アクセス拒否

```bash
$ aws s3 ls s3://other-company-bucket

An error occurred (AccessDenied) when calling the ListObjectsV2 operation: Access Denied
```

**対処**: バケットの所有者または権限を確認

---

### エラー3: リージョン違い

```bash
# バケットが東京リージョンにあるのに、バージニアリージョンで操作
$ aws s3 ls s3://my-tokyo-bucket --region us-east-1

An error occurred (PermanentRedirect) when calling the ListObjectsV2 operation: 
The bucket you are attempting to access must be addressed using the specified endpoint.
```

**対処**: 正しいリージョンを指定

```bash
aws s3 ls s3://my-tokyo-bucket --region ap-northeast-1
```

---

## 💡 実践Tips

### Tip 1: 進捗表示

```bash
# 大きなファイルのアップロード時に進捗を表示
aws s3 cp large-file.zip s3://my-bucket/ --no-progress

# または
aws s3 cp large-file.zip s3://my-bucket/ --only-show-errors
```

---

### Tip 2: 並列アップロード

```bash
# 複数ファイルを並列アップロード（デフォルト10）
aws configure set default.s3.max_concurrent_requests 20

# または
aws s3 sync ./files s3://my-bucket/ \
  --cli-connect-timeout 300 \
  --cli-read-timeout 300
```

---

### Tip 3: プレビュー（ドライラン）

```bash
# 実際には実行せず、何が同期されるか確認
aws s3 sync ./files s3://my-bucket/ --dryrun
```

---

### Tip 4: ストレージクラス指定

```bash
# アーカイブ用に安価なストレージクラスを使用
aws s3 cp file.txt s3://my-bucket/ --storage-class GLACIER

# よく使うストレージクラス
# STANDARD          : 標準
# STANDARD_IA       : 低頻度アクセス
# INTELLIGENT_TIERING : 自動最適化
# GLACIER           : アーカイブ
# DEEP_ARCHIVE      : 長期アーカイブ
```

---

## ✅ このレッスンのチェックリスト

- [ ] S3バケットの一覧を確認できる
- [ ] バケットの作成・削除ができる
- [ ] ファイルのアップロード・ダウンロードができる
- [ ] syncコマンドを使いこなせる
- [ ] s3とs3apiの違いを理解している
- [ ] include/excludeでファイルをフィルタリングできる

---

## 📚 次のステップ

次は **[05. IAM操作の基礎](05-iam-basics.md)** で、ユーザーやロールの管理を学びます！

---

**S3操作の基礎をマスターしました！🎉**
