# CloudFormation 初級チートシート 📋

**初心者が最初に覚えるべき基本事項のクイックリファレンス**

---

## 🎯 CloudFormationとは？

**AWS CloudFormation** = インフラをコード（YAML/JSON）で定義し、自動構築するサービス

### メリット
- ✅ インフラの**バージョン管理**
- ✅ **再現性**（同じ構成を何度でも作成）
- ✅ **自動化**（手動操作不要）
- ✅ **ドキュメント化**（コードが設計書）

---

## 📄 テンプレート基本構造

### 最小構成（必須のみ）

```yaml
Resources:              # ← これだけあれば動く！
  MyBucket:
    Type: AWS::S3::Bucket
```

### 実務での標準構成

```yaml
AWSTemplateFormatVersion: '2010-09-09'    # 推奨（省略可能）
Description: テンプレートの説明               # 任意

Parameters:           # 任意（変数を書く箇所。環境名・インスタンスタイプ等を実行時に指定）
  Environment:
    Type: String
    Default: dev

Resources:            # 必須⭐
  MyBucket:
    Type: AWS::S3::Bucket

Outputs:              # 任意（作成後に決まる値を表示。例：VPC ID、EC2のIP等）
  BucketName:
    Value: !Ref MyBucket
```

### 全セクション構成

```yaml
AWSTemplateFormatVersion: '2010-09-09'  # 推奨
Description: テンプレートの説明            # 任意

# ==========================================
# Metadata: メタ情報（任意）
# ==========================================
Metadata:
  AWS::CloudFormation::Interface:
    ParameterGroups: [...]

# ==========================================
# Parameters: 入力パラメータ（任意）
# 変数を書く箇所。環境名・インスタンスタイプ等を実行時に指定できる
# ==========================================
Parameters:
  Environment:
    Type: String
    Default: dev

# ==========================================
# Mappings: 環境別の設定値マップ（任意）
# ==========================================
Mappings:
  EnvironmentMap:
    dev:
      InstanceType: t3.small
    prod:
      InstanceType: m5.large

# ==========================================
# Conditions: 条件分岐（任意）
# ==========================================
Conditions:
  IsProduction: !Equals [!Ref Environment, prod]

# ==========================================
# Resources: 作成するAWSリソース（必須⭐）
# ==========================================
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: mybucket

# ==========================================
# Outputs: 出力値（任意）
# 作成後に決まる値を表示。例：VPC ID、EC2のIPアドレス等
# 他スタックで参照する場合はExportを使う
# ==========================================
Outputs:
  BucketName:
    Description: S3 Bucket Name
    Value: !Ref MyBucket
    Export:
      Name: !Sub '${AWS::StackName}-BucketName'
```

---

## 📋 セクション一覧（必須・任意の区別）

| セクション | 必須 | 説明 | 学習レベル |
|----------|------|------|-----------|
| `AWSTemplateFormatVersion` | 推奨 | テンプレート形式バージョン | 初級 |
| `Description` | 任意 | テンプレート説明 | 初級 |
| `Metadata` | 任意 | UI設定・メタ情報 | 中級 |
| `Parameters` | 任意 | 入力パラメータ（変数を書く箇所） | 初級 |
| `Mappings` | 任意 | 環境別設定マップ | 初級 |
| `Conditions` | 任意 | 条件分岐 | 初級 |
| **`Resources`** | **必須⭐** | **作成するリソース** | **初級** |
| `Outputs` | 任意 | 出力値（作成後に決まる値を表示） | 初級 |

**ポイント**:
1. **Resources**: これだけは必須！
2. **Parameters**: 変数を書く箇所（環境名・インスタンスタイプ等を実行時に指定）
3. **Outputs**: 作成後に決まる値を表示（例：VPC ID、EC2のIPアドレス等）
4. **Mappings, Conditions**: 環境別設定で使用

---

## 🔤 基本データ型

### Parameters で使える Type

| Type | 説明 | 例 |
|------|------|-----|
| `String` | 文字列 | `"dev"`, `"web-server"` |
| `Number` | 数値 | `3`, `100` |
| `List<Number>` | 数値リスト | `[80, 443]` |
| `CommaDelimitedList` | カンマ区切りリスト | `"subnet-a,subnet-b"` |
| `AWS::EC2::KeyPair::KeyName` | EC2キーペア名 | 既存キーペア |
| `AWS::EC2::VPC::Id` | VPC ID | 既存VPC |
| `List<AWS::EC2::Subnet::Id>` | サブネットID リスト | 既存サブネット複数 |

**例**:
```yaml
Parameters:
  InstanceType:
    Type: String
    Default: t3.small
    AllowedValues:
      - t3.micro
      - t3.small
      - t3.medium
    Description: EC2インスタンスタイプ
  
  VpcId:
    Type: AWS::EC2::VPC::Id
    Description: 既存VPC ID
```

