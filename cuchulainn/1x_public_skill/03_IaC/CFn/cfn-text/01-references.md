# CloudFormation 参考資料一覧

---

## 📖 AWS公式ドキュメント

### 基礎ドキュメント

| タイトル | URL | 説明 |
|---------|-----|------|
| **CloudFormation ユーザーガイド** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/) | 公式の基本ガイド |
| **テンプレートリファレンス** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/template-reference.html) | 全リソースタイプの詳細 |
| **組み込み関数リファレンス** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html) | Ref, Sub, GetAtt等の詳細 |
| **疑似パラメータリファレンス** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html) | AWS::Region, AWS::StackName等 |

### 高度なトピック

| タイトル | URL | 説明 |
|---------|-----|------|
| **ネストスタック** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html) | スタック分割パターン |
| **変更セット** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html) | 安全な更新方法 |
| **ドリフト検出** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/using-cfn-stack-drift.html) | 手動変更の検出 |
| **StackSets** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html) | マルチアカウント/リージョン展開 |
| **カスタムリソース** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/template-custom-resources.html) | Lambda連携 |

---

## 🎯 ベストプラクティス

| タイトル | URL | 説明 |
|---------|-----|------|
| **CloudFormation ベストプラクティス** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/best-practices.html) | AWS推奨のパターン |
| **Well-Architected Framework** | [リンク](https://aws.amazon.com/jp/architecture/well-architected/) | アーキテクチャ設計原則 |
| **セキュリティベストプラクティス** | [リンク](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/security-best-practices.html) | セキュリティ考慮事項 |

---

## 📦 サンプルテンプレート

| リソース | URL | 説明 |
|---------|-----|------|
| **AWS公式サンプル** | [GitHub](https://github.com/awslabs/aws-cloudformation-templates) | 公式のサンプル集 |
| **AWS Solutions Library** | [リンク](https://aws.amazon.com/jp/solutions/) | 本番レベルのテンプレート |
| **CloudFormation Snippets (VS Code)** | [Marketplace](https://marketplace.visualstudio.com/items?itemName=aws-scripting-guy.cform) | VS Code拡張機能 |

---

## 🔧 ツール

### CLI / SDK

| ツール | URL | 説明 |
|--------|-----|------|
| **AWS CLI** | [リンク](https://aws.amazon.com/jp/cli/) | コマンドライン管理 |
| **AWS SDK** | [リンク](https://aws.amazon.com/jp/tools/) | プログラマティック操作 |
| **CloudFormation Linter (cfn-lint)** | [GitHub](https://github.com/aws-cloudformation/cfn-lint) | テンプレート検証ツール |
| **TaskCat** | [GitHub](https://github.com/aws-ia/taskcat) | テンプレート自動テスト |

### GUI / エディタ

| ツール | URL | 説明 |
|--------|-----|------|
| **CloudFormation Designer** | [リンク](https://console.aws.amazon.com/cloudformation/designer) | ビジュアルエディタ |
| **VS Code YAML拡張** | [Marketplace](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) | YAML編集支援 |
| **Former2** | [リンク](https://former2.com/) | 既存リソース→テンプレート変換 |

---

## 📊 リソースタイプ別リファレンス

### ネットワーク

| リソース | リファレンス | 説明 |
|---------|-------------|------|
| **AWS::EC2::VPC** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpc.html) | VPC作成 |
| **AWS::EC2::Subnet** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet.html) | Subnet作成 |
| **AWS::EC2::SecurityGroup** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group.html) | Security Group |
| **AWS::EC2::NatGateway** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-natgateway.html) | NAT Gateway |
| **AWS::ElasticLoadBalancingV2::LoadBalancer** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-loadbalancer.html) | ALB/NLB |

### コンピュート

| リソース | リファレンス | 説明 |
|---------|-------------|------|
| **AWS::EC2::Instance** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-instance.html) | EC2インスタンス |
| **AWS::AutoScaling::AutoScalingGroup** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-as-group.html) | Auto Scaling |
| **AWS::Lambda::Function** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html) | Lambda関数 |
| **AWS::ECS::Cluster** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-cluster.html) | ECS Cluster |

### ストレージ

| リソース | リファレンス | 説明 |
|---------|-------------|------|
| **AWS::S3::Bucket** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-bucket.html) | S3バケット |
| **AWS::RDS::DBInstance** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-rds-database-instance.html) | RDS |
| **AWS::DynamoDB::Table** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dynamodb-table.html) | DynamoDB |

