# 03. プロファイルと認証管理

複数アカウント・環境の管理

---

## 🎯 学習目標

- 複数プロファイルを管理できる
- IAM Roleの切り替えができる
- MFA対応ができる
- クレデンシャルを安全に管理できる

**所要時間**: 45分

---

## 📁 プロファイル管理

### プロファイルとは

複数のAWSアカウントや環境を切り替えて使うための機能

```bash
# プロファイル作成
aws configure --profile dev
aws configure --profile stg
aws configure --profile prod
```

---

### 設定ファイルの構造

**~/.aws/config**:
```ini
[default]
region = ap-northeast-1
output = json

[profile dev]
region = ap-northeast-1
output = json

[profile stg]
region = ap-northeast-1
output = table

[profile prod]
region = ap-northeast-1
output = json
```

**~/.aws/credentials**:
```ini
[default]
aws_access_key_id = AKIAI...
aws_secret_access_key = wJal...

[dev]
aws_access_key_id = AKIAI...DEV
aws_secret_access_key = wJal...DEV

[stg]
aws_access_key_id = AKIAI...STG
aws_secret_access_key = wJal...STG

[prod]
aws_access_key_id = AKIAI...PROD
aws_secret_access_key = wJal...PROD
```

---

### プロファイルの使用

```bash
# コマンドごとに指定
aws ec2 describe-instances --profile dev
aws s3 ls --profile prod

# 環境変数で指定
export AWS_PROFILE=dev
aws ec2 describe-instances

# スクリプトで使用
PROFILE="prod"
aws ec2 describe-instances --profile "$PROFILE"
```

---

### デフォルトプロファイルの変更

```bash
# 一時的に変更
export AWS_PROFILE=dev

# 確認
echo $AWS_PROFILE

# 元に戻す
unset AWS_PROFILE
```

---

## 🎭 IAM Role の使用

### Roleベースの認証

```ini
# ~/.aws/config

# ベースプロファイル
[profile dev]
region = ap-northeast-1
aws_access_key_id = AKIAI...
aws_secret_access_key = wJal...

# Roleを使用するプロファイル
[profile prod]
region = ap-northeast-1
source_profile = dev
role_arn = arn:aws:iam::123456789012:role/ProductionAccessRole
```

**使用**:
```bash
# Roleに切り替えて実行
aws ec2 describe-instances --profile prod
```

---

### クロスアカウントアクセス

```ini
# ~/.aws/config

[profile account-a]
region = ap-northeast-1
aws_access_key_id = AKIAI...
aws_secret_access_key = wJal...

[profile account-b]
region = ap-northeast-1
source_profile = account-a
role_arn = arn:aws:iam::999999999999:role/CrossAccountRole
external_id = unique-external-id
```

---

### セッションの有効期限設定

```ini
# ~/.aws/config

[profile long-session]
region = ap-northeast-1
source_profile = default
role_arn = arn:aws:iam::123456789012:role/MyRole
duration_seconds = 43200  # 12時間（デフォルトは1時間）
```

---

## 🔐 MFA対応

### MFAトークンの取得

```bash
# MFAトークンを使用して一時的な認証情報を取得
aws sts get-session-token \
  --serial-number arn:aws:iam::123456789012:mfa/my-user \
  --token-code 123456 \
  --duration-seconds 43200

# 出力例:
{
    "Credentials": {
        "AccessKeyId": "ASIAI...",
        "SecretAccessKey": "wJal...",
        "SessionToken": "FwoGZXIvYXdzE...",
        "Expiration": "2024-01-16T10:30:00Z"
    }
}
```

---

### MFA認証情報の設定

```bash
# 環境変数に設定
export AWS_ACCESS_KEY_ID="ASIAI..."
export AWS_SECRET_ACCESS_KEY="wJal..."
export AWS_SESSION_TOKEN="FwoGZXIvYXdzE..."

# または credentials ファイルに追加
[mfa]
aws_access_key_id = ASIAI...
aws_secret_access_key = wJal...
aws_session_token = FwoGZXIvYXdzE...
```

---

### MFA自動化スクリプト

```bash
#!/bin/bash
# MFAトークンを取得してプロファイルを設定

MFA_SERIAL="arn:aws:iam::123456789012:mfa/my-user"
PROFILE="mfa"

echo -n "Enter MFA token code: "
read token_code

# トークン取得
credentials=$(aws sts get-session-token \
  --serial-number "$MFA_SERIAL" \
  --token-code "$token_code" \
  --duration-seconds 43200 \
  --output json)

# 認証情報を抽出
access_key=$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')
secret_key=$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')
session_token=$(echo "$credentials" | jq -r '.Credentials.SessionToken')

# プロファイルに設定
aws configure set aws_access_key_id "$access_key" --profile "$PROFILE"
aws configure set aws_secret_access_key "$secret_key" --profile "$PROFILE"
aws configure set aws_session_token "$session_token" --profile "$PROFILE"

echo "MFA profile '$PROFILE' configured successfully"
echo "Use: aws --profile $PROFILE <command>"
```

---

## 🔒 クレデンシャルの安全な管理

### セキュリティベストプラクティス

```bash
# ✅ 推奨
# 1. プロファイルを使用
aws configure --profile my-profile

# 2. IAM Roleを使用
# ~/.aws/config で role_arn を設定

# 3. 環境変数を使用（一時的）
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

# ❌ 避ける
# コマンドラインに直接指定（ヒストリーに残る）
aws s3 ls --access-key AKIAI... --secret-key wJal...
```

---

### ファイルのパーミッション

```bash
# クレデンシャルファイルの権限を制限
chmod 600 ~/.aws/credentials
chmod 600 ~/.aws/config

# 確認
ls -la ~/.aws/
```

