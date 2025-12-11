# 高度なテクニック集

CloudFormation上級者のための実践テクニック

---

## 1. Dynamic References（動的参照）

実行時に外部から値を取得。

### 1.1 Secrets Manager参照

```yaml
Resources:
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      MasterUsername: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:username}}'
      MasterUserPassword: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:password}}'
```

### 1.2 SSM Parameter Store参照

```yaml
# Secure String参照
Resources:
  Instance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !Sub '{{resolve:ssm-secure:my-ami-id:1}}'  # バージョン指定

# 通常のParameter参照
Parameters:
  LatestAMI:
    Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>
    Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2
```

**メリット**:
- 機密情報をテンプレートに含めない
- 値の一元管理
- 環境間での値の共有

---

## 2. Macros & Transform

### 2.1 AWS::Serverless Transform（SAM）

```yaml
Transform: AWS::Serverless-2016-10-31

Resources:
  # 簡略化されたLambda定義
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Runtime: python3.11
      Handler: index.handler
      InlineCode: |
        def handler(event, context):
            return {'statusCode': 200}
      Events:
        ApiEvent:
          Type: Api
          Properties:
            Path: /hello
            Method: get
```

**通常のCloudFormationとの違い**:
- `AWS::Serverless::Function` → `AWS::Lambda::Function` + IAM Role + API Gateway を自動作成
- `Events` セクションでトリガー定義

### 2.2 AWS::Include Transform

外部ファイルをインクルード。

```yaml
Transform: AWS::Include
Parameters:
  Location: s3://my-bucket/common-resources.yaml

Resources:
  # common-resources.yaml の内容がここに展開される
```

### 2.3 カスタムマクロ

```yaml
# マクロ定義（Lambda）
Resources:
  MacroFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: my-macro
      Runtime: python3.11
      Handler: index.handler
      Code:
        ZipFile: |
          def handler(event, context):
              # テンプレート変換ロジック
              fragment = event['fragment']
              # ... 変換処理 ...
              return {
                  'requestId': event['requestId'],
                  'status': 'success',
                  'fragment': fragment
              }
      Role: !GetAtt MacroRole.Arn

  Macro:
    Type: AWS::CloudFormation::Macro
    Properties:
      Name: MyCustomMacro
      FunctionName: !GetAtt MacroFunction.Arn

# 使用
Transform: MyCustomMacro
```

---

## 3. CreationPolicy & UpdatePolicy

### 3.1 CreationPolicy（リソース作成完了シグナル）

```yaml
Resources:
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    CreationPolicy:
      ResourceSignal:
        Count: 2  # 2台のシグナル待ち
        Timeout: PT10M  # 10分でタイムアウト
    Properties:
      MinSize: 2
      MaxSize: 4
      LaunchTemplate:
        LaunchTemplateId: !Ref LaunchTemplate
        Version: !GetAtt LaunchTemplate.LatestVersionNumber

  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateData:
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            
            # シグナル送信（起動完了）
            /opt/aws/bin/cfn-signal -e $? \
              --stack ${AWS::StackName} \
              --resource AutoScalingGroup \
              --region ${AWS::Region}
```

### 3.2 UpdatePolicy（Auto Scaling更新制御）

```yaml
Resources:
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    UpdatePolicy:
      AutoScalingRollingUpdate:
        MinInstancesInService: 1  # 最低1台は稼働維持
        MaxBatchSize: 2           # 2台ずつ更新
        PauseTime: PT5M           # 5分待機
        WaitOnResourceSignals: true
        SuspendProcesses:
          - HealthCheck
          - ReplaceUnhealthy
          - AZRebalance
          - AlarmNotification
          - ScheduledActions
```

**ローリングアップデートの流れ**:
```
1. 新しいインスタンス2台起動
2. ヘルスチェック完了待機
3. 古いインスタンス2台削除
4. 次の2台... （繰り返し）
```

---

## 4. Metadata セクション活用

### 4.1 AWS::CloudFormation::Interface

パラメータをグループ化、UIを改善。

```yaml
Metadata:
  AWS::CloudFormation::Interface:
    ParameterGroups:
      - Label:
          default: 'Network Configuration'
        Parameters:
          - VpcCIDR
          - PublicSubnetCIDR
          - PrivateSubnetCIDR
      - Label:
          default: 'EC2 Configuration'
        Parameters:
          - InstanceType
          - KeyPairName
      - Label:
          default: 'Database Configuration'
        Parameters:
          - DBInstanceClass
          - DBPassword
    
    ParameterLabels:
      VpcCIDR:
        default: 'VPC CIDR Block'
      InstanceType:
        default: 'EC2 Instance Type'
```

**効果**: AWSコンソールでのパラメータ入力が見やすくなる

### 4.2 AWS::CloudFormation::Init（cfn-init）

EC2の初期設定を宣言的に定義。

