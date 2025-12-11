# トラブルシューティングガイド

CloudFormationでよくあるエラーと対処法

---

## 🚨 スタックステータス一覧

### 正常系

| ステータス | 意味 | アクション |
|-----------|------|-----------|
| `CREATE_COMPLETE` | 作成完了 | なし |
| `UPDATE_COMPLETE` | 更新完了 | なし |
| `DELETE_COMPLETE` | 削除完了 | なし |

### 異常系

| ステータス | 意味 | 対処 |
|-----------|------|------|
| `CREATE_FAILED` | 作成失敗 | エラー確認後、スタック削除 → 再作成 |
| `ROLLBACK_COMPLETE` | ロールバック完了 | スタック削除 → 修正後、再作成 |
| `ROLLBACK_FAILED` | ロールバック失敗 | continue-update-rollback |
| `UPDATE_ROLLBACK_COMPLETE` | 更新ロールバック完了 | エラー確認、修正後、再更新 |
| `UPDATE_ROLLBACK_FAILED` | 更新ロールバック失敗 | continue-update-rollback |
| `DELETE_FAILED` | 削除失敗 | 依存リソース削除後、再削除 |

---

## 🔥 よくあるエラー

### エラー1: Resource does not exist

**現象**:
```
Resource does not exist in stack
```

**原因**: 参照しているリソースがテンプレート内に存在しない、または作成順序の問題

**対処**:
```yaml
# DependsOn で明示的な依存関係を定義
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    DependsOn: InternetGatewayAttachment  # IGW接続後に作成
    Properties:
      SubnetId: !Ref PublicSubnet
```

---

### エラー2: Circular dependency

**現象**:
```
Circular dependency between resources
```

**原因**: リソースA → B → A のような循環参照

**対処**:
```yaml
# NG例（循環参照）
Resources:
  SecurityGroupA:
    Type: AWS::EC2::SecurityGroup
    Properties:
      SecurityGroupIngress:
        - SourceSecurityGroupId: !Ref SecurityGroupB
  
  SecurityGroupB:
    Type: AWS::EC2::SecurityGroup
    Properties:
      SecurityGroupIngress:
        - SourceSecurityGroupId: !Ref SecurityGroupA

# OK例（Security Group IDで参照）
Resources:
  SecurityGroupA:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: SG A
  
  SecurityGroupB:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: SG B
  
  SecurityGroupAIngress:
    Type: AWS::EC2::SecurityGroupIngress
    Properties:
      GroupId: !Ref SecurityGroupA
      SourceSecurityGroupId: !Ref SecurityGroupB
  
  SecurityGroupBIngress:
    Type: AWS::EC2::SecurityGroupIngress
    Properties:
      GroupId: !Ref SecurityGroupB
      SourceSecurityGroupId: !Ref SecurityGroupA
```

---

### エラー3: Parameter validation failed

**現象**:
```
Parameter validation failed:
Invalid type for parameter InstanceType, value: 123, type: <class 'int'>, valid types: <class 'str'>
```

**原因**: パラメータの型が不正

**対処**:
```json
// parameters.json
[
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t3.small"  // 文字列として指定
  },
  {
    "ParameterKey": "MinSize",
    "ParameterValue": "1"  // 数値も文字列として渡す
  }
]
```

---

### エラー4: DELETE_FAILED

**現象**:
```
Resource vpc-xxxxx has dependencies and cannot be deleted
```

**原因**: VPC内に他のリソースが残っている

**対処**:
```bash
# 依存リソース確認
aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=vpc-xxxxx"
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-xxxxx"

# 手動削除（または時間を置いて再試行）
aws cloudformation delete-stack --stack-name my-stack

# 強制削除（最終手段）
aws cloudformation delete-stack --stack-name my-stack --retain-resources <ResourceLogicalId>
```

---

### エラー5: VpcLimitExceeded

**現象**:
```
The maximum number of VPCs has been reached
```

**原因**: リージョンのVPC上限（デフォルト5個）超過

**対処**:
```bash
# 不要なVPC削除
aws ec2 describe-vpcs
aws ec2 delete-vpc --vpc-id vpc-xxxxx

# または Service Quota で上限緩和申請
aws service-quotas request-service-quota-increase \
  --service-code vpc \
  --quota-code L-F678F1CE \
  --desired-value 10
```

---

### エラー6: ROLLBACK_FAILED / UPDATE_ROLLBACK_FAILED

**現象**: ロールバックが失敗し、スタックが操作不能

**対処**:
```bash
# 原因調査
aws cloudformation describe-stack-events \
  --stack-name my-stack \
  --max-items 50

# ロールバック続行
aws cloudformation continue-update-rollback \
  --stack-name my-stack

# 特定リソースをスキップ（リソース削除等で対処できない場合）
aws cloudformation continue-update-rollback \
  --stack-name my-stack \
  --resources-to-skip MyProblematicResource
```