---

### クレデンシャルのローテーション

```bash
#!/bin/bash
# アクセスキーをローテーション

USER_NAME="my-user"

# 1. 新しいアクセスキーを作成
echo "Creating new access key..."
new_key=$(aws iam create-access-key --user-name "$USER_NAME")

access_key_id=$(echo "$new_key" | jq -r '.AccessKey.AccessKeyId')
secret_access_key=$(echo "$new_key" | jq -r '.AccessKey.SecretAccessKey')

echo "New Access Key ID: $access_key_id"

# 2. 新しいキーをテスト
AWS_ACCESS_KEY_ID="$access_key_id" \
AWS_SECRET_ACCESS_KEY="$secret_access_key" \
aws sts get-caller-identity

if [ $? -eq 0 ]; then
    echo "New key works!"
    
    # 3. プロファイルを更新
    aws configure set aws_access_key_id "$access_key_id"
    aws configure set aws_secret_access_key "$secret_access_key"
    
    echo "Profile updated with new credentials"
    
    # 4. 古いキーを削除（手動で確認してから実行）
    echo "Don't forget to delete old access key!"
else
    echo "New key doesn't work. Please check."
    exit 1
fi
```

---

## 🌍 環境変数の活用

### 主な環境変数

| 環境変数 | 説明 |
|---------|------|
| `AWS_PROFILE` | 使用するプロファイル |
| `AWS_DEFAULT_REGION` | デフォルトリージョン |
| `AWS_ACCESS_KEY_ID` | アクセスキーID |
| `AWS_SECRET_ACCESS_KEY` | シークレットアクセスキー |
| `AWS_SESSION_TOKEN` | セッショントークン |
| `AWS_CONFIG_FILE` | configファイルのパス |
| `AWS_SHARED_CREDENTIALS_FILE` | credentialsファイルのパス |

---

### 環境変数の使用例

```bash
# プロファイル指定
export AWS_PROFILE=dev
aws ec2 describe-instances

# リージョン指定
export AWS_DEFAULT_REGION=us-east-1
aws ec2 describe-instances

# 一時的な認証情報
export AWS_ACCESS_KEY_ID="ASIAI..."
export AWS_SECRET_ACCESS_KEY="wJal..."
export AWS_SESSION_TOKEN="FwoGZXIvYXdzE..."
```

---

### .envファイルの活用

```bash
# .env
AWS_PROFILE=dev
AWS_DEFAULT_REGION=ap-northeast-1
APP_BUCKET_NAME=my-app-bucket

# 使用
source .env
aws s3 ls s3://$APP_BUCKET_NAME
```

---

## 🛠️ 実践スクリプト

### スクリプト1: 環境切り替え

```bash
#!/bin/bash
# 環境を切り替えるヘルパースクリプト

switch_env() {
    local env=$1
    
    case "$env" in
        dev)
            export AWS_PROFILE=dev
            export APP_BUCKET=my-app-dev-bucket
            ;;
        stg)
            export AWS_PROFILE=stg
            export APP_BUCKET=my-app-stg-bucket
            ;;
        prod)
            export AWS_PROFILE=prod
            export APP_BUCKET=my-app-prod-bucket
            ;;
        *)
            echo "Usage: switch_env <dev|stg|prod>"
            return 1
            ;;
    esac
    
    echo "Switched to $env environment"
    echo "Profile: $AWS_PROFILE"
    echo "Bucket: $APP_BUCKET"
    
    # 確認
    aws sts get-caller-identity
}

# 使用例
switch_env dev
```

---

### スクリプト2: クレデンシャルの検証

```bash
#!/bin/bash
# すべてのプロファイルの認証情報を検証

echo "=== Validating AWS Profiles ==="

# profilesを取得
profiles=$(grep '^\[profile ' ~/.aws/config | sed 's/\[profile \(.*\)\]/\1/')

# defaultも追加
profiles="default $profiles"

for profile in $profiles; do
    echo ""
    echo "Checking profile: $profile"
    
    if aws sts get-caller-identity --profile "$profile" > /dev/null 2>&1; then
        account=$(aws sts get-caller-identity --profile "$profile" --query 'Account' --output text)
        user=$(aws sts get-caller-identity --profile "$profile" --query 'Arn' --output text)
        echo "✅ Valid - Account: $account"
        echo "  User: $user"
    else
        echo "❌ Invalid or expired credentials"
    fi
done
```

---

## 💡 実践Tips

### Tip 1: プロファイルの一覧表示

```bash
# プロファイル一覧
grep '^\[' ~/.aws/credentials | tr -d '[]'
grep '^\[profile' ~/.aws/config | sed 's/\[profile //' | tr -d ']'
```

---

### Tip 2: 現在のプロファイル確認

```bash
# 現在使用中のプロファイル
echo "Current profile: ${AWS_PROFILE:-default}"

# 認証情報の確認
aws sts get-caller-identity
```

---

### Tip 3: プロンプトに表示

```bash
# ~/.bashrc または ~/.zshrc に追加
export PS1="\u@\h [\$AWS_PROFILE] \w $ "

# またはPowerline等を使用
```

---

## ✅ このレッスンのチェックリスト

- [ ] 複数プロファイルを管理できる
- [ ] IAM Roleを使った認証ができる
- [ ] MFAを設定できる
- [ ] クレデンシャルを安全に管理している
- [ ] 環境変数を活用できる

---

## 📚 次のステップ

次は **[04. CloudFormation CLI](04-cloudformation-cli.md)** で、IaCをCLIで操作する方法を学びます！

---

**プロファイルと認証管理をマスターしました！🚀**
