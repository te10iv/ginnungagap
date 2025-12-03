# Terraform Cheat Sheet

**対象**: Terraformの基本を軽く勉強済みの方向け

**重要**: Terraformは「ディレクトリ単位」で実行するツール。`main.tf`や`*.tf`があるディレクトリで操作します。

```bash
cd ./terraform/nagios  # Terraformのコードがあるディレクトリに移動
```

---

## 基本コマンド（これだけ覚えれば95%動ける）

```bash
terraform init       # 初回/provider追加/変更時必須（provider DL、backend設定）
terraform fmt        # コード整形（チーム必須）
terraform validate   # 文法チェック（plan前に推奨）
terraform plan       # 変更確認（-/+再作成に注意！apply前必須）
terraform apply      # 実インフラ反映
terraform destroy    # 全リソース削除（本番禁止）
```

### コマンド詳細

#### `terraform init`
- **用途**: 初回またはprovider/module追加・変更時に必ず実行
- **処理内容**:
  - providerのダウンロード（`.terraform/`に保存）
  - backendの設定（S3など）
  - moduleのダウンロード
- **実行タイミング**:
  - プロジェクト初回
  - providerのバージョン変更
  - 新しいmodule追加
  - backend設定変更

```bash
# 基本
terraform init

# backendの再設定
terraform init -reconfigure

# moduleのアップグレード
terraform init -upgrade
```

#### `terraform fmt`
- **用途**: コードの自動整形（チームでは必須）
- **実行タイミング**: コミット前、PR作成前

```bash
# カレントディレクトリを整形
terraform fmt

# 再帰的に整形
terraform fmt -recursive

# チェックのみ（CI/CDで使用）
terraform fmt -check
```

#### `terraform validate`
- **用途**: 文法チェック（構文エラーの早期発見）
- **実行タイミング**: plan前、CI/CDパイプライン

```bash
terraform validate
```

#### `terraform plan`
- **用途**: 変更点の確認（最重要コマンド）
- **注意**: 破壊的変更（`-/+`）が無いか目視チェック必須
- **実行タイミング**: apply前に必ず実行

```bash
# 基本
terraform plan

# 特定の変数ファイルを指定
terraform plan -var-file="prod.tfvars"

# 出力を保存
terraform plan -out=plan.out

# 特定リソースのみ確認
terraform plan -target=aws_instance.web
```

#### `terraform apply`
- **用途**: 変更を実インフラに反映
- **注意**: plan結果を必ず確認してから実行

```bash
# 基本（確認プロンプトあり）
terraform apply

# 確認なし（CI/CDでのみ使用）
terraform apply -auto-approve

# 保存したplanを適用
terraform apply plan.out

# 変数ファイルを指定
terraform apply -var-file="prod.tfvars"
```

#### `terraform destroy`
- **用途**: 現在のstateで管理している全リソースを削除
- **警告**: 本番環境では絶対に実行しない

```bash
# 基本
terraform destroy

# 確認なし（検証環境のみ）
terraform destroy -auto-approve

# 特定リソースのみ削除
terraform destroy -target=aws_instance.test
```

---

## 部分的な操作（よく使う）

### 既存コードから一部だけ構築したい場合

`-target`オプションで特定リソースのみを操作します。

```bash
# 特定リソースのみplan
terraform plan -target=aws_instance.web

# 特定リソースのみapply
terraform apply -target=aws_instance.web

# 複数リソースを指定
terraform apply \
  -target=aws_instance.web \
  -target=aws_security_group.web

# モジュール全体を指定
terraform apply -target=module.vpc
```

**注意点**:
- 依存関係は自動で含まれる
- 多用すると整合性が崩れるリスクあり
- 本番環境では慎重に使用

### 作成済みリソースのうち、一部だけ削除したい場合

#### 方法1: `-target`で削除

```bash
# 特定リソースのみ削除
terraform destroy -target=aws_instance.test

# 確認
terraform state list
```

#### 方法2: コードから削除してapply

```bash
# 1. .tfファイルからリソース定義を削除
# 2. planで削除されることを確認
terraform plan

# 3. 削除を実行
terraform apply
```

#### 方法3: stateから除外（リソースは残す）

```bash
# リソースをTerraform管理から外す
terraform state rm aws_instance.legacy

# 確認
terraform state list
```

---

## よく使う確認系コマンド

### `terraform state list`
管理中のリソース一覧を表示

```bash
# 全リソース表示
terraform state list

# 特定パターンで絞り込み
terraform state list | grep aws_instance
```

