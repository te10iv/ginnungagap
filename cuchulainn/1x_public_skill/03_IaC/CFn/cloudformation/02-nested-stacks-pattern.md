# ネストスタックと再利用パターン

CloudFormationの大規模構成における必須パターン

---

## 📦 ネストスタックとは

親スタック内で子スタックを呼び出す構造。テンプレートを分割・再利用可能にする。

### メリット

- ✅ テンプレートサイズ制限（500KB）を回避
- ✅ 責任範囲の分離（ネットワーク、コンピュート、DB等）
- ✅ 再利用性の向上
- ✅ チーム開発での並行作業
- ✅ 部分的な更新が容易

### デメリット

- ❌ 親スタック削除時に子スタックもすべて削除
- ❌ S3へのテンプレートアップロードが必要
- ❌ 依存関係の管理が複雑化

---

## 🏗️ 基本構造

### 親スタック（master-stack.yaml）

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Master Stack'

Parameters:
  ProjectName:
    Type: String
    Default: myproject
  
  Environment:
    Type: String
    AllowedValues: [dev, stg, prod]

Resources:
  # ネットワークスタック
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-bucket/cfn/network.yaml
      Parameters:
        ProjectName: !Ref ProjectName
        Environment: !Ref Environment
        VpcCIDR: 10.0.0.0/16
      Tags:
        - Key: Name
          Value: !Sub '${ProjectName}-${Environment}-network'

  # コンピュートスタック（ネットワークに依存）
  ComputeStack:
    Type: AWS::CloudFormation::Stack
    DependsOn: NetworkStack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-bucket/cfn/compute.yaml
      Parameters:
        VpcId: !GetAtt NetworkStack.Outputs.VpcId
        SubnetIds: !GetAtt NetworkStack.Outputs.PrivateSubnetIds
        SecurityGroupId: !GetAtt NetworkStack.Outputs.WebSecurityGroupId
      Tags:
        - Key: Name
          Value: !Sub '${ProjectName}-${Environment}-compute'

  # データベーススタック
  DatabaseStack:
    Type: AWS::CloudFormation::Stack
    DependsOn: NetworkStack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-bucket/cfn/database.yaml
      Parameters:
        VpcId: !GetAtt NetworkStack.Outputs.VpcId
        SubnetIds: !GetAtt NetworkStack.Outputs.DBSubnetIds
        SecurityGroupId: !GetAtt NetworkStack.Outputs.DBSecurityGroupId
      TimeoutInMinutes: 30

Outputs:
  VpcId:
    Value: !GetAtt NetworkStack.Outputs.VpcId
    Export:
      Name: !Sub '${AWS::StackName}-VPC'
  
  EC2InstanceId:
    Value: !GetAtt ComputeStack.Outputs.InstanceId
  
  RDSEndpoint:
    Value: !GetAtt DatabaseStack.Outputs.DBEndpoint
```

### 子スタック（network.yaml）

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Network Stack - VPC, Subnets, NAT Gateway'

Parameters:
  ProjectName:
    Type: String
  
  Environment:
    Type: String
  
  VpcCIDR:
    Type: String
    Default: 10.0.0.0/16

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Sub '${ProjectName}-${Environment}-vpc'

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: true

  WebSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Web server security group
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0

Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref VPC
  
  PrivateSubnetIds:
    Description: Private Subnet IDs (comma-separated)
    Value: !Join [',', [!Ref PrivateSubnet1, !Ref PrivateSubnet2]]
  
  WebSecurityGroupId:
    Description: Web Security Group ID
    Value: !Ref WebSecurityGroup
```

---

## 📤 子スタックの出力を親で使用

### GetAtt で出力値取得

```yaml
# 単一値
VpcId: !GetAtt NetworkStack.Outputs.VpcId

# リスト（カンマ区切り文字列をリストに変換）
SubnetIds: !Split [',', !GetAtt NetworkStack.Outputs.PrivateSubnetIds]
```

---

## 🔄 スタック間の依存関係

### 明示的依存（DependsOn）

```yaml
Resources:
  ComputeStack:
    Type: AWS::CloudFormation::Stack
    DependsOn: NetworkStack  # NetworkStack完了後に作成
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/compute.yaml
```

### 暗黙的依存（GetAtt / Ref）

```yaml
Resources:
  ComputeStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      Parameters:
        VpcId: !GetAtt NetworkStack.Outputs.VpcId  # 自動的に依存
```

---

## 🗂️ ディレクトリ構造パターン

### パターン1: 機能別分割

```
cloudformation/
├── master-stack.yaml          # 親スタック
├── network/
│   └── network-stack.yaml     # ネットワーク
├── compute/
│   ├── ec2-stack.yaml         # EC2
│   └── alb-stack.yaml         # ALB
├── database/
│   └── rds-stack.yaml         # RDS
└── security/
    └── iam-stack.yaml         # IAM
```

### パターン2: 環境別分割

