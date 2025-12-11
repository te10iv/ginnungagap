# StackSets - マルチアカウント・マルチリージョン展開

複数のAWSアカウント・リージョンに一括デプロイ

---

## 🌍 StackSetsとは

1つのテンプレートを、**複数のAWSアカウント・複数のリージョン**に一括デプロイできる機能。

### 使用ケース

- ✅ セキュリティベースライン（全アカウント共通）
- ✅ CloudTrail、Config有効化（ガバナンス）
- ✅ IAM Role の統一配布
- ✅ マルチリージョンDR構成
- ✅ Organizations での組織全体管理

---

## 📊 StackSets の構成要素

| 要素 | 説明 |
|------|------|
| **StackSet** | テンプレートとパラメータの集合 |
| **Stack Instance** | 特定のアカウント・リージョンにデプロイされたスタック |
| **Administrator Account** | StackSetを管理するアカウント |
| **Target Account** | スタックがデプロイされるアカウント |

---

## 🚀 StackSets の作成

### 前提条件

**Administrator Account（管理側）にIAM Role作成**:
```yaml
AWSCloudFormationStackSetAdministrationRole
```

**Target Account（対象側）にIAM Role作成**:
```yaml
AWSCloudFormationStackSetExecutionRole
```

### StackSet作成

```bash
# StackSet作成
aws cloudformation create-stack-set \
  --stack-set-name security-baseline \
  --template-body file://baseline.yaml \
  --description 'Security baseline for all accounts' \
  --capabilities CAPABILITY_NAMED_IAM \
  --permission-model SERVICE_MANAGED \
  --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=false

# Stack Instances作成（特定アカウント・リージョン）
aws cloudformation create-stack-instances \
  --stack-set-name security-baseline \
  --accounts 123456789012 234567890123 \
  --regions ap-northeast-1 us-east-1 \
  --operation-preferences \
    FailureToleranceCount=1,\
    MaxConcurrentCount=2
```

### Organizations統合（推奨）

```bash
# Organizations全体に自動デプロイ
aws cloudformation create-stack-set \
  --stack-set-name org-baseline \
  --template-body file://baseline.yaml \
  --permission-model SERVICE_MANAGED \
  --auto-deployment Enabled=true \
  --call-as DELEGATED_ADMIN

# OU単位でデプロイ
aws cloudformation create-stack-instances \
  --stack-set-name org-baseline \
  --deployment-targets OrganizationalUnitIds=ou-xxxx-yyyyyyyy \
  --regions ap-northeast-1
```

---

## 📋 StackSet更新

```bash
# StackSet更新（テンプレート変更）
aws cloudformation update-stack-set \
  --stack-set-name security-baseline \
  --template-body file://baseline-v2.yaml \
  --operation-preferences \
    FailureTolerancePercentage=30,\
    MaxConcurrentPercentage=50

# Stack Instances追加
aws cloudformation create-stack-instances \
  --stack-set-name security-baseline \
  --accounts 345678901234 \
  --regions eu-west-1

# Stack Instances削除
aws cloudformation delete-stack-instances \
  --stack-set-name security-baseline \
  --accounts 123456789012 \
  --regions us-west-2 \
  --no-retain-stacks
```

---

## 🎯 実践例

### 例1: CloudTrail全リージョン有効化

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Enable CloudTrail in all regions'

Resources:
  CloudTrailBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub 'cloudtrail-${AWS::AccountId}-${AWS::Region}'
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true

  BucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref CloudTrailBucket
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: AWSCloudTrailAclCheck
            Effect: Allow
            Principal:
              Service: cloudtrail.amazonaws.com
            Action: s3:GetBucketAcl
            Resource: !GetAtt CloudTrailBucket.Arn
          - Sid: AWSCloudTrailWrite
            Effect: Allow
            Principal:
              Service: cloudtrail.amazonaws.com
            Action: s3:PutObject
            Resource: !Sub '${CloudTrailBucket.Arn}/*'
            Condition:
              StringEquals:
                s3:x-amz-acl: bucket-owner-full-control

  Trail:
    Type: AWS::CloudTrail::Trail
    DependsOn: BucketPolicy
    Properties:
      TrailName: !Sub 'org-trail-${AWS::Region}'
      S3BucketName: !Ref CloudTrailBucket
      IsLogging: true
      IsMultiRegionTrail: true
      IncludeGlobalServiceEvents: true
      EnableLogFileValidation: true

