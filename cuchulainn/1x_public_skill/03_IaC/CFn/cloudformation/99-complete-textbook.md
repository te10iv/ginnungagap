# CloudFormation 完全教科書

CloudFormation中級者向けの包括的ガイド

---

## 📖 目次

1. [CloudFormation基礎](#1-cloudformation基礎)
2. [テンプレート構文](#2-テンプレート構文)
3. [組み込み関数](#3-組み込み関数)
4. [リソース管理](#4-リソース管理)
5. [スタック操作](#5-スタック操作)
6. [高度なパターン](#6-高度なパターン)
7. [ベストプラクティス](#7-ベストプラクティス)
8. [セキュリティ](#8-セキュリティ)
9. [パフォーマンス最適化](#9-パフォーマンス最適化)
10. [トラブルシューティング](#10-トラブルシューティング)

---

## 1. CloudFormation基礎

### 1.1 CloudFormationとは

Infrastructure as Code (IaC) を実現するAWSのサービス。JSONまたはYAML形式のテンプレートで、AWSリソースを宣言的に定義・管理。

**主な特徴**:
- 宣言的記述（What、Howではない）
- 変更の追跡とロールバック
- スタック単位での管理
- ドリフト検出
- 変更セット（プレビュー機能）

### 1.2 主要概念

| 用語 | 説明 |
|------|------|
| **テンプレート** | リソース定義を記述したファイル（YAML/JSON） |
| **スタック** | テンプレートから作成されたリソースの集合 |
| **変更セット** | 更新前の変更内容プレビュー |
| **ドリフト** | テンプレートと実際のリソース状態の差異 |
| **疑似パラメータ** | AWS::Region等の組み込み変数 |

### 1.3 CloudFormation vs 他のIaCツール

| 項目 | CloudFormation | Terraform | Ansible |
|------|---------------|-----------|---------|
| **対応クラウド** | AWS専用 | マルチクラウド | 構成管理中心 |
| **状態管理** | AWS管理 | State file | 冪等性で管理 |
| **記法** | JSON/YAML | HCL | YAML |
| **ドリフト検出** | ✅ | 手動 | ❌ |
| **プレビュー** | 変更セット | plan | --check |
| **料金** | 無料 | 無料（Enterprise有料） | 無料 |

---

## 2. テンプレート構文

### 2.1 テンプレート構造

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Description: 'テンプレートの説明（オプション）'

Metadata:
  AWS::CloudFormation::Interface:
    ParameterGroups:
      - Label:
          default: 'Network Configuration'
        Parameters:
          - VpcCIDR

Parameters:
  VpcCIDR:
    Type: String
    Default: 10.0.0.0/16

Mappings:
  RegionMap:
    ap-northeast-1:
      AMI: ami-xxxxx

Conditions:
  IsProduction: !Equals [!Ref Environment, prod]

Transform:
  - AWS::Serverless-2016-10-31

Resources:
  MyBucket:
    Type: AWS::S3::Bucket

Outputs:
  BucketName:
    Value: !Ref MyBucket
```

### 2.2 Parameters（パラメータ）

**パラメータタイプ**:

```yaml
Parameters:
  # 文字列
  StringParam:
    Type: String
    Default: value
    AllowedValues: [dev, stg, prod]
    AllowedPattern: '^[a-zA-Z0-9]*$'
    MinLength: 1
    MaxLength: 64
    ConstraintDescription: 'Must be alphanumeric'
  
  # 数値
  NumberParam:
    Type: Number
    Default: 3
    MinValue: 1
    MaxValue: 10
  
  # リスト
  CommaDelimitedListParam:
    Type: CommaDelimitedList
    Default: 'val1,val2,val3'
  
  # AWS固有の型
  VpcIdParam:
    Type: AWS::EC2::VPC::Id
  
  SubnetIdsParam:
    Type: List<AWS::EC2::Subnet::Id>
  
  KeyPairParam:
    Type: AWS::EC2::KeyPair::KeyName
  
  # SSM Parameter Store参照
  LatestAMI:
    Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>
    Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2
```

### 2.3 Mappings（マッピング）

```yaml
Mappings:
  # リージョン別AMI
  RegionMap:
    ap-northeast-1:
      AMI: ami-0c3fd0f5d33134a76
      InstanceType: t3.small
    us-east-1:
      AMI: ami-0c55b159cbfafe1f0
      InstanceType: t3.medium
  
  # 環境別設定
  EnvironmentConfig:
    dev:
      InstanceType: t3.small
      MinSize: 1
      BackupRetention: 7
    prod:
      InstanceType: m5.large
      MinSize: 2
      BackupRetention: 30

# 使用例
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', AMI]
      InstanceType: !FindInMap [EnvironmentConfig, !Ref Environment, InstanceType]
```

### 2.4 Conditions（条件）

```yaml
Conditions:
  # 等価条件
  IsProduction: !Equals [!Ref Environment, prod]
  
  # 否定
  IsNotProduction: !Not [!Equals [!Ref Environment, prod]]
  
  # AND条件
  CreateProdResources: !And
    - !Equals [!Ref Environment, prod]
    - !Equals [!Ref Region, ap-northeast-1]
  
  # OR条件
  CreateDevOrStg: !Or
    - !Equals [!Ref Environment, dev]
    - !Equals [!Ref Environment, stg]
  
  # リソース存在確認
  HasKeyPair: !Not [!Equals [!Ref KeyPairName, '']]

# 使用例
Resources:
  # Conditionでリソース作成を制御
  NATGateway:
    Type: AWS::EC2::NatGateway
    Condition: IsProduction
  
  # プロパティ値を条件分岐
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      MultiAZ: !If [IsProduction, true, false]
      BackupRetentionPeriod: !If [IsProduction, 30, 7]
```

---

## 3. 組み込み関数

### 3.1 参照関数

```yaml
# Ref - リソースID/パラメータ値を取得
!Ref MyBucket           # バケット名
!Ref InstanceType       # パラメータ値

# GetAtt - リソース属性を取得
!GetAtt MyBucket.Arn               # ARN取得
!GetAtt MyInstance.PrivateIp       # Private IP
!GetAtt LoadBalancer.DNSName       # ALBのDNS名
```

### 3.2 文字列操作

```yaml
# Sub - 変数展開
!Sub '${ProjectName}-${Environment}-bucket'
!Sub 'arn:aws:s3:::${BucketName}/*'

# 複数行の場合
!Sub |
  #!/bin/bash
  echo "Project: ${ProjectName}"
  echo "Region: ${AWS::Region}"

# Join - 結合
!Join
  - '-'
  - [!Ref ProjectName, !Ref Environment, 'web']
# → "myproject-dev-web"

# Split - 分割
!Split [',', 'a,b,c']  # → ['a', 'b', 'c']
```

### 3.3 リスト・選択

```yaml
# Select - リスト要素選択
!Select [0, !GetAZs '']  # 最初のAZ
!Select [1, ['a', 'b', 'c']]  # 'b'

# GetAZs - AZ一覧取得
!GetAZs ''                    # 現在のリージョン
!GetAZs 'us-east-1'          # 指定リージョン
```

### 3.4 検索

```yaml
# FindInMap - マッピング検索
!FindInMap [MapName, TopLevelKey, SecondLevelKey]

# 例
!FindInMap [RegionMap, !Ref 'AWS::Region', AMI]
```

### 3.5 変換

```yaml
# Base64 - Base64エンコード
UserData:
  Fn::Base64: !Sub |
    #!/bin/bash
    echo "Hello ${ProjectName}"

# ImportValue - 他スタックの出力値
!ImportValue OtherStack-VpcId
```

### 3.6 条件関数

```yaml
# If - 三項演算子
!If [IsProduction, m5.large, t3.small]

# Equals - 等価比較
!Equals [!Ref Env, prod]

# Not - 否定
!Not [!Equals [!Ref Env, dev]]

# And - AND条件
!And [条件1, 条件2, 条件3]

# Or - OR条件
!Or [条件1, 条件2]
```

---

## 4. リソース管理

### 4.1 リソース定義

```yaml
Resources:
  LogicalResourceId:  # テンプレート内での識別子
    Type: AWS::Service::Resource
    Properties:
      Property1: Value1
      Property2: Value2
    Metadata:
      Key: Value
    DependsOn: OtherResource
    DeletionPolicy: Retain
    UpdateReplacePolicy: Snapshot
    Condition: CreateInProduction
```

### 4.2 DeletionPolicy

```yaml
Resources:
  # Retain - スタック削除時もリソースを保持
  CriticalData:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain
  
  # Snapshot - 削除前にスナップショット作成
  Database:
    Type: AWS::RDS::DBInstance
    DeletionPolicy: Snapshot
  
  # Delete - 削除（デフォルト）
  TempBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Delete
```

### 4.3 UpdateReplacePolicy

```yaml
Resources:
  Database:
    Type: AWS::RDS::DBInstance
    UpdateReplacePolicy: Snapshot  # 更新で置換される場合、スナップショット作成
    DeletionPolicy: Snapshot
```

### 4.4 DependsOn

```yaml
Resources:
  VPC:
    Type: AWS::EC2::VPC
  
  InternetGateway:
    Type: AWS::EC2::InternetGateway
  
  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway
  
  # IGWアタッチ後に作成
  PublicRoute:
    Type: AWS::EC2::Route
    DependsOn: AttachGateway
    Properties:
      RouteTableId: !Ref RouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway
```

---

## 5. スタック操作

### 5.1 スタック作成

```bash
# 基本
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml

# パラメータ指定
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters \
    ParameterKey=Environment,ParameterValue=dev \
    ParameterKey=InstanceType,ParameterValue=t3.small

# パラメータファイル使用
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters file://params.json

# IAMリソース作成
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_NAMED_IAM

# タグ指定
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --tags Key=Environment,Value=dev Key=Project,Value=myapp
```

### 5.2 スタック更新

```bash
# 基本更新
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml

# パラメータのみ更新（テンプレートは変更なし）
aws cloudformation update-stack \
  --stack-name my-stack \
  --use-previous-template \
  --parameters ParameterKey=InstanceType,ParameterValue=t3.medium

# 前の値を使用
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters ParameterKey=Param1,UsePreviousValue=true
```

### 5.3 変更セット

```bash
# 変更セット作成
aws cloudformation create-change-set \
  --stack-name my-stack \
  --change-set-name my-changes \
  --template-body file://template.yaml

# 変更セット確認
aws cloudformation describe-change-set \
  --stack-name my-stack \
  --change-set-name my-changes

# 変更セット実行
aws cloudformation execute-change-set \
  --stack-name my-stack \
  --change-set-name my-changes

# 変更セット削除（実行しない場合）
aws cloudformation delete-change-set \
  --stack-name my-stack \
  --change-set-name my-changes
```

### 5.4 スタック削除

```bash
# 基本削除
aws cloudformation delete-stack --stack-name my-stack

# 削除完了待機
aws cloudformation wait stack-delete-complete --stack-name my-stack

# 特定リソースを保持して削除
aws cloudformation delete-stack \
  --stack-name my-stack \
  --retain-resources MyImportantResource
```

---

## 6. 高度なパターン

### 6.1 ネストスタック

親スタックから子スタックを呼び出し、テンプレートを分割。

```yaml
# 親スタック
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/network.yaml
      Parameters:
        VpcCIDR: 10.0.0.0/16
      TimeoutInMinutes: 10

Outputs:
  VpcId:
    Value: !GetAtt NetworkStack.Outputs.VpcId
```

### 6.2 StackSets

複数アカウント・リージョンに一括デプロイ。

```bash
# StackSet作成
aws cloudformation create-stack-set \
  --stack-set-name my-stackset \
  --template-body file://template.yaml

# スタックインスタンス作成
aws cloudformation create-stack-instances \
  --stack-set-name my-stackset \
  --accounts 123456789012 234567890123 \
  --regions ap-northeast-1 us-east-1
```

### 6.3 カスタムリソース

Lambda関数で独自のリソースロジックを実装。

```yaml
Resources:
  CustomResourceFunction:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: python3.11
      Handler: index.lambda_handler
      Code:
        ZipFile: |
          import cfnresponse
          def lambda_handler(event, context):
              cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
  
  MyCustomResource:
    Type: Custom::MyResource
    Properties:
      ServiceToken: !GetAtt CustomResourceFunction.Arn
```

---

## 7. ベストプラクティス

### 7.1 テンプレート設計

✅ **DO**:
- Parameters で環境変数を定義
- Mappings で環境別設定を管理
- Outputs で重要な値をエクスポート
- Tags をすべてのリソースに付与
- DeletionPolicy で重要データを保護

❌ **DON'T**:
- ハードコード（リージョン、アカウントID等）
- 巨大な単一テンプレート（200リソース超）
- リソース名の直接指定（自動生成推奨）

### 7.2 運用

✅ **DO**:
- 本番環境では変更セット必須
- 定期的なドリフト検出
- cfn-lint でバリデーション
- Git管理
- CI/CD統合

❌ **DON'T**:
- 手動でのリソース変更
- 変更セットなしの本番更新
- Secrets/Password のハードコード

---

## 8. セキュリティ

### 8.1 IAM Role

```yaml
Resources:
  MyRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
      Policies:
        - PolicyName: S3Access
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action: s3:GetObject
                Resource: !Sub 'arn:aws:s3:::${BucketName}/*'
```

### 8.2 Secrets管理

```yaml
# Secrets Manager
Resources:
  DBPassword:
    Type: AWS::SecretsManager::Secret
    Properties:
      GenerateSecretString:
        SecretStringTemplate: '{"username": "admin"}'
        GenerateStringKey: 'password'
        PasswordLength: 32
        ExcludeCharacters: '"@/\'
  
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      MasterUsername: !Sub '{{resolve:secretsmanager:${DBPassword}:SecretString:username}}'
      MasterUserPassword: !Sub '{{resolve:secretsmanager:${DBPassword}:SecretString:password}}'
```

---

## 9. パフォーマンス最適化

### 9.1 並列作成

DependsOnを最小限にし、並列作成を促進。

### 9.2 テンプレート分割

大規模構成はネストスタックで分割。

### 9.3 キャッシュ活用

UsePreviousValueでパラメータキャッシュ。

---

## 10. トラブルシューティング

詳細は `07-troubleshooting.md` を参照。

---

## 📚 まとめ

このCloud Formation教科書で、以下が身につきます：

- ✅ CloudFormationの基礎から高度な機能まで
- ✅ 実践的なパターンとベストプラクティス
- ✅ マルチ環境管理とCI/CD統合
- ✅ セキュリティとトラブルシューティング

**これでCloudFormation中級者！🚀**
