# YAML補足資料 - CloudFormation版

CloudFormationで必要なYAML知識

---

## 🎯 この資料について

### 対象
- CloudFormation初心者
- YAMLを初めて使う方

### 範囲
- **CloudFormationで必要な範囲**: 必須⭐
- **一般的なYAML知識**: 参考（プログラミング用途等）

---

## ⭐ CloudFormationで必須のYAML知識

### 1. インデント（超重要！）

**ルール**: **スペース2つ**（タブはNG!!）

```yaml
# ✅ 正しい（スペース2つ）
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16

# ❌ 間違い（タブ使用）
Resources:
	MyVPC:    # ← タブ（エラーになる）

# ❌ 間違い（スペース数がバラバラ）
Resources:
MyVPC:
   Type: AWS::EC2::VPC
```

**VSCode設定**（推奨）:
```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false
}
```

---

### 2. キー・バリュー（基本）

```yaml
# 基本形
Key: Value

# CloudFormation例
AWSTemplateFormatVersion: '2010-09-09'
Description: My Template

# 階層構造
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: mybucket
```

**ポイント**:
- `:` の後には**スペース1つ**
- インデントでネスト構造を表現

---

### 3. 文字列

#### 基本形

```yaml
# 通常（クォート不要）
BucketName: mybucket
Description: This is my bucket
Environment: dev

# クォート付き（シングル・ダブル両方OK）
BucketName: 'mybucket'
BucketName: "mybucket"

# 数値を文字列として扱う場合（クォート必要）
Version: "2.0"
Port: "80"

# 特殊文字がある場合（クォート推奨）
Description: "Bucket for dev/test environment"
URL: "http://example.com"

# 複数行（| = 改行保持）⭐ CloudFormationで頻出
UserData: |
  #!/bin/bash
  yum update -y
  echo "Hello World"

# 複数行（> = 改行を空白に）
Description: >
  This is a long description
  that spans multiple lines.
```

---

#### クォートが必要な場合・不要な場合（重要！）

**基本原則**:
- Stringは**クォートなし**でも**クォート付き**でもOK
- ただし、YAMLの文法ルールで**必須の場合**がある

**クォートが必要な6パターン**:

##### ① YAMLが特別な意味として解釈してしまう文字列

```yaml
# ❌ 間違い（boolean として解釈される）
Value: yes     # ← true になってしまう
Value: no      # ← false になってしまう
Value: on      # ← true になってしまう
Value: off     # ← false になってしまう

# ❌ 間違い（数値として解釈される）
Value: 01      # ← 数値 1 になってしまう（ゼロ埋め消える）
Value: 123e4   # ← 指数表記 1230000 になってしまう

# ✅ 正しい（文字列として扱われる）
Value: "yes"
Value: "no"
Value: "on"
Value: "off"
Value: "01"
Value: "123e4"
```

##### ② コロン（:）を含む場合

```yaml
# ❌ 間違い（構文エラー）
URL: http://example.com

# ✅ 正しい
URL: "http://example.com"
KeyValue: "key:value"
```

##### ③ 先頭が特殊文字（*, &, !, ?, -, @, #）の場合

```yaml
# ❌ 間違い（YAMLの構文として解釈される）
Value: *abc     # ← アンカーとして解釈
Value: !abc     # ← タグとして解釈
Value: @user    # ← エラー

# ✅ 正しい
Value: "*abc"
Value: "!abc"
Value: "@user"
Value: "#comment-like"
```

##### ④ !Sub など組み込み関数の中で文字列を展開する場合

```yaml
# ❌ 避ける（エラーになる可能性）
BucketName: !Sub ${ProjectName}-bucket

# ✅ 正しい（シングルクォート推奨）
BucketName: !Sub '${ProjectName}-bucket'
BucketName: !Sub "${ProjectName}-bucket"    # ダブルでもOK
```

##### ⑤ 改行・スペースを保持したい場合

```yaml
# 複数行の文字列
Value: |
  line1
  line2
  line3

# 先頭・末尾のスペースを保持
Value: "  spaced value  "
```

##### ⑥ JSONやBase64のような複雑な記号を含む場合

```yaml
# JSON文字列
JsonData: "{\"key\":\"value\"}"

# Base64エンコード
EncodedData: "SGVsbG8gV29ybGQ="
```

---

#### クォートが不要な場合

```yaml
# 単純な文字列はクォートなしでOK
Environment: dev
BucketName: my-bucket
InstanceName: web-server-01
InstanceType: t3.micro
AvailabilityZone: ap-northeast-1a
SecurityGroup: MySecurityGroup
```

CloudFormationの典型的なパラメータ値（InstanceType、AZ、タグ名など）は**クォートなし**で問題ありません。

---

#### クォート必要性まとめ（表形式）

