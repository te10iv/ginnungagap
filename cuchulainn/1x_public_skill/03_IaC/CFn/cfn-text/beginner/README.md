# CloudFormation 初級編 🌱

CloudFormationの基礎から、実践的なテンプレート作成まで

---

## 🎯 初級編の目標

**到達レベル**: VPC + EC2 + RDS の基本構成を自力で作れる

### 習得スキル
- ✅ CloudFormationの基本概念
- ✅ YAML構文でのテンプレート作成
- ✅ Parameters, Mappings, Conditions の使い方
- ✅ 基本的な組み込み関数（10種類）
- ✅ Outputs によるスタック間連携
- ✅ 実践的なBefore/After理解

**所要時間**: 1〜2週間

---

## 📚 学習コンテンツ

| 順序 | ファイル | 内容 | 所要時間 |
|------|---------|------|---------|
| 1 | **[01-cfn-basics](01-cfn-basics.md)** | CloudFormationとは？IaCの基礎 | 30分 |
| 2 | **[02-basic-syntax](02-basic-syntax.md)** | テンプレート基本構文（YAML） | 45分 |
| 3 | **[03-parameters-mappings](03-parameters-mappings-conditions.md)** | Parameters, Mappings, Conditions | 60分 |
| 4 | **[04-intrinsic-functions](04-intrinsic-functions-basic.md)** | 組み込み関数（Ref, Sub, GetAtt等） | 60分 |
| 5 | **[05-outputs-imports](05-outputs-imports.md)** | Outputs, Export, ImportValue | 45分 |
| 6 | **[06-sample-templates](06-sample-templates-basic.md)** | 基礎サンプルテンプレート集 | 90分 |
| 7 | **[07-before-after](07-before-after-guide.md)** | Before/After実践（超重要！） | 120分 |
| - | **[チートシート](99-beginner-cheatsheet.md)** | クイックリファレンス | 常時参照 |

---

## 🎓 推奨学習フロー

### Week 1: 基礎固め

**Day 1-2**:
1. [01-cfn-basics](01-cfn-basics.md) - CloudFormation入門
2. [02-basic-syntax](02-basic-syntax.md) - YAML構文
3. [チートシート](99-beginner-cheatsheet.md) - 手元に置いて参照

**Day 3-4**:
4. [03-parameters-mappings](03-parameters-mappings-conditions.md)
   - Parameters で柔軟性確保
   - Mappings で環境別設定
   - Conditions で条件分岐

**Day 5-6**:
5. [04-intrinsic-functions](04-intrinsic-functions-basic.md)
   - !Ref, !Sub, !GetAtt
   - !Join, !Select, !GetAZs

### Week 2: 実践

**Day 7-8**:
6. [05-outputs-imports](05-outputs-imports.md)
   - Outputs で値を公開
   - Export でクロススタック参照

**Day 9-10**:
7. [06-sample-templates](06-sample-templates-basic.md)
   - VPC + EC2 + RDS 構成
   - 実際にデプロイ

**Day 11-14**:
8. [07-before-after](07-before-after-guide.md)
   - **初級編の総まとめ**
   - ベタ書き → 洗練コード
   - 組み込み関数の実践的な使い方

---

## ✅ 初級編チェックリスト

### 基本知識
- [ ] CloudFormationの基本概念を説明できる
- [ ] IaCのメリットを理解した
- [ ] スタックのライフサイクルを理解した

### テンプレート作成
- [ ] YAML構文でテンプレートを書ける
- [ ] Parameters を使える
- [ ] Mappings で環境別設定ができる
- [ ] Conditions で条件分岐ができる

### 組み込み関数
- [ ] !Ref を使える
- [ ] !GetAtt を使える
- [ ] !Sub で文字列展開ができる
- [ ] !Join, !Select, !GetAZs を使える
- [ ] !FindInMap で Mappings から値を取得できる
- [ ] !If で条件分岐ができる

### スタック間連携
- [ ] Outputs で値を出力できる
- [ ] Export で値をエクスポートできる
- [ ] ImportValue で他スタックから参照できる

### 実践
- [ ] VPC を作成できる
- [ ] Subnet, Security Group を作成できる
- [ ] EC2, RDS を作成できる
- [ ] Before/After の違いを理解した
- [ ] 保守性の高いテンプレートを書ける

---

## 🚀 初級編修了後

### 次のステップ
1. ✅ **[中級編](../../intermediate/)** に進む
2. ✅ 実際のプロジェクトで適用
3. ✅ AWS認定資格の勉強開始

---

**CloudFormation初級編で、基礎を完璧にマスターしましょう！📚**
