# 03. EC2操作の基礎

EC2インスタンスの基本操作をマスターする

---

## 🎯 学習目標

- EC2インスタンスの一覧を取得できる
- インスタンスの起動・停止・再起動ができる
- インスタンス情報を取得できる
- タグを設定・確認できる
- セキュリティグループを確認できる

**所要時間**: 45分

---

## 📋 インスタンス一覧の取得

### 基本コマンド

```bash
# 全インスタンスの情報を取得
aws ec2 describe-instances

# テーブル形式で見やすく
aws ec2 describe-instances --output table
```

---

### 実行中のインスタンスのみ取得

```bash
# 実行中のインスタンスのみ
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running"

# 停止中のインスタンスのみ
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=stopped"
```

---

### インスタンスIDのみ取得

```bash
# 実行中のインスタンスIDのみ
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text

# 出力例:
# i-1234567890abcdef0 i-0987654321fedcba0
```

---

### インスタンス状態の確認

```bash
# インスタンスID、タイプ、状態を一覧表示
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]' \
  --output table

# 出力例:
# -----------------------------------
# |      DescribeInstances          |
# +-----------+-----------+----------+
# |  i-123... |  t3.micro |  running |
# |  i-456... |  t3.small |  stopped |
# +-----------+-----------+----------+
```

---

## 🚀 インスタンスの起動・停止

### インスタンスの停止

```bash
# 単一インスタンスを停止
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# 出力例:
{
    "StoppingInstances": [
        {
            "CurrentState": {
                "Code": 64,
                "Name": "stopping"
            },
            "InstanceId": "i-1234567890abcdef0",
            "PreviousState": {
                "Code": 16,
                "Name": "running"
            }
        }
    ]
}
```

---

### 複数インスタンスを停止

```bash
# 複数のインスタンスを一度に停止
aws ec2 stop-instances \
  --instance-ids i-1234567890abcdef0 i-0987654321fedcba0
```

---

### インスタンスの起動

```bash
# 停止中のインスタンスを起動
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# 出力例:
{
    "StartingInstances": [
        {
            "CurrentState": {
                "Code": 0,
                "Name": "pending"
            },
            "InstanceId": "i-1234567890abcdef0",
            "PreviousState": {
                "Code": 80,
                "Name": "stopped"
            }
        }
    ]
}
```

---

### インスタンスの再起動

```bash
# インスタンスを再起動
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0
```

**注意**: 再起動は即座に実行されます！

---

### 状態コード一覧

| コード | 状態 | 説明 |
|--------|------|------|
| 0 | pending | 起動中 |
| 16 | running | 実行中 |
| 32 | shutting-down | シャットダウン中 |
| 48 | terminated | 終了済み |
| 64 | stopping | 停止中 |
| 80 | stopped | 停止済み |

---

## 🔍 インスタンス情報の取得

### 特定インスタンスの詳細情報

```bash
# 特定のインスタンス情報を取得
aws ec2 describe-instances --instance-ids i-1234567890abcdef0
```

---

### 必要な情報だけを抽出

```bash
# インスタンスIDとパブリックIPを取得
aws ec2 describe-instances \
  --instance-ids i-1234567890abcdef0 \
  --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' \
  --output table

# プライベートIPも含める
aws ec2 describe-instances \
  --instance-ids i-1234567890abcdef0 \
  --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,PrivateIpAddress]' \
  --output table
```

---

### インスタンスの詳細情報（整形版）

```bash
# インスタンスの主要情報を見やすく表示
aws ec2 describe-instances \
  --instance-ids i-1234567890abcdef0 \
  --query 'Reservations[*].Instances[*].{
    ID:InstanceId,
    Type:InstanceType,
    State:State.Name,
    AZ:Placement.AvailabilityZone,
    PublicIP:PublicIpAddress,
    PrivateIP:PrivateIpAddress
  }' \
  --output table
```

---

## 🏷️ タグの操作

### タグとは

インスタンスに**名前や用途**を付けるメタデータ

