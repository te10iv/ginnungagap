# 01. CloudFormation基礎

CloudFormationとは何か？なぜ使うのか？

---

## 🎯 学習目標

- CloudFormationの基本概念を理解する
- IaC（Infrastructure as Code）のメリットを理解する
- CloudFormationの全体像を把握する

**所要時間**: 30分

---

## 📚 CloudFormationとは？

### 定義

**AWS CloudFormation** = AWSインフラを**コード（テンプレート）で定義し、自動的に構築・管理**するサービス

```
コードを書く → テンプレート作成 → スタック作成 → インフラ完成！
```

### 具体例

**手動の場合**:
1. AWSコンソールにログイン
2. VPCを作成
3. サブネットを2つ作成
4. Internet Gatewayを作成・アタッチ
5. Route Tableを作成・設定
6. Security Groupを作成
7. EC2インスタンスを起動
・・・
手でぽちぽちつくるのに慣れてる人でも　30分〜1時間はかかる
人間が作るので、作業ミスも起こり得る(常にもう一人が隣でチェックするなんてことになったらナンセンス。。。)


**CloudFormationの場合**:

- 事前に用意した設定ファイルを流せ、という実行命令をひとつ出せば、、、5分後...完成！
  - 設定ファイル完成後に、誰かに確認してもらえば良い
```bash
aws cloudformation create-stack \
  --stack-name my-web-app \
  --template-body file://template.yaml

```

---

## 🌟 IaC（Infrastructure as Code）とは？

### インフラをコードで管理する考え方

| 従来の手動管理 | IaC（CloudFormation） |
|--------------|---------------------|
| 手動でポチポチ | コードで定義 |
| 手順書が必要 | コードが手順書 |
| 再現困難 | 何度でも再現可能 |
| 人的ミス多発 | 自動化でミス削減 |
| バージョン管理不可 | Git管理可能 |

※別の仕組みと組み合わせれば無人で指定時刻に実行することも可能

---

## ✨ CloudFormationのメリット

### 1. 再現性

**同じテンプレート = 同じインフラ**

```yaml
# template.yaml を使えば...
# 開発環境: aws cloudformation create-stack --stack-name dev ...
# 本番環境: aws cloudformation create-stack --stack-name prod ...
# → 同じ構成を簡単に複製！
```

### 2. バージョン管理

```bash
git add template.yaml
git commit -m "Add RDS instance"
git push

# インフラの変更履歴が Git に残る！
# いつ、誰が、何を変更したか明確
```

### 3. 自動化

**手動作業の手間が不要に**

```yaml
# template.yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
  
  MySubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC    # ← VPC IDを自動で参照
      CidrBlock: 10.0.1.0/24
```

**手動の場合**:
1. VPCを作成
2. 作成されたVPC ID（vpc-xxxxx）をメモ
3. Subnetを作成する際に、手動でVPC IDを入力
4. Security Groupを作成する際に、また手動でVPC IDを入力
5. ...（毎回コピペが必要）

**CloudFormationの場合**:
- `!Ref MyVPC` と書くだけで自動的にVPC IDが使われる
- コピペ不要！ミスも発生しない！
- 依存関係も自動で解決（VPC → Subnet → EC2の順に作成される）

### 4. ドキュメント化

**コードが最新の設計書**

```yaml
# template.yaml を見れば...
# - どのリソースが存在するか
# - どう設定されているか
# - どう関連しているか
# → すべて分かる！
```

### 5. 削除も簡単

```bash
# スタック削除 = すべてのリソース削除
aws cloudformation delete-stack --stack-name my-web-app

# 関連リソースも正しい順序で削除される
# （手動だと削除順序ミスでエラー多発）
```

---

## 🏗️ CloudFormationの基本概念

### 1. テンプレート（Template）とは

**そのままインフラの設計図となる**（YAML or JSON）
- 現在はYAML形式で作成するのが主流

```yaml
# template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: My first CloudFormation template

Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-unique-bucket-name
```

### 2. スタック（Stack）

**テンプレートから作成されたリソースのまとまり**

```
template.yaml → aws cloudformation create-stack → スタック作成
                                                    ├── VPC
                                                    ├── Subnet x2
                                                    ├── EC2
                                                    └── RDS
```

**スタック = まとめて操作できる単位**
- **作成（Create）**: スタック作成 = 全リソースをまとめて作成
- **更新（Update）**: スタック更新 = 変更されたリソースだけ更新
- **削除（Delete）**: スタック削除 = 全リソースをまとめて削除

