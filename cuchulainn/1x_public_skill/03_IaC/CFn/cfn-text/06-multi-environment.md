# マルチ環境管理パターン

dev/stg/prod環境を効率的に管理

---

## 🎯 マルチ環境管理の課題

同じインフラを複数環境（開発・ステージング・本番）にデプロイする際の課題：

- ❌ 環境ごとにテンプレートをコピー（保守困難）
- ❌ 設定値のハードコード
- ❌ 環境間の設定ミス
- ❌ コスト管理の複雑化

---

## 📋 推奨パターン

### パターン1: Parameters + Mappings

**特徴**: 1つのテンプレート、パラメータで環境切り替え

```yaml
Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, stg, prod]
    Default: dev

Mappings:
  EnvironmentConfig:
    dev:
      InstanceType: t3.small
      MinSize: 1
      MaxSize: 2
      MultiAZ: false
      BackupRetention: 7
    stg:
      InstanceType: t3.medium
      MinSize: 1
      MaxSize: 4
      MultiAZ: false
      BackupRetention: 14
    prod:
      InstanceType: m5.large
      MinSize: 2
      MaxSize: 10
      MultiAZ: true
      BackupRetention: 30

Conditions:
  IsProduction: !Equals [!Ref Environment, prod]
  IsNotProduction: !Not [!Equals [!Ref Environment, prod]]

Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !FindInMap [EnvironmentConfig, !Ref Environment, InstanceType]
      Tags:
        - Key: Environment
          Value: !Ref Environment
  
  # 本番環境のみ作成
  NATGateway:
    Type: AWS::EC2::NatGateway
    Condition: IsProduction
    Properties:
      AllocationId: !GetAtt EIP.AllocationId
      SubnetId: !Ref PublicSubnet
  
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      Engine: mysql
      DBInstanceClass: !FindInMap [EnvironmentConfig, !Ref Environment, InstanceType]
      MultiAZ: !FindInMap [EnvironmentConfig, !Ref Environment, MultiAZ]
      BackupRetentionPeriod: !FindInMap [EnvironmentConfig, !Ref Environment, BackupRetention]
```

**デプロイ**:
```bash
# 開発環境
aws cloudformation create-stack \
  --stack-name myapp-dev \
  --template-body file://template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=dev

# 本番環境
aws cloudformation create-stack \
  --stack-name myapp-prod \
  --template-body file://template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=prod
```

---

### パターン2: パラメータファイル分離

**特徴**: テンプレートは共通、パラメータファイルを環境別に用意

**ディレクトリ構造**:
```
cloudformation/
├── template.yaml           # 共通テンプレート
└── parameters/
    ├── dev.json
    ├── stg.json
    └── prod.json
```

**template.yaml**:
```yaml
Parameters:
  InstanceType:
    Type: String
  
  MinSize:
    Type: Number
  
  MaxSize:
    Type: Number
  
  MultiAZ:
    Type: String
    AllowedValues: ['true', 'false']

Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
```

**parameters/dev.json**:
```json
[
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t3.small"
  },
  {
    "ParameterKey": "MinSize",
    "ParameterValue": "1"
  },
  {
    "ParameterKey": "MaxSize",
    "ParameterValue": "2"
  },
  {
    "ParameterKey": "MultiAZ",
    "ParameterValue": "false"
  }
]
```

**parameters/prod.json**:
```json
[
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "m5.large"
  },
  {
    "ParameterKey": "MinSize",
    "ParameterValue": "2"
  },
  {
    "ParameterKey": "MaxSize",
    "ParameterValue": "10"
  },
  {
    "ParameterKey": "MultiAZ",
    "ParameterValue": "true"
  }
]
```

**デプロイ**:
```bash
# 開発環境
aws cloudformation create-stack \
  --stack-name myapp-dev \
  --template-body file://template.yaml \
  --parameters file://parameters/dev.json

# 本番環境
aws cloudformation create-stack \
  --stack-name myapp-prod \
  --template-body file://template.yaml \
  --parameters file://parameters/prod.json
```

---

### パターン3: ネストスタック + 環境別親スタック

**特徴**: 子スタックは共通、親スタックを環境別に用意

**ディレクトリ構造**:
```
cloudformation/
├── common/                 # 共通テンプレート（子スタック）
│   ├── network.yaml
│   ├── compute.yaml
│   └── database.yaml
└── environments/           # 環境別親スタック
    ├── dev-master.yaml
    ├── stg-master.yaml
    └── prod-master.yaml
```

**common/network.yaml**（共通）:
```yaml
Parameters:
  VpcCIDR:
    Type: String
  
  EnableNATGateway:
    Type: String

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
  
  NATGateway:
    Type: AWS::EC2::NatGateway
    Condition: CreateNAT
    Properties:
      AllocationId: !GetAtt EIP.AllocationId
      SubnetId: !Ref PublicSubnet

Conditions:
  CreateNAT: !Equals [!Ref EnableNATGateway, 'true']
```