| ケース | クォート | 例 |
|--------|---------|-----|
| boolean と誤解される文字列 | **必要** | `"yes"`, `"no"`, `"on"`, `"off"` |
| ゼロ埋め数値 | **必要** | `"01"`, `"001"` |
| 指数表記に見える文字列 | **必要** | `"123e4"` |
| コロン（:）を含む | **必要** | `"http://..."`, `"key:value"` |
| 先頭が特殊文字 | **必要** | `"*abc"`, `"!abc"`, `"@user"` |
| !Sub の文字列展開 | **必要** | `!Sub '${Env}-app'` |
| JSON文字列 | **必要** | `"{\"key\":\"value\"}"` |
| Base64データ | **必要** | `"SGVsbG8gV29ybGQ="` |
| 単純な文字列 | 不要 | `dev`, `mybucket`, `t3.micro` |

---

#### 実務での鉄則

**迷ったら、Stringはすべてクォートで囲っておけば安全！**

```yaml
# ✅ 安全策（明示的）
Environment: "dev"
InstanceType: "t3.micro"
BucketName: "mybucket"

# ✅ OK（シンプルな場合）
Environment: dev
InstanceType: t3.micro
BucketName: mybucket
```

**チーム開発では**:
- クォートあり：明示的で安全
- クォートなし：場合によってYAMLが誤解して事故る

**そのため、実務のCFnテンプレートではクォート推奨です。**

---

**CloudFormationでの使い分け**:
- 通常: クォート不要（ただし安全策としてクォート付きも推奨）
- UserData: `|` を使う⭐
- 長い説明: `>` を使う
- !Sub: **必ずクォート**⭐

---

### 4. リスト

```yaml
# 方法1: ハイフン（CloudFormationで推奨）
SecurityGroupIds:
  - sg-12345
  - sg-67890

Tags:
  - Key: Name
    Value: MyInstance
  - Key: Environment
    Value: dev

# 方法2: JSON形式（短い場合のみ）
AllowedValues: [dev, stg, prod]
Ports: [80, 443]
```

**CloudFormationでの使用例**:
```yaml
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      SecurityGroupIds:
        - !Ref WebSG
        - !Ref AppSG
      Tags:
        - Key: Name
          Value: WebServer
```

---

### 5. コメント

```yaml
# これはコメント
Resources:
  MyBucket:    # 行末コメント
    Type: AWS::S3::Bucket
    # Properties:    # コメントアウト
    #   BucketName: mybucket
```

**ポイント**:
- `#` 以降がコメント
- 複数行コメントは各行に `#` が必要

---

### 6. 真偽値

```yaml
# true/false
Enabled: true
MultiAZ: false

# yes/no も使える（同じ意味）
Enabled: yes
MultiAZ: no
```

**CloudFormation例**:
```yaml
Resources:
  MyRDS:
    Type: AWS::RDS::DBInstance
    Properties:
      MultiAZ: true          # Multi-AZ有効
      PubliclyAccessible: false  # Public アクセス無効
```

---

### 7. 数値

```yaml
# 整数
Port: 80
Count: 3

# 小数
Threshold: 0.5

# 文字列にしたい場合はクォート
Version: "1.0"
```

---

### 8. null（空値）

```yaml
# null（値なし）
OptionalValue: null
OptionalValue: ~        # null の別表記

# 値がない場合は省略可能
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    # Properties は省略可能（リソースによる）
```

---

## 🔧 CloudFormation固有の記法

### 1. 組み込み関数（短縮形）

```yaml
# CloudFormation専用の記法
Resources:
  MySubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC              # 短縮形⭐
      # VpcId: Fn::Ref: MyVPC       # 完全形（使わない）
      
      CidrBlock: !Sub '10.0.${SubnetNumber}.0/24'  # 短縮形⭐
      # CidrBlock:                   # 完全形（使わない）
      #   Fn::Sub: '10.0.${SubnetNumber}.0/24'
```

**ポイント**:
- `!` から始まるのがCloudFormation固有
- 短縮形を使う⭐

---

### 2. クォートのルール（CloudFormation固有）

#### シングル vs ダブル

```yaml
# ✅ 推奨（シングルクォート）⭐
Description: 'My CloudFormation Template'
BucketName: !Sub '${ProjectName}-bucket'

# ✅ OK（ダブルクォート）
Description: "My CloudFormation Template"
BucketName: !Sub "${ProjectName}-bucket"

# ✅ OK（クォートなし・シンプルな場合）
Description: My CloudFormation Template
BucketName: mybucket

# ❌ 避ける（!Sub では必ずクォート）
BucketName: !Sub ${ProjectName}-bucket    # エラーになる可能性
```

**CloudFormationでの推奨**:
1. **!Sub**: シングルクォート必須⭐
2. **通常**: クォートなしでOK（安全策としてクォート付きも推奨）
3. **特殊文字**: シングルクォート

**詳細な説明は「3. 文字列」セクションを参照**

---

## 📚 参考：一般的なYAML知識

### アンカー・エイリアス（CloudFormationでは非対応）