### 💡 補足：クォートが必要な場合と不要な場合

**基本原則**:
- String は**クォートなし**でも**クォート付き**でもOK
- ただし、YAMLの文法ルールで**必須の場合**がある

**クォートが必要な6パターン**:

#### ① YAMLが特別な意味として解釈してしまう文字列

```yaml
# ❌ 間違い（boolean として解釈される）
Value: yes     # ← true になってしまう
Value: no      # ← false になってしまう
Value: on      # ← true になってしまう
Value: off     # ← false になってしまう

# ❌ 間違い（数値として解釈される）
Value: 01      # ← 数値 1 になってしまう
Value: 123e4   # ← 指数表記になってしまう

# ✅ 正しい
Value: "yes"
Value: "no"
Value: "01"
Value: "123e4"
```

#### ② コロン（:）を含む場合

```yaml
# ❌ 間違い
Value: http://example.com

# ✅ 正しい
Value: "http://example.com"
Value: "key:value"
```

#### ③ 先頭が特殊文字（*, &, !, ?, -, @, #）の場合

```yaml
# ❌ 間違い
Value: *abc

# ✅ 正しい
Value: "*abc"
Value: "!abc"
Value: "@user"
```

#### ④ !Sub など組み込み関数の中で文字列を展開する場合

```yaml
# ❌ 避ける
Value: !Sub ${Env}-${Name}

# ✅ 正しい
Value: !Sub "${Env}-${Name}"
Value: !Sub '${Env}-${Name}'    # シングルでもOK
```

#### ⑤ 改行・スペースを保持したい場合

```yaml
Value: |
  line1
  line2
```

#### ⑥ JSONやBase64のような複雑な記号を含む場合

```yaml
Value: "{\"key\":\"value\"}"
Value: "SGVsbG8gV29ybGQ="
```

---

#### クォートが不要な場合

```yaml
# 単純な文字列はクォートなしでOK
Value: dev
Value: my-bucket
Value: web-server-01
Value: t3.micro
Value: ap-northeast-1a
```

---

#### クォート必要性まとめ

| ケース | クォート | 例 |
|--------|---------|-----|
| boolean と誤解される文字列 | 必要 | `yes` / `no` / `on` / `off` |
| ゼロ埋め数値 | 必要 | `01`, `001` |
| 特殊記号を含む | 必要 | `http://...`, `key:value` |
| !Sub の文字列展開 | 必要 | `!Sub "${Env}-app"` |
| 先頭が特殊文字 | 必要 | `*abc`, `!abc` |
| JSON, Base64 | 必要 | `{"key":"value"}` |
| 単純な文字列 | 不要 | `dev`, `mybucket` |

---

#### 実務での鉄則

**迷ったら、Stringはすべてクォートで囲っておけば安全！**

- クォートあり：明示的で安全
- クォートなし：場合によってYAMLが誤解して事故る

**詳細は [yaml-guide-for-cfn.md](yaml-guide-for-cfn.md) を参照**

---

## 🔧 基本的な組み込み関数（Intrinsic Functions）

### 1. `!Ref` - リソース参照

**用途**: リソースのID・名前を取得

```yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
  
  MySubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC    # ← VPC IDを参照
      CidrBlock: 10.0.1.0/24

Parameters:
  InstanceType:
    Type: String
    Default: t3.small

Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType    # ← パラメータ参照
```

**返り値**:
- Parameters → パラメータ値
- Resources → リソースのID（通常）

---

### 2. `!GetAtt` - 属性取得

**用途**: リソースの詳細な属性を取得

```yaml
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-xxxxx
      InstanceType: t3.small

Outputs:
  InstancePrivateIp:
    Value: !GetAtt MyEC2.PrivateIp    # ← Private IP取得
  
  InstancePublicIp:
    Value: !GetAtt MyEC2.PublicIp     # ← Public IP取得
```

**よく使う属性**:
- EC2: `PrivateIp`, `PublicIp`, `AvailabilityZone`
- RDS: `Endpoint.Address`, `Endpoint.Port`
- ALB: `DNSName`

---

### 3. `!Sub` - 文字列展開

**用途**: 変数を文字列に埋め込む

```yaml
Parameters:
  ProjectName:
    Type: String
    Default: myapp
  Environment:
    Type: String
    Default: dev

Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${ProjectName}-${Environment}-bucket'
      # 結果: myapp-dev-bucket

  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-xxxxx
      Tags:
        - Key: Name
          Value: !Sub '${ProjectName}-${Environment}-web'
          # 結果: myapp-dev-web
```

**疑似パラメータも使える**:
```yaml
Description: !Sub 'Stack in ${AWS::Region} account ${AWS::AccountId}'
# 結果: Stack in ap-northeast-1 account 123456789012
```