---

### エラー7: Insufficient capabilities

**現象**:
```
Requires capabilities : [CAPABILITY_NAMED_IAM]
```

**原因**: IAMリソース作成に必要な権限確認が未実施

**対処**:
```bash
# --capabilities 追加
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

---

### エラー8: Template format error

**現象**:
```
Template format error: YAML not well-formed
```

**原因**: YAMLシンタックスエラー

**対処**:
```bash
# YAMLバリデーション
yamllint template.yaml

# cfn-lint で検証
pip install cfn-lint
cfn-lint template.yaml

# または、JSONに変換して確認
python -c "import yaml, json; print(json.dumps(yaml.safe_load(open('template.yaml'))))"
```

---

## 🔍 デバッグ手法

### 1. スタックイベント確認

```bash
# 最新イベント表示
aws cloudformation describe-stack-events \
  --stack-name my-stack \
  --max-items 20 \
  | jq '.StackEvents[] | {
      Timestamp: .Timestamp,
      ResourceStatus: .ResourceStatus,
      LogicalResourceId: .LogicalResourceId,
      ResourceStatusReason: .ResourceStatusReason
    }'

# エラーイベントのみ抽出
aws cloudformation describe-stack-events \
  --stack-name my-stack \
  | jq '.StackEvents[] | select(.ResourceStatus | contains("FAILED"))'
```

### 2. CloudWatch Logsでログ確認

```bash
# Lambda関数のログ（カスタムリソース等）
aws logs tail /aws/lambda/my-function --follow

# EC2 UserDataのログ
aws ssm start-session --target i-xxxxx
sudo tail -f /var/log/cloud-init-output.log
```

### 3. ドリフト検出

```bash
# 手動変更の検出
aws cloudformation detect-stack-drift --stack-name my-stack

# 結果確認
aws cloudformation describe-stack-resource-drifts \
  --stack-name my-stack \
  --stack-resource-drift-status-filters MODIFIED
```

---

## 💡 予防策

### 1. 変更セットで事前確認

```bash
# 本番更新前に必ず変更セット作成
aws cloudformation create-change-set \
  --stack-name prod-stack \
  --change-set-name update-20250110 \
  --template-body file://template.yaml

# 変更内容確認
aws cloudformation describe-change-set \
  --stack-name prod-stack \
  --change-set-name update-20250110
```

### 2. cfn-lint で静的解析

```bash
# インストール
pip install cfn-lint

# テンプレート検証
cfn-lint template.yaml

# ルール指定
cfn-lint template.yaml --ignore-checks W3002 W3005
```

### 3. DeletionPolicy 設定

```yaml
Resources:
  Database:
    Type: AWS::RDS::DBInstance
    DeletionPolicy: Snapshot  # 削除時にスナップショット作成
    Properties:
      Engine: mysql
  
  CriticalBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain  # スタック削除時も保持
```

---

## 🔧 復旧手順

### シナリオ1: CREATE_FAILED からの復旧

```bash
# 1. エラー確認
aws cloudformation describe-stack-events \
  --stack-name failed-stack \
  | jq '.StackEvents[] | select(.ResourceStatus == "CREATE_FAILED")'

# 2. スタック削除
aws cloudformation delete-stack --stack-name failed-stack

# 3. 削除完了待機
aws cloudformation wait stack-delete-complete --stack-name failed-stack

# 4. テンプレート修正後、再作成
aws cloudformation create-stack \
  --stack-name failed-stack \
  --template-body file://template-fixed.yaml
```

### シナリオ2: UPDATE_ROLLBACK_FAILED からの復旧

```bash
# 1. エラー確認
aws cloudformation describe-stack-events --stack-name stuck-stack

# 2. ロールバック続行
aws cloudformation continue-update-rollback --stack-name stuck-stack

# 3. それでも失敗する場合、リソースをスキップ
aws cloudformation continue-update-rollback \
  --stack-name stuck-stack \
  --resources-to-skip ProblematicResource

# 4. 手動でリソース削除
aws ec2 terminate-instances --instance-ids i-xxxxx

# 5. 再度ロールバック続行
aws cloudformation continue-update-rollback --stack-name stuck-stack
```

---

## 📊 監視・アラート設定

### CloudWatch Alarms

```yaml
Resources:
  StackFailureAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: CloudFormation-Stack-Failure
      MetricName: StackUpdateFailed
      Namespace: AWS/CloudFormation
      Statistic: Sum
      Period: 300
      EvaluationPeriods: 1
      Threshold: 1
      ComparisonOperator: GreaterThanOrEqualToThreshold
      AlarmActions:
        - !Ref SNSTopic
```

---

## 🎓 学習リソース

- [AWS公式: トラブルシューティング](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/troubleshooting.html)
- [CloudFormation エラーメッセージ一覧](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html)

---

**トラブルシューティングで、CloudFormationの問題を素早く解決！🔧**