```yaml
# 一般的なYAMLでは使えるが、CloudFormationでは使えない
defaults: &defaults
  InstanceType: t3.small
  
dev:
  <<: *defaults    # CloudFormationでは使えない！
```

**CloudFormationの代替**:
- Mappings を使う
- Parameters を使う

---

### 複雑なデータ型（CloudFormationでは限定的）

```yaml
# 一般的なYAML
date: 2025-12-11
binary: !!binary base64data

# CloudFormationでは
# - 文字列、数値、真偽値、リスト、マップのみ
# - 日付型、バイナリ型は使わない
```

---

## ⚠️ よくあるエラーと対処法

### エラー1: インデントミス

```yaml
# ❌ エラー
Resources:
MyBucket:
  Type: AWS::S3::Bucket

# エラーメッセージ:
# Template format error: YAML not well-formed
```

**対処**: インデントをスペース2つに統一

```yaml
# ✅ 修正後
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
```

---

### エラー2: タブ使用

```yaml
# ❌ エラー（見た目では分からない）
Resources:
	MyBucket:    # ← タブ

# エラーメッセージ:
# mapping values are not allowed here
```

**対処**: タブをスペースに変換（VSCodeの設定）

---

### エラー3: クォートミス

```yaml
# ❌ エラー（!Sub でクォートなし）
BucketName: !Sub ${ProjectName}-bucket

# エラーメッセージ:
# Template error: variable names in Fn::Sub syntax must be unique
```

**対処**: !Sub は必ずクォート

```yaml
# ✅ 修正後
BucketName: !Sub '${ProjectName}-bucket'
```

---

### エラー3-2: boolean と誤解される文字列

```yaml
# ❌ エラー（yes が true として解釈される）
Parameters:
  EnableFeature:
    Type: String
    Default: yes    # ← boolean の true になってしまう

# 意図しない動作になる
```

**対処**: クォートで囲む

```yaml
# ✅ 修正後
Parameters:
  EnableFeature:
    Type: String
    Default: "yes"    # ← 文字列として扱われる
```

---

### エラー3-3: コロンを含む文字列

```yaml
# ❌ エラー（コロンが構文として解釈される）
URL: http://example.com

# エラーメッセージ:
# mapping values are not allowed here
```

**対処**: クォートで囲む

```yaml
# ✅ 修正後
URL: "http://example.com"
```

---

### エラー4: リストのインデント

```yaml
# ❌ エラー
Tags:
- Key: Name
  Value: MyBucket

# エラーメッセージ:
# Template format error: YAML not well-formed
```

**対処**: ハイフンのインデントを揃える

```yaml
# ✅ 修正後
Tags:
  - Key: Name
    Value: MyBucket
```

---

## ✅ CloudFormation用YAML チェックリスト

### 基本
- [ ] インデントはスペース2つ
- [ ] タブは使っていない
- [ ] `:` の後にスペースがある
- [ ] コメントは `#` で始まる

### CloudFormation固有
- [ ] `!Ref`, `!Sub` 等の短縮形を使っている
- [ ] `!Sub` はシングルクォートで囲んでいる
- [ ] UserData は `|` を使っている
- [ ] yes/no/on/off/01 等はクォートで囲んでいる
- [ ] URLやコロンを含む文字列はクォートで囲んでいる

### 構造
- [ ] `Resources:` セクションが必須
- [ ] `Type:` が各リソースに必須
- [ ] インデントが正しい

---

## 🔧 便利なツール

### VSCode拡張機能

```bash
# YAML拡張
code --install-extension redhat.vscode-yaml

# CloudFormation拡張
code --install-extension aws-cloudformation.yaml-schema
```

### CLIツール

```bash
# cfn-lint（テンプレート検証）
pip install cfn-lint
cfn-lint template.yaml

# YAML構文チェック
python -c "import yaml; yaml.safe_load(open('template.yaml'))"
```

---

## 📖 まとめ

### CloudFormationで必要なYAML知識

| 項目 | 重要度 | ポイント |
|------|--------|---------|
| インデント | ★★★★★ | スペース2つ、タブNG |
| キー・バリュー | ★★★★★ | `: ` 後にスペース |
| 文字列 | ★★★★★ | クォートの要否を理解⭐ |
| リスト | ★★★★★ | ハイフン形式 |
| コメント | ★★★☆☆ | `#` |
| 複数行 | ★★★★☆ | UserDataで `|` |
| 組み込み関数 | ★★★★★ | `!Ref`, `!Sub` 等 |
| クォートルール | ★★★★★ | yes/no/on/off/01等は必須⭐ |

### 学習の流れ

1. ✅ このYAMLガイドを読む
2. ✅ [01. CFn基礎](01-cfn-basics.md) に戻る
3. ✅ [02. 基本構文](02-basic-syntax.md) で実践
4. ✅ サンプルテンプレートで練習

---

**CloudFormationに必要なYAML知識をマスターしましょう！📚**
