# 04. CloudFormation CLI

CloudFormationスタックのCLI操作

---

## 🎯 学習目標

- スタックの作成・更新・削除ができる
- Change Setを活用できる
- パラメータとタグを管理できる
- デプロイを自動化できる

**所要時間**: 45分

---

## 📚 CloudFormation CLI 基礎

### 主なコマンド

| コマンド | 説明 |
|---------|------|
| `create-stack` | スタック作成 |
| `update-stack` | スタック更新 |
| `delete-stack` | スタック削除 |
| `describe-stacks` | スタック情報取得 |
| `list-stacks` | スタック一覧 |
| `describe-stack-events` | イベント確認 |
| `describe-stack-resources` | リソース確認 |

---

## 🚀 スタックの作成

### 基本的な作成

```bash
# テンプレートファイルから作成
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml

# S3上のテンプレートから作成
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-url https://s3.amazonaws.com/my-bucket/template.yaml
```

---

### パラメータ指定

```bash
# コマンドラインでパラメータ指定
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters \
    ParameterKey=Environment,ParameterValue=dev \
    ParameterKey=InstanceType,ParameterValue=t3.micro
```

---

### パラメータファイルを使用

**params.json**:
```json
[
  {
    "ParameterKey": "Environment",
    "ParameterValue": "dev"
  },
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t3.micro"
  }
]
```

```bash
# ファイルからパラメータ読み込み
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters file://params.json
```

---

### IAM権限の許可

```bash
# IAMリソースを作成する場合
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM

# 名前付きIAMリソースの場合
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

---

### タグの追加

```bash
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --tags \
    Key=Environment,Value=dev \
    Key=Project,Value=MyApp \
    Key=Owner,Value=dev-team
```

---

## 🔄 スタックの更新

### 基本的な更新

```bash
# スタックを更新
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters file://params.json
```

---

### パラメータの再利用

```bash
# 既存のパラメータ値を再利用
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters \
    ParameterKey=Environment,UsePreviousValue=true \
    ParameterKey=InstanceType,ParameterValue=t3.small
```

---

## 🔍 Change Set

### Change Setとは

スタック更新前に**変更内容をプレビュー**する機能

---

### Change Setの作成

```bash
# Change Set作成
aws cloudformation create-change-set \
  --stack-name my-stack \
  --change-set-name my-changeset \
  --template-body file://template.yaml \
  --parameters file://params.json
```

---

### Change Setの確認

```bash
# Change Set詳細を確認
aws cloudformation describe-change-set \
  --stack-name my-stack \
  --change-set-name my-changeset

# 変更内容のみ表示
aws cloudformation describe-change-set \
  --stack-name my-stack \
  --change-set-name my-changeset \
  --query 'Changes[*].ResourceChange.{
    Action:Action,
    Resource:LogicalResourceId,
    Type:ResourceType,
    Replacement:Replacement
  }' \
  --output table
```

---

### Change Setの実行

```bash
# Change Setを実行（スタックを更新）
aws cloudformation execute-change-set \
  --stack-name my-stack \
  --change-set-name my-changeset

# Change Setを削除（実行しない）
aws cloudformation delete-change-set \
  --stack-name my-stack \
  --change-set-name my-changeset
```

---

## 🗑️ スタックの削除

### 基本的な削除

```bash
# スタックを削除
aws cloudformation delete-stack --stack-name my-stack

# 削除完了を待つ
aws cloudformation wait stack-delete-complete --stack-name my-stack
```

---

### 保護されたスタックの削除

```bash
# 削除保護を無効化
aws cloudformation update-termination-protection \
  --stack-name my-stack \
  --no-enable-termination-protection

# スタックを削除
aws cloudformation delete-stack --stack-name my-stack
```

---

## 📊 スタック情報の取得

### スタック一覧

```bash
# すべてのスタック
aws cloudformation list-stacks

# 実行中のスタックのみ
aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE

# スタック名のみ表示
aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
  --query 'StackSummaries[*].StackName' \
  --output table
```

---

### スタック詳細

```bash
# スタック情報取得
aws cloudformation describe-stacks --stack-name my-stack

# 特定情報のみ抽出
aws cloudformation describe-stacks \
  --stack-name my-stack \
  --query 'Stacks[0].{
    Name:StackName,
    Status:StackStatus,
    Created:CreationTime
  }'

# Outputs取得
aws cloudformation describe-stacks \
  --stack-name my-stack \
  --query 'Stacks[0].Outputs'
```

---

### リソース一覧

```bash
# スタックのリソース一覧
aws cloudformation describe-stack-resources \
  --stack-name my-stack

# リソース名と物理IDのみ表示
aws cloudformation describe-stack-resources \
  --stack-name my-stack \
  --query 'StackResources[*].{
    Logical:LogicalResourceId,
    Physical:PhysicalResourceId,
    Type:ResourceType
  }' \
  --output table
```

---

### イベント確認

```bash
# スタックイベント一覧
aws cloudformation describe-stack-events \
  --stack-name my-stack

# 最新10件のみ
aws cloudformation describe-stack-events \
  --stack-name my-stack \
  --max-items 10

# 失敗イベントのみ
aws cloudformation describe-stack-events \
  --stack-name my-stack \
  --query 'StackEvents[?contains(ResourceStatus, `FAILED`)].{
    Time:Timestamp,
    Resource:LogicalResourceId,
    Status:ResourceStatus,
    Reason:ResourceStatusReason
  }' \
  --output table
