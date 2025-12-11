# CloudFormation 中級チートシート 📋

**実務で必要な高度な機能のクイックリファレンス**

---

## 🎯 中級者が習得すべきスキル

- ✅ ネストスタックによるモジュール化
- ✅ 変更セットで安全な更新
- ✅ ドリフト検出と修正
- ✅ カスタムリソース（Lambda連携）
- ✅ マルチ環境管理
- ✅ StackSets（マルチアカウント）
- ✅ 高度な組み込み関数
- ✅ CI/CD統合

---

## 🏗️ ネストスタック（Nested Stacks）

### 概要

大規模テンプレートを複数の小さなテンプレートに分割し、再利用可能にする

### 親スタック

```yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/mybucket/network.yaml
      Parameters:
        VpcCidr: 10.0.0.0/16
        Environment: !Ref Environment
      Tags:
        - Key: Name
          Value: NetworkStack

  ComputeStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/mybucket/compute.yaml
      Parameters:
        VpcId: !GetAtt NetworkStack.Outputs.VpcId    # ← 他スタックの出力参照
        SubnetId: !GetAtt NetworkStack.Outputs.PublicSubnetId
    DependsOn: NetworkStack    # ← 依存関係を明示
```

### 子スタック（network.yaml）

```yaml
Parameters:
  VpcCidr:
    Type: String
  Environment:
    Type: String

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCidr

Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: !Sub '${AWS::StackName}-VpcId'
```

**メリット**:
- テンプレートサイズ制限（51,200バイト）回避
- モジュール再利用
- チーム開発（担当分割）

---

## 🔄 変更セット（Change Sets）

### 作成

```bash
# 変更セット作成
aws cloudformation create-change-set \
  --stack-name my-stack \
  --change-set-name my-changes \
  --template-body file://updated-template.yaml \
  --parameters ParameterKey=InstanceType,ParameterValue=t3.medium
```

### 確認

```bash
# 変更セット内容確認
aws cloudformation describe-change-set \
  --stack-name my-stack \
  --change-set-name my-changes

# 変更内容のみ抽出
aws cloudformation describe-change-set \
  --stack-name my-stack \
  --change-set-name my-changes \
  --query 'Changes[*].ResourceChange'
```

### 実行

```bash
# 変更セット実行
aws cloudformation execute-change-set \
  --stack-name my-stack \
  --change-set-name my-changes

# 削除（実行しない場合）
aws cloudformation delete-change-set \
  --stack-name my-stack \
  --change-set-name my-changes
```

**変更の種類**:
- `Add`: 新規作成
- `Modify`: 更新
- `Remove`: 削除
- `Dynamic`: 実行時に決定

**Replacement（置換）**:
- `True`: リソース削除→作成（データ消失リスク！）
- `False`: インプレース更新
- `Conditional`: 条件次第

---

## 🔍 ドリフト検出（Drift Detection）

### ドリフト検出実行

```bash
# ドリフト検出開始
aws cloudformation detect-stack-drift --stack-name my-stack

# 結果確認
aws cloudformation describe-stack-drift-detection-status \
  --stack-drift-detection-id <detection-id>

# 詳細確認
aws cloudformation describe-stack-resource-drifts \
  --stack-name my-stack
```

### ドリフト状態

| 状態 | 意味 |
|------|------|
| `IN_SYNC` | 同期（正常） |
| `MODIFIED` | 手動変更あり |
| `DELETED` | リソース削除済み |
| `NOT_CHECKED` | 未チェック |

### 修正方法

**方法1**: テンプレート更新
```bash
# 現在の状態をテンプレートに反映
aws cloudformation update-stack \
  --stack-name my-stack \
  --use-previous-template \
  --parameters file://current-params.json
```

**方法2**: リソース再作成
```bash
# スタック削除→再作成
aws cloudformation delete-stack --stack-name my-stack
aws cloudformation create-stack --stack-name my-stack --template-body file://template.yaml
```

---

## 🔧 カスタムリソース（Custom Resources）

### Lambda関数（カスタムリソースハンドラー）

