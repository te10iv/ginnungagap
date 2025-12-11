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

## 💡 組み込み関数（Intrinsic Functions）詳細

### 🔗 Ref - リソース参照

**用途**: リソースのID・名前を取得

```yaml
Resources:
  MyBucket:
    Type: AWS::S3::Bucket

  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      # パラメータ参照
      InstanceType: !Ref InstanceTypeParam
      # 他リソース参照（S3バケット名）
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          echo "Bucket: !Ref MyBucket"
```

**⚠️ 制約**:
- **同一テンプレート内のみ**参照可能
- 別テンプレートで使うには `Outputs` + `Export` + `ImportValue` が必要

**返される値**:
- `AWS::S3::Bucket` → バケット名
- `AWS::EC2::Instance` → インスタンスID (i-xxxxx)
- `AWS::EC2::VPC` → VPC ID (vpc-xxxxx)

---

### 🔍 GetAtt - 属性取得

**用途**: リソースの詳細属性を取得（RefよりID以外の情報）

```yaml
Resources:
  MyBucket:
    Type: AWS::S3::Bucket

  MyInstance:
    Type: AWS::EC2::Instance

Outputs:
  BucketArn:
    Value: !GetAtt MyBucket.Arn              # ARN取得
  
  InstancePrivateIP:
    Value: !GetAtt MyInstance.PrivateIp      # Private IP取得
  
  LoadBalancerDNS:
    Value: !GetAtt MyALB.DNSName            # ALBのDNS名
```

**⚠️ 制約**:
- **同一テンプレート内のみ**参照可能
- 属性名はリソースタイプごとに異なる（ドキュメント確認必須）

**よく使う属性**:
- `Arn` - ARN（ほぼ全リソース）
- `PrivateIp`, `PublicIp` - EC2のIP
- `DNSName` - ALBのDNS名
- `Endpoint.Address` - RDSのエンドポイント

---

### 📝 Sub - 変数展開

**用途**: 文字列内で変数を展開（最頻出関数）

```yaml
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      # パラメータ展開
      BucketName: !Sub '${ProjectName}-${Environment}-bucket'
      
      # 疑似パラメータ展開
      Tags:
        - Key: StackId
          Value: !Sub '${AWS::StackId}'
  
  # 複数行の場合
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          echo "Project: ${ProjectName}"
          echo "Region: ${AWS::Region}"
          echo "Account: ${AWS::AccountId}"
          aws s3 cp s3://${MyBucket}/data /tmp/
```

**🎯 有用な場面**:
- リソース名の統一命名規則
- UserData内での動的値参照
- ARN構築

**⚠️ 制約**:
- **同一テンプレート内のみ**参照可能
- `!Ref` や `!GetAtt` の結果は展開可能
- 別テンプレートの値は `!ImportValue` で事前取得が必要

**疑似パラメータ**:
- `${AWS::Region}` - リージョン
- `${AWS::AccountId}` - アカウントID
- `${AWS::StackName}` - スタック名
- `${AWS::StackId}` - スタックID

---

### 🔗 ImportValue - スタック間参照

**用途**: 他スタックの出力値を参照（**唯一のスタック間参照方法**）

**スタックA（出力側）**:
```yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC

Outputs:
  VpcId:
    Value: !Ref MyVPC
    Export:
      Name: NetworkStack-VpcId    # ← Export名（リージョン内で一意）
  
  PrivateSubnetIds:
    Value: !Join [',', [!Ref PrivateSubnet1, !Ref PrivateSubnet2]]
    Export:
      Name: NetworkStack-PrivateSubnets
```

**スタックB（参照側）**:
```yaml
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      # スタックAのVPC IDを参照
      SubnetId: !ImportValue NetworkStack-VpcId
  
  MyRDS:
    Type: AWS::RDS::DBInstance
    Properties:
      DBSubnetGroupName: !Ref DBSubnetGroup
  
  DBSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      # カンマ区切り文字列をリストに変換
      SubnetIds: !Split [',', !ImportValue NetworkStack-PrivateSubnets]
```

**⚠️ 重要な制約**:
1. **Outputsに`Export`がないと使えない**
2. **Export名はリージョン内で一意**（重複不可）
3. **Import使用中はExport削除不可**（スタック削除失敗）
4. **Export名の変更は影響大**（依存スタック全て更新必要）

**💡 ベストプラクティス**:
- Export名に`${AWS::StackName}`を含める（一意性確保）
- リスト値は`!Join`で結合、参照側で`!Split`で分割

---

### ➕ Join - 文字列結合

**用途**: リストを区切り文字で結合

```yaml
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      # [ProjectName, Environment, 'bucket'] → "myapp-dev-bucket"
      BucketName: !Join ['-', [!Ref ProjectName, !Ref Environment, 'bucket']]

Outputs:
  # Subnetのリストをカンマ区切りでExport（ImportValue用）
  SubnetIds:
    Value: !Join [',', [!Ref Subnet1, !Ref Subnet2, !Ref Subnet3]]
    Export:
      Name: !Sub '${AWS::StackName}-Subnets'
```

