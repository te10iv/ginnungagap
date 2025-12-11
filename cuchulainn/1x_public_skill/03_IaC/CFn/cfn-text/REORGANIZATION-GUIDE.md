# CloudFormation Wiki 再編成ガイド 📋

初級編・中級編への完全再編成

---

## 🎯 再編成の目的

### 改善前の課題
- ❌ 番号がないため、どれから見れば良いか分からない
- ❌ 初級者向けと中級者向けが混在
- ❌ 学習順序が不明瞭
- ❌ チートシートが1つで初心者には難しい

### 改善後
- ✅ **初級編（Beginner）** と **中級編（Intermediate）** に明確に分離
- ✅ 各ファイルに**番号を付与**して学習順序を明確化
- ✅ **初級チートシート** と **中級チートシート** を分離
- ✅ 各ディレクトリにREADMEを配置して学習パスを明示

---

## 📁 新しいディレクトリ構造

```
cfn-text/
├── README.md                          # メインREADME（学習全体ガイド）
├── REORGANIZATION-GUIDE.md            # このファイル（再編成ガイド）
│
├── beginner/                          # 初級編（1〜2週間）
│   ├── README.md                      # 初級編ガイド
│   ├── 01-cfn-basics.md              # CloudFormation基礎
│   ├── 02-basic-syntax.md            # テンプレート基本構文
│   ├── 03-parameters-mappings-conditions.md  # Parameters, Mappings, Conditions
│   ├── 04-intrinsic-functions-basic.md       # 組み込み関数（基礎）
│   ├── 05-outputs-imports.md         # Outputs, Export, ImportValue
│   ├── 06-sample-templates-basic.md  # 基礎サンプルテンプレート
│   ├── 07-before-after-guide.md      # Before/After実践
│   ├── 99-beginner-cheatsheet.md     # 初級チートシート
│   └── templates/                     # サンプルテンプレート
│       ├── before-basic.yaml
│       ├── after-advanced.yaml
│       ├── import-example.yaml
│       └── deployment-guide.md
│
└── intermediate/                      # 中級編（2〜4週間）
    ├── README.md                      # 中級編ガイド
    ├── 01-nested-stacks.md           # ネストスタック
    ├── 02-change-sets.md             # 変更セット
    ├── 03-drift-detection.md         # ドリフト検出
    ├── 04-custom-resources.md        # カスタムリソース
    ├── 05-multi-environment.md       # マルチ環境管理
    ├── 06-stacksets.md               # StackSets
    ├── 07-advanced-techniques.md     # 高度なテクニック
    ├── 08-cicd-integration.md        # CI/CD統合
    ├── 09-security-best-practices.md # セキュリティ
    ├── 10-troubleshooting.md         # トラブルシューティング
    ├── 11-sample-templates-advanced.md  # 実践サンプルテンプレート
    └── 99-intermediate-cheatsheet.md    # 中級チートシート
```

---

## 🔄 ファイルマッピング表

### 初級編へ移動

| 旧ファイル名 | 新ファイル名 | 理由 |
|------------|------------|------|
| `00-cloudformation-cheatsheet.md` | `beginner/99-beginner-cheatsheet.md` | 初級者向けに再編集 |
| `before-after-comparison.md` | `beginner/07-before-after-guide.md` | 初級の総まとめ |
| `before-basic.yaml` | `beginner/templates/before-basic.yaml` | Before版サンプル |
| `after-advanced.yaml` | `beginner/templates/after-advanced.yaml` | After版サンプル |
| `import-example.yaml` | `beginner/templates/import-example.yaml` | ImportValue例 |
| `deployment-guide.md` | `beginner/templates/deployment-guide.md` | デプロイ手順 |
| `README-before-after.md` | `beginner/07-before-after-README.md` | Before/After教材ガイド |

### 中級編へ移動

| 旧ファイル名 | 新ファイル名 | 理由 |
|------------|------------|------|
| `02-nested-stacks-pattern.md` | `intermediate/01-nested-stacks.md` | 番号整理 |
| `03-change-sets.md` | `intermediate/02-change-sets.md` | 番号整理 |
| `04-drift-detection.md` | `intermediate/03-drift-detection.md` | 番号整理 |
| `05-custom-resources.md` | `intermediate/04-custom-resources.md` | 番号整理 |
| `06-multi-environment.md` | `intermediate/05-multi-environment.md` | 番号整理 |
| `09-stacksets.md` | `intermediate/06-stacksets.md` | 番号整理 |
| `10-advanced-techniques.md` | `intermediate/07-advanced-techniques.md` | 番号整理 |
| `11-cicd-integration.md` | `intermediate/08-cicd-integration.md` | 番号整理 |
| `12-security-best-practices.md` | `intermediate/09-security-best-practices.md` | 番号整理 |
| `07-troubleshooting.md` | `intermediate/10-troubleshooting.md` | 中級に移動 |
| `08-sample-templates.md` | `intermediate/11-sample-templates-advanced.md` | 中級に移動 |

