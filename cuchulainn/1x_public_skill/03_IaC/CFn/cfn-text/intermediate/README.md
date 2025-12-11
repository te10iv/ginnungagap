# CloudFormation 中級編 🚀

実務で使える高度な機能とベストプラクティス

---

## 🎯 中級編の目標

**到達レベル**: マルチアカウント対応の本番グレードインフラを構築できる

### 習得スキル
- ✅ ネストスタックによるモジュール化
- ✅ 変更セットで安全な更新
- ✅ ドリフト検出と修正
- ✅ カスタムリソース（Lambda連携）
- ✅ マルチ環境管理（dev/stg/prod）
- ✅ StackSetsでマルチアカウント展開
- ✅ CI/CD統合
- ✅ セキュリティベストプラクティス

**所要時間**: 2〜4週間

**前提条件**: 初級編を完了していること

---

## 📚 学習コンテンツ

| 順序 | ファイル | 内容 | 難易度 |
|------|---------|------|--------|
| 1 | **[01-nested-stacks](01-nested-stacks.md)** | ネストスタックによるモジュール化 | ★★☆ |
| 2 | **[02-change-sets](02-change-sets.md)** | 変更セットで安全な更新 | ★★☆ |
| 3 | **[03-drift-detection](03-drift-detection.md)** | ドリフト検出・修正 | ★★☆ |
| 4 | **[04-custom-resources](04-custom-resources.md)** | Lambda連携・カスタムリソース | ★★★ |
| 5 | **[05-multi-environment](05-multi-environment.md)** | マルチ環境管理（dev/stg/prod） | ★★☆ |
| 6 | **[06-stacksets](06-stacksets.md)** | StackSetsでマルチアカウント | ★★★ |
| 7 | **[07-advanced-techniques](07-advanced-techniques.md)** | 高度なテクニック集 | ★★★ |
| 8 | **[08-cicd-integration](08-cicd-integration.md)** | CI/CD統合 | ★★★ |
| 9 | **[09-security](09-security-best-practices.md)** | セキュリティベストプラクティス | ★★★ |
| 10 | **[10-troubleshooting](10-troubleshooting.md)** | トラブルシューティング | ★★☆ |
| 11 | **[11-sample-templates](11-sample-templates-advanced.md)** | 実践サンプルテンプレート集 | ★★★ |
| - | **[チートシート](99-intermediate-cheatsheet.md)** | 中級者向けクイックリファレンス | 常時参照 |

---

## 🎓 推奨学習フロー

### Week 1-2: 設計力向上

**Day 1-3: モジュール化設計**
1. [01-nested-stacks](01-nested-stacks.md)
   - テンプレート分割
   - 再利用可能なモジュール設計
   - 依存関係管理

**Day 4-6: 安全な運用**
2. [02-change-sets](02-change-sets.md)
   - 変更前のプレビュー
   - 安全な更新手順
3. [03-drift-detection](03-drift-detection.md)
   - 手動変更の検出
   - ドリフト修正方法

**Day 7-10: 環境管理**
4. [05-multi-environment](05-multi-environment.md)
   - dev/stg/prod 環境分離
   - 環境別パラメータ管理
   - コスト最適化

### Week 3-4: 高度な機能

**Day 1-4: 機能拡張**
5. [04-custom-resources](04-custom-resources.md)
   - Lambda連携
   - CloudFormation機能拡張
   - カスタムロジック実装

**Day 5-7: マルチアカウント**
6. [06-stacksets](06-stacksets.md)
   - 複数アカウント同時デプロイ
   - AWS Organizations 連携
   - ガバナンス設計

**Day 8-10: 高度なテクニック**
7. [07-advanced-techniques](07-advanced-techniques.md)
   - Dynamic References
   - Macros と Transform
   - DeletionPolicy, UpdatePolicy

### Week 5-6: 実務統合

**Day 1-3: CI/CD統合**
8. [08-cicd-integration](08-cicd-integration.md)
   - GitHub Actions 連携
   - AWS CodePipeline
   - 自動テスト

**Day 4-6: セキュリティ**
9. [09-security](09-security-best-practices.md)
   - セキュリティベストプラクティス
   - KMS暗号化
   - IAM権限設計

**Day 7-10: 運用スキル**
10. [10-troubleshooting](10-troubleshooting.md)
    - よくあるエラーと対処法
    - デバッグ手法
11. [11-sample-templates](11-sample-templates-advanced.md)
    - 実践サンプル実行

---

## ✅ 中級編チェックリスト

### 設計スキル
- [ ] ネストスタックで大規模構成を設計できる
- [ ] マルチ環境対応テンプレートを設計できる
- [ ] スタック間の依存関係を設計できる
- [ ] 再利用可能なモジュールを作成できる

### 運用スキル
- [ ] 変更セットで安全に更新できる
- [ ] ドリフト検出・修正ができる
- [ ] DeletionPolicy, UpdatePolicy を適切に設定できる
- [ ] トラブルシューティングができる

### 高度な機能
- [ ] カスタムリソースでLambda連携できる
- [ ] Dynamic References でSecrets Manager参照できる
- [ ] StackSets でマルチアカウントデプロイできる
- [ ] Macros, Transform を使える

### CI/CD統合
- [ ] GitHub Actions / CodePipeline に統合できる
- [ ] cfn-lint, Checkov でテストできる
- [ ] 自動デプロイパイプラインを構築できる

### セキュリティ
- [ ] セキュリティベストプラクティスを適用できる
- [ ] KMS暗号化を設定できる
- [ ] IAM権限を適切に設計できる

---

## 🎯 実践プロジェクト

### プロジェクト1: スケーラブルWebアプリ
- 構成: VPC + ALB + Auto Scaling + RDS Multi-AZ
- 学習: 高可用性設計、自動スケーリング

### プロジェクト2: サーバーレスAPI
- 構成: Lambda + API Gateway + DynamoDB
- 学習: サーバーレスアーキテクチャ

### プロジェクト3: マルチアカウントガバナンス
- 構成: StackSets + CloudTrail + Config
- 学習: 組織全体の統制

---

## 🚀 中級編修了後

### 次のステップ
1. ✅ 実際のプロジェクトで実践
2. ✅ AWS Certified DevOps Engineer - Professional 取得
3. ✅ Terraform との使い分け検討
4. ✅ Infrastructure Testing の導入

---

**CloudFormation中級編で、実務レベルのスキルを習得しましょう！🚀**
