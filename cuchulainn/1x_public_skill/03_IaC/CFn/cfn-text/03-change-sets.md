# 変更セット（Change Sets）による安全な更新

本番環境での CloudFormation 更新に必須の機能

---

## 🔄 変更セットとは

スタック更新前に、変更内容をプレビューできる機能。**本番環境では必須**。

### メリット

- ✅ 更新内容を事前確認（削除リソース、置換リソース等）
- ✅ 意図しない削除・置換を防止
- ✅ レビュープロセスへの組み込み
- ✅ ロールバックリスクの軽減

---

## 🎯 変更セットのワークフロー

```
1. 変更セット作成
   ↓
2. 変更内容をレビュー
   ↓
3. 承認
   ↓
4. 変更セット実行
   ↓
5. スタック更新完了
```

---

## 📋 変更セット作成

### CLI

```bash
# 変更セット作成
aws cloudformation create-change-set \
  --stack-name my-stack \
  --change-set-name update-20250110 \
  --template-body file://template.yaml \
  --parameters \
    ParameterKey=InstanceType,ParameterValue=t3.medium \
  --capabilities CAPABILITY_NAMED_IAM

# 作成完了を待機
aws cloudformation wait change-set-create-complete \
  --stack-name my-stack \
  --change-set-name update-20250110
```

### パラメータファイル使用

```bash
# parameters.json
[
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t3.medium"
  },
  {
    "ParameterKey": "Environment",
    "UsePreviousValue": true
  }
]

# 変更セット作成
aws cloudformation create-change-set \
  --stack-name my-stack \
  --change-set-name update-20250110 \
  --template-body file://template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM
```

---

## 🔍 変更セットの確認

### 詳細表示

```bash
# 変更セット内容確認
aws cloudformation describe-change-set \
  --stack-name my-stack \
  --change-set-name update-20250110 \
  --output json | jq '.Changes'

# 変更セット一覧
aws cloudformation list-change-sets --stack-name my-stack
```

### 出力例

```json
{
  "Changes": [
    {
      "Type": "Resource",
      "ResourceChange": {
        "Action": "Modify",
        "LogicalResourceId": "WebServer",
        "PhysicalResourceId": "i-1234567890abcdef0",
        "ResourceType": "AWS::EC2::Instance",
        "Replacement": "True",  # 置換が発生（要注意！）
        "Scope": ["Properties"],
        "Details": [
          {
            "Target": {
              "Attribute": "Properties",
              "Name": "InstanceType",
              "RequiresRecreation": "Always"
            },
            "Evaluation": "Static",
            "ChangeSource": "DirectModification"
          }
        ]
      }
    }
  ]
}
```

### 重要な確認ポイント

| フィールド | 意味 | 注意事項 |
|-----------|------|---------|
| **Action** | `Add`, `Modify`, `Remove`, `Import` | `Remove` は削除を意味 |
| **Replacement** | `True`, `False`, `Conditional` | `True` はリソース置換（再作成） |
| **Scope** | 変更される属性 | `Properties`, `Tags`, `Metadata` |
| **RequiresRecreation** | `Always`, `Conditionally`, `Never` | 再作成の必要性 |

---

## ✅ 変更セット実行

```bash
# 変更セット実行
aws cloudformation execute-change-set \
  --stack-name my-stack \
  --change-set-name update-20250110

# 完了を待機
aws cloudformation wait stack-update-complete --stack-name my-stack

# スタック確認
aws cloudformation describe-stacks --stack-name my-stack
```

---

## ❌ 変更セット削除（実行しない場合）

```bash
# 変更セット削除
aws cloudformation delete-change-set \
  --stack-name my-stack \
  --change-set-name update-20250110
```

**注意**: 変更セットを削除してもスタックは変更されない（安全）。

---

## 🚨 危険な変更の検出

### リソース置換（Replacement: True）

**影響**:
- リソースが削除され、新規作成される
- **物理IDが変わる**（EC2のInstance ID、RDSのEndpoint等）
- **データが失われる可能性**（EBS、RDS等）

**例**: EC2インスタンスタイプ変更

```yaml
# 変更前
Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t3.small  # ← これを変更

# 変更後
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t3.medium  # 置換が発生！
```

**変更セット出力**:
```json
{
  "ResourceChange": {
    "Action": "Modify",
    "Replacement": "True",  # ← 要注意！
    "ResourceType": "AWS::EC2::Instance"
  }
}
```

### リソース削除（Action: Remove）

**影響**:
- リソースが完全に削除される
- 復元不可（バックアップがなければ）

**原因**:
- テンプレートからリソース定義を削除
- Condition が False に変更

---

## 🛡️ 安全な更新パターン