**使用例**:
- 手動削除後にstateに残っている問題を確認
- 管理対象リソースの確認
- インポート前の確認

### `terraform state show`
特定リソースの詳細情報を表示

```bash
# リソースの詳細を表示
terraform state show aws_instance.web

# 特定の属性のみ確認
terraform state show aws_instance.web | grep private_ip
```

### `terraform output`
出力値の表示

```bash
# 全ての出力を表示
terraform output

# 特定の出力のみ表示
terraform output alb_dns_name

# JSON形式で出力
terraform output -json
```

**使用例**:
- ALB/NLBのDNS名取得
- RDSエンドポイント確認
- 他のツールとの連携

### `terraform show`
現在のstateまたはplanファイルの内容を表示

```bash
# 現在のstate内容を表示
terraform show

# planファイルの内容を表示
terraform show plan.out

# JSON形式で出力
terraform show -json
```

### `terraform graph`
リソースの依存関係をグラフ化

```bash
# DOT形式で出力
terraform graph

# 画像化（Graphviz必要）
terraform graph | dot -Tpng > graph.png
```

---

## state操作コマンド

### リソースの移動・名前変更

```bash
# リソースをstate内で移動
terraform state mv aws_instance.old aws_instance.new

# モジュール間で移動
terraform state mv module.old.aws_instance.web module.new.aws_instance.web
```

### リソースをstateから削除（実リソースは残す）

```bash
# 管理から外す
terraform state rm aws_instance.legacy

# 複数削除
terraform state rm aws_instance.test1 aws_instance.test2
```

### リソースのインポート

```bash
# 既存リソースをstateに追加
terraform import aws_instance.web i-1234567890abcdef0

# モジュール内のリソースをインポート
terraform import module.vpc.aws_vpc.main vpc-12345678
```

### stateの確認とバックアップ

```bash
# stateをローカルにダウンロード
terraform state pull > terraform.tfstate.backup

# stateをアップロード（危険！）
terraform state push terraform.tfstate

# backendからstateを更新
terraform refresh
```

---

## ワークスペース管理

複数環境（dev/stg/prod）を同じコードで管理する方法

```bash
# ワークスペース一覧
terraform workspace list

# 新規作成
terraform workspace new dev
terraform workspace new prod

# 切り替え
terraform workspace select dev

# 現在のワークスペース確認
terraform workspace show

# 削除
terraform workspace delete dev
```

**使用例**:
```hcl
# main.tf
locals {
  env = terraform.workspace
  instance_type = terraform.workspace == "prod" ? "t3.medium" : "t3.micro"
}

resource "aws_instance" "web" {
  instance_type = local.instance_type
  tags = {
    Environment = local.env
  }
}
```

---

## よく使うオプション

### 変数の指定

```bash
# コマンドラインで指定
terraform apply -var="instance_type=t3.micro"

# 変数ファイルを指定
terraform apply -var-file="prod.tfvars"

# 複数の変数ファイル
terraform apply -var-file="common.tfvars" -var-file="prod.tfvars"

# 環境変数で指定
export TF_VAR_instance_type="t3.micro"
terraform apply
```

### その他の便利なオプション

```bash
# 並列実行数を変更（デフォルト10）
terraform apply -parallelism=20

# ログレベルを変更
TF_LOG=DEBUG terraform apply

# 特定のログのみ出力
TF_LOG=TRACE terraform apply 2>&1 | grep -i error

# 状態のロックを無効化（緊急時のみ）
terraform apply -lock=false
```

---

## 実務で重要なポイント

### 1. Terraformは「state」に基づき差分を作る

3つの要素の整合性が重要:
- **コード** (`*.tf`ファイル)
- **実インフラ** (AWS/Azure/GCPなど)
- **state** (`terraform.tfstate`、前回の状態)

**問題例**:
- 手動でAWSコンソールからリソースを削除 → stateとの不整合
- 別の人が同時にapply → state競合
- stateファイルの喪失 → 全リソースが孤立

**対策**:
- S3などリモートbackendを使用
- state lockingを有効化（DynamoDB）
- 手動変更を避ける

---

### 2. planの差分記号を正しく読む

| 記号 | 意味 | 注意度 |
|------|------|--------|
| `+` | 作成 | 低 |
| `-` | 削除 | **高** |
| `~` | 更新（in-place） | 中 |
| `-/+` | 再作成（破壊的変更） | **最高** |

**見慣れない差分が出たら絶対にapplyしない**

