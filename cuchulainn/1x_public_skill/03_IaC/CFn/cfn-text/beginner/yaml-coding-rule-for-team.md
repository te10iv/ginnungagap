# YAML コーディング規約（CloudFormation 含む）

チームで共有するYAML コーディング規約

---

## 🎯 0. 対象と前提

### 対象

- ✅ CloudFormation テンプレート（YAML）
- ✅ その他 IaC 系 YAML（CDK, Terraform の tfvars.yaml、CI/CD 設定など）

### 目的

- 📖 可読性・保守性を高める
- 🛡️ パースエラーや型誤認（yes/no, on/off 問題）を防ぐ
- 🤝 チームで「書き方の揺れ」を減らす

---

## 📏 1. 基本ルール（全体方針）

| 項目 | ルール |
|------|--------|
| インデント | スペース 2 文字固定 |
| タブ文字 | **禁止** |
| 文字コード | UTF-8 |
| 改行コード | LF |
| キーの命名 | kebab-case または CamelCase<br>（CFn の場合は公式リソース仕様に従う） |
| ファイルサイズ | 1 ファイルあたり 500 行以内<br>→ 超える場合はファイル分割を検討 |

---

## 🔢 2. インデントと改行

### 2-1. インデントはスペース 2 文字

```yaml
# ✅ 正しい
Resources:
  MyResource:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t3.micro
```

**ポイント**:
- ネストが深くなりすぎる場合は構造を見直す（マップの入れ子を減らす）

---

### 2-2. 改行ルール

- ✅ 上位セクション間には **1 行空行**を挿入
  - `Parameters` / `Mappings` / `Resources` / `Outputs` など
- ✅ リソースとリソースの間も **1 行空ける**

```yaml
# ✅ 正しい
Parameters:
  Environment:
    Type: String

Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    
  MySubnet:
    Type: AWS::EC2::Subnet
```

---

## 📝 3. 文字列（String）の書き方

### 3-1. 原則：String はダブルクォートで統一

```yaml
# ✅ 推奨（ダブルクォート）
Value: "dev"
BucketName: "my-app-bucket"
```

**理由**:
- ✅ boolean, 数値と誤判定されるのを防ぐ
- ✅ `!Sub` などで `${}` 展開する際のバグを避ける
- ✅ チームで統一しやすい

---

### 3-2. シングルクォートを使ってよいケース

**「変数展開させたくない」「中に `${}` をそのまま書きたい」場合のみ**

```yaml
# ✅ OK（展開させない文字列）
Value: '${Env}-app'

# ✅ OK（シングルクォート内の ' は '' で表現）
Value: 'Don''t stop'
```

---

### 3-3. クォート必須のケース

以下は **必ずダブルクォート**：

| パターン | 理由 | 例 |
|---------|------|-----|
| yes/no/on/off | boolean と誤認防止 | `"yes"`, `"no"`, `"on"`, `"off"` |
| ゼロ埋め数値 | ゼロ埋め保持 | `"01"`, `"001"` |
| URL | コロン（:）を含む | `"http://example.com"` |
| key:value形式 | コロン（:）を含む | `"key:value"` |
| !Sub の文字列展開 | ${}を含む | `"${Env}-app"` |

```yaml
# ✅ 正しい
Value: "yes"          # boolean と誤認防止
Value: "no"
Value: "on"
Value: "off"
Value: "01"           # ゼロ埋め保持
Value: "http://example.com"
Value: "key:value"
Value: "${Env}-app"
```

---

## 🔣 4. 真偽値 / 数値 / null の扱い

### ルール

| 型 | ルール | 例 |
|----|--------|-----|
| boolean | `true` / `false`（小文字）のみ使用 | `Enabled: true` |
| 数値 | クォートなしで記載 | `Count: 3` |
| null | 原則使わず、キーごと削除を検討 | - |

```yaml
# ✅ 正しい
Enabled: true
Count: 3
TimeoutSeconds: 30

# ❌ 禁止
Enabled: yes      # yes, no, on, off は禁止！
Enabled: on
```

**重要**: `yes`, `no`, `on`, `off` は **禁止**

---

## 📋 5. 配列（リスト）の書き方

### 5-1. 基本形

```yaml
# ✅ 正しい
SecurityGroupIngress:
  - IpProtocol: "tcp"
    FromPort: 22
    ToPort: 22
    CidrIp: "0.0.0.0/0"
  - IpProtocol: "tcp"
    FromPort: 80
    ToPort: 80
    CidrIp: "0.0.0.0/0"
```

**ポイント**:
- `-` の後ろにスペース 1 個
- 要素がマップの場合、`-` の次の行をインデント 2 文字

---

### 5-2. 1 行配列は「シンプルな文字列のみ」の場合に限定

```yaml
# ✅ OK（シンプルな文字列のみ）
AvailabilityZones: ["ap-northeast-1a", "ap-northeast-1c"]

# ❌ 避ける（長い場合やオブジェクトを含む場合）
# 長くなる場合は必ず縦に書く
```

---

## ⚡ 6. CloudFormation 固有ルール

### 6-1. セクションの順序

CloudFormation テンプレートは、以下の順番を基本とする：

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: テンプレートの説明

Metadata:
  # メタ情報

Parameters:
  # パラメータ

Mappings:
  # マッピング

Conditions:
  # 条件

Resources:
  # リソース（必須）

