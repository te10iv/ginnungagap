# 02. スクリプト作成

AWS CLIを使った自動化スクリプト

---

## 🎯 学習目標

- エラーハンドリングができる
- ループと条件分岐を使いこなせる
- ログ出力を実装できる
- 実務で使えるスクリプトを作成できる

**所要時間**: 60分

---

## 📝 スクリプトの基本構造

### 基本テンプレート

```bash
#!/bin/bash
# スクリプトの説明

# エラーで即座に終了
set -euo pipefail

# 変数定義
REGION="ap-northeast-1"
PROFILE="default"

# 色付きログ
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
}

# メイン処理
main() {
    log_info "Starting script..."
    
    # ここに処理を書く
    
    log_info "Script completed successfully"
}

# スクリプト実行
main "$@"
```

---

## ⚠️ エラーハンドリング

### set オプション

```bash
#!/bin/bash

# エラーが発生したら即座に終了
set -e

# 未定義変数を使用したらエラー
set -u

# パイプの途中でエラーが発生したら終了
set -o pipefail

# まとめて設定
set -euo pipefail
```

---

### try-catch パターン

```bash
#!/bin/bash

# エラーをキャッチ
if ! aws ec2 describe-instances --region ap-northeast-1 > /dev/null 2>&1; then
    echo "Error: Failed to describe instances"
    exit 1
fi

# または
aws ec2 describe-instances --region ap-northeast-1 || {
    echo "Error: Failed to describe instances"
    exit 1
}
```

---

### リトライロジック

```bash
#!/bin/bash

retry() {
    local max_attempts=$1
    shift
    local command="$@"
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt/$max_attempts: $command"
        
        if $command; then
            echo "Success!"
            return 0
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            echo "Failed. Retrying in 5 seconds..."
            sleep 5
        fi
        
        attempt=$((attempt + 1))
    done
    
    echo "Failed after $max_attempts attempts"
    return 1
}

# 使用例
retry 3 aws s3 cp large-file.zip s3://my-bucket/
```

---

## 🔄 ループと条件分岐

### forループ

```bash
#!/bin/bash

# リージョンのループ
for region in ap-northeast-1 us-east-1 eu-west-1; do
    echo "Checking region: $region"
    aws ec2 describe-instances --region "$region"
done

# 配列のループ
instance_ids=("i-123..." "i-456..." "i-789...")
for instance_id in "${instance_ids[@]}"; do
    aws ec2 stop-instances --instance-ids "$instance_id"
done

# コマンド出力のループ
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text | while read instance_id; do
    echo "Processing: $instance_id"
    aws ec2 describe-instances --instance-ids "$instance_id"
done
```

---

### whileループ

```bash
#!/bin/bash

# スタック作成完了を待つ
while true; do
    status=$(aws cloudformation describe-stacks \
      --stack-name my-stack \
      --query 'Stacks[0].StackStatus' \
      --output text)
    
    echo "Current status: $status"
    
    if [ "$status" == "CREATE_COMPLETE" ]; then
        echo "Stack creation completed!"
        break
    elif [ "$status" == "CREATE_FAILED" ]; then
        echo "Stack creation failed!"
        exit 1
    fi
    
    sleep 10
done
```

---

### 条件分岐

```bash
#!/bin/bash

# if-elif-else
if [ "$ENV" == "prod" ]; then
    INSTANCE_TYPE="m5.large"
elif [ "$ENV" == "stg" ]; then
    INSTANCE_TYPE="t3.medium"
else
    INSTANCE_TYPE="t3.micro"
fi

# caseステートメント
case "$ENV" in
    prod)
        INSTANCE_TYPE="m5.large"
        ;;
    stg)
        INSTANCE_TYPE="t3.medium"
        ;;
    dev)
        INSTANCE_TYPE="t3.micro"
        ;;
    *)
        echo "Unknown environment: $ENV"
        exit 1
        ;;
esac
```

---

## 📊 ログ出力

### ログファイルへの出力

