# 06. 実務自動化Tips

実務で使えるベストプラクティスとノウハウ

---

## 🎯 学習目標

- バックアップを自動化できる
- リソース監視を実装できる
- コスト最適化ができる
- セキュリティチェックを自動化できる
- CI/CD統合ができる

**所要時間**: 45分

---

## 💾 バックアップ自動化

### AMI自動作成

```bash
#!/bin/bash
set -euo pipefail

# 設定
INSTANCE_TAG_NAME="backup-target"
RETENTION_DAYS=7
REGION="ap-northeast-1"

# バックアップ対象インスタンスを取得
instance_ids=$(aws ec2 describe-instances \
  --filters "Name=tag:Backup,Values=$INSTANCE_TAG_NAME" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text \
  --region "$REGION")

for instance_id in $instance_ids; do
    echo "Creating AMI for: $instance_id"
    
    # インスタンス名を取得
    instance_name=$(aws ec2 describe-instances \
      --instance-ids "$instance_id" \
      --query 'Reservations[0].Instances[0].Tags[?Key==`Name`].Value|[0]' \
      --output text \
      --region "$REGION")
    
    # AMI作成
    ami_name="backup-${instance_name}-$(date +%Y%m%d-%H%M%S)"
    ami_id=$(aws ec2 create-image \
      --instance-id "$instance_id" \
      --name "$ami_name" \
      --no-reboot \
      --region "$REGION" \
      --query 'ImageId' \
      --output text)
    
    echo "Created AMI: $ami_id"
    
    # タグ追加
    aws ec2 create-tags \
      --resources "$ami_id" \
      --tags \
        Key=Name,Value="$ami_name" \
        Key=CreatedBy,Value=AutoBackup \
        Key=RetentionDays,Value="$RETENTION_DAYS" \
      --region "$REGION"
done

# 古いAMIを削除
echo "Cleaning up old AMIs..."
cutoff_date=$(date -d "$RETENTION_DAYS days ago" +%Y-%m-%d)

aws ec2 describe-images \
  --owners self \
  --filters "Name=tag:CreatedBy,Values=AutoBackup" \
  --query "Images[?CreationDate<='$cutoff_date'].[ImageId,Name]" \
  --output text \
  --region "$REGION" | while read ami_id name; do
    echo "Deleting old AMI: $ami_id ($name)"
    aws ec2 deregister-image --image-id "$ami_id" --region "$REGION"
done

echo "Backup completed"
```

---

### EBSスナップショット自動作成

```bash
#!/bin/bash
set -euo pipefail

# すべてのボリュームのスナップショットを作成
volume_ids=$(aws ec2 describe-volumes \
  --filters "Name=tag:Backup,Values=true" \
  --query 'Volumes[*].VolumeId' \
  --output text)

for volume_id in $volume_ids; do
    echo "Creating snapshot for: $volume_id"
    
    snapshot_id=$(aws ec2 create-snapshot \
      --volume-id "$volume_id" \
      --description "Auto backup $(date +%Y-%m-%d)" \
      --query 'SnapshotId' \
      --output text)
    
    aws ec2 create-tags \
      --resources "$snapshot_id" \
      --tags \
        Key=Name,Value="Auto-Snapshot-$volume_id" \
        Key=CreatedBy,Value=AutoBackup \
        Key=CreatedAt,Value="$(date --iso-8601)"
    
    echo "Created snapshot: $snapshot_id"
done
```

---

## 📊 リソース監視

### 未使用リソースの検出