```
cloudformation/
├── common/
│   ├── network.yaml           # 共通テンプレート
│   └── database.yaml
├── environments/
│   ├── dev-master.yaml        # 開発環境親スタック
│   ├── stg-master.yaml        # ステージング環境
│   └── prod-master.yaml       # 本番環境
└── parameters/
    ├── dev-params.json        # 環境別パラメータ
    ├── stg-params.json
    └── prod-params.json
```

---

## 🚀 デプロイ方法

### S3にテンプレートをアップロード

```bash
# S3バケット作成
aws s3 mb s3://my-cfn-templates-bucket

# テンプレートアップロード
aws s3 sync ./cloudformation s3://my-cfn-templates-bucket/cfn/

# バージョニング有効化（推奨）
aws s3api put-bucket-versioning \
  --bucket my-cfn-templates-bucket \
  --versioning-configuration Status=Enabled
```

### 親スタックをデプロイ

```bash
# スタック作成
aws cloudformation create-stack \
  --stack-name myproject-dev-master \
  --template-body file://master-stack.yaml \
  --parameters \
    ParameterKey=ProjectName,ParameterValue=myproject \
    ParameterKey=Environment,ParameterValue=dev \
  --capabilities CAPABILITY_NAMED_IAM

# スタック更新
aws cloudformation update-stack \
  --stack-name myproject-dev-master \
  --template-body file://master-stack.yaml \
  --parameters \
    ParameterKey=ProjectName,UsePreviousValue=true \
    ParameterKey=Environment,UsePreviousValue=true
```

---

## 🎯 実践パターン

### パターン1: 3層アーキテクチャ

```
master-stack.yaml
├── network-stack.yaml (VPC, Subnets, NAT Gateway)
├── security-stack.yaml (Security Groups, IAM Roles)
├── compute-stack.yaml (EC2, ALB, Auto Scaling)
└── database-stack.yaml (RDS, ElastiCache)
```

### パターン2: マイクロサービス

```
master-stack.yaml
├── common-stack.yaml (VPC, 共通リソース)
├── service-a-stack.yaml (サービスA)
├── service-b-stack.yaml (サービスB)
└── monitoring-stack.yaml (CloudWatch, Alarms)
```

### パターン3: マルチ環境

```
dev-master-stack.yaml
├── common/network-stack.yaml (共通テンプレート)
├── common/compute-stack.yaml
└── common/database-stack.yaml

prod-master-stack.yaml
├── common/network-stack.yaml (同じテンプレート)
├── common/compute-stack.yaml
└── common/database-stack.yaml
```

---

## 💡 ベストプラクティス

### ✅ DO

1. **S3バケットのバージョニング**: テンプレート履歴管理
2. **Output Export**: スタック間連携に使用
3. **タグ統一**: すべてのスタックに同じタグ
4. **タイムアウト設定**: 長時間かかるリソースは `TimeoutInMinutes` 設定
5. **パラメータ統一**: 親スタックで一元管理

```yaml
Resources:
  DatabaseStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/db.yaml
      TimeoutInMinutes: 60  # RDS作成は時間がかかる
```

### ❌ DON'T

1. 循環参照（スタックAがBに依存、BがAに依存）
2. ハードコードされたARN・ID
3. 過度な分割（1リソース = 1スタックは非効率）

---

## 🔍 トラブルシューティング

### 子スタック作成失敗

**現象**: 親スタックが `CREATE_FAILED`、子スタックが残る

**対処**:
```bash
# 子スタック確認
aws cloudformation describe-stacks --stack-name <child-stack-name>

# 親スタック削除（子も自動削除）
aws cloudformation delete-stack --stack-name master-stack
```

### TemplateURL 404エラー

**原因**: S3バケットが非公開、またはパスが間違っている

**対処**:
```bash
# S3バケットを確認
aws s3 ls s3://my-bucket/cfn/

# テンプレート再アップロード
aws s3 cp network.yaml s3://my-bucket/cfn/network.yaml
```

### パラメータ型不一致

**現象**: `Parameter validation failed`

**対処**: 親スタックから渡すパラメータの型を確認

```yaml
# 親スタック
Parameters:
  SubnetIds: !GetAtt NetworkStack.Outputs.SubnetIds  # String

# 子スタック（NGパターン）
Parameters:
  SubnetIds:
    Type: List<AWS::EC2::Subnet::Id>  # List型なのでエラー

# 子スタック（OKパターン）
Parameters:
  SubnetIds:
    Type: CommaDelimitedList  # カンマ区切り文字列として受け取る
```

---

## 📊 コスト最適化

### 開発環境でネストスタックを削減

```yaml
Conditions:
  IsProduction: !Equals [!Ref Environment, prod]

Resources:
  # 本番環境のみ監視スタック作成
  MonitoringStack:
    Type: AWS::CloudFormation::Stack
    Condition: IsProduction
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/monitoring.yaml
```

---

## 🎓 学習リソース

- [AWS公式: ネストスタック](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html)
- [ネストスタックのベストプラクティス](https://aws.amazon.com/jp/blogs/devops/best-practices-for-organizing-larger-cloudformation-templates/)

---

**ネストスタックで、大規模なCloudFormation構成を効率的に管理！🏗️**
