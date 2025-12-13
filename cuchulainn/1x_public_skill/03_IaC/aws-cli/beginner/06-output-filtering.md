# 06. 出力とフィルタリング

出力結果の整形と必要な情報の抽出

---

## 🎯 学習目標

- 3つの出力形式を使い分けられる
- --queryで必要な情報を抽出できる
- --filtersでリソースを絞り込める
- jqとの連携ができる

**所要時間**: 45分

---

## 📊 出力形式

### 3つの出力形式

```bash
# JSON形式（デフォルト）
aws ec2 describe-instances --output json

# テーブル形式（人間が見やすい）
aws ec2 describe-instances --output table

# テキスト形式（タブ区切り）
aws ec2 describe-instances --output text
```

---

### json形式

```bash
$ aws ec2 describe-instances --output json

{
    "Reservations": [
        {
            "Instances": [
                {
                    "InstanceId": "i-1234567890abcdef0",
                    "InstanceType": "t3.micro",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    }
                }
            ]
        }
    ]
}
```

**特徴**:
- ✅ プログラムで処理しやすい
- ✅ すべての情報が含まれる
- ✅ jqで加工できる
- ❌ 人間には読みにくい

---

### table形式

```bash
$ aws ec2 describe-instances --output table

-----------------------------------------------
|            DescribeInstances                |
+---------------------------------------------+
||              Reservations                 ||
|+-------------------------------------------+|
|||             Instances                    |||
||+-------------+---------------------------+||
|||  InstanceId |  InstanceType             |||
||+-------------+---------------------------+||
|||  i-123...   |  t3.micro                 |||
||+-------------+---------------------------+||
```

**特徴**:
- ✅ 人間が見やすい
- ✅ ターミナルで直接確認しやすい
- ❌ プログラムで処理しにくい
- ❌ すべての情報は表示されない

---

### text形式

```bash
$ aws ec2 describe-instances --output text

RESERVATIONS    123456789012    r-xxxxx
INSTANCES       ...     i-1234567890abcdef0     t3.micro
```

**特徴**:
- ✅ `cut`, `awk`, `grep`で処理しやすい
- ✅ シェルスクリプトで使いやすい
- ❌ 階層構造がわかりにくい

---

## 🔍 --query オプション

### JMESPathとは

AWS CLIの`--query`オプションはJMESPathという構文を使用します。

**基本構造**:
```bash
aws <service> <command> --query '<JMESPath式>'
```

---

### 基本的な抽出

```bash
# Reservationsを取得
aws ec2 describe-instances --query 'Reservations'

# Reservations内のInstancesを取得
aws ec2 describe-instances --query 'Reservations[*].Instances'

# すべてのInstanceIdを取得
aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId'
```

---

### 配列の操作

```bash
# 最初の要素
aws ec2 describe-instances --query 'Reservations[0]'

# 最後の要素
aws ec2 describe-instances --query 'Reservations[-1]'

# 範囲指定（0〜2番目）
aws ec2 describe-instances --query 'Reservations[0:3]'

# すべての要素（フラット化）
aws ec2 describe-instances --query 'Reservations[*].Instances[*]' --output text
```

---

### 特定フィールドの抽出

```bash
# InstanceIdのみ
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text

# 出力例:
# i-1234567890abcdef0 i-0987654321fedcba0
```

---

### 複数フィールドの抽出

```bash
# InstanceIdとInstanceTypeを取得
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType]' \
  --output table

# 出力例:
# -----------------------------------
# |      DescribeInstances          |
# +-----------+--------------------+
# |  i-123... |  t3.micro          |
# |  i-456... |  t3.small          |
# +-----------+--------------------+
```

---

### フィールド名を指定

```bash
# フィールド名付きで取得（JSONオブジェクト形式）
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{
    ID:InstanceId,
    Type:InstanceType,
    State:State.Name,
    IP:PublicIpAddress
  }' \
  --output table

# 出力例:
# ---------------------------------------------------------
# |                    DescribeInstances                  |
# +-------------+--------+----------+--------------------+
# |     ID      | State  |    IP    |       Type         |
# +-------------+--------+----------+--------------------+
# |  i-123...   | running| 1.2.3.4  |  t3.micro          |
# +-------------+--------+----------+--------------------+
```