Outputs:
  # 出力
```

**ポイント**: 使わないセクションは省略可だが、使うときは上記順を守る。

---

### 6-2. Intrinsic Functions（組み込み関数）の書き方

**短縮記法（YAML タグ）を使用する**：
- ✅ `!Ref`, `!Sub`, `!GetAtt`, `!Join`, `!If`, `!Equals`, `!And`, `!Or`, `!Not` など
- ❌ `Fn::Sub` などのロングフォームは **原則禁止**（読みづらい）

```yaml
# ✅ 正しい
Value: !Ref VPC
Name: !Sub "${EnvName}-vpc"
AlbDNS: !GetAtt ALB.DNSName

# ❌ 避ける（ロングフォーム）
Value:
  Fn::Ref: VPC
```

---

### 6-3. !Sub の書き方

**文字列は必ずダブルクォート**：

```yaml
# ✅ 正しい
Name: !Sub "${EnvName}-public-a"
Arn: !Sub "arn:aws:s3:::${BucketName}/*"
```

**マッピング形式の !Sub もありうるが、複雑になりやすいので多用しない**：

```yaml
# 使えるが、複雑になりやすい
Name: !Sub
  - "${Env}-${Name}"
  - { Env: !Ref Env, Name: "app" }
```

---

## 💬 7. コメントルール

### ルール

- ✅ コメントは必ず `#` の後にスペース 1 つ
- ✅ 「なぜその値か」を説明するコメントは積極的に書く
- ❌ 「コードから明らか」なコメントは書かない

```yaml
# ✅ 良いコメント
InstanceType: "t3.micro"   # 開発環境ではコスト削減のため小さめ

# ❌ 不要なコメント（コードから明らか）
InstanceType: "t3.micro"   # インスタンスタイプを指定
```

---

## 🏷️ 8. 命名規則（CloudFormation 向け推奨）

### 8-1. リソース論理名（Logical ID）

**PascalCase で記述**：

```yaml
# ✅ 正しい
Resources:
  VPC:
    Type: AWS::EC2::VPC
  
  PublicSubnetA:
    Type: AWS::EC2::Subnet
  
  AppServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
  
  WebEC2Instance:
    Type: AWS::EC2::Instance
```

**例**:
- `VPC`, `PublicSubnetA`, `AppServerSecurityGroup`, `WebEC2Instance`

---

### 8-2. Export 名（Outputs の Export Name）

**変えたくなくなるくらい明示的な命名にする**

**パターン例**: `<System>-<Env>-<Layer>-<Resource>`

```yaml
# ✅ 正しい
Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: "sns-app-dev-network-vpc-id"
      # システム名-環境-レイヤー-リソース
```

**例**:
- `sns-app-dev-network-vpc-id`
- `projectA-prod-app-alb-arn`
- `pf01-stg-db-endpoint`

---

## 📄 9. マルチライン文字列

**エラーメッセージ / スクリプトなど、複数行は `|`（リテラル）を利用**

```yaml
# ✅ 正しい
UserData:
  Fn::Base64: !Sub |
    #!/bin/bash
    yum update -y
    echo "Hello" > /var/www/html/index.html
```

**ポイント**:
- ✅ 末尾スペースは入れない

---

## 📁 10. ファイル分割とディレクトリ構成（CloudFormation 例）

### ディレクトリ構成例

```
cfn/
  ├── network/
  │   ├── vpc.yaml
  │   └── subnet.yaml
  ├── app/
  │   ├── ec2.yaml
  │   └── alb.yaml
  ├── db/
  │   └── rds.yaml
  └── parameters/
      ├── dev.json
      ├── stg.json
      └── prod.json
```

---

### テンプレート分割方針

| レイヤー | 内容 |
|---------|------|
| **network** | VPC / Subnet / RouteTable / SG |
| **app** | ALB / EC2 / ECS |
| **db** | RDS / ElastiCache |

**共通ルール**:
- ✅ Export / ImportValue で連携
- ❌ 循環依存は作らない

---

## 🔍 11. 自動チェック（Lint）の利用

### YAML 構文チェック

```bash
# yamllint を使用（GitHook / CI で実行）
yamllint template.yaml
```

### CloudFormation テンプレチェック

```bash
# cfn-lint を使用
cfn-lint template.yaml
```

**ルール**:
- ✅ PR 時に必ず両方を通す
- ✅ CI/CD パイプラインに組み込む

---

## ✅ 12. まとめ（運用のポイント）

### 重要ルール一覧

| 項目 | ルール |
|------|--------|
| インデント | スペース 2 文字、タブ禁止 |
| String | 基本ダブルクォート（例外的にシングル） |
| boolean | `true`/`false`、小文字のみ |
| yes/no/on/off | **禁止** |
| Intrinsic Functions | 短縮記法（`!Ref`, `!Sub`, `!GetAtt`） |
| Export 名 | 一意・安定命名を徹底 |
| ファイルサイズ | 500 行を目安に分割 |
| Lint | yamllint / cfn-lint を CI に組み込み |

---

## 📚 関連資料

- [yaml-guide-for-cfn.md](yaml-guide-for-cfn.md) - YAML の基礎知識
- [99-beginner-cheatsheet.md](99-beginner-cheatsheet.md) - CloudFormation クイックリファレンス

---

**チーム全員でルールを守って、保守性の高いテンプレートを作りましょう！🚀**