**🎯 有用な場面**:
- リスト値をExportする（ImportValue用にカンマ区切り化）
- 複雑な命名規則

---

### ✂️ Split - 文字列分割

**用途**: 文字列を区切り文字でリストに分割

```yaml
Resources:
  DBSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      # "subnet-xxx,subnet-yyy" → [subnet-xxx, subnet-yyy]
      SubnetIds: !Split [',', !ImportValue NetworkStack-Subnets]
```

**🎯 有用な場面**:
- ImportValueで取得したカンマ区切り文字列をリスト化
- パラメータのCommaDelimitedListを分割

---

### 🔎 Select - リスト要素選択

**用途**: リストから指定インデックスの要素を取得

```yaml
Resources:
  MySubnet:
    Type: AWS::EC2::Subnet
    Properties:
      # AZリストの最初を取得
      AvailabilityZone: !Select [0, !GetAZs '']
  
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      # パラメータリストの2番目
      SubnetId: !Select [1, !Ref SubnetIds]
```

**🎯 有用な場面**:
- 最初のAZ取得（`!Select [0, !GetAZs '']`）
- リストパラメータから特定要素取得

---

### 🌏 GetAZs - AZ取得

**用途**: リージョンのAZ一覧を取得

```yaml
Resources:
  Subnet1:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [0, !GetAZs '']    # 1番目のAZ
  
  Subnet2:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [1, !GetAZs '']    # 2番目のAZ
```

**引数**:
- `''` または省略 → 現在のリージョン
- `'us-east-1'` → 指定リージョン

---

### 🗺️ FindInMap - マッピング検索

**用途**: Mappingsから値を取得

```yaml
Mappings:
  RegionMap:
    ap-northeast-1:
      AMI: ami-xxxxx
    us-east-1:
      AMI: ami-yyyyy

Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      # リージョンに応じたAMIを自動取得
      ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', AMI]
```

**引数**: `[MapName, TopLevelKey, SecondLevelKey]`

---

### ❓ If - 条件分岐

**用途**: 条件による値の切り替え（三項演算子）

```yaml
Conditions:
  IsProduction: !Equals [!Ref Environment, prod]

Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      # 本番ならm5.large、それ以外はt3.small
      InstanceType: !If [IsProduction, m5.large, t3.small]
```

**引数**: `[ConditionName, 真の場合の値, 偽の場合の値]`

**⚠️ 制約**:
- Conditionsセクションで定義した条件名のみ使用可能

---

### 🔐 Base64 - Base64エンコード

**用途**: UserDataのエンコード（必須）

```yaml
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          echo "Hello ${ProjectName}"
          aws s3 cp s3://${MyBucket}/data /tmp/
```

**⚠️ 制約**:
- UserDataは**必ずBase64エンコード必須**
- `!Sub`と組み合わせて動的値を展開可能

---

### 📊 まとめ: スタック間参照の条件

| 関数 | スコープ | 別スタック参照 | 必要条件 |
|------|---------|-------------|---------|
| `!Ref` | 同一テンプレート | ❌ | なし |
| `!GetAtt` | 同一テンプレート | ❌ | なし |
| `!Sub` | 同一テンプレート | ❌ | なし |
| `!ImportValue` | 複数スタック | ✅ | **Outputsに`Export`が必須** |

**💡 重要ポイント**:
```yaml
# ❌ これはできない（別テンプレートから直接Ref）
Properties:
  VpcId: !Ref OtherStackVPC    # エラー！

# ✅ 正しい方法
# スタックA（出力側）
Outputs:
  VpcId:
    Value: !Ref MyVPC
    Export:
      Name: MyVPC-Id    # ← Export必須

# スタックB（参照側）
Properties:
  VpcId: !ImportValue MyVPC-Id    # ← ImportValue使用
```

---

## 📦 Parameters（パラメータ）

### 基本例

```yaml
Parameters:
  InstanceType:
    Type: String                    # 文字列型
    Default: t3.small
    AllowedValues: [t3.small, t3.medium, t3.large]
    Description: EC2 instance type
  
  KeyName:
    Type: AWS::EC2::KeyPair::KeyName    # AWS固有型（KeyPairのドロップダウン表示）
    Description: SSH key pair
  
  VpcId:
    Type: AWS::EC2::VPC::Id             # AWS固有型（VPCのドロップダウン表示）
    Description: VPC ID
  
  SubnetIds:
    Type: List<AWS::EC2::Subnet::Id>    # AWS固有型のリスト
    Description: Subnet IDs
```

### パラメータタイプ一覧

#### 📝 基本型
- `String` - 文字列（環境名、プロジェクト名等）
- `Number` - 数値（ポート番号、サイズ等）
- `List<Number>` - 数値のリスト
- `CommaDelimitedList` - カンマ区切り文字列 → リストに変換

