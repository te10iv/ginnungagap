# AWS + Terraform + Ansible 学習ロードマップ

## 0. 学習のゴールと方針

- ゴール
  - 主要な AWS サービス（約 50 個）を「実際に構成を作れるレベル」で使いこなす
  - Terraform でインフラを IaC 化し、モジュール化までできるようにする
  - Ansible で Apache/Nginx・Zabbix・Nagios/Munin などの構成管理ができるようにする
  - 最終的に CI/CD（GitHub Actions or CodePipeline）+ Terraform Remote Backend まで到達する

- 学習スタイル
  - 各 Step ごとに **具体的なアウトプット（成果物）** を決める
  - Terraform は **共通モジュール（vpc, ec2, rds, alb, asg…）** を再利用
  - Ansible は **ロールベース**（roles/web, roles/zabbix など）で積み上げる
  - Cursor / ChatGPT を使ってコードを自動生成・リファクタリングしていく

---

## 0.5. 基礎固め：Terraform Before/After 実践教材（超推奨！）

**📖 教材**: [terraform-before-after-guide.md](../Terraform/terraform-before-after-guide.md)

### 目的

Terraformの**初心者コード**（ベタ書き）から**中級者コード**（変数・モジュール活用）への進化を、実際のコードで学ぶ。

### 習得できる中級テクニック

- ✅ **variables** によるパラメータ化
- ✅ **locals** による共通値の集約
- ✅ **outputs** による情報の受け渡し
- ✅ **count** による複数リソース作成
- ✅ **for_each** による動的リソース生成
- ✅ **module** によるコード分割・再利用
- ✅ **data source** による既存リソース取得
- ✅ **state** 管理の理解
- ✅ 実務ベストプラクティス（命名規則、ディレクトリ構成）

### AWS構成（最小構成）

```
VPC (10.0.0.0/16)
├── Public Subnet × 2 (AZ-a, AZ-c)
├── Private Subnet × 2 (AZ-a, AZ-c)
├── EC2 × 2台 (count で作成)
└── RDS × 2台 (Primary + Read Replica)
```

### Before版の問題点

- ❌ すべてハードコード
- ❌ 値の重複が多い
- ❌ 環境変更が困難
- ❌ 再利用性ゼロ
- ❌ 保守性が低い

### After版の改善点

- ✅ variables で柔軟性確保
- ✅ locals で命名規則統一
- ✅ for_each でサブネット動的生成
- ✅ count で EC2 複数作成
- ✅ module で VPC 分離
- ✅ outputs で値を公開
- ✅ data source で最新AMI取得

### 学習の流れ

1. **Before版を読む**（15分） - ハードコードの問題点理解
2. **After版を読む**（30分） - 構造化手法を理解
3. **比較表で確認**（10分） - 改善効果を実感
4. **実際にデプロイ**（30分） - 動作確認
5. **自分のコードに適用**（継続） - 実践

### 教材の特徴

- 📊 **Before/After比較表**で改善効果を明確化
- 🎯 **中級者が理解すべき概念一覧**を網羅
- 🗂️ **ディレクトリ構成パターン**3種類を提示
- 🔧 **terraform plan の読み方**を詳解
- 💡 **実務ベストプラクティス**を伝授

### この教材で到達できるレベル

- Step 1〜2 を自分で構造化できる
- モジュール化の設計ができる
- チーム開発に対応できるコードが書ける
- 保守性・再利用性の高いTerraformコードが書ける

**💡 推奨**: Step 1に進む前に、この教材で基礎を固めることを強く推奨！

---

## 1. AWS 主要サービス（対象 50 サービス）

### 1-1. Compute
- EC2
- Auto Scaling
- Elastic Load Balancing（ALB/NLB）
- Lambda
- ECS
- ECR
- Fargate

### 1-2. Storage
- S3
- S3 Glacier / Archive
- EBS
- EFS

### 1-3. Database & Cache
- RDS
- Aurora
- DynamoDB
- ElastiCache

### 1-4. Network
- VPC
- サブネット（Public / Private）
- Route Table
- Internet Gateway（IGW）
- NAT Gateway
- VPC Endpoint（Gateway/Interface）
- PrivateLink
- Transit Gateway
- Direct Connect
- Site-to-Site VPN
- Client VPN
- Route 53
- Global Accelerator

### 1-5. Security & Identity
- IAM
- KMS
- Secrets Manager
- Cognito
- WAF
- Shield Advanced
- Organizations
- Control Tower

### 1-6. Monitoring / Logging / Config
- CloudWatch
- CloudWatch Logs
- CloudTrail
- Config
- Trusted Advisor
- Systems Manager（SSM）

### 1-7. Delivery / CDN / Integration
- CloudFront
- API Gateway
- SQS
- SNS
- EventBridge
- Step Functions
- Athena

### 1-8. DevOps / CI/CD
- CodeCommit
- CodeBuild
- CodeDeploy
- CodePipeline
- GitHub Actions（外部サービスだが積極活用）

---

## 2. 学習ステップ一覧（Step 1〜14）

難易度ランク
- S：インフラの根幹・絶対理解
- A：実務で高頻度
- B：理解していれば十分

---

### Step 1（難易度：S）
**VPC + EC2 1台（超最小構成）**

- ゴール
  - 1つの VPC と Public Subnet 上に EC2(AL2023) を 1 台構築
  - SSM(Session Manager) でログイン
  - Apache を入れて「Hello World」ページを表示