**メリット**: 
- 個別にリソースを削除する必要なし
- 削除忘れによる課金の心配なし
- 1コマンドで環境全体を削除可能

---

### 3. リソース（Resource）- 必須セクション

**作成されるAWSサービスの実体**

```yaml
Resources:                      # ← このセクションは必須！
  MyEC2Instance:                # ← リソース論理名（任意の名前）
    Type: AWS::EC2::Instance    # ← リソースタイプ（必須）
    Properties:                 # ← プロパティ（リソースごとに異なる）
      ImageId: ami-xxxxx
      InstanceType: t3.small
```

**必須要素**:
- `Resources`: セクション自体が必須
- `Type`: 各リソースに必須
- `Properties`: リソースの設定（多くは必須）

---

### 4. パラメータ（Parameter）- 任意セクション

**実行時に指定する変数**
何度も登場する値、状況によって値を使い分けたいものなどは、ここに追記していく楽になる。

```yaml
Parameters:               # 任意セクション
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, stg, prod]

Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub 'mybucket-${Environment}'
      # dev → mybucket-dev
      # prod → mybucket-prod
```

---

### 5. 出力（Output）- 任意セクション

**作成されたリソース情報の出力**

```yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16

Outputs:              # 任意セクション
  VpcId:
    Description: VPC ID
    Value: !Ref MyVPC
    # 出力: vpc-0123456789abcdef
```

**用途**:
- スタック作成後に値を確認
- 他スタックで値を参照（Export使用）
- CI/CDで値を取得

---

## 📝 現場で使う高度なセクション

### 全セクション一覧

```yaml
AWSTemplateFormatVersion: '2010-09-09'  # 推奨
Description: 説明                        # 任意

Metadata:             # 任意（パラメータグループ等のUI設定）
  AWS::CloudFormation::Interface:
    ParameterGroups:
      - Label:
          default: "Network Configuration"
        Parameters:
          - VpcCidr

Parameters:           # 任意（入力パラメータ）
  VpcCidr:
    Type: String

Mappings:             # 任意（キー・バリューマップ）
  EnvironmentMap:
    dev:
      InstanceType: t3.small
    prod:
      InstanceType: m5.large

Conditions:           # 任意（条件分岐）
  IsProduction: !Equals [!Ref Environment, prod]

Resources:            # 必須⭐
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCidr

Outputs:              # 任意（出力値）
  VpcId:
    Value: !Ref MyVPC
```

### セクション詳細

| セクション | 必須 | 用途 | 学習 |
|----------|------|------|------|
| `AWSTemplateFormatVersion` | 推奨 | テンプレート形式バージョン | 初級 |
| `Description` | 任意 | テンプレート説明 | 初級 |
| `Metadata` | 任意 | UI設定・メタ情報 | 中級 |
| `Parameters` | 任意 | 入力パラメータ | 初級 |
| `Mappings` | 任意 | 環境別設定マップ | 初級 |
| `Conditions` | 任意 | 条件分岐 | 初級 |
| **`Resources`** | **必須⭐** | **作成するリソース** | **初級** |
| `Outputs` | 任意 | 出力値 | 初級 |

💡 **詳細**: [チートシート](99-beginner-cheatsheet.md) と [02. 基本構文](02-basic-syntax.md) を参照

---

## 🔄 CloudFormationの動作フロー

```
1. テンプレート作成
   ↓
2. バリデーション（構文チェック）
   ↓
3. スタック作成開始
   ↓
4. リソースを依存関係順に作成
   ├── VPC作成
   ├── Subnet作成（VPC必要）
   ├── Internet Gateway作成
   ├── IGWをVPCにアタッチ
   ├── Route Table作成
   ├── Security Group作成
   └── EC2作成（Subnet, SG必要）
   ↓
5. CREATE_COMPLETE（完成！）
```

**自動で依存関係を解決**
- VPCがないとSubnetは作れない
- SubnetがないとEC2は起動できない
→ CloudFormationが正しい順序で作成

---

## 📊 スタックの状態（Stack Status）

### 作成時

| 状態 | 意味 |
|------|------|
| `CREATE_IN_PROGRESS` | 作成中 |
| `CREATE_COMPLETE` | 作成成功 ✅ |
| `CREATE_FAILED` | 作成失敗 ❌ |
| `ROLLBACK_IN_PROGRESS` | ロールバック中（失敗時） |
| `ROLLBACK_COMPLETE` | ロールバック完了 |

