# 05. IAM操作の基礎

IAMユーザー、ロール、ポリシーの基本操作

---

## 🎯 学習目標

- IAMユーザーの一覧を確認できる
- ユーザーの作成・削除ができる
- アクセスキーを管理できる
- ポリシーを確認できる
- ロールの基本を理解する

**所要時間**: 45分

---

## 👤 IAMユーザー操作

### ユーザー一覧の確認

```bash
# すべてのIAMユーザーを表示
aws iam list-users

# ユーザー名のみ表示
aws iam list-users --query 'Users[*].UserName' --output table

# 出力例:
# ------------------------
# |      ListUsers       |
# +----------------------+
# |  admin-user          |
# |  dev-user            |
# |  test-user           |
# +----------------------+
```

---

### ユーザーの作成

```bash
# 新しいIAMユーザーを作成
aws iam create-user --user-name new-user

# 出力例:
{
    "User": {
        "Path": "/",
        "UserName": "new-user",
        "UserId": "AIDAI...",
        "Arn": "arn:aws:iam::123456789012:user/new-user",
        "CreateDate": "2024-01-15T10:30:00Z"
    }
}
```

---

### ユーザー情報の取得

```bash
# 特定ユーザーの詳細情報
aws iam get-user --user-name my-user

# 現在の認証情報（自分）
aws iam get-user
```

---

### ユーザーの削除

```bash
# ユーザーを削除
aws iam delete-user --user-name old-user

# ⚠️ 注意: アクセスキー、ポリシー等を先に削除する必要がある
```

---

### ユーザーの完全削除（依存関係も含む）

```bash
#!/bin/bash
# ユーザーを完全に削除するスクリプト

USER="old-user"

echo "Deleting user: $USER"

# 1. アクセスキーを削除
for key in $(aws iam list-access-keys --user-name $USER --query 'AccessKeyMetadata[*].AccessKeyId' --output text); do
    echo "Deleting access key: $key"
    aws iam delete-access-key --user-name $USER --access-key-id $key
done

# 2. アタッチされたポリシーをデタッチ
for policy in $(aws iam list-attached-user-policies --user-name $USER --query 'AttachedPolicies[*].PolicyArn' --output text); do
    echo "Detaching policy: $policy"
    aws iam detach-user-policy --user-name $USER --policy-arn $policy
done

# 3. インラインポリシーを削除
for policy in $(aws iam list-user-policies --user-name $USER --query 'PolicyNames[*]' --output text); do
    echo "Deleting inline policy: $policy"
    aws iam delete-user-policy --user-name $USER --policy-name $policy
done

# 4. グループから削除
for group in $(aws iam list-groups-for-user --user-name $USER --query 'Groups[*].GroupName' --output text); do
    echo "Removing from group: $group"
    aws iam remove-user-from-group --user-name $USER --group-name $group
done

# 5. ユーザーを削除
echo "Deleting user..."
aws iam delete-user --user-name $USER

echo "Done!"
```

---

## 🔑 アクセスキー管理

### アクセスキー一覧の確認

```bash
# 特定ユーザーのアクセスキー一覧
aws iam list-access-keys --user-name my-user

# 自分のアクセスキー一覧
aws iam list-access-keys
```

---

### アクセスキーの作成

```bash
# 新しいアクセスキーを作成
aws iam create-access-key --user-name my-user

# 出力例:
{
    "AccessKey": {
        "UserName": "my-user",
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "Status": "Active",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "CreateDate": "2024-01-15T10:30:00Z"
    }
}

# ⚠️ 重要: SecretAccessKeyは作成時のみ表示されます！
```

---

### アクセスキーの無効化

```bash
# アクセスキーを無効化（削除ではない）
aws iam update-access-key \
  --user-name my-user \
  --access-key-id AKIAIOSFODNN7EXAMPLE \
  --status Inactive
```

---

### アクセスキーの削除

```bash
# アクセスキーを完全に削除
aws iam delete-access-key \
  --user-name my-user \
  --access-key-id AKIAIOSFODNN7EXAMPLE
```

---

### アクセスキーの最終使用日時確認