```bash
#!/bin/bash
set -euo pipefail

# Slack Webhook URL
SLACK_WEBHOOK="${SLACK_WEBHOOK_URL:-}"

notify() {
    local message="$1"
    echo "$message"
    
    if [ -n "$SLACK_WEBHOOK" ]; then
        curl -X POST "$SLACK_WEBHOOK" \
          -H 'Content-Type: application/json' \
          -d "{\"text\":\"$message\"}"
    fi
}

echo "=== Checking for unused resources ==="

# 未使用EIP
echo "Checking Elastic IPs..."
unassociated_eips=$(aws ec2 describe-addresses \
  --query 'Addresses[?AssociationId==null].[PublicIp,AllocationId]' \
  --output text)

if [ -n "$unassociated_eips" ]; then
    count=$(echo "$unassociated_eips" | wc -l)
    notify "⚠️ Found $count unassociated Elastic IP(s)"
fi

# 停止中のインスタンス（30日以上）
echo "Checking stopped instances..."
cutoff_date=$(date -d "30 days ago" +%Y-%m-%d)

old_stopped=$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=stopped" \
  --query "Reservations[*].Instances[?LaunchTime<='$cutoff_date'].[InstanceId,Tags[?Key==\`Name\`].Value|[0],LaunchTime]" \
  --output text)

if [ -n "$old_stopped" ]; then
    count=$(echo "$old_stopped" | wc -l)
    notify "ℹ️ Found $count instance(s) stopped for >30 days"
fi

# 未アタッチのボリューム
echo "Checking unattached volumes..."
unattached_volumes=$(aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query 'Volumes[*].[VolumeId,Size]' \
  --output text)

if [ -n "$unattached_volumes" ]; then
    count=$(echo "$unattached_volumes" | wc -l)
    total_size=$(echo "$unattached_volumes" | awk '{sum+=$2} END {print sum}')
    notify "💾 Found $count unattached volume(s) (Total: ${total_size}GB)"
fi

# 古いスナップショット（90日以上）
echo "Checking old snapshots..."
cutoff_date=$(date -d "90 days ago" +%Y-%m-%d)

old_snapshots=$(aws ec2 describe-snapshots \
  --owner-ids self \
  --query "Snapshots[?StartTime<='$cutoff_date'].[SnapshotId,VolumeSize]" \
  --output text)

if [ -n "$old_snapshots" ]; then
    count=$(echo "$old_snapshots" | wc -l)
    total_size=$(echo "$old_snapshots" | awk '{sum+=$2} END {print sum}')
    notify "📦 Found $count snapshot(s) older than 90 days (Total: ${total_size}GB)"
fi

echo "Monitoring check completed"
```

---

## 💰 コスト最適化

### インスタンスタイプ最適化提案

```bash
#!/bin/bash
# CPU使用率が低いインスタンスを検出

THRESHOLD=20  # CPU使用率閾値（%）
PERIOD=7      # 監視期間（日）

echo "=== Checking for underutilized instances (last $PERIOD days) ==="

# 実行中のインスタンス一覧
instance_ids=$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

for instance_id in $instance_ids; do
    # CPU使用率を取得（平均）
    avg_cpu=$(aws cloudwatch get-metric-statistics \
      --namespace AWS/EC2 \
      --metric-name CPUUtilization \
      --dimensions Name=InstanceId,Value="$instance_id" \
      --start-time "$(date -d "$PERIOD days ago" --iso-8601)" \
      --end-time "$(date --iso-8601)" \
      --period 86400 \
      --statistics Average \
      --query 'Datapoints[*].Average' \
      --output text | awk '{sum+=$1; n++} END {if(n>0) print sum/n; else print 0}')
    
    avg_cpu=$(printf "%.0f" "$avg_cpu")
    
    if [ "$avg_cpu" -lt "$THRESHOLD" ]; then
        instance_type=$(aws ec2 describe-instances \
          --instance-ids "$instance_id" \
          --query 'Reservations[0].Instances[0].InstanceType' \
          --output text)
        
        name=$(aws ec2 describe-instances \
          --instance-ids "$instance_id" \
          --query 'Reservations[0].Instances[0].Tags[?Key==`Name`].Value|[0]' \
          --output text)
        
        echo "⚠️ $instance_id ($name) - $instance_type - Avg CPU: ${avg_cpu}%"
        echo "   Consider downsizing to save costs"
    fi
done
```

---

### RI/SavingsPlansレポート

```bash
#!/bin/bash
# 予約インスタンスとSavings Plansのカバレッジを確認

echo "=== Checking RI/Savings Plans Coverage ==="

# EC2インスタンスのタイプ別集計
echo "Instance Type Distribution:"
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceType' \
  --output text | tr '\t' '\n' | sort | uniq -c | sort -rn

echo ""
echo "Recommendations:"
echo "- Review top instance types for RI/Savings Plans opportunities"
echo "- Consider 1-year or 3-year commitments for stable workloads"
```

---

## 🔐 セキュリティチェック

### セキュリティグループ監査