```yaml
# タグの例
- Key: Name
  Value: WebServer
- Key: Environment
  Value: production
- Key: Owner
  Value: dev-team
```

---

### タグの確認

```bash
# インスタンスのタグを確認
aws ec2 describe-instances \
  --instance-ids i-1234567890abcdef0 \
  --query 'Reservations[*].Instances[*].Tags'

# Nameタグだけを確認
aws ec2 describe-instances \
  --instance-ids i-1234567890abcdef0 \
  --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' \
  --output text
```

---

### タグの作成

```bash
# 単一タグを追加
aws ec2 create-tags \
  --resources i-1234567890abcdef0 \
  --tags Key=Name,Value=WebServer

# 複数タグを一度に追加
aws ec2 create-tags \
  --resources i-1234567890abcdef0 \
  --tags Key=Name,Value=WebServer Key=Environment,Value=production Key=Owner,Value=dev-team
```

---

### タグでフィルタリング

```bash
# Nameタグが「WebServer」のインスタンスを検索
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=WebServer"

# Environmentタグが「production」のインスタンスを検索
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=production"

# 複数条件
aws ec2 describe-instances \
  --filters \
    "Name=tag:Name,Values=WebServer" \
    "Name=tag:Environment,Values=production"
```

---

### タグの削除

```bash
# タグを削除
aws ec2 delete-tags \
  --resources i-1234567890abcdef0 \
  --tags Key=Owner
```

---

## 🔐 セキュリティグループの確認

### インスタンスのセキュリティグループを確認

```bash
# インスタンスに設定されているSGを確認
aws ec2 describe-instances \
  --instance-ids i-1234567890abcdef0 \
  --query 'Reservations[*].Instances[*].SecurityGroups[*].[GroupId,GroupName]' \
  --output table
```

---

### セキュリティグループの詳細を確認

```bash
# SG全体の情報を取得
aws ec2 describe-security-groups

# 特定のSGの詳細
aws ec2 describe-security-groups --group-ids sg-1234567890abcdef0

# SGのインバウンドルールのみ表示
aws ec2 describe-security-groups \
  --group-ids sg-1234567890abcdef0 \
  --query 'SecurityGroups[*].IpPermissions'
```

---

### SGのルール確認（読みやすく）

```bash
# インバウンドルールを整形して表示
aws ec2 describe-security-groups \
  --group-ids sg-1234567890abcdef0 \
  --query 'SecurityGroups[*].IpPermissions[*].[IpProtocol,FromPort,ToPort,IpRanges[*].CidrIp]' \
  --output table

# 出力例:
# ----------------------------------------
# |     DescribeSecurityGroups           |
# +------+-------+-------+---------------+
# | tcp  |  22   |  22   | 0.0.0.0/0    |
# | tcp  |  80   |  80   | 0.0.0.0/0    |
# | tcp  | 443   | 443   | 0.0.0.0/0    |
# +------+-------+-------+---------------+
```

---

## 📊 AMI（Amazon Machine Image）

### AMI一覧の確認

```bash
# 自分が所有するAMI一覧
aws ec2 describe-images --owners self

# Amazon公式のAmazon Linux 2023 AMIを検索
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*" \
  --query 'Images[*].[ImageId,Name,CreationDate]' \
  --output table | head -20
```

---

### 最新のAmazon Linux AMIを取得

```bash
# 最新のAmazon Linux 2023 AMIを取得
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023.*-x86_64" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name]' \
  --output text
```

---

### AMIからインスタンスを起動

```bash
# AMIからインスタンスを起動（最小構成）
aws ec2 run-instances \
  --image-id ami-0123456789abcdef0 \
  --instance-type t3.micro \
  --key-name my-key \
  --security-group-ids sg-xxxxx \
  --subnet-id subnet-xxxxx

# 出力例にInstanceIdが含まれる
```

---

## 🛠️ 実践例

### 例1: 全インスタンスの状態を確認

