# CloudFormation 完全学習ガイド 📚

初心者から中級者まで、段階的にCloudFormationをマスター

---

## 🎯 この学習ガイドについて

CloudFormationを**実務で使いこなせるレベル**になるための、段階的な学習パスを提供します。

### 学習目標
- ✅ CloudFormationの基礎から高度な機能まで体系的に習得
- ✅ 実務で即戦力として活躍できるスキルセット
- ✅ 保守性の高いテンプレート設計能力

### 対象者
- CloudFormation初心者
- AWSインフラエンジニア
- DevOpsエンジニア志望者

---

## 📚 学習コンテンツ構成

### 🌱 初級編（Beginner）- 1〜2週間

**到達目標**: CloudFormationの基本を理解し、シンプルなテンプレートを作成できる

| 順序 | ファイル | 内容 | 所要時間 |
|------|---------|------|---------|
| 1 | **[01-cfn-basics](beginner/01-cfn-basics.md)** | CloudFormationとは？基本概念 | 30分 |
| 2 | **[02-basic-syntax](beginner/02-basic-syntax.md)** | テンプレート基本構文（YAML） | 45分 |
| 3 | **[03-parameters-mappings](beginner/03-parameters-mappings-conditions.md)** | Parameters, Mappings, Conditions | 60分 |
| 4 | **[04-intrinsic-functions](beginner/04-intrinsic-functions-basic.md)** | 組み込み関数（Ref, Sub, GetAtt等） | 60分 |
| 5 | **[05-outputs-imports](beginner/05-outputs-imports.md)** | Outputs, Export, ImportValue | 45分 |
| 6 | **[06-sample-templates](beginner/06-sample-templates-basic.md)** | 基礎サンプルテンプレート集 | 90分 |
| 7 | **[07-before-after](beginner/07-before-after-guide.md)** | Before/After実践（超重要！） | 120分 |
| - | **[チートシート](beginner/99-beginner-cheatsheet.md)** | 初級者向けクイックリファレンス | 常時参照 |

**初級編修了で作れるもの**: VPC + EC2 + RDS の基本構成

---

### 🚀 中級編（Intermediate）- 2〜4週間

**到達目標**: 大規模・複雑なインフラを設計し、実務運用できる

| 順序 | ファイル | 内容 | 難易度 |
|------|---------|------|--------|
| 1 | **[01-nested-stacks](intermediate/01-nested-stacks.md)** | ネストスタックによるモジュール化 | ★★☆ |
| 2 | **[02-change-sets](intermediate/02-change-sets.md)** | 変更セットで安全な更新 | ★★☆ |
| 3 | **[03-drift-detection](intermediate/03-drift-detection.md)** | ドリフト検出・修正 | ★★☆ |
| 4 | **[04-custom-resources](intermediate/04-custom-resources.md)** | Lambda連携・カスタムリソース | ★★★ |
| 5 | **[05-multi-environment](intermediate/05-multi-environment.md)** | マルチ環境管理（dev/stg/prod） | ★★☆ |
| 6 | **[06-stacksets](intermediate/06-stacksets.md)** | StackSetsでマルチアカウント | ★★★ |
| 7 | **[07-advanced-techniques](intermediate/07-advanced-techniques.md)** | 高度なテクニック集 | ★★★ |
| 8 | **[08-cicd-integration](intermediate/08-cicd-integration.md)** | CI/CD統合 | ★★★ |
| 9 | **[09-security](intermediate/09-security-best-practices.md)** | セキュリティベストプラクティス | ★★★ |
| 10 | **[10-troubleshooting](intermediate/10-troubleshooting.md)** | トラブルシューティング | ★★☆ |
| 11 | **[11-sample-templates](intermediate/11-sample-templates-advanced.md)** | 実践サンプルテンプレート集 | ★★★ |
| - | **[チートシート](intermediate/99-intermediate-cheatsheet.md)** | 中級者向けクイックリファレンス | 常時参照 |

**中級編修了で作れるもの**: マルチアカウント対応の本番グレードインフラ

---

## 🎓 推奨学習パス

### 🌱 初級編（1〜2週間）

#### Week 1: 基礎固め

**Day 1-2: CloudFormation入門**
1. [01-cfn-basics](beginner/01-cfn-basics.md) - CloudFormationとは
2. [02-basic-syntax](beginner/02-basic-syntax.md) - YAML構文
3. [チートシート](beginner/99-beginner-cheatsheet.md) - 手元に置いて参照

