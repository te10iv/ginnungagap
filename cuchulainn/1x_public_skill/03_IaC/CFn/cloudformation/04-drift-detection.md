# ドリフト検出と修正

手動変更を検出し、IaCの一貫性を保つ必須機能

---

## 🔍 ドリフトとは

CloudFormationテンプレートと実際のリソース状態の差異。**手動変更**により発生。

### よくあるドリフトの原因

- ❌ AWS Console での直接変更
- ❌ AWS CLI/SDK での直接変更
- ❌ 他のツール（Ansible、Terraform等）による変更
- ❌ Auto Scaling による自動変更
- ❌ AWS側の自動パッチ適用

---

## 📊 ドリフトの種類

| ステータス | 意味 | アクション |
|-----------|------|-----------|
| **IN_SYNC** | 同期状態（正常） | なし |
| **MODIFIED** | プロパティが変更された | テンプレート修正または手動で戻す |
| **DELETED** | リソースが削除された | 再作成 |
| **NOT_CHECKED** | ドリフト検出未実施 | 検出実行 |

---

## 🎯 ドリフト検出の実行

### スタック全体の検出

```bash
# ドリフト検出開始
aws cloudformation detect-stack-drift \
  --stack-name my-stack

# 出力例
{
    "StackDriftDetectionId": "12345678-1234-1234-1234-123456789012"
}

# 検出完了を待機
aws cloudformation wait stack-drift-detection-complete \
  --stack-drift-detection-id 12345678-1234-1234-1234-123456789012

# 結果確認
aws cloudformation describe-stack-drift-detection-status \
  --stack-drift-detection-id 12345678-1234-1234-1234-123456789012
```

### 結果の詳細表示

```bash
# ドリフトしたリソース一覧
aws cloudformation describe-stack-resource-drifts \
  --stack-name my-stack \
  --stack-resource-drift-status-filters MODIFIED DELETED

# JSON整形して表示
aws cloudformation describe-stack-resource-drifts \
  --stack-name my-stack \
  --stack-resource-drift-status-filters MODIFIED \
  --output json | jq '.StackResourceDrifts[] | {
    LogicalResourceId: .LogicalResourceId,
    ResourceType: .ResourceType,
    StackResourceDriftStatus: .StackResourceDriftStatus,
    PropertyDifferences: .PropertyDifferences
  }'
```

### 出力例

```json
{
  "LogicalResourceId": "WebServer",
  "ResourceType": "AWS::EC2::Instance",
  "StackResourceDriftStatus": "MODIFIED",
  "PropertyDifferences": [
    {
      "PropertyPath": "/Properties/InstanceType",
      "ExpectedValue": "t3.small",     // テンプレート値
      "ActualValue": "t3.medium",       // 実際の値
      "DifferenceType": "NOT_EQUAL"
    },
    {
      "PropertyPath": "/Properties/Tags/0/Value",
      "ExpectedValue": "WebServer",
      "ActualValue": "WebServer-Modified",
      "DifferenceType": "NOT_EQUAL"
    }
  ]
}
```

---

## 🔧 特定リソースのドリフト検出

```bash
# 特定リソースのみ検出
aws cloudformation detect-stack-resource-drift \
  --stack-name my-stack \
  --logical-resource-id WebServer

# 結果確認
aws cloudformation describe-stack-resource-drifts \
  --stack-name my-stack \
  --stack-resource-drift-status-filters MODIFIED \
  | jq '.StackResourceDrifts[] | select(.LogicalResourceId == "WebServer")'
```

---

## 🛠️ ドリフトの修正方法

### 方法1: テンプレートを実際の状態に合わせる

実際の状態が正しい場合、テンプレートを更新。

```yaml
# 修正前（テンプレート）
Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t3.small

# 修正後（実際の状態に合わせる）
Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t3.medium  # 実際の値に合わせる
```

```bash
# スタック更新
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --use-previous-template
```

### 方法2: リソースをテンプレート通りに戻す

テンプレートが正しい場合、リソースを戻す。

```bash
# オプション1: スタック更新（強制的にテンプレート通りにする）
aws cloudformation update-stack \
  --stack-name my-stack \
  --use-previous-template \
  --parameters UsePreviousValue=true

# オプション2: 手動で戻す（インスタンスタイプ等）
aws ec2 modify-instance-attribute \
  --instance-id i-1234567890abcdef0 \
  --instance-type t3.small
```

### 方法3: リソースを置換

ドリフトが大きい場合、リソースを再作成。

```yaml
# テンプレートで名前を変更（新しいリソースが作成される）
Resources:
  WebServerNew:  # 名前を変更
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t3.small
```

---

## 🚨 ドリフトが検出されやすいリソース

### よくドリフトするリソース

| リソース | 変更されやすい項目 | 理由 |
|---------|------------------|------|
| **EC2 Instance** | InstanceType, Tags, SecurityGroups | 手動でのスケーリング、タグ変更 |
| **Security Group** | SecurityGroupIngress, SecurityGroupEgress | 緊急対応でのルール追加 |
| **RDS** | BackupRetentionPeriod, Tags | バックアップ設定変更 |
| **S3 Bucket** | Tags, LifecycleConfiguration | タグ・ライフサイクル変更 |
| **IAM Role** | Policies | 権限追加・削除 |
| **Lambda** | Environment, MemorySize | 環境変数・メモリ変更 |

