# 01. 高度なフィルタリング

JMESPathを使いこなす

---

## 🎯 学習目標

- JMESPathの構文を深く理解する
- 複雑な条件フィルタが書ける
- Projection（射影）を使いこなせる
- 関数を活用できる

**所要時間**: 45分

---

## 📐 JMESPath 基礎の復習

### 基本構文

```bash
# 配列の全要素
Reservations[*]

# ネストした配列
Reservations[*].Instances[*]

# 特定フィールド
Reservations[*].Instances[*].InstanceId
```

---

## 🔍 高度な条件フィルタ

### 比較演算子

| 演算子 | 説明 | 例 |
|--------|------|-----|
| `==` | 等しい | `State.Name=='running'` |
| `!=` | 等しくない | `State.Name!='terminated'` |
| `<` | 未満 | `VolumeSize<100` |
| `<=` | 以下 | `VolumeSize<=100` |
| `>` | より大きい | `VolumeSize>100` |
| `>=` | 以上 | `VolumeSize>=100` |

---

### 文字列の比較

```bash
# 完全一致
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?InstanceType==`t3.micro`]'

# 前方一致（startsWithは非対応のため、別の方法が必要）
# タグの値が特定の文字列を含む場合
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?contains(Tags[?Key==`Name`].Value|[0], `web`)]'
```

---

### 論理演算子

```bash
# AND条件
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?State.Name==`running` && InstanceType==`t3.micro`]'

# OR条件
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?State.Name==`running` || State.Name==`stopped`]'

# NOT条件
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?State.Name!=`terminated`]'

# 複合条件
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?(State.Name==`running` && InstanceType==`t3.micro`) || InstanceType==`t3.small`]'
```

---

### null チェック

```bash
# PublicIpAddressがnullでないインスタンス
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?PublicIpAddress!=`null`]'

# Nameタグが設定されているインスタンス
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?Tags[?Key==`Name`] | length(@) > `0`]'
```

---

## 📊 Projection（射影）

### List Projection

```bash
# 基本形：配列の各要素から特定フィールドを抽出
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].InstanceId'

# 複数フィールド（配列形式）
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType]'

# 複数フィールド（オブジェクト形式）
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType}'
```

---

### Flatten Projection

```bash
# 二重配列を平坦化
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text

# 比較：
# [*][*] → ネストした配列のまま
# [][]   → 平坦化された配列
```

---

### Object Projection

```bash
# オブジェクトの値を配列として取得
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{
    ID:InstanceId,
    Type:InstanceType,
    State:State.Name,
    IP:PublicIpAddress,
    Name:Tags[?Key==`Name`].Value|[0]
  }'
```

---

## 🔧 JMESPath 関数

### length() - 長さを取得

```bash
# インスタンス数をカウント
aws ec2 describe-instances \
  --query 'length(Reservations[*].Instances[*])'

# タグの数をカウント
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{
    ID:InstanceId,
    TagCount:length(Tags)
  }'
```

---

### contains() - 含まれているかチェック

```bash
# Nameタグに"web"を含むインスタンス
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?contains(Tags[?Key==`Name`].Value|[0], `web`)]'

# セキュリティグループに特定のSGが含まれるか
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?contains(SecurityGroups[*].GroupId, `sg-xxxxx`)]'
```

---

### starts_with() / ends_with()

```bash
# Nameタグが"web"で始まるインスタンス
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?starts_with(Tags[?Key==`Name`].Value|[0], `web`)]'

# Nameタグが"server"で終わるインスタンス
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?ends_with(Tags[?Key==`Name`].Value|[0], `server`)]'
```

---

### sort_by() - ソート

```bash
# LaunchTimeでソート（昇順）
aws ec2 describe-instances \
  --query 'sort_by(Reservations[*].Instances[*], &LaunchTime)'

# InstanceTypeでソート
aws ec2 describe-instances \
  --query 'sort_by(Reservations[*].Instances[*], &InstanceType)[*].{
    ID:InstanceId,
    Type:InstanceType
  }'

# 降順ソート（reverse関数と組み合わせ）
aws ec2 describe-instances \
  --query 'reverse(sort_by(Reservations[*].Instances[*], &LaunchTime))'
```

---

### max_by() / min_by() - 最大・最小

```bash
# 最新のインスタンス
aws ec2 describe-instances \
  --query 'max_by(Reservations[*].Instances[*], &LaunchTime)'

# 最も古いインスタンス
aws ec2 describe-instances \
  --query 'min_by(Reservations[*].Instances[*], &LaunchTime)'
```

---

### join() - 文字列結合

```bash
# InstanceIdをカンマ区切りで結合
aws ec2 describe-instances \
  --query 'join(`, `, Reservations[*].Instances[*].InstanceId)' \
  --output text

# 出力例:
# i-123..., i-456..., i-789...
```

---

### to_string() - 文字列変換

```bash
# 数値を文字列に変換
aws ec2 describe-volumes \
  --query 'Volumes[*].{
    ID:VolumeId,
    Size:to_string(Size)
  }'
```

---

## 🎨 複雑な実践例

### 例1: 複数条件での絞り込み

```bash
# 実行中 かつ t3系 かつ PublicIPあり
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?
    State.Name==`running` &&
    starts_with(InstanceType, `t3.`) &&
    PublicIpAddress!=`null`
  ].{
    Name:Tags[?Key==`Name`].Value|[0],
    ID:InstanceId,
    Type:InstanceType,
    IP:PublicIpAddress
  }' \
  --output table
```

