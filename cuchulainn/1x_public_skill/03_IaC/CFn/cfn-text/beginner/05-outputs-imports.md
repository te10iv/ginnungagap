# 05. Outputs と ImportValue

スタック間でリソースを連携させる

---

## 🎯 学習目標

- Outputs でスタックから値を出力する
- Export で値を他スタックで使えるようにする
- ImportValue で他スタックの値を参照する
- スタック間連携の設計ができる

**所要時間**: 45分

---

## 📤 Outputs（出力値）

### 概要

**スタックから値を外部に出力する機能**

CloudFormationでリソースを作成すると、IDやIPアドレスなどが自動的に割り当てられます。Outputsは、これらの**作成後に決まる値を表示**するために使います。

```yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16

Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref MyVPC
    # 実行後に「vpc-0123456789abcdef」のような値が表示される
```

**なぜ必要？**

スタックを作成すると、AWSが自動的にIDを割り当てます：
- VPC → `vpc-0123456789abcdef`
- EC2 → `i-0a1b2c3d4e5f6g7h8`
- S3バケット → 指定した名前

これらの値を**後で確認したり、他のスタックで使うため**にOutputsが必要です。

---

### 用途

#### 1. スタック作成後に値を確認

```bash
# CLIで出力値を確認
aws cloudformation describe-stacks --stack-name my-stack

# 例：作成されたVPC IDを確認
# "OutputKey": "VpcId"
# "OutputValue": "vpc-0123456789abcdef"
```

#### 2. 他スタックで参照（Export使用）

後述の Export と組み合わせて、別のスタックから値を参照できます。

#### 3. 外部システムへの情報提供

CI/CDツールや監視システムに、作成されたリソースの情報を渡す際に使用します。

---

### Outputs の基本構文

```yaml
Outputs:
  出力名:
    Description: 説明文
    Value: 出力する値
    Export:              # ← 他スタックで使う場合のみ
      Name: エクスポート名
```

---

### 例1: 基本的な Outputs

```yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
  
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-xxxxx
      InstanceType: t3.small

Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref MyVPC
  
  InstanceId:
    Description: EC2 Instance ID
    Value: !Ref MyEC2
  
  PublicIp:
    Description: EC2 Public IP Address
    Value: !GetAtt MyEC2.PublicIp
  
  PrivateIp:
    Description: EC2 Private IP Address
    Value: !GetAtt MyEC2.PrivateIp
```

**確認方法**:
```bash
# CLIで確認
aws cloudformation describe-stacks \
  --stack-name my-stack \
  --query 'Stacks[0].Outputs'

# 出力例:
# [
#   {
#     "OutputKey": "VpcId",
#     "OutputValue": "vpc-0123456789abcdef",
#     "Description": "VPC ID"
#   },
#   {
#     "OutputKey": "PublicIp",
#     "OutputValue": "18.182.123.45",
#     "Description": "EC2 Public IP Address"
#   }
# ]
```

---

## 🔗 Export（エクスポート）

### 概要

**Outputsの値を他スタックで使えるようにする**

Outputsだけでは、そのスタック内で値を確認できるだけです。Exportを追加すると、**他のスタックからもその値を参照できる**ようになります。

```yaml
Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref MyVPC
    Export:
      Name: MyVPC-VpcId    # ← エクスポート名（他スタックから参照可能に）
```

**イメージ**:
```
ネットワークスタック（VPC作成）
  ↓ Export で VPC ID を公開
アプリケーションスタック（EC2作成）
  ↓ ImportValue で VPC ID を取得
  ↓ その VPC 内に EC2 を配置
```

**なぜ必要？**

大規模なシステムでは、リソースを1つのテンプレートで管理すると複雑になります。
- ネットワーク（VPC、Subnet）は別スタック
- アプリケーション（EC2、RDS）は別スタック

このように**分割管理**するために、スタック間で値を受け渡す仕組みが必要です。

---

### Export の命名ルール

**ユニークな名前**が必要（同一リージョン内で重複不可）

```yaml
# ❌ 悪い例（重複しやすい）
Export:
  Name: VpcId

# ✅ 良い例（スタック名を含める）
Export:
  Name: !Sub '${AWS::StackName}-VpcId'
```

---

### 例2: Export を使った Outputs

