# デプロイガイド

Before/After テンプレートの実行方法

---

## 📋 前提条件

- AWS CLI インストール済み
- AWS認証情報設定済み
- EC2 Key Pair 作成済み（オプション）

---

## 🔴 Before版のデプロイ

### ⚠️ 注意

Before版は**実行不可**です（ハードコードされたIDが実際には存在しないため）。
学習用のコード例として参照してください。

---

## 🟢 After版のデプロイ

### 1. 基本デプロイ（開発環境）

```bash
# スタック作成
aws cloudformation create-stack \
  --stack-name myapp-dev-stack \
  --template-body file://after-advanced.yaml \
  --parameters \
    ParameterKey=ProjectName,ParameterValue=myapp \
    ParameterKey=Environment,ParameterValue=dev \
    ParameterKey=DBPassword,ParameterValue=SecurePassword123! \
    ParameterKey=CreateReadReplica,ParameterValue=false \
  --capabilities CAPABILITY_IAM

# 作成完了を待機（約10分）
aws cloudformation wait stack-create-complete \
  --stack-name myapp-dev-stack

# 出力値確認
aws cloudformation describe-stacks \
  --stack-name myapp-dev-stack \
  --query 'Stacks[0].Outputs'
```

### 2. 本番環境デプロイ

```bash
# 本番環境（Read Replica付き）
aws cloudformation create-stack \
  --stack-name myapp-prod-stack \
  --template-body file://after-advanced.yaml \
  --parameters \
    ParameterKey=ProjectName,ParameterValue=myapp \
    ParameterKey=Environment,ParameterValue=prod \
    ParameterKey=DBPassword,ParameterValue=VerySecurePassword456! \
    ParameterKey=CreateReadReplica,ParameterValue=true \
  --capabilities CAPABILITY_IAM
```

**違い**:
- InstanceType: t3.small → m5.large
- DBInstanceClass: db.t3.small → db.r6i.large
- MultiAZ: false → true
- BackupRetentionPeriod: 7日 → 30日
- Read Replica: 作成される

---

## 🔗 ImportValue 例のデプロイ

### 1. 元のスタックをデプロイ

```bash
aws cloudformation create-stack \
  --stack-name myapp-dev-stack \
  --template-body file://after-advanced.yaml \
  --parameters \
    ParameterKey=DBPassword,ParameterValue=SecurePass123!
```

### 2. ImportValue スタックをデプロイ

```bash
aws cloudformation create-stack \
  --stack-name myapp-dev-additional \
  --template-body file://import-example.yaml \
  --parameters \
    ParameterKey=NetworkStackName,ParameterValue=myapp-dev-stack \
  --capabilities CAPABILITY_IAM
```

---

## 🔍 確認方法

### スタック情報確認

```bash
# スタック一覧
aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE

# 特定スタックの詳細
aws cloudformation describe-stacks \
  --stack-name myapp-dev-stack

# 出力値のみ表示
aws cloudformation describe-stacks \
  --stack-name myapp-dev-stack \
  --query 'Stacks[0].Outputs' \
  --output table
```

### Export確認

```bash
# Export一覧
aws cloudformation list-exports

# 特定Exportを使用しているスタック確認
aws cloudformation list-imports \
  --export-name myapp-dev-stack-VPC
```

### リソース確認

```bash
# Web Server IPアドレス取得
WEB_IP=$(aws cloudformation describe-stacks \
  --stack-name myapp-dev-stack \
  --query 'Stacks[0].Outputs[?OutputKey==`WebServer1PublicIP`].OutputValue' \
  --output text)

# Webページアクセス
curl http://${WEB_IP}
```

---

## 🔄 更新

### パラメータ変更

```bash
# Read Replicaを追加
aws cloudformation update-stack \
  --stack-name myapp-dev-stack \
  --use-previous-template \
  --parameters \
    ParameterKey=ProjectName,UsePreviousValue=true \
    ParameterKey=Environment,UsePreviousValue=true \
    ParameterKey=DBPassword,UsePreviousValue=true \
    ParameterKey=CreateReadReplica,ParameterValue=true
```

### 変更セットで事前確認（推奨）

```bash
# 変更セット作成
aws cloudformation create-change-set \
  --stack-name myapp-dev-stack \
  --change-set-name add-read-replica \
  --use-previous-template \
  --parameters \
    ParameterKey=CreateReadReplica,ParameterValue=true

# 変更内容確認
aws cloudformation describe-change-set \
  --stack-name myapp-dev-stack \
  --change-set-name add-read-replica

# 変更セット実行
aws cloudformation execute-change-set \
  --stack-name myapp-dev-stack \
  --change-set-name add-read-replica
```

---

## 🗑️ 削除

### ImportValue使用時の削除順序

```bash
# 1. まずImport側を削除
aws cloudformation delete-stack \
  --stack-name myapp-dev-additional

# 削除完了待機
aws cloudformation wait stack-delete-complete \
  --stack-name myapp-dev-additional

# 2. 次にExport側を削除
aws cloudformation delete-stack \
  --stack-name myapp-dev-stack

aws cloudformation wait stack-delete-complete \
  --stack-name myapp-dev-stack
```

### 通常の削除

```bash
# スタック削除
aws cloudformation delete-stack \
  --stack-name myapp-dev-stack

# 削除完了待機
aws cloudformation wait stack-delete-complete \
  --stack-name myapp-dev-stack
```

**⚠️ 注意**:
- RDSは `DeletionPolicy: Snapshot` のため、削除前に自動スナップショット作成
- スナップショットは手動削除が必要

---

## 💰 コスト概算

### 開発環境（最小構成）

| リソース | 台数 | 料金/月 |
|---------|------|---------|
| EC2 (t3.small) | 2台 | $30 |
| RDS (db.t3.small) | 1台 | $30 |
| NAT Gateway | 0台 | $0 |
| **合計** | - | **約$60/月** |

### 本番環境（HA構成）

| リソース | 台数 | 料金/月 |
|---------|------|---------|
| EC2 (m5.large) | 2台 | $140 |
| RDS (db.r6i.large, MultiAZ) | 1台 | $400 |
| RDS Read Replica | 1台 | $200 |
| **合計** | - | **約$740/月** |

**節約ポイント**:
- 開発環境は業務時間外停止（Auto Stop Lambda使用）
- Read Replicaは本番のみ作成

---

## 🚨 トラブルシューティング

### エラー1: DBPassword が短すぎる

```
DBPassword must be at least 8 characters
```

**対処**: 8文字以上のパスワードを指定

### エラー2: Export名が重複

```
Export myapp-dev-stack-VPC already exists
```

**対処**: スタック名を変更するか、既存スタックを削除

### エラー3: ImportValue が見つからない

```
No export named myapp-dev-stack-VPC found
```

**対処**: Export側のスタックが先にデプロイされているか確認

---

## 📚 次のステップ

1. ✅ Before版のコードを読んで問題点を理解
2. ✅ After版をデプロイして動作確認
3. ✅ Parameters を変更して再デプロイ
4. ✅ import-example.yaml で ImportValue を体験
5. ✅ 変更セットで安全な更新を体験
6. ✅ 自分のプロジェクトに応用

---

**このガイドで、CloudFormation中級テクニックを実践習得！🚀**