```yaml
Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Metadata:
      AWS::CloudFormation::Init:
        config:
          packages:
            yum:
              httpd: []
              php: []
          
          files:
            /var/www/html/index.html:
              content: |
                <html>
                  <body><h1>Hello CloudFormation!</h1></body>
                </html>
              mode: '000644'
              owner: apache
              group: apache
            
            /etc/cfn/cfn-hup.conf:
              content: !Sub |
                [main]
                stack=${AWS::StackId}
                region=${AWS::Region}
              mode: '000400'
              owner: root
              group: root
          
          services:
            sysvinit:
              httpd:
                enabled: true
                ensureRunning: true
    
    Properties:
      ImageId: ami-xxxxx
      InstanceType: t3.small
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash -xe
          yum install -y aws-cfn-bootstrap
          
          # cfn-init実行
          /opt/aws/bin/cfn-init -v \
            --stack ${AWS::StackName} \
            --resource WebServer \
            --region ${AWS::Region}
          
          # シグナル送信
          /opt/aws/bin/cfn-signal -e $? \
            --stack ${AWS::StackName} \
            --resource WebServer \
            --region ${AWS::Region}
    
    CreationPolicy:
      ResourceSignal:
        Timeout: PT10M
```

---

## 5. Cross-Stack References（スタック間参照）

### 5.1 Export / ImportValue

**スタックA（Export）**:
```yaml
Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: NetworkStack-VpcId
  
  PrivateSubnetIds:
    Value: !Join [',', [!Ref PrivateSubnet1, !Ref PrivateSubnet2]]
    Export:
      Name: NetworkStack-PrivateSubnetIds
```

**スタックB（Import）**:
```yaml
Resources:
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      VPCSecurityGroups:
        - !Ref DBSecurityGroup
      DBSubnetGroupName: !Ref DBSubnetGroup

  DBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      VpcId: !ImportValue NetworkStack-VpcId

  DBSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      SubnetIds: !Split [',', !ImportValue NetworkStack-PrivateSubnetIds]
```

**注意点**:
- Export名はリージョン内で一意
- Export使用中のスタックは削除不可
- Export名の変更は影響が大きい

---

## 6. DeletionPolicy & UpdateReplacePolicy

### 6.1 使い分け

```yaml
Resources:
  # 本番データベース: 削除時・置換時ともにスナップショット
  ProductionDB:
    Type: AWS::RDS::DBInstance
    DeletionPolicy: Snapshot
    UpdateReplacePolicy: Snapshot
    Properties:
      Engine: mysql
  
  # ログバケット: 削除時は保持、置換時は削除
  LogBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain
    UpdateReplacePolicy: Delete
  
  # 一時データ: 削除・置換ともに削除
  TempBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Delete
    UpdateReplacePolicy: Delete
```

### 6.2 スナップショット戦略

```yaml
Resources:
  Database:
    Type: AWS::RDS::DBInstance
    DeletionPolicy: Snapshot
    UpdateReplacePolicy: Snapshot
    Properties:
      FinalDBSnapshotIdentifier: !Sub '${AWS::StackName}-final-snapshot-${AWS::AccountId}'
      DeleteAutomatedBackups: false
```

---

## 7. Nested Stacks vs StackSets

| 項目 | Nested Stacks | StackSets |
|------|--------------|-----------|
| **用途** | 1アカウント内の分割 | マルチアカウント展開 |
| **親子関係** | あり（親削除→子も削除） | なし（独立） |
| **更新** | 親スタック更新で連動 | 個別更新または一括更新 |
| **リージョン** | 1リージョン | マルチリージョン対応 |

**使い分け**:
- 1アカウント内の大規模構成 → **Nested Stacks**
- 複数アカウント・リージョン → **StackSets**

---

## 8. Service Catalog統合

再利用可能な製品としてテンプレートを配布。

```yaml
# product.yaml（Service Catalog製品）
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Service Catalog Product - WordPress'

Parameters:
  InstanceType:
    Type: String
    AllowedValues: [t3.small, t3.medium]

Resources:
  # ... WordPress構成 ...

# ユーザーはパラメータのみ入力、テンプレートは隠蔽
```

**メリット**:
- 標準構成の配布
- ガバナンス強化
- 非技術者でもデプロイ可能

---

## 9. CloudFormation Registry

サードパーティリソースタイプを使用。

```yaml
# Datadog統合例
Resources:
  DatadogIntegration:
    Type: Datadog::Integrations::AWS
    Properties:
      AccountID: !Ref 'AWS::AccountId'
      RoleName: DatadogIntegrationRole
```

---

## 10. Termination Protection

誤削除防止。

```bash
# 削除保護を有効化
aws cloudformation update-termination-protection \
  --stack-name prod-stack \
  --enable-termination-protection

# 削除保護を解除
aws cloudformation update-termination-protection \
  --stack-name prod-stack \
  --no-enable-termination-protection
```

---

## 💡 上級テクニック

### テクニック1: 条件付きリソース置換回避

```yaml
# AMI変更時に置換を回避（ignore_changes相当）
Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !Ref LatestAMI
      # ignore_changes的な動作は不可
      # → Launch Templateで対応
```

### テクニック2: 複雑な条件分岐