```yaml
# ネットワークスタック (network-stack)
AWSTemplateFormatVersion: '2010-09-09'
Description: Network Stack

Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
  
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
  
  PublicSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 10.0.2.0/24
      AvailabilityZone: !Select [1, !GetAZs '']

Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref MyVPC
    Export:
      Name: !Sub '${AWS::StackName}-VpcId'
  
  PublicSubnet1Id:
    Description: Public Subnet 1 ID
    Value: !Ref PublicSubnet1
    Export:
      Name: !Sub '${AWS::StackName}-PublicSubnet1Id'
  
  PublicSubnet2Id:
    Description: Public Subnet 2 ID
    Value: !Ref PublicSubnet2
    Export:
      Name: !Sub '${AWS::StackName}-PublicSubnet2Id'
  
  # リストとして出力
  PublicSubnetIds:
    Description: Public Subnet IDs
    Value: !Join [',', [!Ref PublicSubnet1, !Ref PublicSubnet2]]
    Export:
      Name: !Sub '${AWS::StackName}-PublicSubnetIds'
```

---

## 📥 ImportValue（インポート）

### 概要

**他スタックのExportされた値を参照する**

ImportValueは、他のスタックがExportした値を**自分のスタックで使う**ための機能です。

```yaml
# アプリケーションスタック (app-stack)
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-xxxxx
      InstanceType: t3.small
      SubnetId: !ImportValue network-stack-PublicSubnet1Id    # ← 他スタックから値を取得
```

**仕組み**:

1. **ネットワークスタック**がSubnet IDをExport
   ```yaml
   Outputs:
     PublicSubnet1Id:
       Value: subnet-xxxxx
       Export:
         Name: network-stack-PublicSubnet1Id
   ```

2. **アプリケーションスタック**がImportValue で取得
   ```yaml
   SubnetId: !ImportValue network-stack-PublicSubnet1Id
   # → subnet-xxxxx が自動的に入る
   ```

**メリット**:
- Subnet IDを手動でコピペする必要なし
- ネットワークスタックを作り直しても、新しいIDが自動的に使われる
- 値の不整合が起きない

---

### ImportValue の基本構文

```yaml
!ImportValue エクスポート名
```

---

### 例3: ImportValue を使ったスタック

```yaml
# アプリケーションスタック (app-stack)
AWSTemplateFormatVersion: '2010-09-09'
Description: Application Stack

Parameters:
  NetworkStackName:
    Type: String
    Default: network-stack
    Description: Network stack name

Resources:
  # Security Group
  WebSG:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Web Server SG
      VpcId: !ImportValue 
        Fn::Sub: '${NetworkStackName}-VpcId'    # ← VPC IDをインポート
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
  
  # EC2 Instance
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-xxxxx
      InstanceType: t3.small
      SubnetId: !ImportValue
        Fn::Sub: '${NetworkStackName}-PublicSubnet1Id'  # ← Subnet IDをインポート
      SecurityGroupIds:
        - !Ref WebSG

Outputs:
  InstanceId:
    Description: EC2 Instance ID
    Value: !Ref MyEC2
```

---

## 🔄 スタック間連携のフロー

### 全体の流れ

```
Step 1: ネットワークスタック作成
  ↓ VPC、Subnetを作成
  ↓ VPC ID、Subnet IDをExport
  
Step 2: Exportの確認
  ↓ 正しく公開されているか確認
  
Step 3: アプリケーションスタック作成
  ↓ ImportValueでVPC ID、Subnet IDを取得
  ↓ そのネットワーク内にEC2を配置
```

---

### Step 1: ネットワークスタック作成

まず、VPCやSubnetなどのネットワークリソースを作成します。

```bash
# network-stack を作成
aws cloudformation create-stack \
  --stack-name network-stack \
  --template-body file://network.yaml

# 完了を待つ（5分程度）
aws cloudformation wait stack-create-complete \
  --stack-name network-stack

# 完了したら「CREATE_COMPLETE」と表示される
```

---

### Step 2: Export確認

ネットワークスタックが正しく値をExportしているか確認します。

```bash
# Exportされた値を確認
aws cloudformation list-exports

# 出力例:
# {
#   "Exports": [
#     {
#       "ExportingStackId": "arn:aws:cloudformation:...:stack/network-stack/...",
#       "Name": "network-stack-VpcId",
#       "Value": "vpc-0123456789abcdef"    # ← この値が他スタックで使える
#     },
#     {
#       "Name": "network-stack-PublicSubnet1Id",
#       "Value": "subnet-aaa"    # ← この値が他スタックで使える
#     }
#   ]
# }
```