---

### 条件フィルタ

```bash
# 実行中のインスタンスのみ
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?State.Name==`running`]'

# t3.microのみ
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?InstanceType==`t3.micro`]'

# 複数条件（AND）
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?State.Name==`running` && InstanceType==`t3.micro`]'

# 複数条件（OR）
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?State.Name==`running` || State.Name==`stopped`]'
```

**注意**: 文字列リテラルは**バッククォート**（\`）で囲む！

---

### Nameタグの取得

```bash
# Nameタグの値を取得
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' \
  --output text

# InstanceIdとNameタグを並べて表示
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[
    InstanceId,
    Tags[?Key==`Name`].Value|[0]
  ]' \
  --output table
```

---

### ソート

```bash
# LaunchTimeでソート（古い順）
aws ec2 describe-instances \
  --query 'sort_by(Reservations[*].Instances[*], &LaunchTime)'

# InstanceIdでソート
aws ec2 describe-instances \
  --query 'sort_by(Reservations[*].Instances[*], &InstanceId)'
```

---

### 集計関数

```bash
# インスタンス数をカウント
aws ec2 describe-instances \
  --query 'length(Reservations[*].Instances[*])'

# 出力例:
# 5
```

---

## 🎯 --filters オプション

### filtersとqueryの違い

| オプション | 処理タイミング | 用途 |
|-----------|--------------|------|
| `--filters` | AWS側で絞り込み | リソースの検索 |
| `--query` | ローカルで加工 | 出力の整形 |

**推奨**: 先に`--filters`で絞り込み、次に`--query`で整形

---

### 基本的なフィルタ

```bash
# 実行中のインスタンスのみ
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running"

# 停止中のインスタンスのみ
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=stopped"

# 複数の状態
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running,stopped"
```

---

### タグでフィルタ

```bash
# Nameタグが"WebServer"のインスタンス
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=WebServer"

# Environmentタグが"production"のインスタンス
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=production"

# 複数のタグ条件（AND）
aws ec2 describe-instances \
  --filters \
    "Name=tag:Name,Values=WebServer" \
    "Name=tag:Environment,Values=production"
```

---

### インスタンスタイプでフィルタ

```bash
# t3.microのみ
aws ec2 describe-instances \
  --filters "Name=instance-type,Values=t3.micro"

# 複数のインスタンスタイプ
aws ec2 describe-instances \
  --filters "Name=instance-type,Values=t3.micro,t3.small"
```

---

### VPCでフィルタ

```bash
# 特定VPC内のインスタンス
aws ec2 describe-instances \
  --filters "Name=vpc-id,Values=vpc-xxxxx"

# 特定Subnet内のインスタンス
aws ec2 describe-instances \
  --filters "Name=subnet-id,Values=subnet-xxxxx"
```

---

### filtersとqueryの組み合わせ

```bash
# 実行中のt3.microインスタンスのIDを取得
aws ec2 describe-instances \
  --filters \
    "Name=instance-state-name,Values=running" \
    "Name=instance-type,Values=t3.micro" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text
```

---

## 🔧 jq との連携

### jqとは

JSONを処理するコマンドラインツール

```bash
# インストール（Mac）
brew install jq

# インストール（Linux）
sudo apt install jq
```

---

### 基本的な使い方

```bash
# 整形して表示
aws ec2 describe-instances | jq '.'

# 特定フィールドを抽出
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId'

# 複数フィールド
aws ec2 describe-instances | jq '.Reservations[].Instances[] | {InstanceId, State}'
```

---

### 条件フィルタ

```bash
# 実行中のインスタンスのみ
aws ec2 describe-instances | jq '.Reservations[].Instances[] | select(.State.Name=="running")'

# t3.microのみ
aws ec2 describe-instances | jq '.Reservations[].Instances[] | select(.InstanceType=="t3.micro")'
```

---

### 整形

```bash
# カスタム形式で出力
aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "\(.InstanceId) \(.InstanceType) \(.State.Name)"'