```python
import cfnresponse
import boto3

def lambda_handler(event, context):
    try:
        if event['RequestType'] == 'Create':
            # リソース作成ロジック
            result = create_resource(event['ResourceProperties'])
            physical_id = result['Id']
        
        elif event['RequestType'] == 'Update':
            # リソース更新ロジック
            result = update_resource(event['PhysicalResourceId'], event['ResourceProperties'])
            physical_id = event['PhysicalResourceId']
        
        elif event['RequestType'] == 'Delete':
            # リソース削除ロジック
            delete_resource(event['PhysicalResourceId'])
            physical_id = event['PhysicalResourceId']
        
        cfnresponse.send(event, context, cfnresponse.SUCCESS, result, physical_id)
    
    except Exception as e:
        cfnresponse.send(event, context, cfnresponse.FAILED, {'Error': str(e)})
```

### テンプレートでの使用

```yaml
Resources:
  CustomResourceFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: CustomResourceHandler
      Runtime: python3.11
      Handler: index.lambda_handler
      Role: !GetAtt LambdaExecutionRole.Arn
      Code:
        ZipFile: |
          # Lambda コード

  MyCustomResource:
    Type: Custom::MyResource
    Properties:
      ServiceToken: !GetAtt CustomResourceFunction.Arn
      CustomProperty1: Value1
      CustomProperty2: Value2
```

**ユースケース**:
- CloudFormation非対応サービスの操作
- 外部APIの呼び出し
- 複雑な初期化処理
- リソース削除時のクリーンアップ

---

## 🌍 マルチ環境管理

### パターン1: Mappings

```yaml
Mappings:
  EnvironmentMap:
    dev:
      InstanceType: t3.small
      DbClass: db.t3.micro
      MultiAZ: false
      BackupRetention: 1
    stg:
      InstanceType: t3.medium
      DbClass: db.t3.small
      MultiAZ: false
      BackupRetention: 7
    prod:
      InstanceType: m5.large
      DbClass: db.r6i.large
      MultiAZ: true
      BackupRetention: 30

Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, stg, prod]

Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !FindInMap [EnvironmentMap, !Ref Environment, InstanceType]
  
  MyRDS:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceClass: !FindInMap [EnvironmentMap, !Ref Environment, DbClass]
      MultiAZ: !FindInMap [EnvironmentMap, !Ref Environment, MultiAZ]
      BackupRetentionPeriod: !FindInMap [EnvironmentMap, !Ref Environment, BackupRetention]
```

### パターン2: Conditions

```yaml
Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, stg, prod]

Conditions:
  IsProduction: !Equals [!Ref Environment, prod]
  IsStaging: !Equals [!Ref Environment, stg]
  IsProdOrStg: !Or
    - !Condition IsProduction
    - !Condition IsStaging
  IsNotProduction: !Not [!Condition IsProduction]

Resources:
  # 本番のみ作成
  ReadReplica:
    Type: AWS::RDS::DBInstance
    Condition: IsProduction
    Properties:
      SourceDBInstanceIdentifier: !Ref PrimaryDB
  
  # 本番のみMulti-AZ
  PrimaryDB:
    Type: AWS::RDS::DBInstance
    Properties:
      MultiAZ: !If [IsProduction, true, false]
  
  # 本番・ステージングのみNAT Gateway
  NATGateway:
    Type: AWS::EC2::NatGateway
    Condition: IsProdOrStg
    Properties:
      SubnetId: !Ref PublicSubnet
      AllocationId: !GetAtt EIP.AllocationId
```

---

## 🌐 StackSets（マルチアカウント・マルチリージョン）

### StackSet作成

```bash
# StackSet作成
aws cloudformation create-stack-set \
  --stack-set-name security-baseline \
  --template-body file://security-baseline.yaml \
  --parameters ParameterKey=EnableCloudTrail,ParameterValue=true \
  --capabilities CAPABILITY_IAM \
  --permission-model SERVICE_MANAGED \
  --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=false
```

### スタックインスタンス作成

