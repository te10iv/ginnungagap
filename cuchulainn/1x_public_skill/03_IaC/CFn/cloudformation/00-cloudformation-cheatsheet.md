# CloudFormation チートシート（1枚紙）

これだけ見ればCloudFormation中級者！

---

## 📋 CloudFormationとは

AWS リソースをコード（テンプレート）で定義・管理するIaCサービス。JSONまたはYAML形式で記述。

**メリット**:
- インフラのバージョン管理
- 環境の再現性
- 自動化・効率化
- ドリフト検出

---

## 🏗️ 基本構造

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'テンプレートの説明'

# パラメータ（入力値）
Parameters:
  EnvironmentName:
    Type: String
    Default: dev
    AllowedValues: [dev, stg, prod]

# 条件分岐
Conditions:
  IsProduction: !Equals [!Ref EnvironmentName, prod]

# リソース定義（必須）
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${EnvironmentName}-my-bucket'
      VersioningConfiguration:
        Status: Enabled

# 出力値
Outputs:
  BucketName:
    Value: !Ref MyBucket
    Export:
      Name: !Sub '${AWS::StackName}-BucketName'
```

---

## 🔧 主要セクション

| セクション | 必須 | 説明 |
|-----------|------|------|
| **AWSTemplateFormatVersion** | - | テンプレートバージョン |
| **Description** | - | テンプレート説明 |
| **Parameters** | - | 入力パラメータ定義 |
| **Mappings** | - | キー・バリューマップ |
| **Conditions** | - | 条件定義 |
| **Resources** | ✅ | リソース定義（必須） |
| **Outputs** | - | 出力値定義 |

---

## 💡 組み込み関数（Intrinsic Functions）

### よく使う関数

```yaml
# 参照
!Ref MyResource              # リソースID取得
!GetAtt MyResource.Arn       # 属性取得

# 文字列操作
!Sub '${EnvName}-bucket'     # 変数展開
!Join ['-', [a, b, c]]       # 結合 → "a-b-c"

# 条件
!If [IsProduction, m5.large, t3.small]
!Equals [!Ref Env, prod]
!Not [!Equals [!Ref Env, dev]]
!And [条件1, 条件2]
!Or [条件1, 条件2]

# リスト・マップ
!Select [0, !GetAZs '']      # AZ取得
!FindInMap [MapName, Key1, Key2]
!Split [',', 'a,b,c']        # → [a, b, c]

# Base64
!Base64 'UserData script'

# ImportValue（スタック間参照）
!ImportValue ExportedName
```

---

## 📦 Parameters（パラメータ）

```yaml
Parameters:
  InstanceType:
    Type: String
    Default: t3.small
    AllowedValues: [t3.small, t3.medium, t3.large]
    Description: EC2 instance type
  
  KeyName:
    Type: AWS::EC2::KeyPair::KeyName
    Description: SSH key pair
  
  VpcId:
    Type: AWS::EC2::VPC::Id
    Description: VPC ID
  
  SubnetIds:
    Type: List<AWS::EC2::Subnet::Id>
    Description: Subnet IDs
```

**パラメータタイプ**:
- `String`, `Number`, `List<Number>`, `CommaDelimitedList`
- `AWS::EC2::VPC::Id`, `AWS::EC2::Subnet::Id`
- `AWS::EC2::KeyPair::KeyName`
- `AWS::SSM::Parameter::Value<String>`

---

## 🗺️ Mappings（マッピング）

```yaml
Mappings:
  RegionMap:
    ap-northeast-1:
      AMI: ami-0c3fd0f5d33134a76
    us-east-1:
      AMI: ami-0c55b159cbfafe1f0

Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', AMI]
```

---

## ⚡ Conditions（条件）

```yaml
Conditions:
  IsProduction: !Equals [!Ref EnvironmentName, prod]
  IsNotProduction: !Not [!Equals [!Ref EnvironmentName, prod]]
  CreateResources: !And
    - !Equals [!Ref EnvironmentName, prod]
    - !Equals [!Ref Region, ap-northeast-1]

Resources:
  ProdOnlyBucket:
    Type: AWS::S3::Bucket
    Condition: IsProduction
  
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !If [IsProduction, m5.large, t3.small]
```

---

## 📤 Outputs（出力）

```yaml
Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref MyVPC
    Export:
      Name: !Sub '${AWS::StackName}-VPC'
  
  BucketArn:
    Value: !GetAtt MyBucket.Arn
    Export:
      Name: MyBucketArn
```

**他スタックで使用**:
```yaml
Resources:
  MyResource:
    Type: AWS::XXX
    Properties:
      VpcId: !ImportValue MyStack-VPC
```

---

## 🔗 リソース依存関係

```yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
  
  MySubnet:
    Type: AWS::EC2::Subnet
    DependsOn: MyVPC  # 明示的な依存
    Properties:
      VpcId: !Ref MyVPC  # 暗黙的な依存
```

**DependsOn使用ケース**:
- IAM Roleの作成待ち
- インターネットゲートウェイのアタッチ待ち

---

## 🏃 スタック操作

### CLI コマンド

```bash
# スタック作成
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters ParameterKey=Env,ParameterValue=dev \
  --capabilities CAPABILITY_NAMED_IAM

# スタック更新
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml

# 変更セット作成（事前確認）
aws cloudformation create-change-set \
  --stack-name my-stack \
  --change-set-name my-changes \
  --template-body file://template.yaml