---

### 例2: タグベースのグループ化

```bash
# Environmentタグごとにインスタンスを集計
for env in dev stg prod; do
    count=$(aws ec2 describe-instances \
      --filters "Name=tag:Environment,Values=$env" \
      --query 'length(Reservations[*].Instances[*])' \
      --output text)
    echo "Environment: $env, Count: $count"
done
```

---

### 例3: ネストした情報の抽出

```bash
# セキュリティグループのルール詳細を抽出
aws ec2 describe-security-groups \
  --query 'SecurityGroups[*].{
    Name:GroupName,
    ID:GroupId,
    InboundRules:IpPermissions[*].{
      Protocol:IpProtocol,
      FromPort:FromPort,
      ToPort:ToPort,
      CIDR:IpRanges[*].CidrIp|[0]
    }
  }' \
  --output json
```

---

### 例4: 複数サービスの情報を統合

```bash
#!/bin/bash
# EC2とRDSの情報を統合

echo "=== EC2 Instances ==="
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].{
    Type:"EC2",
    Name:Tags[?Key==`Name`].Value|[0],
    ID:InstanceId,
    LaunchTime:LaunchTime
  }' \
  --output table

echo ""
echo "=== RDS Instances ==="
aws rds describe-db-instances \
  --query 'DBInstances[*].{
    Type:"RDS",
    Name:DBInstanceIdentifier,
    ID:DbiResourceId,
    LaunchTime:InstanceCreateTime
  }' \
  --output table
```

---

## 🔬 高度なテクニック

### Pipe（パイプ）演算子

```bash
# パイプで結果を繋ぐ
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value | [0]'

# 複数のパイプ
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*] | [0] | {ID:InstanceId, Type:InstanceType}'
```

---

### Multi-Select Hash

```bash
# 複数のフィールドを同時に選択
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{
    BasicInfo: {ID:InstanceId, Type:InstanceType},
    Network: {IP:PublicIpAddress, VPC:VpcId},
    State: State.Name
  }'
```

---

### 条件分岐（三項演算子的な使い方）

```bash
# PublicIPがあればそれを、なければPrivateIPを表示
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{
    ID:InstanceId,
    IP:PublicIpAddress || PrivateIpAddress
  }'
```

---

## 🛠️ 実践スクリプト

### スクリプト1: 詳細レポート生成

```bash
#!/bin/bash
# EC2インスタンスの詳細レポートを生成

OUTPUT="ec2-report-$(date +%Y%m%d).json"

aws ec2 describe-instances \
  --query '{
    Summary: {
      TotalInstances: length(Reservations[*].Instances[*]),
      RunningInstances: length(Reservations[*].Instances[?State.Name==`running`]),
      StoppedInstances: length(Reservations[*].Instances[?State.Name==`stopped`])
    },
    InstancesByType: Reservations[*].Instances[*].InstanceType | sort(@) | {
      Types: @,
      UniqueTypes: unique(@)
    },
    Instances: Reservations[*].Instances[*].{
      Name:Tags[?Key==`Name`].Value|[0],
      ID:InstanceId,
      Type:InstanceType,
      State:State.Name,
      LaunchTime:LaunchTime,
      PublicIP:PublicIpAddress,
      PrivateIP:PrivateIpAddress
    } | sort_by(@, &LaunchTime)
  }' > "$OUTPUT"

echo "Report saved to: $OUTPUT"
```

---

### スクリプト2: コスト分析

```bash
#!/bin/bash
# インスタンスタイプ別のインスタンス数を集計

echo "=== Instance Type Distribution ==="

aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceType' \
  --output text | tr '\t' '\n' | sort | uniq -c | sort -rn

echo ""
echo "=== Total Running Instances ==="

aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'length(Reservations[*].Instances[*])'
```

---

## 💡 実践Tips

### Tip 1: クエリのデバッグ

```bash
# 段階的に確認
# Step 1: 基本構造
aws ec2 describe-instances --query 'Reservations'

# Step 2: Instancesまで
aws ec2 describe-instances --query 'Reservations[*].Instances'

# Step 3: 特定フィールド
aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId'

# Step 4: フィルタ追加
aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId'
```

---

### Tip 2: クエリをファイルに保存

```bash
# complex-query.jmespath
Reservations[*].Instances[?State.Name==`running`].{
  Name:Tags[?Key==`Name`].Value|[0],
  ID:InstanceId,
  Type:InstanceType,
  State:State.Name,
  LaunchTime:LaunchTime
} | sort_by(@, &LaunchTime) | reverse(@)

# 使用
aws ec2 describe-instances --query file://complex-query.jmespath --output table
```

---

### Tip 3: jqとの使い分け

```bash
# JMESPath（--query）の利点:
# - AWS CLIに標準搭載
# - AWS APIのレスポンス構造に最適化

# jqの利点:
# - より柔軟な処理
# - 複雑な変換が可能
# - JSONの生成・編集が得意

# 使い分け:
# シンプルな抽出 → --query
# 複雑な加工 → jq
```

---

## ✅ このレッスンのチェックリスト

- [ ] 複雑な条件フィルタが書ける
- [ ] Projectionを理解している
- [ ] JMESPath関数を使いこなせる
- [ ] ネストした情報を抽出できる
- [ ] 実務で使えるクエリが書ける

---

## 📚 次のステップ

次は **[02. スクリプト作成](02-scripting.md)** で、自動化スクリプトの作成を学びます！

---

**高度なフィルタリングをマスターしました！🚀**