```bash
# 特定のアカウント・リージョンにデプロイ
aws cloudformation create-stack-instances \
  --stack-set-name security-baseline \
  --accounts 123456789012 234567890123 \
  --regions us-east-1 ap-northeast-1 \
  --operation-preferences \
      FailureToleranceCount=1,\
      MaxConcurrentCount=5
```

### Organizations統合

```bash
# 組織単位（OU）全体にデプロイ
aws cloudformation create-stack-instances \
  --stack-set-name security-baseline \
  --deployment-targets OrganizationalUnitIds=ou-xxxx-yyyyyyyy \
  --regions us-east-1 ap-northeast-1 eu-west-1
```

**ユースケース**:
- セキュリティベースライン（CloudTrail, Config）
- IAMロール・ポリシー統一
- ログ集約設定
- ガバナンス設定

---

## 🔐 高度な組み込み関数

### `!Split` - 文字列分割

```yaml
Parameters:
  CidrList:
    Type: String
    Default: "10.0.1.0/24,10.0.2.0/24,10.0.3.0/24"

Resources:
  Subnet1:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock: !Select [0, !Split [',', !Ref CidrList]]
      # 結果: 10.0.1.0/24
```

### `!Cidr` - CIDR自動分割

```yaml
Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16

  Subnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: !Select [0, !Cidr [!GetAtt VPC.CidrBlock, 4, 8]]
      # 結果: 10.0.0.0/24
  
  Subnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: !Select [1, !Cidr [!GetAtt VPC.CidrBlock, 4, 8]]
      # 結果: 10.0.1.0/24
```

### Dynamic References - Secrets Manager

```yaml
Resources:
  MyRDS:
    Type: AWS::RDS::DBInstance
    Properties:
      MasterUsername: admin
      MasterUserPassword: !Sub '{{resolve:secretsmanager:${DBPasswordSecret}:SecretString:password}}'
      # Secrets Managerから動的に取得
```

### Dynamic References - SSM Parameter Store

```yaml
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !Sub '{{resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64}}'
      # SSM Parameter Storeから最新AMI取得
```

---

## 🛡️ DeletionPolicy & UpdateReplacePolicy

### DeletionPolicy

```yaml
Resources:
  # スタック削除時にスナップショット作成
  MyRDS:
    Type: AWS::RDS::DBInstance
    DeletionPolicy: Snapshot
    Properties:
      # ...
  
  # スタック削除してもリソース保持
  MyS3Bucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain
    Properties:
      # ...
  
  # スタック削除時にリソースも削除（デフォルト）
  MyEC2:
    Type: AWS::EC2::Instance
    DeletionPolicy: Delete
    Properties:
      # ...
```

**オプション**:
- `Delete`: 削除（デフォルト）
- `Retain`: 保持
- `Snapshot`: スナップショット作成（RDS, EBS等）

### UpdateReplacePolicy

```yaml
Resources:
  MyRDS:
    Type: AWS::RDS::DBInstance
    UpdateReplacePolicy: Snapshot    # 更新時の置換でスナップショット
    DeletionPolicy: Snapshot         # 削除時もスナップショット
    Properties:
      # ...
```

---

## 🎭 CreationPolicy & UpdatePolicy

### CreationPolicy - リソース作成完了を待つ

```yaml
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    CreationPolicy:
      ResourceSignal:
        Count: 1
        Timeout: PT15M    # 15分待つ
    Properties:
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          
          # 成功シグナル送信
          /opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} \
            --resource MyEC2 --region ${AWS::Region}
```

### UpdatePolicy - Auto Scaling更新

```yaml
Resources:
  MyASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    UpdatePolicy:
      AutoScalingRollingUpdate:
        MinInstancesInService: 2
        MaxBatchSize: 2
        PauseTime: PT5M
        WaitOnResourceSignals: true
    Properties:
      # ...
```

---

## 🔗 高度なスタック間連携

### クロススタック参照（Export/ImportValue）