- 使う AWS サービス
  - VPC, Subnet, Route Table, IGW, EC2, IAM, SSM, Security Group

- Terraform アウトプット（成果物）
  - `steps/step01_vpc-ec2/terraform/` 以下
    - `main.tf`
    - `variables.tf`
    - `outputs.tf`
  - 共通モジュール利用
    - `module "vpc" { ... }`
    - `module "ec2" { ... }`

- Ansible アウトプット（成果物）
  - `steps/step01_vpc-ec2/ansible/`
    - `inventory/hosts`
    - `site.yml`
    - `roles/web/tasks/main.yml`（Apache インストール & index.html 配備）

- 学びのテーマ
  - VPC / Subnet / RouteTable / IGW の最小構成
  - Security Group の基本（80/443/SSM）
  - UserData vs Ansible での構成管理

---

### Step 2（難易度：S）
**VPC + EC2(web/apache) + RDS(MySQL)**

- ゴール
  - Step1 の構成に Private Subnet + RDS(MySQL) を追加
  - EC2 から RDS へ接続できるようにする

- 使う AWS サービス
  - 上記 + RDS, DB Subnet Group, Parameter Group, Security Group(DB)

- Terraform アウトプット
  - `steps/step02_vpc-ec2-rds/terraform/`
    - `main.tf`, `variables.tf`, `outputs.tf`
  - モジュール
    - `module "vpc"`（再利用 or 強化）
    - `module "ec2_web"`
    - `module "rds_mysql"`

- Ansible アウトプット
  - `steps/step02_vpc-ec2-rds/ansible/`
    - `roles/web/templates/app-config.php.j2` などで DB 接続情報を設定

- 学びのテーマ
  - Private Subnet の考え方
  - DB Subnet Group / Multi-AZ の意味
  - SG で Web → DB 通信（ポート 3306）を許可する設計

---

### Step 3（難易度：A）
**監視用 VPC + Zabbix サーバ構築（Ansible）**

> 「本番 VPC」と「監視 VPC」を分けるイメージ

- ゴール
  - 既存 Web+RDS 構成とは別に、新しい VPC に Zabbix サーバ EC2 を 1 台立てる
  - VPC Peering or Transit Gateway（シンプルなら Peering）で接続
  - Web サーバに Zabbix Agent を入れて監視

- 使う AWS サービス
  - VPC（2つ）、VPC Peering、EC2、SSM, Security Group

- Terraform アウトプット
  - `steps/step03_monitoring-zabbix/terraform/`
    - 本番 VPC / 監視 VPC / Peering / EC2(Zabbix) をコード化

- Ansible アウトプット
  - `steps/step03_monitoring-zabbix/ansible/`
    - `roles/zabbix-server`
    - `roles/zabbix-agent`

- 学びのテーマ
  - マルチ VPC 構成
  - 監視サーバと監視対象のネットワーク設計
  - Ansible で複数ロール・複数ホストを扱う

---

### Step 4（難易度：S）
**ALB + AutoScaling（3層 Web 基盤の入り口）**

- ゴール
  - Web サーバ EC2 を Auto Scaling Group に変更
  - ALB + Target Group で EC2 をロードバランシング
  - ヘルスチェックの設定まで実施

- 使う AWS サービス
  - ALB, Target Group, Auto Scaling, Launch Template, EC2, CloudWatch（最低限）

- Terraform アウトプット
  - `steps/step04_alb-asg/terraform/`
  - モジュール例
    - `module "alb"`
    - `module "asg_web"`

- Ansible アウトプット
  - 基本は Step2 の Web ロールを流用
  - UserData で大部分を済ませるパターンも比較

- 学びのテーマ
  - ALB / Target Group / Listeners の設計
  - AutoScaling のスケーリングポリシーのイメージ
  - Immutable な Web サーバ設計

---

### Step 5（難易度：A）
**CloudWatch / SNS / Logs / Trail / Config**

- ゴール
  - EC2 / ALB / RDS などのメトリクスを CloudWatch で可視化
  - しきい値ベースの CloudWatch Alarm → SNS 通知
  - CloudTrail + Config で設定変更の履歴管理

- 使う AWS サービス
  - CloudWatch, CloudWatch Logs, SNS, CloudTrail, Config

- Terraform アウトプット
  - `steps/step05_observability/terraform/`
  - CloudWatch Alarm, SNS Topic, Subscription, CloudTrail, Config Rules などを作成

- 学びのテーマ
  - インフラ監視の基本（メトリクス / ログ / イベント）
  - SNS 通知の設計（メール / Slack Webhook など）
  - 監査・変更履歴管理の重要性

---

### Step 6〜14（概要だけ）

ここはざっくり。あとで Cursor と一緒に肉付けしていく想定。

- Step 6：S3 + CloudFront + ACM（静的サイト）
- Step 7：ECS on Fargate（コンテナ基盤）
- Step 8：ECS + Aurora + ElastiCache（DB & キャッシュ）
- Step 9：Lambda + API Gateway + DynamoDB + SQS + SNS + StepFunctions
- Step 10：WAF + Athena でログ分析
- Step 11：WAF / Shield / KMS / Secrets（セキュリティまわり）
- Step 12：CI/CD（GitHub Actions or CodePipeline）
- Step 13：CI/CD + Terraform Remote Backend（S3 + DynamoDB ロック）
- Step 14：Network サービス（Transit Gateway / DX / VPN 等）シナリオ + Terraform