```bash
# アクセスキーの最終使用情報
aws iam get-access-key-last-used \
  --access-key-id AKIAIOSFODNN7EXAMPLE

# 出力例:
{
    "UserName": "my-user",
    "AccessKeyLastUsed": {
        "LastUsedDate": "2024-01-15T10:30:00Z",
        "ServiceName": "ec2",
        "Region": "ap-northeast-1"
    }
}
```

---

## 📜 ポリシー操作

### ポリシー一覧の確認

```bash
# AWS管理ポリシー一覧
aws iam list-policies --scope AWS --max-items 20

# カスタマー管理ポリシー一覧（自分が作成したポリシー）
aws iam list-policies --scope Local

# ポリシー名のみ表示
aws iam list-policies --scope AWS \
  --query 'Policies[*].PolicyName' \
  --output table | head -30
```

---

### ポリシーの詳細確認

```bash
# ポリシーのバージョン一覧を取得
aws iam list-policy-versions \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

# ポリシーの内容を取得（デフォルトバージョン）
aws iam get-policy-version \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess \
  --version-id v1
```

---

### ユーザーにポリシーをアタッチ

```bash
# AWS管理ポリシーをユーザーにアタッチ
aws iam attach-user-policy \
  --user-name my-user \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

# 複数のポリシーをアタッチ
aws iam attach-user-policy \
  --user-name my-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess

aws iam attach-user-policy \
  --user-name my-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

---

### ユーザーのポリシー確認

```bash
# ユーザーにアタッチされているポリシー一覧
aws iam list-attached-user-policies --user-name my-user

# 出力例:
{
    "AttachedPolicies": [
        {
            "PolicyName": "ReadOnlyAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/ReadOnlyAccess"
        }
    ]
}
```

---

### ポリシーのデタッチ

```bash
# ユーザーからポリシーをデタッチ
aws iam detach-user-policy \
  --user-name my-user \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
```

---

### カスタムポリシーの作成

```bash
# JSONファイルからポリシーを作成
aws iam create-policy \
  --policy-name MyCustomPolicy \
  --policy-document file://policy.json
```

**policy.json**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]
}
```

---

## 👥 グループ操作

### グループ一覧の確認

```bash
# すべてのIAMグループを表示
aws iam list-groups

# グループ名のみ表示
aws iam list-groups --query 'Groups[*].GroupName' --output table
```

---

### グループの作成

```bash
# 新しいグループを作成
aws iam create-group --group-name developers
```

---

### グループにユーザーを追加

```bash
# ユーザーをグループに追加
aws iam add-user-to-group \
  --user-name dev-user \
  --group-name developers
```

---

### グループのメンバー確認

```bash
# グループに所属するユーザー一覧
aws iam get-group --group-name developers
```

---

### グループにポリシーをアタッチ

```bash
# グループにポリシーをアタッチ
aws iam attach-group-policy \
  --group-name developers \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

---

## 🎭 ロール操作

### ロール一覧の確認

```bash
# すべてのIAMロールを表示
aws iam list-roles

# ロール名のみ表示
aws iam list-roles --query 'Roles[*].RoleName' --output table
```

---

### ロールの詳細確認

```bash
# 特定ロールの詳細情報
aws iam get-role --role-name MyRole

# ロールにアタッチされているポリシー
aws iam list-attached-role-policies --role-name MyRole
```

---

### ロールの作成

```bash
# EC2インスタンス用のロールを作成
aws iam create-role \
  --role-name MyEC2Role \
  --assume-role-policy-document file://trust-policy.json
```

**trust-policy.json**（信頼ポリシー）:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

---

### ロールにポリシーをアタッチ

```bash
# ロールにポリシーをアタッチ
aws iam attach-role-policy \
  --role-name MyEC2Role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

---

## 🛠️ 実践例

### 例1: 読み取り専用ユーザーの作成

```bash
#!/bin/bash
# 読み取り専用ユーザーを作成

USER="readonly-user"

echo "Creating user: $USER"

# 1. ユーザー作成
aws iam create-user --user-name $USER

# 2. 読み取り専用ポリシーをアタッチ
aws iam attach-user-policy \
  --user-name $USER \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

# 3. アクセスキー作成
aws iam create-access-key --user-name $USER

echo "User created: $USER"
```

---

### 例2: 未使用アクセスキーの検出