---

### 4. `!Join` - 文字列結合

**用途**: リストを区切り文字で結合

```yaml
Parameters:
  ProjectName:
    Type: String
    Default: myapp

Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Join
        - '-'
        - - !Ref ProjectName
          - 'data'
          - 'bucket'
      # 結果: myapp-data-bucket
```

**!Sub vs !Join**:
- **!Sub**: シンプルな変数展開に最適
- **!Join**: リストを動的に結合する場合

---

### 5. `!Select` - リストから要素取得

**用途**: リストの特定インデックスを取得

```yaml
Parameters:
  SubnetIds:
    Type: CommaDelimitedList
    Default: "subnet-aaa,subnet-bbb,subnet-ccc"

Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      SubnetId: !Select [0, !Ref SubnetIds]    # ← 最初のサブネット
      # 結果: subnet-aaa
```

---

### 6. `!GetAZs` - AZ一覧取得

**用途**: リージョンの全AZを取得

```yaml
Resources:
  Subnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      AvailabilityZone: !Select [0, !GetAZs '']    # ← 最初のAZ
      CidrBlock: 10.0.1.0/24
  
  Subnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      AvailabilityZone: !Select [1, !GetAZs '']    # ← 2番目のAZ
      CidrBlock: 10.0.2.0/24
```

**`!GetAZs ''`**: 現在のリージョンの全AZ

---

### 7. `!FindInMap` - Mappingsから値取得

**用途**: 環境別設定を取得

```yaml
Mappings:
  EnvironmentMap:
    dev:
      InstanceType: t3.small
      DbClass: db.t3.micro
    prod:
      InstanceType: m5.large
      DbClass: db.r6i.large

Parameters:
  Environment:
    Type: String
    Default: dev

Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !FindInMap [EnvironmentMap, !Ref Environment, InstanceType]
      # dev → t3.small, prod → m5.large
```

---

### 8. `!If` - 条件分岐

**用途**: 条件によって値を切り替え

```yaml
Parameters:
  Environment:
    Type: String
    Default: dev

Conditions:
  IsProduction: !Equals [!Ref Environment, prod]

Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !If [IsProduction, m5.large, t3.small]
      # prod → m5.large, それ以外 → t3.small
```

---

## 📤 Outputs（出力値）

### 基本形

```yaml
Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref MyVPC

  EC2PublicIp:
    Description: EC2 Public IP Address
    Value: !GetAtt MyEC2.PublicIp
```

### Export（他スタックから参照可能）

```yaml
Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref MyVPC
    Export:
      Name: MyVPC-VpcId    # ← エクスポート名

  PublicSubnetId:
    Value: !Ref PublicSubnet
    Export:
      Name: !Sub '${AWS::StackName}-PublicSubnetId'
```

### ImportValue（他スタックから参照）

```yaml
# 別のテンプレートで使用
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      SubnetId: !ImportValue MyVPC-PublicSubnetId    # ← インポート
```

**重要**: 
- Export している値は、参照されている間は削除・変更不可！
- Export 名は一意である必要がある
- Export/ImportValue を使って初めて スタック分割・再利用設計 ができる

---

### 📌 Outputs と Export の違い

**重要な区別**:

```yaml
# パターン1: Outputs のみ（同じスタック内でのみ使える）
Outputs:
  VpcId:
    Value: !Ref MyVPC    # ← 同じスタック内でしか参照できない

# パターン2: Outputs + Export（他スタックでも使える）
Outputs:
  VpcId:
    Value: !Ref MyVPC
    Export:
      Name: MyProject-VpcId    # ← 他スタックから参照可能に！
```

**スタック間連携の流れ**:

```
[ VPC Stack ]              [ APP Stack ]
    ↓ Export                    ↓ ImportValue
Outputs:                   Resources:
  VpcId:                     MyEC2:
    Value: !Ref MyVPC          Properties:
    Export:                      VpcId: !ImportValue MyProject-VpcId
      Name: MyProject-VpcId
```

**実例**:

```yaml
# stack-vpc.yml（エクスポート側）
Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref MyVPC
    Export:
      Name: MyVPC-VpcId    # ← エクスポート名

# stack-ec2.yml（インポート側）
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      SubnetId: !ImportValue MyVPC-PublicSubnetId    # ← インポート
```

**詳細**: [05. Outputs と ImportValue](beginner/05-outputs-imports.md) を参照




---

## 🏗️ よく使うリソース

### VPC

```yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: MyVPC
```

### Subnet

```yaml
Resources:
  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: PublicSubnet
```

### Internet Gateway

```yaml
Resources:
  IGW:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: MyIGW

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref MyVPC
      InternetGatewayId: !Ref IGW
```

### Security Group