**ポイント**: ここで表示された `Name` が ImportValue で指定する名前です。

---

### Step 3: アプリケーションスタック作成

ネットワークスタックのExport値を使って、EC2などを作成します。

```bash
# app-stack を作成（network-stackのExport値を使用）
aws cloudformation create-stack \
  --stack-name app-stack \
  --template-body file://app.yaml \
  --parameters ParameterKey=NetworkStackName,ParameterValue=network-stack

# アプリケーションスタックは、ネットワークスタックの値を使って
# 自動的にVPC内にリソースを配置する
```

**重要**: ネットワークスタックが完成してから、アプリケーションスタックを作成すること！

---

## 🎯 実践例: マイクロサービスアーキテクチャ

### スタック構成

```
1. network-stack         # VPC, Subnet, IGW
   ↓
2. database-stack        # RDS (network-stackに依存)
   ↓
3. app-stack             # EC2, ALB (network-stack, database-stackに依存)
```

### network-stack.yaml

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Network Infrastructure

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
  
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
  
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.11.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
  
  PrivateSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.12.0/24
      AvailabilityZone: !Select [1, !GetAZs '']

Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: !Sub '${AWS::StackName}-VpcId'
  
  PublicSubnet1Id:
    Value: !Ref PublicSubnet1
    Export:
      Name: !Sub '${AWS::StackName}-PublicSubnet1Id'
  
  PrivateSubnetIds:
    Value: !Join [',', [!Ref PrivateSubnet1, !Ref PrivateSubnet2]]
    Export:
      Name: !Sub '${AWS::StackName}-PrivateSubnetIds'
```

### database-stack.yaml

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Database Stack

Parameters:
  NetworkStackName:
    Type: String
    Default: network-stack

Resources:
  DBSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupDescription: DB Subnet Group
      SubnetIds: !Split [',', !ImportValue 
        Fn::Sub: '${NetworkStackName}-PrivateSubnetIds']
  
  DBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: DB SG
      VpcId: !ImportValue
        Fn::Sub: '${NetworkStackName}-VpcId'
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          SourceSecurityGroupId: !ImportValue
            Fn::Sub: '${NetworkStackName}-AppSecurityGroupId'
  
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      Engine: mysql
      EngineVersion: '8.0.35'
      DBInstanceClass: db.t3.micro
      AllocatedStorage: 20
      DBSubnetGroupName: !Ref DBSubnetGroup
      VPCSecurityGroups:
        - !Ref DBSecurityGroup
      MasterUsername: admin
      MasterUserPassword: MyPassword123!

Outputs:
  DBEndpoint:
    Value: !GetAtt Database.Endpoint.Address
    Export:
      Name: !Sub '${AWS::StackName}-DBEndpoint'
```

### app-stack.yaml

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Application Stack

Parameters:
  NetworkStackName:
    Type: String
    Default: network-stack
  DatabaseStackName:
    Type: String
    Default: database-stack

Resources:
  AppSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: App SG
      VpcId: !ImportValue
        Fn::Sub: '${NetworkStackName}-VpcId'
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
  
  AppInstance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-xxxxx
      InstanceType: t3.small
      SubnetId: !ImportValue
        Fn::Sub: '${NetworkStackName}-PublicSubnet1Id'
      SecurityGroupIds:
        - !Ref AppSecurityGroup
      UserData: !Base64
        Fn::Sub:
          - |
            #!/bin/bash
            echo "DB_HOST=${DBHost}" > /etc/environment
          - DBHost: !ImportValue
              Fn::Sub: '${DatabaseStackName}-DBEndpoint'

Outputs:
  InstanceId:
    Value: !Ref AppInstance
```

---

## ⚠️ Import/Export の制約

### 1. Export削除の制約

**重要**: Exportを参照しているスタックがあると、元のスタックは削除できません。

**なぜ？**
- アプリケーションスタックが「network-stack-VpcId」を使っている状態で
- ネットワークスタックを削除すると
- アプリケーションスタックが参照先を失い、エラーになってしまうから

**エラー例**:
```bash
# ネットワークスタックを削除しようとする
aws cloudformation delete-stack --stack-name network-stack