**ネットワークスタック**:
```yaml
Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: !Sub '${AWS::StackName}-VpcId'
  
  PrivateSubnetIds:
    Value: !Join [',', [!Ref PrivateSubnet1, !Ref PrivateSubnet2]]
    Export:
      Name: !Sub '${AWS::StackName}-PrivateSubnetIds'
```

**アプリケーションスタック**:
```yaml
Resources:
  MyLambda:
    Type: AWS::Lambda::Function
    Properties:
      VpcConfig:
        SubnetIds: !Split [',', !ImportValue NetworkStack-PrivateSubnetIds]
        SecurityGroupIds:
          - !Ref LambdaSecurityGroup
```

### ネストスタックとの違い

| 項目 | ネストスタック | クロススタック参照 |
|------|---------------|-------------------|
| **関係** | 親子関係 | 独立 |
| **削除** | 親削除で子も削除 | 独立して削除可能 |
| **デプロイ** | 親経由でデプロイ | 個別にデプロイ |
| **用途** | モジュール分割 | 環境間共有 |

---

## 🚀 CI/CD統合

### GitHub Actions例

```yaml
name: Deploy CloudFormation

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-1
      
      - name: Lint CloudFormation
        run: |
          pip install cfn-lint
          cfn-lint template.yaml
      
      - name: Security Scan
        run: |
          pip install checkov
          checkov -f template.yaml
      
      - name: Deploy Stack
        run: |
          aws cloudformation deploy \
            --template-file template.yaml \
            --stack-name my-stack \
            --parameter-overrides Environment=prod \
            --capabilities CAPABILITY_IAM \
            --no-fail-on-empty-changeset
```

---

## 📊 Macros & Transform

### Macro定義（Lambda）

```python
def lambda_handler(event, context):
    fragment = event['fragment']
    status = 'success'
    
    # テンプレート変換処理
    # 例: 特定パターンを展開
    
    return {
        'requestId': event['requestId'],
        'status': status,
        'fragment': fragment
    }
```

### テンプレートで使用

```yaml
Transform: AWS::Serverless-2016-10-31    # SAM Transform

# またはカスタムMacro
Transform: MyCustomMacro

Resources:
  # ...
```

---

## ✅ 中級チェックリスト

### 設計スキル
- [ ] ネストスタックで大規模テンプレートを分割できる
- [ ] マルチ環境対応テンプレートを設計できる
- [ ] スタック間の依存関係を設計できる

### 運用スキル
- [ ] 変更セットで安全な更新ができる
- [ ] ドリフト検出・修正ができる
- [ ] DeletionPolicy, UpdatePolicy を適切に設定できる

### 高度な機能
- [ ] カスタムリソースでLambda連携できる
- [ ] Dynamic References でSecrets Manager参照できる
- [ ] StackSets でマルチアカウントデプロイできる

### CI/CD
- [ ] GitHub Actions / CodePipeline に統合できる
- [ ] cfn-lint, Checkov でテストできる

---

## 🚨 中級者が陥りやすい罠

### 1. Export削除不可エラー

**問題**: Exportを参照しているスタックがあると削除できない

**対処**:
```bash
# 参照元を確認
aws cloudformation list-imports --export-name MyExport

# 参照元を先に削除
aws cloudformation delete-stack --stack-name dependent-stack
```

### 2. ネストスタックのテンプレートURL更新

**問題**: S3のテンプレートを更新しても反映されない

**対処**: S3オブジェクトのバージョニング有効化、またはURL変更

### 3. 循環依存エラー

**問題**: スタック間で相互参照している

**対処**: 依存関係を整理、共有リソースを別スタックに分離

### 4. ChangSet作成後の長時間放置

**問題**: ChangeSetは30日後に自動削除

**対処**: 作成後すぐに確認・実行

---

## 📚 次のステップ

### 中級編完了後

1. ✅ 実際のプロジェクトで実践
2. ✅ AWS Certified DevOps Engineer - Professional 取得
3. ✅ Terraform との使い分け検討
4. ✅ Infrastructure Testingの導入

---

**この中級チートシートで、実務レベルのCloudFormationスキルを習得しましょう！🚀**