**Day 3-4: パラメータと条件分岐**
4. [03-parameters-mappings](beginner/03-parameters-mappings-conditions.md)
   - Parameters で柔軟性確保
   - Mappings で環境別設定
   - Conditions で条件分岐
5. 簡単なテンプレート作成（VPC作成）

**Day 5-6: 組み込み関数**
6. [04-intrinsic-functions](beginner/04-intrinsic-functions-basic.md)
   - !Ref, !Sub, !GetAtt
   - !Join, !Select, !GetAZs
7. サンプルテンプレート実行

#### Week 2: 実践

**Day 7-8: スタック間連携**
8. [05-outputs-imports](beginner/05-outputs-imports.md)
   - Outputs で値を公開
   - Export でクロススタック参照
   - ImportValue で他スタックから取得

**Day 9-10: サンプル実践**
9. [06-sample-templates](beginner/06-sample-templates-basic.md)
   - VPC + EC2 + RDS 構成
   - 実際にデプロイ・動作確認

**Day 11-14: Before/After実践（超重要！）**
10. [07-before-after](beginner/07-before-after-guide.md)
    - ベタ書きコードの問題点理解
    - 洗練されたコードへの進化
    - 組み込み関数の実践的な使い方
    - **初級編の総まとめ**

#### 初級編チェックリスト

- [ ] CloudFormationの基本概念を説明できる
- [ ] YAML構文でテンプレートを書ける
- [ ] Parameters, Mappings, Conditions を使い分けられる
- [ ] 基本的な組み込み関数を使える
- [ ] Outputs + Export でスタック間連携できる
- [ ] VPC + EC2 + RDS の基本構成を作れる

---

### 🚀 中級編（2〜4週間）

#### Week 3-4: 設計力向上

**Day 1-3: モジュール化設計**
1. [01-nested-stacks](intermediate/01-nested-stacks.md)
   - テンプレート分割
   - 再利用可能なモジュール設計
   - 依存関係管理

**Day 4-6: 安全な運用**
2. [02-change-sets](intermediate/02-change-sets.md)
   - 変更前のプレビュー
   - 安全な更新手順
3. [03-drift-detection](intermediate/03-drift-detection.md)
   - 手動変更の検出
   - ドリフト修正方法

**Day 7-10: 環境管理**
4. [05-multi-environment](intermediate/05-multi-environment.md)
   - dev/stg/prod 環境分離
   - 環境別パラメータ管理
   - コスト最適化

#### Week 5-6: 高度な機能

**Day 1-4: 機能拡張**
5. [04-custom-resources](intermediate/04-custom-resources.md)
   - Lambda連携
   - CloudFormation機能拡張
   - カスタムロジック実装

**Day 5-7: マルチアカウント**
6. [06-stacksets](intermediate/06-stacksets.md)
   - 複数アカウント同時デプロイ
   - AWS Organizations 連携
   - ガバナンス設計

**Day 8-10: 高度なテクニック**
7. [07-advanced-techniques](intermediate/07-advanced-techniques.md)
   - Dynamic References
   - Macros と Transform
   - DeletionPolicy, UpdatePolicy

#### Week 7-8: 実務統合

**Day 1-3: CI/CD統合**
8. [08-cicd-integration](intermediate/08-cicd-integration.md)
   - GitHub Actions 連携
   - AWS CodePipeline
   - 自動テスト

**Day 4-6: セキュリティ**
9. [09-security](intermediate/09-security-best-practices.md)
   - セキュリティベストプラクティス
   - KMS暗号化
   - IAM権限設計

**Day 7-10: 運用スキル**
10. [10-troubleshooting](intermediate/10-troubleshooting.md)
    - よくあるエラーと対処法
    - デバッグ手法
11. [11-sample-templates](intermediate/11-sample-templates-advanced.md)
    - 実践サンプル実行

#### 中級編チェックリスト

- [ ] ネストスタックで大規模構成を設計できる
- [ ] 変更セットで安全に更新できる
- [ ] ドリフト検出・修正ができる
- [ ] カスタムリソースでLambda連携できる
- [ ] マルチ環境管理ができる
- [ ] StackSets でマルチアカウント展開できる
- [ ] CI/CD に統合できる
- [ ] セキュリティベストプラクティスを適用できる

---

## 💡 効率的な学習のコツ

### 1. チートシートを常に手元に

- 初級編学習中: [初級チートシート](beginner/99-beginner-cheatsheet.md)
- 中級編学習中: [中級チートシート](intermediate/99-intermediate-cheatsheet.md)