# エラーメッセージ:
# Export network-stack-VpcId is still imported by app-stack
# （app-stackがまだ使っているので削除できません）
```

**正しい削除順序**:

```bash
# 1. まず、参照している側（アプリケーションスタック）を削除
aws cloudformation delete-stack --stack-name app-stack
aws cloudformation wait stack-delete-complete --stack-name app-stack

# 2. 次に、参照されている側（ネットワークスタック）を削除
aws cloudformation delete-stack --stack-name network-stack
```

**覚え方**: **作成の逆順**で削除する
- 作成: ネットワーク → アプリケーション
- 削除: アプリケーション → ネットワーク

---

### 2. Export名の変更不可

**Exportを参照している間は、Export名を変更できません**

**なぜ？**
- Export名を変更すると、ImportValueが参照できなくなるから

**対処**:
1. 参照しているスタックを先に削除
2. Export名を変更
3. 参照しているスタックを再作成（新しいExport名で）

---

## 💡 ベストプラクティス

### 1. Export名にスタック名を含める

**重要**: 
- Export名は同一リージョン内で一意（ユニーク）である必要があります。
  - もっというと、同一アカウント・同一リージョン内でグローバルユニークである必要があります。

```yaml
# ✅ 良い例（スタック名を含める）
Outputs:
  VpcId:
    Value: !Ref MyVPC
    Export:
      Name: !Sub '${AWS::StackName}-VpcId'
      # 例: network-stack-VpcId

# ❌ 悪い例（他のスタックと重複しやすい）
Outputs:
  VpcId:
    Value: !Ref MyVPC
    Export:
      Name: VpcId
      # 複数のスタックがこの名前を使うとエラー
```

**なぜスタック名を含める？**
- 同じテンプレートから複数のスタックを作成できる
- 環境ごと（dev、stg、prod）にスタックを分けられる

---

### 2. スタックの依存関係を明確にする

**設計例**:
```
1. ネットワークスタック（VPC、Subnet）
   ↓ VPC ID、Subnet IDをExport
   
2. データベーススタック（RDS）
   ↓ VPC IDをImport
   ↓ DB Endpoint をExport
   
3. アプリケーションスタック（EC2、ALB）
   ↓ VPC ID、Subnet ID、DB Endpoint をImport
   
4. 監視スタック（CloudWatch）
   ↓ 各リソースIDをImport
```

**ポイント**: 依存関係はシンプルに！複雑な相互参照は避ける。

---

### 3. 削除順序を逆にする

**鉄則**: **作成の逆順**で削除する

```bash
# 作成順序（下から順に依存）
1. network-stack       # ← 最初に作成
2. database-stack      # ← network-stackに依存
3. app-stack           # ← database-stack、network-stackに依存

# 削除順序（上から順に削除）
1. app-stack           # ← 最初に削除（依存する側から）
2. database-stack      # ← 次に削除
3. network-stack       # ← 最後に削除（依存される側）
```

---

### 4. 参照を確認してから削除

**削除前に必ず確認**:

```bash
# このExportを参照しているスタックを確認
aws cloudformation list-imports --export-name network-stack-VpcId

# 出力例:
# {
#   "Imports": [
#     "app-stack",
#     "database-stack"
#   ]
# }

# この場合、app-stack と database-stack を先に削除する必要がある
```

---

## 🚨 Export / ImportValue の失敗例と回避方法

### 前提：Export 名の性質

**重要な制約**:
- ✅ 同一アカウント・同一リージョン内でグローバルユニーク
- ⚠️ 一度 Export すると、その値を Import している限り
  - Export 名の変更不可
  - Export の削除不可
- ⚠️ Import しているスタックがあると、Export 側スタックの削除や一部更新が失敗することがある

**この制約を理解しておくことが、実務での事故防止に超重要です！**

---

### ❌ 失敗例 1：後から変えたくなる名前を Export 名にしてしまう

#### パターン

最初に「ノリ」でこう書く：

```yaml
Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: "Vpc-001"    # ← 後悔する命名
```

あとで環境が増えてきて：
- 「やっぱり `dev-vpc-id` とか、`projectA-dev-vpc` に変えたい…」
- でも、すでに他のスタックで `!ImportValue Vpc-001` を使っている

#### どうなるか

- ❌ Export 名を変更しようとすると、CloudFormation の更新がエラーで失敗します
- ❌ Import しているスタックが生きている限り、古い Export 名を変えられません

#### 回避策

**1. 最初から「将来も変えない前提」の名前にする**

```yaml
# ✅ 良い例
Export:
  Name: pf01-dev-VpcId           # プロジェクト + 環境 + リソース
  # または
  Name: projectA-common-vpc-id   # 安定した命名規則