**environments/dev-master.yaml**:
```yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/common/network.yaml
      Parameters:
        VpcCIDR: 10.0.0.0/16
        EnableNATGateway: 'false'  # 開発環境は不要
  
  ComputeStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/common/compute.yaml
      Parameters:
        InstanceType: t3.small
        MinSize: '1'
```

**environments/prod-master.yaml**:
```yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/common/network.yaml
      Parameters:
        VpcCIDR: 10.0.0.0/16
        EnableNATGateway: 'true'  # 本番環境は必要
  
  ComputeStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/common/compute.yaml
      Parameters:
        InstanceType: m5.large
        MinSize: '2'
```

---

## 💰 コスト最適化パターン

### 開発環境のコスト削減

```yaml
Conditions:
  IsProduction: !Equals [!Ref Environment, prod]
  IsDevelopment: !Equals [!Ref Environment, dev]

Resources:
  # NAT Gateway: 本番のみ（開発環境は$35/月削減）
  NATGateway:
    Type: AWS::EC2::NatGateway
    Condition: IsProduction
  
  # Multi-AZ RDS: 本番のみ（開発環境は50%コスト削減）
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      MultiAZ: !If [IsProduction, true, false]
      BackupRetentionPeriod: !If [IsProduction, 30, 7]
  
  # Auto Scaling: 本番は常時稼働、開発は最小限
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      MinSize: !If [IsProduction, 2, 0]  # 開発は0台でOK
      MaxSize: !If [IsProduction, 10, 2]
      DesiredCapacity: !If [IsProduction, 2, 0]
```

### 自動起動停止

```yaml
Resources:
  # 開発環境のみスケジュール停止
  StopScheduleRule:
    Type: AWS::Events::Rule
    Condition: IsDevelopment
    Properties:
      ScheduleExpression: 'cron(0 10 * * ? *)'  # 19時停止（UTC）
      State: ENABLED
      Targets:
        - Arn: !GetAtt StopInstancesFunction.Arn
          Id: StopTarget
```

---

## 🔐 環境別のセキュリティ設定

```yaml
Mappings:
  SecurityConfig:
    dev:
      AllowedCIDR: 10.0.0.0/8  # 社内ネットワークのみ
      EnableWAF: false
      RequireMFA: false
    prod:
      AllowedCIDR: 0.0.0.0/0   # 全世界
      EnableWAF: true
      RequireMFA: true

Resources:
  SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: !FindInMap [SecurityConfig, !Ref Environment, AllowedCIDR]
  
  WAF:
    Type: AWS::WAFv2::WebACL
    Condition: IsProduction
    Properties:
      Scope: REGIONAL
      DefaultAction:
        Allow: {}
```

---

## 📊 タグ戦略

```yaml
Parameters:
  Environment:
    Type: String
  
  ProjectName:
    Type: String
    Default: myproject
  
  CostCenter:
    Type: String

Resources:
  MyResource:
    Type: AWS::EC2::Instance
    Properties:
      Tags:
        - Key: Name
          Value: !Sub '${ProjectName}-${Environment}-web'
        - Key: Environment
          Value: !Ref Environment
        - Key: Project
          Value: !Ref ProjectName
        - Key: ManagedBy
          Value: CloudFormation
        - Key: CostCenter
          Value: !Ref CostCenter
        - Key: AutoStop
          Value: !If [IsDevelopment, 'enabled', 'disabled']
```

---

## 🚀 デプロイ自動化（CI/CD）

### GitHub Actions例

```yaml
name: Deploy CloudFormation

on:
  push:
    branches:
      - develop  # dev環境
      - main     # prod環境

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Determine Environment
        id: env
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "environment=prod" >> $GITHUB_OUTPUT
          else
            echo "environment=dev" >> $GITHUB_OUTPUT
          fi
      
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: ap-northeast-1
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
      
      - name: Deploy Stack
        run: |
          ENV=${{ steps.env.outputs.environment }}
          
          aws cloudformation deploy \
            --stack-name myapp-$ENV \
            --template-file template.yaml \
            --parameter-overrides file://parameters/$ENV.json \
            --capabilities CAPABILITY_NAMED_IAM \
            --no-fail-on-empty-changeset
```

---

## 💡 ベストプラクティス

### ✅ DO

1. **環境名をスタック名に含める**: `myapp-dev`, `myapp-prod`
2. **タグで環境識別**: 全リソースに `Environment` タグ
3. **Mappings活用**: 環境別設定を一元管理
4. **Conditions活用**: 環境別リソース作成
5. **パラメータファイル管理**: Git管理、暗号化

### ❌ DON'T

1. テンプレートの環境別コピー
2. 本番環境の設定を開発環境でテストしない
3. Secrets/Passwordのハードコード

---

## 📚 学習リソース

- [AWS公式: マルチ環境戦略](https://docs.aws.amazon.com/wellarchitected/latest/framework/a-design-principles.html)
- [パラメータストア統合](https://aws.amazon.com/jp/blogs/mt/integrating-aws-cloudformation-with-aws-systems-manager-parameter-store/)

---

**マルチ環境管理で、開発から本番まで効率的に運用！🚀**