### 更新時

| 状態 | 意味 |
|------|------|
| `UPDATE_IN_PROGRESS` | 更新中 |
| `UPDATE_COMPLETE` | 更新成功 ✅ |
| `UPDATE_ROLLBACK_IN_PROGRESS` | 更新失敗でロールバック中 |
| `UPDATE_ROLLBACK_COMPLETE` | ロールバック完了 |

### 削除時

| 状態 | 意味 |
|------|------|
| `DELETE_IN_PROGRESS` | 削除中 |
| `DELETE_COMPLETE` | 削除成功 ✅ |
| `DELETE_FAILED` | 削除失敗 ❌ |

---

## 💡 CloudFormationの重要な特徴

### 1. 宣言的（Declarative）

**「何をしたいか」を記述**（どうやってやるかは自動）

```yaml
# こう書くだけ
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16

# CloudFormationが...
# - VPCを作成
# - 必要な設定を適用
# - 依存関係を解決
# → すべて自動！
```

### 2. 冪等性（Idempotent）

**何度実行しても同じ結果**

```bash
# 1回目: スタック作成
aws cloudformation create-stack --stack-name my-stack --template-body file://template.yaml
# → VPC作成

# 2回目（同じテンプレート）: 何も変更されない
aws cloudformation update-stack --stack-name my-stack --template-body file://template.yaml
# → "No changes to deploy"
```

### 3. ロールバック機能

**失敗したら自動的に元に戻す**

```
スタック作成中にエラー
  ↓
自動でロールバック
  ↓
作成済みリソースを削除
  ↓
元の状態に戻る（安全！）
```

---

## 🆚 CloudFormation vs 手動管理

### シナリオ: 3層Webアプリ構築

**手動の場合**:
```
所要時間: 1〜2時間
作業: マウスポチポチ30〜40回
ミス: 設定漏れ・入力ミス多発
再現: 手順書見ながら再度ポチポチ
削除: 依存関係を考えて手動削除（30分）
```

**CloudFormationの場合**:
```
所要時間: 5〜10分（コマンド1つ）
作業: aws cloudformation create-stack ...
ミス: テンプレートが正しければミスなし
再現: 同じコマンドで何度でも作成
削除: aws cloudformation delete-stack（5分）
```

---

## 🎓 実習: 最初のスタック作成

### Step 1: テンプレート作成

```yaml
# my-first-stack.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: My First CloudFormation Stack

Resources:
  MyFirstBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub 'my-first-bucket-${AWS::AccountId}'
      Tags:
        - Key: Name
          Value: MyFirstBucket
        - Key: Purpose
          Value: Learning
```

### Step 2: バリデーション

```bash
aws cloudformation validate-template \
  --template-body file://my-first-stack.yaml

# 出力例:
# {
#     "Parameters": [],
#     "Description": "My First CloudFormation Stack"
# }
```

### Step 3: スタック作成

```bash
aws cloudformation create-stack \
  --stack-name my-first-stack \
  --template-body file://my-first-stack.yaml

# 出力例:
# {
#     "StackId": "arn:aws:cloudformation:ap-northeast-1:123456789012:stack/my-first-stack/..."
# }
```

### Step 4: 状態確認

```bash
aws cloudformation describe-stacks --stack-name my-first-stack

# StatusがCREATE_COMPLETEになれば成功！
```

### Step 5: リソース確認

```bash
# S3バケットが作成されているか確認
aws s3 ls | grep my-first-bucket
```

### Step 6: 削除

```bash
aws cloudformation delete-stack --stack-name my-first-stack

# 数分後、スタックとS3バケットが削除される
```

---

## ✅ このレッスンのチェックリスト

- [ ] CloudFormationとは何か説明できる
- [ ] IaCのメリットを3つ以上言える
- [ ] テンプレート、スタック、リソースの違いを理解した
- [ ] スタックの状態（CREATE_COMPLETE等）を理解した
- [ ] 宣言的・冪等性・ロールバックの意味を理解した
- [ ] 最初のスタックを作成・削除できた

---

## 📚 次のステップ

次は **[02. 基本構文](02-basic-syntax.md)** でYAMLの書き方を学びます！

---

**CloudFormationの基礎を理解して、次のステップへ進みましょう！🚀**