### パターン1: Blue-Green デプロイ

```yaml
# 新しいリソースを追加
Resources:
  WebServerNew:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t3.medium

  # 古いリソースは残す（後で手動削除）
  WebServerOld:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t3.small
```

### パターン2: 削除保護

```yaml
Resources:
  Database:
    Type: AWS::RDS::DBInstance
    DeletionPolicy: Snapshot  # 削除時にスナップショット作成
    Properties:
      Engine: mysql
      DeletionProtection: true  # 削除保護
```

### パターン3: 段階的更新

```yaml
# Step 1: 新しいSecurity Groupを追加
Resources:
  NewSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: New SG

# Step 2: EC2に新しいSGを追加（変更セット確認）
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      SecurityGroupIds:
        - !Ref OldSecurityGroup
        - !Ref NewSecurityGroup  # 追加

# Step 3: 古いSGを削除（変更セット確認）
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      SecurityGroupIds:
        - !Ref NewSecurityGroup  # 古いSGを削除
```

---

## 📊 変更セットのステータス

| ステータス | 意味 | アクション |
|-----------|------|-----------|
| `CREATE_PENDING` | 作成中 | 待機 |
| `CREATE_IN_PROGRESS` | 作成処理中 | 待機 |
| `CREATE_COMPLETE` | 作成完了 | 内容確認後、実行 |
| `FAILED` | 作成失敗 | エラー確認、再作成 |

---

## 🎯 実践例

### 例1: RDSインスタンスクラス変更

```bash
# 1. 変更セット作成
aws cloudformation create-change-set \
  --stack-name db-stack \
  --change-set-name upgrade-db-instance \
  --use-previous-template \
  --parameters \
    ParameterKey=DBInstanceClass,ParameterValue=db.t3.medium \
  --capabilities CAPABILITY_IAM

# 2. 変更内容確認
aws cloudformation describe-change-set \
  --stack-name db-stack \
  --change-set-name upgrade-db-instance

# 出力確認: Replacement が False であることを確認
# → RDSインスタンスクラス変更は再作成なし（ダウンタイムあり）

# 3. メンテナンスウィンドウで実行
aws cloudformation execute-change-set \
  --stack-name db-stack \
  --change-set-name upgrade-db-instance
```

### 例2: EC2 AMI更新（置換発生）

```bash
# 1. 変更セット作成
aws cloudformation create-change-set \
  --stack-name web-stack \
  --change-set-name update-ami \
  --template-body file://template.yaml \
  --parameters ParameterKey=LatestAMI,ParameterValue=ami-xxxxx

# 2. 変更内容確認
# Replacement: True を確認 → インスタンスが置換される

# 3. 事前準備
# - ELBからインスタンスを外す
# - バックアップ取得
# - 新しいインスタンス起動先を確認

# 4. 実行
aws cloudformation execute-change-set \
  --stack-name web-stack \
  --change-set-name update-ami
```

---

## 🔧 変更セットとCI/CD

### GitHub Actions例

```yaml
name: CloudFormation Update

on:
  pull_request:
    branches: [main]

jobs:
  create-changeset:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: ap-northeast-1
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
      
      - name: Create Change Set
        run: |
          aws cloudformation create-change-set \
            --stack-name my-stack \
            --change-set-name pr-${{ github.event.pull_request.number }} \
            --template-body file://template.yaml \
            --capabilities CAPABILITY_NAMED_IAM
      
      - name: Describe Change Set
        run: |
          aws cloudformation describe-change-set \
            --stack-name my-stack \
            --change-set-name pr-${{ github.event.pull_request.number }} \
            --output json > changeset.json
      
      - name: Comment PR
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const changes = JSON.parse(fs.readFileSync('changeset.json'));
            const body = `## CloudFormation Change Set\n\n${JSON.stringify(changes.Changes, null, 2)}`;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });
```

---

## 💡 ベストプラクティス

### ✅ DO

1. **本番環境では必ず変更セット使用**
2. **変更セット名に日付・チケット番号を含める**（例: `update-20250110-JIRA-1234`）
3. **Replacement: True のリソースは特に注意**
4. **レビュープロセスに組み込む**
5. **変更セット作成後、すぐに実行しない**（レビュー時間を設ける）

### ❌ DON'T

1. 変更セット確認なしに直接更新
2. Replacement の意味を理解せずに実行
3. 本番環境で `--no-execute-changeset` を使わない

---

## 🎓 学習リソース

- [AWS公式: 変更セット](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html)
- [変更セットのベストプラクティス](https://aws.amazon.com/jp/blogs/devops/update-cloudformation-stacks-using-change-sets/)

---

**変更セットで、本番環境の安全な更新を実現！🛡️**