```bash
#!/bin/bash

LOG_FILE="/var/log/my-script.log"

# ログファイルとコンソールの両方に出力
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 使用例
log "Script started"
log "Processing instances..."
log "Script completed"
```

---

### 標準出力とエラー出力の分離

```bash
#!/bin/bash

# 標準出力とエラー出力を両方ファイルに保存
exec > >(tee -a script.log)
exec 2> >(tee -a script-error.log >&2)

echo "This goes to script.log"
echo "This is an error" >&2
```

---

## 🛠️ 実践スクリプト例

### 例1: AMI自動バックアップ

```bash
#!/bin/bash
set -euo pipefail

# 設定
INSTANCE_ID="${1:-}"
RETENTION_DAYS=7
REGION="ap-northeast-1"

# ログ関数
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
}

# インスタンスIDチェック
if [ -z "$INSTANCE_ID" ]; then
    log_error "Usage: $0 <instance-id>"
    exit 1
fi

# AMI作成
log_info "Creating AMI for instance: $INSTANCE_ID"

DATE=$(date +%Y%m%d-%H%M%S)
AMI_NAME="backup-$INSTANCE_ID-$DATE"

ami_id=$(aws ec2 create-image \
    --instance-id "$INSTANCE_ID" \
    --name "$AMI_NAME" \
    --description "Automated backup created at $DATE" \
    --no-reboot \
    --region "$REGION" \
    --query 'ImageId' \
    --output text)

if [ -z "$ami_id" ]; then
    log_error "Failed to create AMI"
    exit 1
fi

log_info "Created AMI: $ami_id"

# タグ追加
aws ec2 create-tags \
    --resources "$ami_id" \
    --tags Key=Name,Value="$AMI_NAME" \
           Key=BackupDate,Value="$DATE" \
           Key=SourceInstance,Value="$INSTANCE_ID" \
    --region "$REGION"

log_info "Tagged AMI: $ami_id"

# 古いAMIを削除
log_info "Cleaning up old AMIs (older than $RETENTION_DAYS days)..."

CUTOFF_DATE=$(date -d "$RETENTION_DAYS days ago" +%Y-%m-%d)

aws ec2 describe-images \
    --owners self \
    --filters "Name=name,Values=backup-$INSTANCE_ID-*" \
    --region "$REGION" \
    --query "Images[?CreationDate<='$CUTOFF_DATE'].[ImageId,Name,CreationDate]" \
    --output text | while read ami_id name creation_date; do
        log_info "Deleting old AMI: $ami_id ($name, $creation_date)"
        aws ec2 deregister-image --image-id "$ami_id" --region "$REGION"
    done

log_info "Backup completed successfully!"
```

---

### 例2: 環境別デプロイスクリプト

```bash
#!/bin/bash
set -euo pipefail

# 引数チェック
ENVIRONMENT="${1:-}"
if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <dev|stg|prod>"
    exit 1
fi

# 環境別設定
case "$ENVIRONMENT" in
    dev)
        REGION="ap-northeast-1"
        INSTANCE_TYPE="t3.micro"
        KEY_NAME="dev-key"
        ;;
    stg)
        REGION="ap-northeast-1"
        INSTANCE_TYPE="t3.small"
        KEY_NAME="stg-key"
        ;;
    prod)
        REGION="ap-northeast-1"
        INSTANCE_TYPE="m5.large"
        KEY_NAME="prod-key"
        ;;
    *)
        echo "Invalid environment: $ENVIRONMENT"
        exit 1
        ;;
esac

echo "Deploying to $ENVIRONMENT environment..."
echo "Region: $REGION"
echo "Instance Type: $INSTANCE_TYPE"

# CloudFormationスタックのデプロイ
aws cloudformation deploy \
    --template-file template.yaml \
    --stack-name "app-stack-$ENVIRONMENT" \
    --region "$REGION" \
    --parameter-overrides \
        Environment="$ENVIRONMENT" \
        InstanceType="$INSTANCE_TYPE" \
        KeyName="$KEY_NAME" \
    --capabilities CAPABILITY_IAM

echo "Deployment to $ENVIRONMENT completed!"
```