```bash
#!/bin/bash
# 90日以上使われていないアクセスキーを検出

echo "Checking for unused access keys..."

aws iam list-users --query 'Users[*].UserName' --output text | while read user; do
    aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata[*].AccessKeyId' --output text | while read key; do
        last_used=$(aws iam get-access-key-last-used --access-key-id "$key" --query 'AccessKeyLastUsed.LastUsedDate' --output text)
        
        if [ "$last_used" == "None" ]; then
            echo "Never used: $user - $key"
        else
            # 90日以上前かチェック（日付比較のロジックを追加）
            echo "Last used: $user - $key - $last_used"
        fi
    done
done
```

---

### 例3: チームメンバーの一括登録

```bash
#!/bin/bash
# チームメンバーを一括登録してグループに追加

GROUP="developers"
USERS=("alice" "bob" "charlie")

echo "Creating users and adding to group: $GROUP"

for user in "${USERS[@]}"; do
    echo "Processing: $user"
    
    # ユーザー作成
    aws iam create-user --user-name "$user" 2>/dev/null || echo "User $user already exists"
    
    # グループに追加
    aws iam add-user-to-group --user-name "$user" --group-name "$GROUP"
    
    # アクセスキー作成
    aws iam create-access-key --user-name "$user"
done

echo "Done!"
```

---

## ⚠️ よくあるエラーと対処法

### エラー1: ユーザーが既に存在する

```bash
$ aws iam create-user --user-name existing-user

An error occurred (EntityAlreadyExists) when calling the CreateUser operation: 
User with name existing-user already exists.
```

**対処**: 別の名前を使うか、既存ユーザーを確認

```bash
aws iam get-user --user-name existing-user
```

---

### エラー2: ポリシーがアタッチされたまま削除

```bash
$ aws iam delete-user --user-name my-user

An error occurred (DeleteConflict) when calling the DeleteUser operation: 
Cannot delete entity, must detach all policies first.
```

**対処**: 先にポリシーをデタッチ

```bash
aws iam list-attached-user-policies --user-name my-user
aws iam detach-user-policy --user-name my-user --policy-arn arn:aws:iam::aws:policy/...
aws iam delete-user --user-name my-user
```

---

### エラー3: 権限不足

```bash
$ aws iam create-user --user-name new-user

An error occurred (AccessDenied) when calling the CreateUser operation: 
User: ... is not authorized to perform: iam:CreateUser
```

**対処**: IAMポリシーで必要な権限を確認

---

## 💡 実践Tips

### Tip 1: MFA設定の確認

```bash
# ユーザーのMFA設定を確認
aws iam list-mfa-devices --user-name my-user
```

---

### Tip 2: パスワードポリシーの確認

```bash
# アカウントのパスワードポリシーを確認
aws iam get-account-password-policy
```

---

### Tip 3: サービス別の権限確認

```bash
# ユーザーが特定のアクションを実行できるかシミュレート
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/my-user \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::my-bucket/*
```

---

## 🔒 セキュリティベストプラクティス

### 1. 最小権限の原則

```bash
# ❌ 避ける（過剰な権限）
aws iam attach-user-policy \
  --user-name dev-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# ✅ 推奨（必要最小限の権限）
aws iam attach-user-policy \
  --user-name dev-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
```

---

### 2. ルートユーザーは使わない

- ❌ ルートユーザーでの日常作業
- ✅ IAMユーザーを作成して使用

---

### 3. アクセスキーのローテーション

```bash
# 定期的にアクセスキーを更新
# 1. 新しいキーを作成
# 2. アプリケーションの設定を更新
# 3. 古いキーを無効化
# 4. 問題なければ古いキーを削除
```

---

## ✅ このレッスンのチェックリスト

- [ ] IAMユーザーの一覧を確認できる
- [ ] ユーザーの作成・削除ができる
- [ ] アクセスキーを管理できる
- [ ] ポリシーの確認・アタッチができる
- [ ] グループの操作ができる
- [ ] ロールの基本を理解している
- [ ] セキュリティベストプラクティスを理解している

---

## 📚 次のステップ

次は **[06. 出力とフィルタリング](06-output-filtering.md)** で、出力結果の加工を学びます！

---

**IAM操作の基礎をマスターしました！🎉**