### 新規作成ファイル

| ファイル名 | 内容 |
|----------|------|
| `README.md` | 全体学習ガイド（初級・中級の全体像） |
| `REORGANIZATION-GUIDE.md` | このファイル（再編成の説明） |
| `beginner/README.md` | 初級編ガイド |
| `beginner/01-cfn-basics.md` | CloudFormation基礎 ✅ **作成済み** |
| `beginner/02-basic-syntax.md` | テンプレート基本構文 |
| `beginner/03-parameters-mappings-conditions.md` | Parameters等 |
| `beginner/04-intrinsic-functions-basic.md` | 組み込み関数（基礎） |
| `beginner/05-outputs-imports.md` | Outputs, ImportValue |
| `beginner/06-sample-templates-basic.md` | 基礎サンプルテンプレート |
| `beginner/99-beginner-cheatsheet.md` | 初級チートシート ✅ **作成済み** |
| `intermediate/README.md` | 中級編ガイド ✅ **作成済み** |
| `intermediate/99-intermediate-cheatsheet.md` | 中級チートシート ✅ **作成済み** |

---

## 📚 学習パス（再編成後）

### 初心者向けパス（1〜2週間）

```
START
  ↓
① beginner/README.md を読む（全体像把握）
  ↓
② beginner/01-cfn-basics.md（CloudFormation基礎）
  ↓
③ beginner/02-basic-syntax.md（YAML構文）
  ↓
④ beginner/03-parameters-mappings-conditions.md（Parameters等）
  ↓
⑤ beginner/04-intrinsic-functions-basic.md（組み込み関数）
  ↓
⑥ beginner/05-outputs-imports.md（Outputs, ImportValue）
  ↓
⑦ beginner/06-sample-templates-basic.md（サンプル実践）
  ↓
⑧ beginner/07-before-after-guide.md（Before/After実践）⭐ 超重要
  ↓
初級編完了！ → 中級編へ
```

### 中級者向けパス（2〜4週間）

```
初級編完了
  ↓
① intermediate/README.md を読む（全体像把握）
  ↓
② intermediate/01-nested-stacks.md（モジュール化）
  ↓
③ intermediate/02-change-sets.md（安全な更新）
  ↓
④ intermediate/03-drift-detection.md（ドリフト検出）
  ↓
⑤ intermediate/05-multi-environment.md（マルチ環境）
  ↓
⑥ intermediate/04-custom-resources.md（Lambda連携）
  ↓
⑦ intermediate/06-stacksets.md（マルチアカウント）
  ↓
⑧ intermediate/07-advanced-techniques.md（高度な機能）
  ↓
⑨ intermediate/08-cicd-integration.md（CI/CD統合）
  ↓
⑩ intermediate/09-security-best-practices.md（セキュリティ）
  ↓
⑪ intermediate/10-troubleshooting.md（トラブルシューティング）
  ↓
⑫ intermediate/11-sample-templates-advanced.md（実践）
  ↓
中級編完了！実務で活躍🚀
```

---

## 🎯 再編成のポイント

### 1. 番号による学習順序の明確化

**Before（旧構造）**:
```
00-cloudformation-cheatsheet.md
01-references.md
02-nested-stacks-pattern.md
...
```
→ 番号はあるが、初級・中級が混在

**After（新構造）**:
```
beginner/
  01-cfn-basics.md
  02-basic-syntax.md
  ...
intermediate/
  01-nested-stacks.md
  02-change-sets.md
  ...
```
→ レベル別に分離 + 各レベル内で順序明確

### 2. 初級・中級の明確な分離

| 初級編（beginner） | 中級編（intermediate） |
|------------------|---------------------|
| CloudFormation基礎 | ネストスタック |
| YAML構文 | 変更セット |
| Parameters | ドリフト検出 |
| 基本的な組み込み関数 | カスタムリソース |
| Outputs, ImportValue | StackSets |
| VPC+EC2+RDS構成 | CI/CD統合 |

### 3. チートシートの分離

**初級チートシート**:
- CloudFormation基本概念
- 基本的な組み込み関数（!Ref, !Sub, !GetAtt等）
- よく使うリソース（VPC, EC2, RDS）
- 基本コマンド