```bash
#!/bin/bash
# セキュリティグループの開放ルールをチェック

echo "=== Security Group Audit ==="

# すべてのSGを取得
security_groups=$(aws ec2 describe-security-groups \
  --query 'SecurityGroups[*].GroupId' \
  --output text)

for sg_id in $security_groups; do
    # 0.0.0.0/0に開放されているルールを確認
    open_rules=$(aws ec2 describe-security-groups \
      --group-ids "$sg_id" \
      --query "SecurityGroups[0].IpPermissions[?IpRanges[?CidrIp=='0.0.0.0/0']].{
        Protocol:IpProtocol,
        FromPort:FromPort,
        ToPort:ToPort
      }" \
      --output json)
    
    if [ "$open_rules" != "[]" ]; then
        sg_name=$(aws ec2 describe-security-groups \
          --group-ids "$sg_id" \
          --query 'SecurityGroups[0].GroupName' \
          --output text)
        
        echo "⚠️ Security Group: $sg_name ($sg_id)"
        echo "   Open to 0.0.0.0/0:"
        echo "$open_rules" | jq -r '.[] | "   - \(.Protocol) Port \(.FromPort)-\(.ToPort)"'
        echo ""
    fi
done
```

---

### IAMアクセスキー監査

```bash
#!/bin/bash
# 古いアクセスキーや未使用キーを検出

THRESHOLD_DAYS=90

echo "=== IAM Access Key Audit ==="

# すべてのIAMユーザーを取得
users=$(aws iam list-users --query 'Users[*].UserName' --output text)

for user in $users; do
    # アクセスキー一覧
    keys=$(aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata[*].[AccessKeyId,CreateDate]' --output text)
    
    while IFS=$'\t' read -r key_id create_date; do
        # 最終使用日時を取得
        last_used=$(aws iam get-access-key-last-used --access-key-id "$key_id" --query 'AccessKeyLastUsed.LastUsedDate' --output text)
        
        # 作成日が90日以上前かチェック
        create_epoch=$(date -d "$create_date" +%s)
        now_epoch=$(date +%s)
        days_old=$(( (now_epoch - create_epoch) / 86400 ))
        
        if [ "$days_old" -gt "$THRESHOLD_DAYS" ]; then
            echo "⚠️ User: $user, Key: $key_id"
            echo "   Created: $create_date ($days_old days old)"
            echo "   Last Used: ${last_used:-Never}"
            echo "   Action: Consider rotating this key"
            echo ""
        fi
    done <<< "$keys"
done
```

---

## 🔄 CI/CD統合

### GitHub Actions例

```yaml
# .github/workflows/deploy.yml
name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-1
      
      - name: Deploy CloudFormation Stack
        run: |
          aws cloudformation deploy \
            --template-file template.yaml \
            --stack-name my-app-stack \
            --parameter-overrides Environment=prod \
            --capabilities CAPABILITY_IAM
      
      - name: Upload to S3
        run: |
          aws s3 sync ./dist s3://my-app-bucket/ --delete
```

---

### Cronによる定期実行

```bash
# crontabに追加
crontab -e

# 毎日午前2時にバックアップ
0 2 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1

# 毎週月曜午前3時にセキュリティチェック
0 3 * * 1 /path/to/security-check.sh >> /var/log/security.log 2>&1

# 毎時間リソース監視
0 * * * * /path/to/monitor.sh >> /var/log/monitor.log 2>&1
```

---

## 💡 ベストプラクティス

### 1. エラーハンドリング

```bash
# エラーで即座に終了
set -euo pipefail

# トラップで後処理
cleanup() {
    echo "Cleaning up..."
    # リソースの解放等
}
trap cleanup EXIT
```

---

### 2. ログ出力

```bash
# 標準出力とログファイルの両方に出力
exec > >(tee -a script.log)
exec 2>&1

# タイムスタンプ付きログ
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}
```

---

### 3. ドライランモード

```bash
DRY_RUN="${DRY_RUN:-false}"

execute() {
    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY-RUN] $@"
    else
        "$@"
    fi
}
```

---

### 4. 並列実行

```bash
# 複数タスクを並列実行
for region in ap-northeast-1 us-east-1 eu-west-1; do
    (
        aws ec2 describe-instances --region "$region"
    ) &
done
wait
```

---

### 5. リトライロジック

```bash
retry() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        fi
        echo "Attempt $attempt failed. Retrying..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    return 1
}
```

---

## ✅ このレッスンのチェックリスト

- [ ] バックアップ自動化ができる
- [ ] リソース監視を実装できる
- [ ] コスト最適化の提案ができる
- [ ] セキュリティチェックを自動化できる
- [ ] CI/CD統合ができる

---

## 🎓 中級編修了！

おめでとうございます！中級編を完了しました！

次は **[99. 中級チートシート](99-intermediate-cheatsheet.md)** で復習しましょう。

---

**実務自動化Tipsをマスターしました！AWS CLI中級編完了です！🎉**