# 変更セット実行
aws cloudformation execute-change-set \
  --change-set-name my-changes \
  --stack-name my-stack

# スタック削除
aws cloudformation delete-stack --stack-name my-stack

# スタック確認
aws cloudformation describe-stacks --stack-name my-stack
aws cloudformation list-stacks

# ドリフト検出
aws cloudformation detect-stack-drift --stack-name my-stack
```

---

## 🧩 ネストスタック

**親スタック**:
```yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/network.yaml
      Parameters:
        VpcCIDR: 10.0.0.0/16
```

**子スタックの出力を参照**:
```yaml
!GetAtt NetworkStack.Outputs.VpcId
```

---

## 🎯 ベストプラクティス

### ✅ DO（推奨）

1. **パラメータ化**: 環境変数は Parameters で定義
2. **条件分岐**: Conditions で環境別リソース制御
3. **Output Export**: スタック間連携で Export 使用
4. **タグ付け**: すべてのリソースにタグ
5. **変更セット**: 本番更新前に必ず変更セット確認
6. **ネストスタック**: 大規模構成は分割
7. **ドリフト検出**: 定期的に手動変更を検出

### ❌ DON'T（非推奨）

1. ハードコード（環境名、リージョンなど）
2. リソース名の直接指定（自動生成推奨）
3. 手動でのリソース変更（ドリフト発生）
4. 巨大な単一テンプレート（200リソース超）

---

## 🔒 IAM Role とCapabilities

```bash
# IAM リソース作成時は必須
--capabilities CAPABILITY_IAM

# カスタムIAM名指定時
--capabilities CAPABILITY_NAMED_IAM
```

```yaml
Resources:
  MyRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: MyCustomRole  # 名前指定時はCAPABILITY_NAMED_IAM必要
```

---

## 📊 よく使うリソース

### VPC
```yaml
MyVPC:
  Type: AWS::EC2::VPC
  Properties:
    CidrBlock: 10.0.0.0/16
    EnableDnsHostnames: true
    Tags:
      - Key: Name
        Value: MyVPC
```

### Subnet
```yaml
PublicSubnet:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref MyVPC
    CidrBlock: 10.0.1.0/24
    AvailabilityZone: !Select [0, !GetAZs '']
    MapPublicIpOnLaunch: true
```

### Security Group
```yaml
WebSG:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Web server SG
    VpcId: !Ref MyVPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 80
        ToPort: 80
        CidrIp: 0.0.0.0/0
```

### EC2
```yaml
WebServer:
  Type: AWS::EC2::Instance
  Properties:
    ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', AMI]
    InstanceType: !Ref InstanceType
    SubnetId: !Ref PublicSubnet
    SecurityGroupIds: [!Ref WebSG]
    UserData:
      Fn::Base64: !Sub |
        #!/bin/bash
        yum update -y
        yum install -y httpd
        systemctl start httpd
```

### RDS
```yaml
MyDB:
  Type: AWS::RDS::DBInstance
  Properties:
    Engine: mysql
    EngineVersion: '8.0.35'
    DBInstanceClass: db.t3.small
    AllocatedStorage: 50
    DBName: mydb
    MasterUsername: admin
    MasterUserPassword: !Ref DBPassword
    VPCSecurityGroups: [!Ref DBSG]
    DBSubnetGroupName: !Ref DBSubnetGroup
```

### S3
```yaml
MyBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: !Sub '${AWS::StackName}-bucket'
    VersioningConfiguration:
      Status: Enabled
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: AES256
```

---

## 🚨 エラー対処

### よくあるエラー

| エラー | 原因 | 対処 |
|--------|------|------|
| `CREATE_FAILED` | リソース作成失敗 | CloudWatch Logsでエラー詳細確認 |
| `ROLLBACK_COMPLETE` | スタック作成失敗 | スタック削除後、再作成 |
| `UPDATE_ROLLBACK_FAILED` | ロールバック失敗 | 手動修正後、continue-update-rollback |
| `Resource does not exist` | 依存リソース未作成 | DependsOn追加 |
| `Circular dependency` | 循環参照 | 依存関係を見直し |

### ロールバック復旧

```bash
# ロールバック失敗時
aws cloudformation continue-update-rollback --stack-name my-stack
```

---

## 📚 実践パターン

### マルチ環境対応

```yaml
Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, stg, prod]

Mappings:
  EnvironmentMap:
    dev:
      InstanceType: t3.small
      MinSize: 1
      MaxSize: 2
    prod:
      InstanceType: m5.large
      MinSize: 2
      MaxSize: 10

Resources:
  ASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      MinSize: !FindInMap [EnvironmentMap, !Ref Environment, MinSize]
      MaxSize: !FindInMap [EnvironmentMap, !Ref Environment, MaxSize]
```

### コスト最適化

```yaml
Conditions:
  CreateNATGateway: !Equals [!Ref Environment, prod]

Resources:
  # 開発環境ではNAT Gatewayを作らない（コスト削減）
  NATGateway:
    Type: AWS::EC2::NatGateway
    Condition: CreateNATGateway
```

---

## 🎓 学習リソース

- [AWS公式ドキュメント](https://docs.aws.amazon.com/cloudformation/)
- [テンプレートリファレンス](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-reference.html)
- [サンプルテンプレート](https://github.com/awslabs/aws-cloudformation-templates)

---

**このチートシートで CloudFormation 中級者の基礎は完璧！🚀**