```

**命名パターン**: `環境 + 用途 + リソース` の組み合わせで安定命名

**2. もしどうしても変えたくなったら**

```yaml
# Step 1: 新しい Export 名を追加で作る（古いのも残す）
Outputs:
  VpcIdOld:    # 旧
    Value: !Ref VPC
    Export:
      Name: Vpc-001
  
  VpcIdNew:    # 新
    Value: !Ref VPC
    Export:
      Name: projectA-dev-vpc-id
```

```yaml
# Step 2: すべての Import 側スタックを順次切り替える
# 旧：!ImportValue Vpc-001
# 新：!ImportValue projectA-dev-vpc-id
```

```bash
# Step 3: 最後に旧 Export を削除
```

**結論**: かなり手間なので、**最初の命名設計が超重要**です！

---
### ❌ 失敗例 2：Export 名の重複

#### パターン

別チーム or 過去のテンプレートで、うっかり同じ Export 名を使う：

```yaml
# StackA
Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: "projectA-vpc-id"

# StackB（別テンプレート）
Outputs:
  AnotherVpcId:
    Value: !Ref OtherVPC
    Export:
      Name: "projectA-vpc-id"   # ← 同じ名前をつけてしまう！
```

#### どうなるか

- ❌ 2つ目のスタックの作成 / 更新がエラーで失敗します
- ❌ 「すでに同じ Export 名が存在する」という内容のエラーになります

#### 回避策

**Export 名は「プロジェクト単位で命名ルールを決める」**

```
フォーマット例：<System>-<Env>-<Layer>-<Resource>

例：
- sns-app-dev-network-vpc-id
- sns-app-dev-app-alb-arn
- projectA-prod-db-endpoint
```

**重要**: ルールを README や Wiki に残して、チーム全員で共有しておく！

---
### ❌ 失敗例 3：Import されている Export を持つスタックを削除しようとして失敗

#### パターン

「そろそろ VPC を作り直したいから、network スタック（VPC スタック）ごと消そう」

しかし、その VPC ID を Export していて、他のスタックが `!ImportValue` している状態。

#### どうなるか

- ❌ network スタックの削除が **ロールバック** します
- ❌ 「この Export はまだ他のスタックに Import されているため削除できません」という類のエラー

#### 回避策

**依存関係を整理する**

```bash
# Step 1: どのスタックが !ImportValue を使っているか洗い出す
aws cloudformation list-imports --export-name network-stack-VpcId

# Step 2: 依存側スタックを順に対応
# ① 別の Export に切り替える or パラメータ入力に変える
# ② スタックを削除する

# Step 3: 最後に Export を持つスタックを削除する
```

**運用設計のポイント**:

```
✅ 長寿命（めったに削除しない）
  - VPC スタック
  - ネットワーク基盤スタック

❌ 短命（頻繁に作り変える）
  - App スタック
  - DB スタック