```yaml
Resources:
  WebSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Web Server SG
      VpcId: !Ref MyVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: WebSG
```

### EC2

```yaml
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !Ref LatestAmiId    # パラメータから
      InstanceType: t3.small
      SubnetId: !Ref PublicSubnet
      SecurityGroupIds:
        - !Ref WebSecurityGroup
      Tags:
        - Key: Name
          Value: WebServer
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          echo "<h1>Hello from ${AWS::StackName}</h1>" > /var/www/html/index.html
```

### RDS

```yaml
Resources:
  DBSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupDescription: Subnet group for RDS
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2

  MyRDS:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: mydb
      Engine: mysql
      EngineVersion: '8.0.35'
      DBInstanceClass: db.t3.micro
      AllocatedStorage: 20
      StorageType: gp3
      StorageEncrypted: true
      MasterUsername: admin
      MasterUserPassword: !Ref DBPassword    # パラメータから
      DBSubnetGroupName: !Ref DBSubnetGroup
      VPCSecurityGroups:
        - !Ref DBSecurityGroup
```

---

## 🎛️ 疑似パラメータ

テンプレート内で自動的に使える変数

| 疑似パラメータ | 説明 | 例 |
|--------------|------|-----|
| `AWS::AccountId` | AWSアカウントID | `123456789012` |
| `AWS::Region` | リージョン | `ap-northeast-1` |
| `AWS::StackName` | スタック名 | `my-stack` |
| `AWS::StackId` | スタックID | `arn:aws:cloudformation:...` |
| `AWS::NoValue` | 値を削除 | - |

**使用例**:
```yaml
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-${AWS::Region}-bucket'
      # 結果: my-stack-ap-northeast-1-bucket

  MyTopic:
    Type: AWS::SNS::Topic
    Properties:
      DisplayName: !Sub 'Topic in account ${AWS::AccountId}'
```

---

## 🔄 基本コマンド

### スタック作成

```bash
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=dev
```

### スタック更新

```bash
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=prod
```

### スタック削除

```bash
aws cloudformation delete-stack --stack-name my-stack
```

### スタック状態確認

```bash
aws cloudformation describe-stacks --stack-name my-stack

# 出力値確認
aws cloudformation describe-stacks \
  --stack-name my-stack \
  --query 'Stacks[0].Outputs'
```

### テンプレート検証

```bash
aws cloudformation validate-template \
  --template-body file://template.yaml
```

---

## ✅ 初級チェックリスト

### 基本知識
- [ ] CloudFormationとは何か説明できる
- [ ] YAML構文でテンプレートを書ける
- [ ] Parameters, Resources, Outputs の役割を理解した

### 組み込み関数
- [ ] !Ref でリソース・パラメータを参照できる
- [ ] !GetAtt でリソース属性を取得できる
- [ ] !Sub で文字列展開ができる
- [ ] !Join でリスト結合ができる
- [ ] !Select でリスト要素を取得できる

### リソース作成
- [ ] VPC を作成できる
- [ ] Subnet を作成できる
- [ ] Security Group を作成できる
- [ ] EC2 を作成できる
- [ ] RDS を作成できる

### スタック操作
- [ ] AWS CLI でスタック作成できる
- [ ] スタック更新ができる
- [ ] スタック削除ができる
- [ ] スタック状態を確認できる

### スタック間連携
- [ ] Outputs で値を出力できる
- [ ] Export で値をエクスポートできる
- [ ] ImportValue で他スタックから参照できる

---

## 🚨 よくあるエラーと対処法

### 1. `CREATE_FAILED` - リソース作成失敗

**原因**: プロパティ値が不正、権限不足、クォータ超過

**対処**:
```bash
# イベント確認
aws cloudformation describe-stack-events --stack-name my-stack

# CloudWatch Logs確認
aws logs tail /aws/cloudformation/my-stack --follow
```

### 2. `Parameter validation failed` - パラメータ不正

**原因**: 必須パラメータ未指定、型不一致

**対処**: Parameters の Type, AllowedValues を確認

### 3. `Export名が既に存在` エラー

**原因**: 同じ Export Name が既に使われている

**対処**: Export Name をユニークにする
```yaml
Export:
  Name: !Sub '${AWS::StackName}-VpcId'    # ← スタック名を含める
```

### 4. `ImportValue削除不可` エラー

**原因**: Export を他スタックが参照している

**対処**: 参照元スタックを先に削除

---

## 📚 次のステップ

### 初級編を完了したら

1. ✅ [Before/Afterガイド](07-before-after-guide.md) で実践
2. ✅ [中級チートシート](../../intermediate/99-intermediate-cheatsheet.md) へ進む
3. ✅ 実際のプロジェクトで適用

---

**この初級チートシートを手元に置いて、CloudFormationをマスターしましょう！📖**