**中級チートシート**:
- ネストスタック
- 変更セット
- カスタムリソース
- StackSets
- 高度な組み込み関数
- DeletionPolicy, UpdatePolicy
- CI/CD統合

---

## 🔧 移行作業リスト

### Phase 1: ディレクトリ作成 ✅
- [x] `beginner/` ディレクトリ作成
- [x] `intermediate/` ディレクトリ作成
- [x] `beginner/templates/` ディレクトリ作成

### Phase 2: 新規ファイル作成 🚧
- [x] `README-reorganized.md` 作成（新メインREADME）
- [x] `REORGANIZATION-GUIDE.md` 作成（このファイル）
- [x] `beginner/README.md` 作成
- [x] `beginner/01-cfn-basics.md` 作成
- [x] `beginner/99-beginner-cheatsheet.md` 作成
- [x] `intermediate/README.md` 作成
- [x] `intermediate/99-intermediate-cheatsheet.md` 作成
- [ ] `beginner/02-basic-syntax.md` 作成
- [ ] `beginner/03-parameters-mappings-conditions.md` 作成
- [ ] `beginner/04-intrinsic-functions-basic.md` 作成
- [ ] `beginner/05-outputs-imports.md` 作成
- [ ] `beginner/06-sample-templates-basic.md` 作成

### Phase 3: 既存ファイル移動・リネーム 📦
- [ ] `before-after-comparison.md` → `beginner/07-before-after-guide.md`
- [ ] `before-basic.yaml` → `beginner/templates/before-basic.yaml`
- [ ] `after-advanced.yaml` → `beginner/templates/after-advanced.yaml`
- [ ] `import-example.yaml` → `beginner/templates/import-example.yaml`
- [ ] `deployment-guide.md` → `beginner/templates/deployment-guide.md`
- [ ] `02-nested-stacks-pattern.md` → `intermediate/01-nested-stacks.md`
- [ ] `03-change-sets.md` → `intermediate/02-change-sets.md`
- [ ] `04-drift-detection.md` → `intermediate/03-drift-detection.md`
- [ ] `05-custom-resources.md` → `intermediate/04-custom-resources.md`
- [ ] `06-multi-environment.md` → `intermediate/05-multi-environment.md`
- [ ] `09-stacksets.md` → `intermediate/06-stacksets.md`
- [ ] `10-advanced-techniques.md` → `intermediate/07-advanced-techniques.md`
- [ ] `11-cicd-integration.md` → `intermediate/08-cicd-integration.md`
- [ ] `12-security-best-practices.md` → `intermediate/09-security-best-practices.md`
- [ ] `07-troubleshooting.md` → `intermediate/10-troubleshooting.md`
- [ ] `08-sample-templates.md` → `intermediate/11-sample-templates-advanced.md`

### Phase 4: README更新 📝
- [ ] `README.md` を `README-reorganized.md` で置き換え
- [ ] 旧README を `README.old` としてバックアップ

---

## 💡 使い方（学習者向け）

### 初心者の場合

1. **[README.md](README-reorganized.md)** を読んで全体像を把握
2. **[beginner/README.md](beginner/README.md)** で初級編の学習パスを確認
3. **[beginner/99-beginner-cheatsheet.md](beginner/99-beginner-cheatsheet.md)** を手元に置く
4. **beginner/01〜07** を順番に学習
5. **beginner/07-before-after-guide.md** で初級編を総復習
6. 初級編完了後、中級編へ

### 中級者の場合

1. 初級編を飛ばして **[intermediate/README.md](intermediate/README.md)** へ
2. **[intermediate/99-intermediate-cheatsheet.md](intermediate/99-intermediate-cheatsheet.md)** を手元に置く
3. **intermediate/01〜11** を必要に応じて学習
4. 実務で活用

---

## 🎊 再編成の効果

### Before（旧構造）
- ❌ 学習順序が不明瞭
- ❌ 初級・中級が混在
- ❌ 「どこから始めるべきか」が分からない

### After（新構造）
- ✅ 学習順序が一目瞭然（番号付き）
- ✅ レベル別に明確に分離
- ✅ 各レベルのREADMEで学習パスを明示
- ✅ チートシートもレベル別
- ✅ 「beginner/01から順番に」で迷わない

---

**この再編成で、CloudFormation学習が10倍効率的になります！🚀**

---

## 📞 質問・フィードバック

この再編成について質問やフィードバックがあれば、プロジェクトのIssueまでお願いします。

---

**更新日**: 2025-12-11