```yaml
Conditions:
  # 本番 かつ 東京リージョン
  IsProdTokyo: !And
    - !Equals [!Ref Environment, prod]
    - !Equals [!Ref 'AWS::Region', ap-northeast-1]
  
  # 開発 または ステージング
  IsDevOrStg: !Or
    - !Equals [!Ref Environment, dev]
    - !Equals [!Ref Environment, stg]
  
  # 本番 かつ (東京 または バージニア)
  IsProdMultiRegion: !And
    - !Equals [!Ref Environment, prod]
    - !Or
      - !Equals [!Ref 'AWS::Region', ap-northeast-1]
      - !Equals [!Ref 'AWS::Region', us-east-1]
```

### テクニック3: Sub関数の高度な使用

```yaml
# 複数行 + 条件分岐
UserData:
  Fn::Base64: !Sub
    - |
      #!/bin/bash
      export ENVIRONMENT=${Env}
      export DATABASE_HOST=${DBHost}
      export REDIS_HOST=${RedisHost}
      
      if [ "${Env}" == "prod" ]; then
        export LOG_LEVEL=ERROR
      else
        export LOG_LEVEL=DEBUG
      fi
    - Env: !Ref Environment
      DBHost: !GetAtt Database.Endpoint.Address
      RedisHost: !If [CreateRedis, !GetAtt Redis.PrimaryEndPoint.Address, 'none']
```

---

## 💰 コスト最適化の高度なテクニック

### テクニック1: 環境別リソースサイズ

```yaml
Mappings:
  CostOptimization:
    dev:
      NATGateways: 1  # 1台で$35削減
      RDSMultiAZ: false
      RDSInstanceClass: db.t3.small
      EC2InstanceType: t3.small
      AutoScalingMin: 0  # 夜間停止可能
    prod:
      NATGateways: 2
      RDSMultiAZ: true
      RDSInstanceClass: db.r6i.xlarge
      EC2InstanceType: m5.large
      AutoScalingMin: 2

Resources:
  NATGateway1:
    Type: AWS::EC2::NatGateway
    Properties:
      # ...
  
  NATGateway2:
    Type: AWS::EC2::NatGateway
    Condition: CreateSecondNAT
    Properties:
      # ...

Conditions:
  CreateSecondNAT: !Equals
    - !FindInMap [CostOptimization, !Ref Environment, NATGateways]
    - 2
```

### テクニック2: Spot Instances

```yaml
Resources:
  SpotFleet:
    Type: AWS::EC2::SpotFleet
    Condition: IsDevelopment
    Properties:
      SpotFleetRequestConfigData:
        IamFleetRole: !GetAtt SpotFleetRole.Arn
        TargetCapacity: 2
        AllocationStrategy: lowestPrice
        LaunchSpecifications:
          - InstanceType: t3.small
            ImageId: ami-xxxxx
            SpotPrice: '0.01'  # 最大スポット価格
```

---

## 🔒 高度なセキュリティパターン

### パターン1: Secrets Rotation

```yaml
Resources:
  DBSecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      GenerateSecretString:
        SecretStringTemplate: '{"username": "admin"}'
        GenerateStringKey: password
        PasswordLength: 32

  SecretRotation:
    Type: AWS::SecretsManager::RotationSchedule
    Properties:
      SecretId: !Ref DBSecret
      RotationLambdaARN: !GetAtt RotationLambda.Arn
      RotationRules:
        AutomaticallyAfterDays: 30
```

### パターン2: KMS Key Policy

```yaml
Resources:
  EncryptionKey:
    Type: AWS::KMS::Key
    Properties:
      KeyPolicy:
        Version: '2012-10-17'
        Statement:
          - Sid: Enable IAM User Permissions
            Effect: Allow
            Principal:
              AWS: !Sub 'arn:aws:iam::${AWS::AccountId}:root'
            Action: 'kms:*'
            Resource: '*'
          - Sid: Allow use of the key by RDS
            Effect: Allow
            Principal:
              Service: rds.amazonaws.com
            Action:
              - 'kms:Decrypt'
              - 'kms:GenerateDataKey'
            Resource: '*'
```

---

## 📊 監視・ロギングの高度なパターン

### パターン1: CloudWatch Dashboard自動生成

```yaml
Resources:
  Dashboard:
    Type: AWS::CloudWatch::Dashboard
    Properties:
      DashboardName: !Sub '${AWS::StackName}-dashboard'
      DashboardBody: !Sub |
        {
          "widgets": [
            {
              "type": "metric",
              "properties": {
                "metrics": [
                  ["AWS/EC2", "CPUUtilization", {"stat": "Average"}]
                ],
                "period": 300,
                "stat": "Average",
                "region": "${AWS::Region}",
                "title": "EC2 CPU"
              }
            }
          ]
        }
```

---

## 🎓 学習リソース

- [CloudFormation高度な機能](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/template-anatomy.html)
- [AWS::Include Transform](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/create-reusable-transform-function-snippets-and-add-to-your-template-with-aws-include-transform.html)

---

**高度なテクニックで、CloudFormationを使いこなす！🚀**