### セキュリティ

| リソース | リファレンス | 説明 |
|---------|-------------|------|
| **AWS::IAM::Role** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html) | IAM Role |
| **AWS::IAM::Policy** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-policy.html) | IAM Policy |
| **AWS::KMS::Key** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-kms-key.html) | KMS暗号化キー |
| **AWS::SecretsManager::Secret** | [Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-secretsmanager-secret.html) | Secrets Manager |

---

## 🎓 学習コンテンツ

### AWS公式トレーニング

| コンテンツ | URL | 説明 |
|----------|-----|------|
| **AWS Skill Builder** | [リンク](https://skillbuilder.aws/) | 無料オンライン学習 |
| **CloudFormation Workshop** | [リンク](https://catalog.workshops.aws/cfn101/) | ハンズオンワークショップ |
| **AWS Training** | [リンク](https://aws.amazon.com/jp/training/) | 公式トレーニング |

### コミュニティ

| リソース | URL | 説明 |
|---------|-----|------|
| **AWS re:Post** | [リンク](https://repost.aws/) | Q&Aコミュニティ |
| **Stack Overflow** | [リンク](https://stackoverflow.com/questions/tagged/cloudformation) | 技術Q&A |
| **Reddit r/aws** | [リンク](https://www.reddit.com/r/aws/) | AWS総合コミュニティ |

### ブログ・記事

| リソース | URL | 説明 |
|---------|-----|------|
| **AWS ブログ（日本語）** | [リンク](https://aws.amazon.com/jp/blogs/news/) | AWS公式ブログ |
| **Classmethod（日本語）** | [リンク](https://dev.classmethod.jp/referencecat/cloudformation/) | 技術ブログ |
| **Qiita CloudFormation タグ** | [リンク](https://qiita.com/tags/cloudformation) | 日本語技術記事 |

---

## 📱 チートシート・クイックリファレンス

| リソース | URL | 説明 |
|---------|-----|------|
| **Cloudcraft** | [リンク](https://www.cloudcraft.co/) | アーキテクチャ図作成 |
| **AWS Architecture Icons** | [リンク](https://aws.amazon.com/jp/architecture/icons/) | アイコン集 |
| **CloudFormation Cheat Sheet** | [PDF](https://tutorialsdojo.com/aws-cloudformation/) | まとめ資料 |

---

## 🔍 トラブルシューティング

| リソース | URL | 説明 |
|---------|-----|------|
| **CloudFormation トラブルシューティング** | [Docs](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/troubleshooting.html) | 公式トラブルシューティング |
| **Service Quotas** | [Console](https://console.aws.amazon.com/servicequotas/) | サービス上限確認 |
| **AWS Status** | [リンク](https://status.aws.amazon.com/) | AWSサービスステータス |

---

## 🎯 資格試験

| 試験 | URL | 説明 |
|------|-----|------|
| **AWS Certified Solutions Architect** | [リンク](https://aws.amazon.com/jp/certification/certified-solutions-architect-associate/) | Associate/Professional |
| **AWS Certified DevOps Engineer** | [リンク](https://aws.amazon.com/jp/certification/certified-devops-engineer-professional/) | Professional |
| **模擬試験** | [リンク](https://www.udemy.com/topic/aws-certified-solutions-architect-associate/) | Udemy等の模擬試験 |

---

## 📚 書籍

| タイトル | 説明 |
|---------|------|
| **AWSではじめるインフラ構築入門** | CloudFormation実践入門 |
| **Amazon Web Services 基礎からのネットワーク&サーバー構築** | AWS全般の基礎 |
| **AWS認定資格試験テキスト** | 資格試験対策 |

---

## 🆕 新機能・アップデート

| リソース | URL | 説明 |
|---------|-----|------|
| **What's New with AWS** | [リンク](https://aws.amazon.com/jp/new/) | AWS新機能発表 |
| **CloudFormation リリースノート** | [リンク](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/ReleaseHistory.html) | リリース履歴 |
| **AWS Podcast** | [リンク](https://aws.amazon.com/jp/podcasts/aws-podcast/) | 音声コンテンツ |

---

**この資料集で、CloudFormationの学習リソースは完璧！📚**