# 出力例:
# i-1234567890abcdef0 t3.micro running
# i-0987654321fedcba0 t3.small stopped
```

---

## 🛠️ 実践例

### 例1: すべてのインスタンスの状態を一覧表示

```bash
#!/bin/bash
# すべてのインスタンスの状態を整形して表示

aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{
    Name:Tags[?Key==`Name`].Value|[0],
    ID:InstanceId,
    Type:InstanceType,
    State:State.Name,
    IP:PublicIpAddress,
    LaunchTime:LaunchTime
  }' \
  --output table
```

---

### 例2: 実行中のインスタンスのIPアドレスを取得

```bash
#!/bin/bash
# 実行中のインスタンスのIPアドレス一覧

aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[
    Tags[?Key==`Name`].Value|[0],
    PublicIpAddress
  ]' \
  --output text | column -t
```

---

### 例3: タグでグループ化して表示

```bash
#!/bin/bash
# Environmentタグでグループ化

for env in dev stg prod; do
    echo "=== Environment: $env ==="
    
    aws ec2 describe-instances \
      --filters "Name=tag:Environment,Values=$env" \
      --query 'Reservations[*].Instances[*].[
        InstanceId,
        InstanceType,
        State.Name
      ]' \
      --output table
    
    echo ""
done
```

---

### 例4: CSVファイルに出力

```bash
#!/bin/bash
# インスタンス一覧をCSVファイルに出力

echo "InstanceId,InstanceType,State,PublicIP,Name" > instances.csv

aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[
    InstanceId,
    InstanceType,
    State.Name,
    PublicIpAddress,
    Tags[?Key==`Name`].Value|[0]
  ]' \
  --output text | sed 's/\t/,/g' >> instances.csv

echo "Saved to instances.csv"
```

---

## 💡 実践Tips

### Tip 1: エイリアスを設定

```bash
# ~/.bashrc または ~/.zshrc
alias awst='aws --output table'
alias awsj='aws --output json'

# 使用例
awst ec2 describe-instances
```

---

### Tip 2: 複雑なクエリはファイルに保存

```bash
# query.jmespath
Reservations[*].Instances[*].{
  Name:Tags[?Key==`Name`].Value|[0],
  ID:InstanceId,
  Type:InstanceType,
  State:State.Name
}

# 使用
aws ec2 describe-instances --query file://query.jmespath --output table
```

---

### Tip 3: パイプで連携

```bash
# grepと組み合わせ
aws ec2 describe-instances --output text | grep running

# awkで加工
aws ec2 describe-instances --output text | awk '{print $6}'

# sortで並び替え
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text | tr '\t' '\n' | sort
```

---

## ⚠️ よくあるエラーと対処法

### エラー1: クエリ構文エラー

```bash
$ aws ec2 describe-instances --query 'Reservations[*].Instances[*].Name'

Invalid jmespath expression
```

**対処**: `Name`はタグなので正しくは：
```bash
aws ec2 describe-instances --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value'
```

---

### エラー2: フィルタ構文エラー

```bash
$ aws ec2 describe-instances --filters "Name=state,Values=running"

Parameter validation failed:
Unknown parameter in Filters[0]: "Name", must be one of: ...
```

**対処**: 正しいフィルタ名を使う
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
```

---

## ✅ このレッスンのチェックリスト

- [ ] 3つの出力形式を使い分けられる
- [ ] --queryで基本的な抽出ができる
- [ ] 条件フィルタが書ける
- [ ] --filtersでリソースを絞り込める
- [ ] filtersとqueryを組み合わせられる
- [ ] jqの基本的な使い方を理解している

---

## 📚 次のステップ

初級編はこれで完了です！**[99. 初級チートシート](99-beginner-cheatsheet.md)** で復習しましょう。

さらに学びたい方は **[中級編](../intermediate/README.md)** へ進みましょう！

---

**出力とフィルタリングをマスターしました！初級編完了です！🎉**