```

**この役割分担で設計しておくと安全です！**

---
### ❌ 失敗例 4：Export 名をパラメータや !Sub で動的に変えまくる

#### パターン

こんな感じで Export 名そのものを環境やパラメータに依存させる：

```yaml
Parameters:
  Env:
    Type: String
    AllowedValues: [dev, stg, prod]

Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: !Sub "${Env}-VpcId"    # ← 一見良さそうだが...
```

一見良さそうですが、運用時に：
- `dev` → `stg` に Env パラメータを変更
- あるいは Env 値を typo で変えてしまう

#### どうなるか

- ❌ Export 名自体が変わるため、更新がエラーになります
- ❌ 既に `dev-VpcId` で Import しているスタックがあると、`stg-VpcId` への変更が拒否されます

#### 回避策

**環境ごとに「テンプレートは共通」だが、「スタック名を分ける」のが基本**

```bash
# ✅ 正しいパターン
Stack 名：projectA-network-dev → Export 名：projectA-dev-VpcId
Stack 名：projectA-network-stg → Export 名：projectA-stg-VpcId
```

**重要**: Export 名の内部で参照する `Env` は **固定される前提**にする（途中で Env だけ差し替えない）

---
### ❌ 失敗例 5：別リージョン / 別アカウントで ImportValue しようとする（そもそも不可）

#### パターン

- `ap-northeast-1` の VPC を `us-east-1` のスタックから Import したい
- あるいは、別アカウントの Export を Import したい

#### どうなるか

- ❌ CloudFormation の仕様上、ImportValue は **同一アカウント・同一リージョン内のみ有効**です
- ❌ そのため、Template の検証 or デプロイ時にエラーになります

#### 回避策

**クロスアカウント／クロスリージョンで値を共有したい場合は、別の方法を使う**

- ✅ **SSM Parameter Store**
- ✅ **Systems Manager (StackSet + Parameters)**
- ✅ **外部の設定管理**（Git, Parameter ファイルなど）

```yaml
# 例：SSM Parameter Store を使う場合
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      SubnetId: !Sub '{{resolve:ssm:/network/vpc-id}}'
```

**結論**: Export/ImportValue はあくまで「**同アカウント・同リージョン内の IaC 内部連携の仕組み**」と割り切る。

---
### ❌ 失敗例 6：循環参照（StackA ⇄ StackB）が発生する

#### パターン

- StackA が VPC ID を Export、StackB が Import して ALB を作る
- 逆に、StackB 側で作った SG ID を Export して、StackA 側の何かが Import する…など

```
StackA → Export VpcId
  ↑                 ↓
  └──── Import SGId ← StackB → Export SGId
```

#### どうなるか

- ❌ 依存関係が循環し、CloudFormation がどちらを先に作って良いかわからず設計破綻します
- ❌ 実際には、デプロイの順番が組めず、エラーや手動介入が必要になる

#### 回避策

**依存方向は「一方向だけ」にする**

```
✅ 正しいパターン

network（VPC / Subnet）
  ↓
app（ALB / EC2 / ECS）
  ↓
db（RDS / DynamoDB）
  ↓
monitoring（CloudWatch）
```

**原則**: 「基盤スタック → 上位スタック」の **一方通行ルール**を決めると、循環は発生しづらいです！

---
### ✅ まとめ：Export/ImportValue で事故らないための設計原則

#### 1. Export 名は「変えない前提」で設計する

```
命名規則例：system-env-layer-resource

例：
- sns-app-dev-network-vpc-id
- projectA-prod-app-alb-arn
- pf01-stg-db-endpoint
```

#### 2. Export 名は一意 & 役割がわかる名前にする

- ✅ チーム全員がルールを理解している
- ✅ 見ただけで何の値かわかる

#### 3. 依存方向は一方向にする

```
network → app → db のような階層構造
```

#### 4. クロスリージョン / クロスアカウント連携には使わない

- Export/ImportValue は同一アカウント・同一リージョン専用
- 別の方法（SSM Parameter Store など）を使う

#### 5. 基盤スタックは「長生き」、アプリスタックは「短命」

```
長寿命（Export 側）：VPC、ネットワーク基盤
短命（Import 側）：App、DB、Lambda
```

**消したい可能性のあるスタック側に Export を置かない！**

---

### 💡 実務での心構え

このあたりを押さえておくと、

- 「Export 名変えたいんだけど…あ、やめとこう」
- 「このスタック、他から Import されてないよね？」

と **事前に事故を未然防止**できるので、実務でかなり安心して CFn を触れるようになります！


---

## ✅ このレッスンのチェックリスト

- [ ] Outputs の役割を理解した
- [ ] Export で値をエクスポートできる
- [ ] ImportValue で他スタックの値を参照できる
- [ ] スタック間の依存関係を設計できる
- [ ] Export削除の制約を理解した
- [ ] 正しい削除順序を理解した
- [ ] Export 名の命名規則の重要性を理解した
- [ ] よくある失敗パターンと回避策を理解した

---

## 📚 次のステップ

次は **[06. 基礎サンプルテンプレート](06-sample-templates-basic.md)** で、実践的なテンプレートを作成します！

---

**スタック間連携をマスターして、モジュール化されたインフラを作りましょう！🚀**
