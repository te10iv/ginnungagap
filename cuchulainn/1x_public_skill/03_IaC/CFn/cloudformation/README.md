# CloudFormation Wiki 📚

CloudFormation中級者を目指すための完全ガイド

---

## 🎯 このWikiについて

このWikiは、**CloudFormationを実務で使いこなせるレベル**になるための教科書です。

### 対象者
- CloudFormation初心者〜中級者
- AWSインフラエンジニア
- DevOpsエンジニア
- IaC学習者

### 学習目標
- CloudFormationの全機能を理解
- 実務で使えるパターンを習得
- トラブルシューティングスキル向上
- エンタープライズグレードの設計力

---

## 📖 コンテンツ一覧

### 🌟 必読：基礎編

| # | ファイル | 内容 | 所要時間 |
|---|---------|------|---------|
| 0 | **[チートシート](00-cloudformation-cheatsheet.md)** | 1枚紙でCloudFormation基礎 | 15分 |
| 1 | **[参考資料一覧](01-references.md)** | 公式ドキュメント・ツール・学習リソース | 10分 |
| 99 | **[完全教科書](99-complete-textbook.md)** | 包括的なリファレンス | 60分 |

### 🚀 実践編

| # | ファイル | 内容 | 難易度 |
|---|---------|------|--------|
| 2 | **[ネストスタック](02-nested-stacks-pattern.md)** | テンプレート分割・再利用パターン | ★★☆ |
| 3 | **[変更セット](03-change-sets.md)** | 安全な更新方法 | ★★☆ |
| 4 | **[ドリフト検出](04-drift-detection.md)** | 手動変更の検出・修正 | ★★☆ |
| 5 | **[カスタムリソース](05-custom-resources.md)** | Lambda連携・機能拡張 | ★★★ |
| 6 | **[マルチ環境管理](06-multi-environment.md)** | dev/stg/prod環境管理 | ★★☆ |
| 8 | **[サンプルテンプレート](08-sample-templates.md)** | すぐ使える実践テンプレート | ★☆☆ |
| 9 | **[StackSets](09-stacksets.md)** | マルチアカウント展開 | ★★★ |

### 🔧 運用編

| # | ファイル | 内容 | 重要度 |
|---|---------|------|--------|
| 7 | **[トラブルシューティング](07-troubleshooting.md)** | よくあるエラーと対処法 | ★★★ |

---

## 🚀 学習の進め方

### Step 1: 基礎を固める（1-2日）

1. ✅ [チートシート](00-cloudformation-cheatsheet.md)を読む
2. ✅ [完全教科書](99-complete-textbook.md)を読む
3. ✅ [サンプルテンプレート](08-sample-templates.md)を実行

### Step 2: 実践パターンを学ぶ（3-5日）

4. ✅ [ネストスタック](02-nested-stacks-pattern.md)で大規模構成を学ぶ
5. ✅ [マルチ環境管理](06-multi-environment.md)でdev/stg/prod管理
6. ✅ [変更セット](03-change-sets.md)で安全な更新方法を学ぶ

### Step 3: 高度な機能を習得（1週間）

7. ✅ [カスタムリソース](05-custom-resources.md)でLambda連携
8. ✅ [ドリフト検出](04-drift-detection.md)で運用スキル向上
9. ✅ [StackSets](09-stacksets.md)でマルチアカウント管理

### Step 4: 実践（継続）

10. ✅ 実際のプロジェクトで適用
11. ✅ [トラブルシューティング](07-troubleshooting.md)で問題解決

---

## 💡 学習のポイント

### 初心者の方へ
1. まず[チートシート](00-cloudformation-cheatsheet.md)を読んで全体像を把握
2. [サンプルテンプレート](08-sample-templates.md)を実際に動かしてみる
3. わからないことは[完全教科書](99-complete-textbook.md)で調べる