---

### 例3: リソース監視スクリプト

```bash
#!/bin/bash
set -euo pipefail

# 設定
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
THRESHOLD_DAYS=30

# Slack通知関数
notify_slack() {
    local message="$1"
    
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -X POST "$SLACK_WEBHOOK_URL" \
            -H 'Content-Type: application/json' \
            -d "{\"text\":\"$message\"}"
    else
        echo "$message"
    fi
}

# 未使用EIPをチェック
echo "Checking for unassociated Elastic IPs..."

unassociated_eips=$(aws ec2 describe-addresses \
    --query 'Addresses[?AssociationId==null].[PublicIp,AllocationId]' \
    --output text)

if [ -n "$unassociated_eips" ]; then
    count=$(echo "$unassociated_eips" | wc -l)
    notify_slack "⚠️ Found $count unassociated Elastic IP(s):\n$unassociated_eips"
fi

# 停止中のインスタンスをチェック
echo "Checking for stopped instances..."

stopped_instances=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=stopped" \
    --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],LaunchTime]' \
    --output text)

if [ -n "$stopped_instances" ]; then
    count=$(echo "$stopped_instances" | wc -l)
    notify_slack "ℹ️ Found $count stopped instance(s):\n$stopped_instances"
fi

# 古いスナップショットをチェック
echo "Checking for old snapshots..."

CUTOFF_DATE=$(date -d "$THRESHOLD_DAYS days ago" --iso-8601)

old_snapshots=$(aws ec2 describe-snapshots \
    --owner-ids self \
    --query "Snapshots[?StartTime<='$CUTOFF_DATE'].[SnapshotId,Description,StartTime]" \
    --output text)

if [ -n "$old_snapshots" ]; then
    count=$(echo "$old_snapshots" | wc -l)
    notify_slack "📦 Found $count snapshot(s) older than $THRESHOLD_DAYS days:\n$old_snapshots"
fi

echo "Monitoring check completed"
```

---

## 💡 実践Tips

### Tip 1: ドライランモード実装

```bash
#!/bin/bash

DRY_RUN="${DRY_RUN:-false}"

run_command() {
    if [ "$DRY_RUN" == "true" ]; then
        echo "[DRY-RUN] $@"
    else
        "$@"
    fi
}

# 使用例
run_command aws ec2 stop-instances --instance-ids i-xxxxx

# 実行:
# DRY_RUN=true ./script.sh  # ドライラン
# ./script.sh               # 実行
```

---

### Tip 2: 進捗バー表示

```bash
#!/bin/bash

show_progress() {
    local current=$1
    local total=$2
    local width=50
    
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\rProgress: ["
    printf "%${filled}s" | tr ' ' '='
    printf "%$((width - filled))s" | tr ' ' ' '
    printf "] %3d%% (%d/%d)" $percent $current $total
}

# 使用例
total=10
for i in $(seq 1 $total); do
    show_progress $i $total
    sleep 1
done
echo ""
```

---

### Tip 3: 並列実行

```bash
#!/bin/bash

# 複数リージョンで並列実行
regions=("ap-northeast-1" "us-east-1" "eu-west-1")

for region in "${regions[@]}"; do
    (
        echo "Processing $region..."
        aws ec2 describe-instances --region "$region" > "$region-instances.json"
        echo "$region completed"
    ) &
done

# すべての並列処理の完了を待つ
wait

echo "All regions processed"
```

---

## ✅ このレッスンのチェックリスト

- [ ] エラーハンドリングができる
- [ ] リトライロジックを実装できる
- [ ] ループと条件分岐を使いこなせる
- [ ] ログ出力を実装できる
- [ ] 実務で使えるスクリプトを作成できる

---

## 📚 次のステップ

次は **[03. プロファイルと認証](03-profiles-credentials.md)** で、複数アカウントの管理を学びます！

---

**スクリプト作成をマスターしました！🚀**