#### 🔧 AWS固有型（リソースを自動検出してドロップダウン表示）
- `AWS::EC2::VPC::Id` - VPC ID
- `AWS::EC2::Subnet::Id` - Subnet ID
- `List<AWS::EC2::Subnet::Id>` - Subnet IDのリスト
- `AWS::EC2::SecurityGroup::Id` - Security Group ID
- `List<AWS::EC2::SecurityGroup::Id>` - Security Group IDのリスト
- `AWS::EC2::KeyPair::KeyName` - Key Pair名
- `AWS::EC2::Image::Id` - AMI ID
- `AWS::EC2::AvailabilityZone::Name` - AZ名
- `List<AWS::EC2::AvailabilityZone::Name>` - AZ名のリスト

#### 🔐 SSM Parameter Store連携型
- `AWS::SSM::Parameter::Value<String>` - SSM Parameter Storeから値取得
- `AWS::SSM::Parameter::Value<List<String>>` - SSMからリスト取得
- `AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>` - SSMからAMI ID取得
  - 例: `/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2`

**💡 使い分け**:
- **基本型**: 環境変数、設定値等
- **AWS固有型**: 既存リソース選択時（コンソールでドロップダウン表示）
- **SSM連携型**: 最新AMI取得、共通設定値の一元管理

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

## 📤 Outputs（出力）- スタック間連携の要

### 基本構造

```yaml
Outputs:
  VpcId:
    Description: VPC ID              # 説明（任意、推奨）
    Value: !Ref MyVPC                # 出力値（必須）
    Export:                          # Export（他スタックで使う場合のみ）
      Name: !Sub '${AWS::StackName}-VPC'    # Export名（リージョン内で一意）
  
  BucketArn:
    Description: S3 Bucket ARN
    Value: !GetAtt MyBucket.Arn
    Export:
      Name: MyBucketArn
  
  # Exportなし（同一スタック内での確認用）
  WebServerIP:
    Description: Web server public IP
    Value: !GetAtt WebServer.PublicIp
```

### Exportの有無による違い

| 項目 | Export あり | Export なし |
|------|-----------|-----------|
| **用途** | 他スタックで参照 | 確認・デバッグ用 |
| **制約** | Export名は一意必須 | 制約なし |
| **削除** | Import使用中は削除不可 | 自由に削除可能 |
| **参照方法** | `!ImportValue` | 参照不可 |

### 他スタックで使用（ImportValue）

**スタックA（Network）**:
```yaml
# network-stack.yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
  
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
  
  PrivateSubnet2:
    Type: AWS::EC2::Subnet

Outputs:
  VpcId:
    Value: !Ref MyVPC
    Export:
      Name: !Sub '${AWS::StackName}-VPC'    # ← Export名にスタック名を含める
  
  # リスト値はカンマ区切りでExport
  PrivateSubnetIds:
    Value: !Join [',', [!Ref PrivateSubnet1, !Ref PrivateSubnet2]]
    Export:
      Name: !Sub '${AWS::StackName}-PrivateSubnets'
```

**スタックB（Application）**:
```yaml
# app-stack.yaml
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      # スタックAのVPC IDを参照
      SubnetId: !Select [0, !Split [',', !ImportValue network-stack-PrivateSubnets]]
  
  MySecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      VpcId: !ImportValue network-stack-VPC    # ← ImportValueで参照
```

### デプロイ順序の重要性

```bash
# 1. まずNetwork Stack（Export側）
aws cloudformation create-stack \
  --stack-name network-stack \
  --template-body file://network.yaml

# 2. 次にApplication Stack（Import側）
aws cloudformation create-stack \
  --stack-name app-stack \
  --template-body file://app.yaml
```

**⚠️ 削除順序も逆**:
```bash
# 1. まずApp Stack（Import側）を削除
aws cloudformation delete-stack --stack-name app-stack

# 2. 次にNetwork Stack（Export側）を削除
aws cloudformation delete-stack --stack-name network-stack
```

### よくあるエラーと対処

#### エラー1: Export名重複
```
Export name XXX is already exported by stack YYY
```
**対処**: Export名に`${AWS::StackName}`を含めて一意化

#### エラー2: Export削除失敗
```
Export XXX cannot be deleted as it is in use by YYY
```
**対処**: Import使用側のスタックを先に削除

#### エラー3: ImportValueが見つからない
```
No export named XXX found
```
**対処**: Export側スタックが先にデプロイされているか確認

### ベストプラクティス

**✅ DO**:
```yaml
# Export名にスタック名を含める（一意性）
Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: !Sub '${AWS::StackName}-VPC'    # ✅ 推奨

# リスト値はJoinでExport
  SubnetIds:
    Value: !Join [',', [!Ref Subnet1, !Ref Subnet2]]
    Export:
      Name: !Sub '${AWS::StackName}-Subnets'
```

**❌ DON'T**:
```yaml
# Export名をハードコード（重複リスク）
Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: MyVPC    # ❌ 他のスタックと重複する可能性
```

### 確認コマンド

```bash
# スタックの出力値確認
aws cloudformation describe-stacks \
  --stack-name my-stack \
  --query 'Stacks[0].Outputs'

# Export一覧確認
aws cloudformation list-exports

# 特定のExportを使用しているスタック確認
aws cloudformation list-imports \
  --export-name MyVPC-Id
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