### 中級者の方へ
1. [ネストスタック](02-nested-stacks-pattern.md)でアーキテクチャ設計力向上
2. [変更セット](03-change-sets.md)で運用スキル向上
3. [カスタムリソース](05-custom-resources.md)で高度な自動化

### 上級者の方へ
1. [StackSets](09-stacksets.md)でマルチアカウント管理
2. [ドリフト検出](04-drift-detection.md)の自動化実装
3. CI/CD統合

---

## 🎯 実践プロジェクト

### プロジェクト1: 基本的なWebアプリ（初級）
**構成**: VPC + EC2 + RDS  
**テンプレート**: [Sample 1](08-sample-templates.md#sample-1-基本的な3層アーキテクチャ)  
**学習目標**: CloudFormation基本操作、ネットワーク設計

### プロジェクト2: スケーラブルWebアプリ（中級）
**構成**: VPC + ALB + Auto Scaling + RDS  
**テンプレート**: [Sample 2](08-sample-templates.md#sample-2-alb--auto-scaling)  
**学習目標**: 負荷分散、自動スケーリング

### プロジェクト3: サーバーレスAPI（中級）
**構成**: Lambda + API Gateway + DynamoDB  
**テンプレート**: [Sample 3, 7](08-sample-templates.md)  
**学習目標**: サーバーレスアーキテクチャ

### プロジェクト4: マルチアカウントガバナンス（上級）
**構成**: StackSets + CloudTrail + Config + GuardDuty  
**テンプレート**: [StackSets例](09-stacksets.md)  
**学習目標**: 組織全体の統制

---

## 🔧 便利なツール

### 必須ツール
- **AWS CLI**: スタック操作
- **cfn-lint**: テンプレート検証
- **VS Code + YAML拡張**: テンプレート編集

### インストール

```bash
# AWS CLI
brew install awscli

# cfn-lint
pip install cfn-lint

# VS Code拡張
code --install-extension redhat.vscode-yaml
```

---

## 📊 習得スキルマップ

### レベル1: 初級（このWiki学習で到達）

- ✅ テンプレート基本構文
- ✅ Parameters, Mappings, Conditions
- ✅ 組み込み関数（Ref, Sub, GetAtt等）
- ✅ 基本的なリソース作成（VPC, EC2, S3等）
- ✅ スタック操作（create/update/delete）

### レベル2: 中級（このWikiで習得可能）

- ✅ ネストスタック設計
- ✅ 変更セット活用
- ✅ ドリフト検出・修正
- ✅ マルチ環境管理
- ✅ セキュリティベストプラクティス
- ✅ トラブルシューティング

### レベル3: 上級（このWiki + 実践で習得）

- ✅ カスタムリソース実装
- ✅ StackSets運用
- ✅ CI/CD統合
- ✅ マクロ・Transform活用
- ✅ 大規模アーキテクチャ設計

---

## 💰 コストについて

CloudFormationサービス自体は**無料**。作成されたAWSリソースのみ課金。

**学習用の推奨設定**:
- 開発環境: t3.small、Single-AZ（月$50程度）
- 使用後はスタック削除でコスト$0

---

## 📞 質問・サポート

### 困ったときは

1. [トラブルシューティング](07-troubleshooting.md)を確認
2. [AWS公式ドキュメント](01-references.md)を参照
3. AWS re:Post でコミュニティに質問
4. CloudWatch Logs でエラー詳細を確認

---

## 🎊 次のステップ

このWikiを完了したら：

1. ✅ 実際のプロジェクトで適用
2. ✅ CI/CD（GitHub Actions等）と統合
3. ✅ Terraform等の他のIaCツールと比較
4. ✅ AWS認定資格（Solutions Architect、DevOps Engineer）取得

---

## 📚 関連Wiki

- **[Terraform Wiki](../../Terraform/)**: Terraform学習リソース
- **[AWS Wiki](../../../AWS/)**: AWS全般の知識

---

**CloudFormationをマスターして、インフラ構築を自動化しましょう！🚀**

---

## 📝 更新履歴

- 2025-12-10: Wiki初版作成