Outputs:
  TrailArn:
    Value: !GetAtt Trail.Arn
```

**デプロイ**:
```bash
# 全組織・全リージョンに展開
aws cloudformation create-stack-set \
  --stack-set-name org-cloudtrail \
  --template-body file://cloudtrail.yaml \
  --permission-model SERVICE_MANAGED \
  --auto-deployment Enabled=true

aws cloudformation create-stack-instances \
  --stack-set-name org-cloudtrail \
  --deployment-targets OrganizationalUnitIds=r-xxxx \
  --regions ap-northeast-1 us-east-1 eu-west-1
```

### 例2: セキュリティベースライン

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Security Baseline - Config, GuardDuty, Security Hub'

Resources:
  # Config有効化
  ConfigRecorder:
    Type: AWS::Config::ConfigurationRecorder
    Properties:
      Name: default
      RoleArn: !GetAtt ConfigRole.Arn
      RecordingGroup:
        AllSupported: true
        IncludeGlobalResourceTypes: true

  ConfigRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: config.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/ConfigRole

  # GuardDuty有効化
  GuardDutyDetector:
    Type: AWS::GuardDuty::Detector
    Properties:
      Enable: true
      FindingPublishingFrequency: FIFTEEN_MINUTES

  # Security Hub有効化
  SecurityHub:
    Type: AWS::SecurityHub::Hub
    Properties:
      ControlFindingGenerator: SECURITY_CONTROL
      EnableDefaultStandards: true

Outputs:
  ConfigRecorderName:
    Value: !Ref ConfigRecorder
  
  GuardDutyDetectorId:
    Value: !Ref GuardDutyDetector
```

---

## 🔧 運用パターン

### パターン1: リージョン別パラメータ

```yaml
Parameters:
  InstanceType:
    Type: String
    Default: t3.small

Mappings:
  RegionConfig:
    ap-northeast-1:
      AMI: ami-xxxxx
      AvailabilityZones: 3
    us-east-1:
      AMI: ami-yyyyy
      AvailabilityZones: 6

Resources:
  Instance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !FindInMap [RegionConfig, !Ref 'AWS::Region', AMI]
```

### パターン2: アカウント別タグ

```yaml
Resources:
  MyResource:
    Type: AWS::S3::Bucket
    Properties:
      Tags:
        - Key: AccountId
          Value: !Ref 'AWS::AccountId'
        - Key: Region
          Value: !Ref 'AWS::Region'
        - Key: StackSetName
          Value: !Ref 'AWS::StackName'
```

---

## 💡 ベストプラクティス

### ✅ DO

1. **Organizations統合**: Service-Managed Permission Model使用
2. **Auto Deployment**: 新規アカウント自動展開
3. **Operation Preferences**: 並列度・失敗許容度設定
4. **変更セット**: StackSet更新前にプレビュー
5. **タグ統一**: 全スタックに同じタグ戦略

```bash
# Operation Preferences例
--operation-preferences \
  FailureTolerancePercentage=20,\
  MaxConcurrentPercentage=50,\
  RegionConcurrencyType=PARALLEL
```

### ❌ DON'T

1. Self-Managed Permission Model（手動IAM設定が必要）
2. 全アカウント・全リージョンへの一斉展開（段階的に）
3. Stack Instance削除時の --retain-stacks 乱用

---

## 🚨 トラブルシューティング

### 問題1: Stack Instance作成失敗

**原因**: Target AccountにExecutionRoleがない

**対処**:
```bash
# ExecutionRole確認
aws iam get-role --role-name AWSCloudFormationStackSetExecutionRole

# なければ作成
aws cloudformation create-stack \
  --stack-name StackSetExecutionRole \
  --template-url https://s3.amazonaws.com/cloudformation-stackset-sample-templates-us-east-1/StackSetExecutionRole.yml \
  --capabilities CAPABILITY_NAMED_IAM
```

### 問題2: UPDATE_FAILED

**対処**:
```bash
# 失敗したStack Instanceを確認
aws cloudformation list-stack-instances \
  --stack-set-name my-stackset \
  --filters Key=Status,Values=OUTDATED

# 再試行
aws cloudformation update-stack-instances \
  --stack-set-name my-stackset \
  --accounts 123456789012 \
  --regions ap-northeast-1
```

---

## 📚 学習リソース

- [AWS公式: StackSets](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html)
- [StackSets with Organizations](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/stacksets-orgs.html)

---

**StackSetsで、マルチアカウント環境を効率的に管理！🌍**