---

## 🎯 実践パターン

### パターン1: 定期的なドリフト検出（EventBridge）

```yaml
# drift-detection-lambda.yaml
Resources:
  DriftDetectionFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: drift-detection
      Runtime: python3.11
      Handler: index.lambda_handler
      Code:
        ZipFile: |
          import boto3
          
          cfn = boto3.client('cloudformation')
          
          def lambda_handler(event, context):
              stacks = cfn.list_stacks(
                  StackStatusFilter=['CREATE_COMPLETE', 'UPDATE_COMPLETE']
              )
              
              for stack in stacks['StackSummaries']:
                  stack_name = stack['StackName']
                  
                  # ドリフト検出
                  response = cfn.detect_stack_drift(StackName=stack_name)
                  drift_id = response['StackDriftDetectionId']
                  
                  print(f"Drift detection started for {stack_name}: {drift_id}")
              
              return {'statusCode': 200}
      Role: !GetAtt LambdaExecutionRole.Arn

  # 毎日実行
  DriftDetectionRule:
    Type: AWS::Events::Rule
    Properties:
      ScheduleExpression: 'cron(0 9 * * ? *)'  # 毎日9時（UTC）
      State: ENABLED
      Targets:
        - Arn: !GetAtt DriftDetectionFunction.Arn
          Id: DriftDetectionTarget
```

### パターン2: ドリフト検出時のSNS通知

```yaml
Resources:
  DriftNotificationFunction:
    Type: AWS::Lambda::Function
    Properties:
      Code:
        ZipFile: |
          import boto3
          import json
          
          cfn = boto3.client('cloudformation')
          sns = boto3.client('sns')
          
          def lambda_handler(event, context):
              stack_name = event['stack_name']
              
              # ドリフト検出
              response = cfn.detect_stack_drift(StackName=stack_name)
              drift_id = response['StackDriftDetectionId']
              
              # 完了待ち
              waiter = cfn.get_waiter('stack_drift_detection_complete')
              waiter.wait(StackDriftDetectionId=drift_id)
              
              # ドリフトリソース取得
              drifts = cfn.describe_stack_resource_drifts(
                  StackName=stack_name,
                  StackResourceDriftStatusFilters=['MODIFIED', 'DELETED']
              )
              
              if drifts['StackResourceDrifts']:
                  # SNS通知
                  message = f"Drift detected in {stack_name}:\n\n"
                  for drift in drifts['StackResourceDrifts']:
                      message += f"- {drift['LogicalResourceId']} ({drift['ResourceType']})\n"
                  
                  sns.publish(
                      TopicArn='arn:aws:sns:ap-northeast-1:123456789012:drift-alerts',
                      Subject=f'CloudFormation Drift Alert: {stack_name}',
                      Message=message
                  )
              
              return {'drifts': len(drifts['StackResourceDrifts'])}
```

---

## 📊 ドリフト検出の制限事項

### 検出できないリソース

| リソースタイプ | 理由 |
|-------------|------|
| **AWS::CloudFormation::Stack** | ネストスタック自体は検出不可 |
| **カスタムリソース** | Lambda等で定義されたリソース |
| 一部のリソースタイプ | サポート対象外 |

### 検出できないプロパティ

- 読み取り専用プロパティ
- AWS側で自動更新されるプロパティ（例: RDSのエンドポイント）
- Secrets Manager等の機密情報

---

## 💡 ベストプラクティス

### ✅ DO

1. **定期的なドリフト検出**: 週次または月次で実行
2. **CI/CD統合**: デプロイ前にドリフト検出
3. **アラート設定**: ドリフト検出時にSlack/Email通知
4. **ドリフトログ保存**: 履歴管理のためS3に保存
5. **タグ管理**: `ManagedBy: CloudFormation` タグで手動変更を抑制

### ❌ DON'T

1. 手動変更を前提とした設計
2. ドリフトを長期間放置
3. 緊急対応での手動変更後、テンプレート未更新

---

## 🔧 ドリフト防止策

### 1. SCPによる手動変更の制限

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:ModifyInstanceAttribute",
        "ec2:TerminateInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalArn": [
            "arn:aws:iam::123456789012:role/CloudFormationRole"
          ]
        }
      }
    }
  ]
}
```

### 2. Config Rulesによる監視

```yaml
Resources:
  CloudFormationStackDriftRule:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: cloudformation-stack-drift-detection-check
      Description: Checks if CloudFormation stacks have drift
      Source:
        Owner: AWS
        SourceIdentifier: CLOUDFORMATION_STACK_DRIFT_DETECTION_CHECK
```

### 3. タグによる管理

```yaml
Resources:
  MyResource:
    Type: AWS::EC2::Instance
    Properties:
      Tags:
        - Key: ManagedBy
          Value: CloudFormation
        - Key: DoNotModify
          Value: 'true'
```

---

## 📚 学習リソース

- [AWS公式: ドリフト検出](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/using-cfn-stack-drift.html)
- [ドリフト検出のベストプラクティス](https://aws.amazon.com/jp/blogs/mt/detect-drift-and-remediate-with-cloudformation/)

---

**ドリフト検出で、IaCの一貫性を保ち、インフラの信頼性を向上！🔍**