**例**:
```
# 安全な変更
~ aws_instance.web
    tags.Environment: "dev" -> "development"

# 危険な変更（再作成）
-/+ aws_instance.web (new resource required)
    ami: "ami-123" -> "ami-456"

# 最も危険（削除）
- aws_db_instance.main
```

---

### 3. initが必要になるタイミング

```bash
# これらの変更後はinitが必要
terraform init
```

- providerの追加・変更・バージョンアップ
- 新しいmoduleの追加
- backend設定の変更（S3、DynamoDB等）
- `.terraform/`ディレクトリの削除後

---

### 4. stateの分離（dev/stg/prod）

**方法1: ディレクトリ分離**
```
terraform/
├── dev/
│   ├── main.tf
│   └── terraform.tfstate
├── stg/
│   ├── main.tf
│   └── terraform.tfstate
└── prod/
    ├── main.tf
    └── terraform.tfstate
```

**方法2: ワークスペース分離**
```bash
terraform workspace new dev
terraform workspace new stg
terraform workspace new prod
```

**方法3: backend key分離（推奨）**
```hcl
# dev/backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# prod/backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
```

---

## トラブルシューティング

### よくあるエラーと対処法

#### 1. State lock取得エラー

```
Error: Error acquiring the state lock
```

**原因**: 別のterraformプロセスが実行中、または前回の異常終了

**対処**:
```bash
# ロック状況確認
terraform force-unlock <LOCK_ID>

# 最終手段（慎重に）
terraform force-unlock -force <LOCK_ID>
```

#### 2. Provider not found

```
Error: Could not load plugin
```

**対処**:
```bash
# 再初期化
terraform init

# プロバイダーを更新
terraform init -upgrade
```

#### 3. リソースが見つからない

```
Error: Error reading: Resource not found
```

**対処**:
```bash
# stateから削除
terraform state rm <resource>

# または再インポート
terraform import <resource> <id>

# stateを最新化
terraform refresh
```

#### 4. 依存関係エラー

```
Error: Cycle: resource depends on itself
```

**対処**:
- 循環参照を確認
- `depends_on`の見直し
- リソース定義の順序を変更

---

## 注意事項（最重要）

### ⚠️ いつもと違うメッセージが出たら絶対にapplyしない

Terraformの事故は99%「planの見落とし」が原因。

**絶対に立ち止まるべきサイン**:

❌ **見慣れない差分**
```
-/+ aws_rds_instance.main (forces replacement)
```

❌ **リソースの大量な再作成**
```
Plan: 10 to add, 0 to change, 10 to destroy.
```

❌ **重要リソースの削除**
```
- aws_db_instance.production
- aws_lb.main
- aws_s3_bucket.important_data
```

❌ **予期しない属性変更**
```
~ aws_security_group.main
    ingress: [...] -> [] (all rules removed)
```

### ✅ チェックリスト

apply前に必ず確認:
- [ ] planの差分を最初から最後まで読んだ
- [ ] `-/+`（再作成）が無いか確認した
- [ ] 削除対象に重要リソースが無いか確認した
- [ ] 変更内容が意図通りか理解した
- [ ] 本番環境なら上長/チームの承認を得た
- [ ] バックアップ/ロールバック手順を確認した

---

## 便利なエイリアス設定

```bash
# ~/.bashrc または ~/.zshrc に追加
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tff='terraform fmt -recursive'
alias tfv='terraform validate'
alias tfo='terraform output'
alias tfs='terraform state'
alias tfsl='terraform state list'
alias tfsh='terraform state show'
alias tfw='terraform workspace'
```

---

## まとめ

### Terraformの本質

Terraformの本質は**「差分管理」**。

```
コード (.tf) + 実インフラ (AWS) + State (.tfstate) = 差分
```

### 成功の鍵

1. **planを必ず読む** - これだけで99%の事故は防げる
2. **小さく頻繁にapply** - 一度に大量の変更を避ける
3. **stateを保護する** - リモートbackend + state locking
4. **環境を分離する** - dev/stg/prodでstateを分ける
5. **手動変更を避ける** - 全てをコード化する

### 事故を防ぐ心構え

> 「いつもと違う」と感じたら、**必ず立ち止まる**

- 見慣れないメッセージ
- 予想外の差分
- 大量の再作成
- 重要リソースの削除

**これらは全て危険信号。applyする前に必ず確認すること。**

---

## 参考リンク

- [Terraform公式ドキュメント](https://developer.hashicorp.com/terraform)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