```

---

## ⏱️ 待機コマンド

### wait コマンド

```bash
# スタック作成完了を待つ
aws cloudformation wait stack-create-complete \
  --stack-name my-stack

# スタック更新完了を待つ
aws cloudformation wait stack-update-complete \
  --stack-name my-stack

# スタック削除完了を待つ
aws cloudformation wait stack-delete-complete \
  --stack-name my-stack

# Change Set作成完了を待つ
aws cloudformation wait change-set-create-complete \
  --stack-name my-stack \
  --change-set-name my-changeset
```

---

## 🛠️ 実践スクリプト

### スクリプト1: デプロイ自動化

```bash
#!/bin/bash
set -euo pipefail

# 設定
STACK_NAME="${1:-my-stack}"
TEMPLATE_FILE="template.yaml"
PARAMS_FILE="params.json"
REGION="ap-northeast-1"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Deploying stack: $STACK_NAME"

# スタックの存在確認
if aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" > /dev/null 2>&1; then
    
    log "Stack exists. Creating change set..."
    
    # Change Set作成
    aws cloudformation create-change-set \
        --stack-name "$STACK_NAME" \
        --change-set-name "deploy-$(date +%Y%m%d-%H%M%S)" \
        --template-body "file://$TEMPLATE_FILE" \
        --parameters "file://$PARAMS_FILE" \
        --capabilities CAPABILITY_IAM \
        --region "$REGION"
    
    # Change Set作成完了を待つ
    aws cloudformation wait change-set-create-complete \
        --stack-name "$STACK_NAME" \
        --change-set-name "deploy-$(date +%Y%m%d-%H%M%S)" \
        --region "$REGION"
    
    log "Change set created. Reviewing changes..."
    
    # 変更内容を表示
    aws cloudformation describe-change-set \
        --stack-name "$STACK_NAME" \
        --change-set-name "deploy-$(date +%Y%m%d-%H%M%S)" \
        --query 'Changes[*].ResourceChange' \
        --region "$REGION"
    
    # 実行確認
    read -p "Execute change set? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        log "Deployment cancelled"
        exit 0
    fi
    
    # Change Set実行
    aws cloudformation execute-change-set \
        --stack-name "$STACK_NAME" \
        --change-set-name "deploy-$(date +%Y%m%d-%H%M%S)" \
        --region "$REGION"
    
    # 更新完了を待つ
    log "Waiting for stack update..."
    aws cloudformation wait stack-update-complete \
        --stack-name "$STACK_NAME" \
        --region "$REGION"
    
    log "Stack updated successfully!"
    
else
    log "Stack does not exist. Creating new stack..."
    
    # スタック作成
    aws cloudformation create-stack \
        --stack-name "$STACK_NAME" \
        --template-body "file://$TEMPLATE_FILE" \
        --parameters "file://$PARAMS_FILE" \
        --capabilities CAPABILITY_IAM \
        --tags \
            Key=Environment,Value=dev \
            Key=DeployedBy,Value="$(whoami)" \
        --region "$REGION"
    
    # 作成完了を待つ
    log "Waiting for stack creation..."
    aws cloudformation wait stack-create-complete \
        --stack-name "$STACK_NAME" \
        --region "$REGION"
    
    log "Stack created successfully!"
fi

# Outputs表示
log "Stack outputs:"
aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --query 'Stacks[0].Outputs' \
    --region "$REGION"
```

---

### スクリプト2: スタック監視

```bash
#!/bin/bash
# スタックイベントをリアルタイム監視

STACK_NAME="${1:-my-stack}"

echo "Monitoring stack: $STACK_NAME"
echo "Press Ctrl+C to stop"
echo ""

last_event=""

while true; do
    # 最新イベントを取得
    current_event=$(aws cloudformation describe-stack-events \
        --stack-name "$STACK_NAME" \
        --max-items 1 \
        --query 'StackEvents[0].[Timestamp,ResourceStatus,LogicalResourceId,ResourceStatusReason]' \
        --output text)
    
    # 新しいイベントの場合のみ表示
    if [ "$current_event" != "$last_event" ]; then
        echo "$current_event"
        last_event="$current_event"
    fi
    
    sleep 5
done
```

---

## 💡 実践Tips

### Tip 1: テンプレートの検証

```bash
# テンプレート構文チェック
aws cloudformation validate-template \
  --template-body file://template.yaml
```

---

### Tip 2: ドリフト検出

```bash
# ドリフト検出開始
aws cloudformation detect-stack-drift --stack-name my-stack

# 結果確認
aws cloudformation describe-stack-drift-detection-status \
  --stack-drift-detection-id <detection-id>
```

---

### Tip 3: スタックポリシー

```bash
# スタックポリシーを設定（誤削除防止）
aws cloudformation set-stack-policy \
  --stack-name my-stack \
  --stack-policy-body file://policy.json
```

---

## ✅ このレッスンのチェックリスト

- [ ] スタックの作成・更新・削除ができる
- [ ] Change Setを活用できる
- [ ] パラメータファイルを使用できる
- [ ] waitコマンドを使いこなせる
- [ ] デプロイスクリプトを作成できる

---

## 📚 次のステップ

次は **[05. VPC・ネットワーク](05-vpc-networking.md)** で、ネットワーク操作を学びます！

---

**CloudFormation CLIをマスターしました！🚀**
