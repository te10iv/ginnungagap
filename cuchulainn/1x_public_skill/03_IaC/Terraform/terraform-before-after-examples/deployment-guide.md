# Terraform Before/After デプロイガイド

実際にTerraformコードを実行する手順

---

## 📋 前提条件

### 必須

- Terraform 1.0以上インストール済み
- AWS CLI インストール済み
- AWS認証情報設定済み（`aws configure`）

### 確認

```bash
# Terraform バージョン確認
terraform version

# AWS認証情報確認
aws sts get-caller-identity
```

---

## 🔴 Before版（学習用）

Before版は**実行不可**です。ハードコードされたリソースIDが実際には存在しないため、学習用のコード例として参照してください。

### Before版の確認

```bash
cd terraform-before-after-examples/before/

# コード確認
cat main.tf | less

# 問題点をメモしながら読む：
# - ハードコードされた箇所
# - 重複しているコード
# - 環境変更時に修正が必要な箇所
```

---

## 🟢 After版（実行推奨）

### Step 1: 準備

```bash
cd terraform-before-after-examples/after/

# tfvars ファイル作成
cp terraform.tfvars.example terraform.tfvars

# パスワード設定（必須）
vim terraform.tfvars
# db_password を変更
```

**terraform.tfvars**:
```hcl
db_password = "YourSecurePassword123!"  # 必ず変更
```

---

### Step 2: 初期化

```bash
# Terraform 初期化
terraform init

# プラグイン・モジュールのダウンロード
# 出力例:
# Initializing modules...
# Initializing the backend...
# Initializing provider plugins...
```

---

### Step 3: フォーマット・バリデーション

```bash
# コードフォーマット
terraform fmt -recursive

# バリデーション
terraform validate

# 出力: Success! The configuration is valid.
```

---

### Step 4: プラン確認

```bash
# プラン作成
terraform plan -out=tfplan

# 詳細確認
terraform show tfplan
```

**プランの読み方**:
```
Terraform will perform the following actions:

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                    = (known after apply)
      + cidr_block             = "10.0.0.0/16"
      + id                     = (known after apply)
      # ...
    }

Plan: 15 to add, 0 to change, 0 to destroy.
```

**記号の意味**:
- `+` : 作成される
- `-` : 削除される
- `~` : 変更される
- `-/+` : 置換される（削除→作成）⚠️

---

### Step 5: 適用

```bash
# プラン適用
terraform apply tfplan

# または対話式
terraform apply

# 完了まで約10分
```

---

### Step 6: 確認

```bash
# 出力値確認
terraform output

# JSON形式で取得
terraform output -json

# 特定の値のみ取得
terraform output web_public_ips

# State 確認
terraform state list

# 特定リソースの詳細
terraform state show aws_instance.web[0]
```

### Web Server アクセス

```bash
# Web Server IP 取得
WEB_IP=$(terraform output -raw web_public_ips | jq -r '.[0]')

# アクセス
curl http://${WEB_IP}

# またはブラウザで http://<IP> を開く
```

---

## 🔄 環境の切り替え

### 開発環境 → 本番環境

```bash
# 本番環境用のtfvars作成
cp terraform-prod.tfvars.example terraform-prod.tfvars

# パスワード設定
vim terraform-prod.tfvars

# 本番環境としてプラン
terraform plan -var-file=terraform-prod.tfvars

# 適用
terraform apply -var-file=terraform-prod.tfvars
```

**違い**:
- EC2: t3.small → m5.large
- RDS: db.t3.small → db.r6i.large
- Read Replica: 作成される
- Backup: 7日 → 30日

---

## 🗑️ リソース削除

```bash
# すべてのリソース削除
terraform destroy

# または特定のtfvarsで削除
terraform destroy -var-file=terraform-prod.tfvars

# 確認プロンプト:
# Do you really want to destroy all resources?
# Enter a value: yes

# 完了まで約10分
```

**⚠️ 注意**:
- RDS は削除前にスナップショットが作成されます
- スナップショットは手動削除が必要
- EBS ボリュームも別途確認・削除が必要な場合があります

---

## 📊 コスト概算

### 開発環境（最小構成）

| リソース | スペック | 料金/月 |
|---------|---------|---------|
| EC2 | t3.small × 2 | $30 |
| RDS | db.t3.small × 1 | $30 |
| データ転送 | - | $5 |
| **合計** | - | **約$65/月** |

### 本番環境（HA構成）

| リソース | スペック | 料金/月 |
|---------|---------|---------|
| EC2 | m5.large × 2 | $140 |
| RDS Primary | db.r6i.large (MultiAZ) | $400 |
| RDS Replica | db.r6i.large | $200 |
| データ転送 | - | $20 |
| **合計** | - | **約$760/月** |

**節約ポイント**:
- 開発環境は業務時間外停止
- Read Replica は本番のみ作成
- 学習後は必ず `terraform destroy`

---

## 🚨 トラブルシューティング

### エラー1: State lock エラー

```
Error: Error acquiring the state lock
```

**原因**: 他の terraform プロセスが実行中

**対処**:
```bash
# 強制ロック解除（最終手段）
terraform force-unlock <LOCK_ID>
```

---

### エラー2: AMI not found

```
Error: no matching AMI found
```

**原因**: リージョンにAMIが存在しない

**対処**:
```hcl
# data source の filter を確認
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

---

### エラー3: Resource already exists

```
Error: resource already exists
```

**原因**: 同じ名前のリソースが既に存在

**対処**:
```bash
# 既存リソースをimport
terraform import aws_vpc.main vpc-xxxxx

# またはリソース名を変更
```

---

## 🔍 State 操作コマンド

```bash
# State 一覧
terraform state list

# リソース詳細表示
terraform state show aws_instance.web[0]

# リソースを State から削除（Terraform管理から外す）
terraform state rm aws_instance.web[0]

# リソース名変更
terraform state mv aws_instance.old aws_instance.new

# State をPull（確認用）
terraform state pull > state.json
```

---

## 💡 実務での使い方

### パターン1: Workspace で環境分離

```bash
# Workspace 作成
terraform workspace new dev
terraform workspace new prod

# Workspace 切り替え
terraform workspace select dev
terraform apply

terraform workspace select prod
terraform apply -var-file=terraform-prod.tfvars
```

### パターン2: ディレクトリで環境分離（推奨）

```
environments/
├── dev/
│   ├── main.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    └── terraform.tfvars
```

---

## 🎓 学習チェックリスト

### 実行前
- [ ] Before版を読んで問題点を理解した
- [ ] After版の構造を理解した
- [ ] variables, locals, outputs の役割を理解した
- [ ] count と for_each の違いを理解した

### 実行中
- [ ] terraform init が成功した
- [ ] terraform plan を読めた
- [ ] `+`, `-`, `~`, `-/+` の意味を理解した
- [ ] terraform apply が成功した

### 実行後
- [ ] terraform output で値を確認した
- [ ] Web Serverにアクセスできた
- [ ] terraform state list で管理対象を確認した
- [ ] terraform destroy でクリーンアップした

### 応用
- [ ] terraform-prod.tfvars で本番環境を作成した
- [ ] 環境による違いを確認した
- [ ] 自分のプロジェクトに適用できる

---

## 📚 次のステップ

1. ✅ terraform-before-after-guide.md を熟読
2. ✅ After版を実行して動作確認
3. ✅ 変数を変更して再実行
4. ✅ 新しいリソースを追加してみる
5. ✅ モジュールを分離してみる
6. ✅ 実際のプロジェクトに適用

---

**このガイドで、Terraform中級テクニックを実践習得！🚀**