```bash
#!/bin/bash
# すべてのインスタンスの状態を一覧表示

echo "=== EC2 Instance Status ==="

aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[
    InstanceId,
    Tags[?Key==`Name`].Value|[0],
    InstanceType,
    State.Name,
    PublicIpAddress
  ]' \
  --output table
```

---

### 例2: 停止中のインスタンスを一括起動

```bash
#!/bin/bash
# 停止中のインスタンスを全て起動

# 停止中のインスタンスIDを取得
stopped_instances=$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=stopped" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

if [ -z "$stopped_instances" ]; then
    echo "No stopped instances found."
    exit 0
fi

echo "Starting instances: $stopped_instances"

# 起動
aws ec2 start-instances --instance-ids $stopped_instances

echo "Done!"
```

---

### 例3: タグで絞り込んで停止

```bash
#!/bin/bash
# 特定のタグを持つインスタンスを停止

TAG_NAME="Environment"
TAG_VALUE="dev"

# タグでフィルタしてインスタンスIDを取得
instance_ids=$(aws ec2 describe-instances \
  --filters \
    "Name=tag:${TAG_NAME},Values=${TAG_VALUE}" \
    "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

if [ -z "$instance_ids" ]; then
    echo "No running instances with tag ${TAG_NAME}=${TAG_VALUE}"
    exit 0
fi

echo "Stopping instances: $instance_ids"

# 停止
aws ec2 stop-instances --instance-ids $instance_ids

echo "Done!"
```

---

## ⚠️ よくあるエラーと対処法

### エラー1: インスタンスが見つからない

```bash
$ aws ec2 describe-instances --instance-ids i-invalid

An error occurred (InvalidInstanceID.NotFound) when calling the DescribeInstances operation: 
The instance ID 'i-invalid' does not exist
```

**対処**: インスタンスIDを確認

```bash
# まず一覧を確認
aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text
```

---

### エラー2: 権限不足

```bash
$ aws ec2 stop-instances --instance-ids i-xxxxx

An error occurred (UnauthorizedOperation) when calling the StopInstances operation: 
You are not authorized to perform this operation.
```

**対処**: IAMポリシーで `ec2:StopInstances` 権限を確認

---

### エラー3: リージョン違い

```bash
# 東京リージョンで作成したインスタンスをバージニアリージョンで探すとエラー
aws ec2 describe-instances --region us-east-1 --instance-ids i-xxxxx
```

**対処**: 正しいリージョンを指定

```bash
aws ec2 describe-instances --region ap-northeast-1 --instance-ids i-xxxxx
```

---

## 💡 実践Tips

### Tip 1: インスタンスIDを変数に格納

```bash
# インスタンスIDを変数に格納
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=WebServer" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text | head -1)

# 使用例
aws ec2 stop-instances --instance-ids $INSTANCE_ID
```

---

### Tip 2: jqで整形

```bash
# jqで見やすく整形
aws ec2 describe-instances | jq '.Reservations[].Instances[] | {
  InstanceId,
  State: .State.Name,
  PublicIP: .PublicIpAddress,
  Name: .Tags[]? | select(.Key=="Name") | .Value
}'
```

---

### Tip 3: watchで監視

```bash
# インスタンスの状態を監視
watch -n 5 'aws ec2 describe-instances \
  --instance-ids i-xxxxx \
  --query "Reservations[*].Instances[*].State.Name" \
  --output text'
```

---

## ✅ このレッスンのチェックリスト

- [ ] EC2インスタンス一覧を取得できる
- [ ] フィルタを使って特定のインスタンスを検索できる
- [ ] インスタンスの起動・停止ができる
- [ ] タグの作成・確認ができる
- [ ] タグでインスタンスをフィルタリングできる
- [ ] セキュリティグループを確認できる
- [ ] AMI情報を取得できる

---

## 📚 次のステップ

次は **[04. S3操作の基礎](04-s3-basics.md)** で、S3バケットとオブジェクトの操作を学びます！

---

**EC2操作の基礎をマスターしました！🎉**