### 2. 手を動かしながら学ぶ

理論だけでなく、実際にAWSコンソール・CLIでデプロイ！

```bash
# テンプレート作成
vim my-stack.yaml

# バリデーション
aws cloudformation validate-template --template-body file://my-stack.yaml

# デプロイ
aws cloudformation create-stack \
  --stack-name my-test-stack \
  --template-body file://my-stack.yaml

# 確認
aws cloudformation describe-stacks --stack-name my-test-stack
```

### 3. Before/After教材は必修

[Before/Afterガイド](beginner/07-before-after-guide.md)は、初級編の集大成。必ず実践してください。

### 4. エラーは成長のチャンス

エラーが出たら、[トラブルシューティング](intermediate/10-troubleshooting.md)で調べて理解を深めましょう。

---

## 🎯 実践プロジェクト

### 初級プロジェクト

**プロジェクト1: シンプルWeb構成**
- 構成: VPC + Public Subnet + EC2 + Apache
- 学習: 基本的なリソース作成

**プロジェクト2: 3層アーキテクチャ**
- 構成: VPC + Public/Private Subnet + EC2 + RDS
- 学習: ネットワーク設計、セキュリティグループ

**プロジェクト3: Before/After実践**
- 構成: VPC + EC2 x2 + RDS x2（Read Replica）
- 学習: 組み込み関数、パラメータ化、スタック間連携

### 中級プロジェクト

**プロジェクト4: スケーラブルWeb**
- 構成: VPC + ALB + Auto Scaling + RDS Multi-AZ
- 学習: 高可用性設計、自動スケーリング

**プロジェクト5: サーバーレスAPI**
- 構成: Lambda + API Gateway + DynamoDB
- 学習: サーバーレスアーキテクチャ

**プロジェクト6: マルチアカウントガバナンス**
- 構成: StackSets + CloudTrail + Config
- 学習: 組織全体の統制

---

## 🔧 必須ツール

### インストール

```bash
# AWS CLI
brew install awscli

# cfn-lint（テンプレート検証）
pip install cfn-lint

# Checkov（セキュリティスキャン）
pip install checkov
```

### 基本コマンド

```bash
# テンプレート検証
cfn-lint template.yaml

# セキュリティチェック
checkov -f template.yaml

# スタック作成
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml

# スタック状態確認
aws cloudformation describe-stacks --stack-name my-stack

# スタック削除
aws cloudformation delete-stack --stack-name my-stack
```

---

## 💰 学習コスト

### 初級編（目安）
- **EC2**: t3.micro（無料枠対象） - $0〜$10/月
- **RDS**: db.t3.micro（無料枠対象） - $0〜$15/月
- **合計**: 無料〜$25/月

### 中級編（目安）
- **EC2**: t3.small x2 - $30/月
- **RDS**: db.t3.small + Read Replica - $60/月
- **ALB**: - $20/月
- **合計**: $110/月程度

**💡 コスト削減のコツ**:
- 学習後は必ずスタック削除
- 業務時間外は停止
- 無料枠を最大活用

---

## 📚 参考資料

### 公式ドキュメント
- [AWS CloudFormation ユーザーガイド](https://docs.aws.amazon.com/ja_jp/cloudformation/)
- [リソースタイプリファレンス](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)

### コミュニティ
- [AWS re:Post](https://repost.aws/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/amazon-cloudformation)

---

## 🚀 次のステップ

### 初級編修了後
1. ✅ 中級編に進む
2. ✅ 実際のプロジェクトで適用
3. ✅ AWS Certified Solutions Architect - Associate 取得

### 中級編修了後
1. ✅ CI/CD統合
2. ✅ Terraform と比較・使い分け
3. ✅ AWS Certified DevOps Engineer - Professional 取得
4. ✅ 実務で大規模インフラ構築

---

## 📞 困ったときは

1. [初級チートシート](beginner/99-beginner-cheatsheet.md) / [中級チートシート](intermediate/99-intermediate-cheatsheet.md)
2. [トラブルシューティング](intermediate/10-troubleshooting.md)
3. CloudWatch Logs でエラー詳細確認
4. AWS re:Post で質問

---

**CloudFormationを段階的にマスターして、インフラエンジニアとして成長しましょう！🚀**

---

## 📝 更新履歴

- 2025-12-11: 初級編・中級編に完全再編成
- 2025-12-11: 学習順序を明確化（番号付きファイル名）
- 2025-12-11: 初級・中級チートシートを分離
