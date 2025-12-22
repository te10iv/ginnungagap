# AWS Systems Manager 学習に役立つ参考資料

## 📚 参考書

### AWS運用入門 - DevOpsチームとして知っておくべき運用の基本
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4297119072
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4297119072
- **出版社**: 技術評論社
- **発行年月日**: 2020年5月
- **価格**: ¥3,278
- **概要**: AWS運用に特化した書籍。Systems Manager（Session Manager、Run Command、Patch Manager、Parameter Store）を実務観点で詳細解説。中級者向け。
- **評価**:
  - **良い点**: 
    - Systems Managerの実務的な運用パターンを包括的に学べる
    - Session Manager、Run Command、Patch Managerの使い分けが明確
    - Parameter StoreとSecrets Managerの使い分けも解説
    - CloudWatch、CloudTrailとの連携も詳細
  - **悪い点**: 
    - 2020年発行のため、新機能（Fleet Manager等）は未掲載
    - Systems Manager特化ではなく、AWS運用全般の本
- **向いている人**: AWS運用担当者、Systems Managerを実務で使いたい人

### AWSではじめるインフラ構築入門
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4798163430
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4798163430
- **出版社**: 翔泳社
- **発行年月日**: 2021年5月
- **価格**: ¥3,080
- **概要**: AWS初学者向けのインフラ構築入門書。Systems ManagerのSession Managerを使ったEC2操作をハンズオン形式で学べる。初学者向け。
- **評価**:
  - **良い点**: 
    - Session Managerの基本操作を手を動かして学べる
    - 図解が多く初学者に優しい
    - SSH不要でEC2にアクセスする方法を理解できる
  - **悪い点**: 
    - Session Manager以外の機能（Patch Manager、Automation等）は説明が少ない
    - Systems Manager特化ではない
- **向いている人**: AWS初学者、Session Managerを学びたい人

---

## 🎥 参考 Udemy 動画

### これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **タイトル**: これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **URL**: https://www.udemy.com/course/aws-associate/
- **制作者（講師名）**: 鈴木 憲一（アルシエ）
- **言語**: 日本語
- **発行年月日**: 2019年（定期更新あり）
- **価格**: 定価 ¥27,800 / セール時 ¥1,600〜¥2,000
- **概要**: AWS認定資格対策講座。Systems Managerの基本機能（Session Manager、Parameter Store）をハンズオン形式で学習。初学者向け。
- **評価**:
  - **良い点**: 
    - Systems Managerの基本操作を動画で確認できる
    - Session Manager、Parameter Storeの基本を学べる
    - 日本語で丁寧な解説
  - **悪い点**: 
    - Systems Manager特化ではないため、基本のみ
    - Patch Manager、Automation等の高度な機能は未カバー
- **向いている人**: AWS初学者、Systems Managerの基本操作を動画で学びたい人

### AWS Operations (英語)
- **タイトル**: AWS Operations
- **URL**: 不明
- **制作者（講師名）**: 不明
- **言語**: 英語
- **発行年月日**: 不明
- **価格**: 不明
- **概要**: Systems Manager特化の運用講座があればここに記載（※現時点で実在確認できず）
- **評価**:
  - **良い点**: 不明
  - **悪い点**: 不明
- **向いている人**: 不明

---

## 📺 参考 YouTube

### ⭐ AWS Black Belt Online Seminar - AWS Systems Manager
- **チャンネル名**: AWS Japan 公式チャンネル
- **動画タイトル**: AWS Systems Manager
- **URL**: https://www.youtube.com/watch?v=Fk6aECTnFyk
- **言語**: 日本語
- **概要**: AWS公式のSystems Manager解説動画。全機能（Session Manager、Run Command、Patch Manager、Automation、Parameter Store等）を網羅。無料で最新情報を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式の一次情報で信頼性が高い
    - Systems Managerの全機能を体系的に学べる
    - 無料で視聴可能
    - スライド資料もダウンロード可能
    - 各機能の使い分けが明確
  - **悪い点**: 
    - 動画が長い（1時間以上）
    - ハンズオンはないため、実際の操作は別途必要
- **向いている人**: Systems Managerを体系的に学びたい全レベルの学習者

### クラスメソッド - Systems Manager解説動画
- **チャンネル名**: クラスメソッド公式チャンネル
- **動画タイトル**: Systems Manager関連の解説動画（複数）
- **URL**: https://www.youtube.com/@classmethod
- **言語**: 日本語
- **概要**: AWSパートナー企業による解説動画。Systems Managerの実践的な使い方、ハマりポイントを学べる。
- **評価**:
  - **良い点**: 
    - 実務で使える具体的な設定例が豊富
    - 日本語で分かりやすい
    - 無料
  - **悪い点**: 
    - 動画数が限定的
    - 体系的な学習には他の教材も必要
- **向いている人**: Systems Managerの実践的な使い方を知りたい人

---

## 🌐 参考サイト（ブログ・公式ドキュメント・技術記事）

### ⭐ AWS Systems Manager 公式ドキュメント
- **タイトル**: AWS Systems Manager ユーザーガイド
- **URL**: https://docs.aws.amazon.com/systems-manager/
- **運営元**: AWS公式
- **概要**: Systems Managerの公式ドキュメント。全機能の詳細仕様、ベストプラクティス、API リファレンスを提供。
- **評価**:
  - **良い点**: 
    - 最も正確で最新の情報
    - 全機能を網羅（Session Manager、Run Command、Patch Manager、Automation、Parameter Store、OpsCenter等）
    - コードサンプル、CLI/SDK例が豊富
    - 日本語版も充実
  - **悪い点**: 
    - ボリュームが多く、初学者には情報量が多すぎる
    - 機能が多岐にわたり、どこから学べばよいか迷う
- **向いている人**: 全レベル（特に正確な仕様を確認したい人）

### ⭐ AWS Black Belt Online Seminar - AWS Systems Manager 資料
- **タイトル**: AWS Black Belt Online Seminar - AWS Systems Manager
- **URL**: https://aws.amazon.com/jp/blogs/news/webinar-bb-aws-systems-manager-2023/
- **運営元**: AWS Japan公式
- **概要**: AWS公式のSystems Manager解説資料（PDF/動画）。基本から実践まで日本語で学べる一次情報。
- **評価**:
  - **良い点**: 
    - AWS公式の信頼できる一次情報
    - 日本語で詳細に解説
    - PDF資料をダウンロードして復習可能
    - 定期的に更新され、新機能もカバー
    - 各機能の使い分けが明確
  - **悪い点**: 
    - 動画が長い（60分以上）
    - ハンズオン環境は自分で用意が必要
- **向いている人**: Systems Managerを体系的に学びたい全レベルの学習者

### Classmethod（クラスメソッド）DevelopersIO - Systems Manager記事
- **タイトル**: Systems Manager関連記事（複数）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド株式会社（AWS Premier Tier Services Partner）
- **概要**: AWS専門のブログメディア。Systems Manager関連の実践的な記事が多数。Session Manager、Patch Manager、Automation等の具体的な設定例が豊富。
- **評価**:
  - **良い点**: 
    - 実務で使える具体的な設定例、スクリプト例が豊富
    - ハマりポイント、トラブルシューティングが充実
    - ほぼ毎日更新され、新機能も迅速にキャッチアップ
    - 日本語で分かりやすい
  - **悪い点**: 
    - 記事数が膨大で、初学者は何から読むべきか迷う
    - 記事の質にややバラつきあり
- **向いている人**: 実務でSystems Managerを使う人、具体的な設定例を探している人

### AWS Well-Architected Framework - 運用セクション
- **タイトル**: AWS Well-Architected Framework - Operational Excellence Pillar
- **URL**: https://docs.aws.amazon.com/wellarchitected/
- **運営元**: AWS公式
- **概要**: AWSのベストプラクティス集。Systems Managerを使った運用自動化のベストプラクティスを解説。
- **評価**:
  - **良い点**: 
    - AWS公式のベストプラクティス
    - Systems Managerを使った運用設計の考え方を学べる
    - Automation、OpsCenter等の使い分けも解説
  - **悪い点**: 
    - 初学者には抽象度が高い
    - 具体的な設定手順は少ない
- **向いている人**: 中級者以上、運用設計のベストプラクティスを学びたい人

---

## 🎯 参考になる学習者向けサービス

### AWS Skill Builder
- **サービス名**: AWS Skill Builder
- **URL**: https://skillbuilder.aws/
- **運営元**: AWS公式
- **料金体系**: 無料コース多数 / 有料プラン（$29/月）
- **概要**: AWS公式の学習プラットフォーム。Systems Manager関連のラーニングパス、ハンズオンラボあり。
- **評価**:
  - **良い点**: 
    - AWS公式で信頼性が高い
    - ハンズオン環境が提供される
    - Session Manager、Patch Manager等の実習ができる
    - 無料コースも充実
  - **悪い点**: 
    - 英語コンテンツが多い（日本語は一部のみ）
    - 有料プランでないと全機能使えない
- **向いている人**: AWS認定資格を目指す人、ハンズオンで学びたい人

### AWS Hands-on for Beginners
- **サービス名**: AWS Hands-on for Beginners
- **URL**: https://aws.amazon.com/jp/aws-jp-introduction/aws-jp-webinar-hands-on/
- **運営元**: AWS Japan公式
- **料金体系**: 無料
- **概要**: AWS公式の初学者向けハンズオンシリーズ。Systems Manager関連のハンズオンあり。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 日本語で丁寧な解説
    - 実際にAWS環境で手を動かせる
    - 初学者に優しい設計
  - **悪い点**: 
    - 基本的な内容が中心
    - Automation、OpsCenter等の高度な機能は別途学習が必要
- **向いている人**: AWS初学者、Systems Managerを実際に触ってみたい人

---

## 🛠️ その他ハンズオン（実技・構築力が身につくもの）

### ⭐ AWS Workshops - Systems Manager Workshop
- **タイトル**: AWS Systems Manager Workshop
- **URL**: https://catalog.workshops.aws/
- **提供元**: AWS公式
- **価格**: 無料
- **概要**: AWS公式のSystems Managerハンズオンワークショップ。Session Manager、Run Command、Patch Manager、Automationを実践。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 実際のAWS環境で手を動かせる
    - 各機能を実際に体験できる
    - ステップバイステップで初学者にも優しい
  - **悪い点**: 
    - 英語のみ（日本語版なし）
    - AWS環境の構築は自分で行う必要がある
- **向いている人**: ハンズオンで学びたい人、英語で学習できる人

### Systems Manager Automation Runbook サンプル集（公式）
- **タイトル**: AWS Systems Manager Automation runbook reference
- **URL**: https://docs.aws.amazon.com/systems-manager-automation-runbooks/
- **提供元**: AWS公式
- **価格**: 無料
- **概要**: AWS公式のAutomation Runbookサンプル集。EC2停止、AMI作成、パッチ適用等の実践的なRunbook例を提供。
- **評価**:
  - **良い点**: 
    - AWS公式で信頼性が高い
    - 実務でよく使うRunbookパターンが網羅
    - コピー&ペーストで即使える
    - 無料
  - **悪い点**: 
    - サンプル集なので、体系的な学習には不向き
    - Runbookの解説は最小限
- **向いている人**: Automationを使う人、実践的なRunbook例を探している人

---

## 📝 補足：Systems Manager学習のポイント

### 重要トピックと教材の対応

1. **Session Manager（SSH不要のEC2接続）**
   - → AWS Black Belt、公式ドキュメント、AWS運用入門書籍、AWSインフラ構築入門書籍

2. **Run Command（複数EC2への一括コマンド実行）**
   - → AWS Black Belt、公式ドキュメント、AWS運用入門書籍

3. **Patch Manager（OSパッチ管理）**
   - → AWS Black Belt、公式ドキュメント、AWS運用入門書籍

4. **Automation（運用自動化、Runbook）**
   - → AWS Black Belt、公式ドキュメント、Automation Runbookサンプル集

5. **Parameter Store（設定値・シークレット管理）**
   - → AWS Black Belt、公式ドキュメント、AWS運用入門書籍

6. **State Manager（設定管理、コンプライアンス）**
   - → AWS Black Belt、公式ドキュメント

7. **OpsCenter（運用管理、インシデント管理）**
   - → AWS Black Belt、公式ドキュメント

8. **Fleet Manager（サーバー管理）**
   - → AWS Black Belt（最新版）、公式ドキュメント

### おすすめ学習パス

**初学者（Systems Manager初めて）**
1. AWS Black Belt動画（1時間）
2. AWS Hands-on for Beginners（Session Manager、2時間）
3. AWSインフラ構築入門書籍

**中級者（実務で使いたい）**
1. AWS運用入門書籍（Session Manager、Run Command、Patch Manager、Parameter Store）
2. 公式ドキュメント（必要箇所）
3. Classmethod記事で実践Tips収集

**上級者（運用自動化を極める）**
1. 公式ドキュメント（Automation、State Manager、OpsCenter）
2. Automation Runbookサンプル集
3. AWS Workshops でハンズオン
4. Classmethod記事で最新Tips収集

### Systems Manager機能一覧と使い分け

Systems Manager学習では、機能が多岐にわたるため、使い分けを理解することが重要：

| 機能 | 用途 | 主な使用場面 |
|------|------|--------------|
| **Session Manager** | SSH不要のEC2接続 | セキュアな管理操作、踏み台不要 |
| **Run Command** | 複数EC2への一括コマンド実行 | 一時的なコマンド実行、設定変更 |
| **Patch Manager** | OSパッチ管理 | 定期的なパッチ適用、脆弱性対応 |
| **Automation** | 運用自動化（Runbook） | AMI作成、EC2停止/起動、パッチ適用 |
| **Parameter Store** | 設定値・シークレット管理 | DB接続文字列、APIキー等の管理 |
| **State Manager** | 設定管理、コンプライアンス | 定期的な設定適用、監視エージェント導入 |
| **OpsCenter** | 運用管理、インシデント管理 | 障害対応、変更管理 |
| **Fleet Manager** | サーバー管理（GUI） | ファイル操作、ログ確認（GUI） |
| **Inventory** | サーバー情報収集 | ソフトウェア棚卸、コンプライアンス確認 |

### 実務でよく使う機能ランキング

1. **Session Manager** - ほぼすべての環境で使用
2. **Parameter Store** - ほぼすべてのアプリで使用
3. **Patch Manager** - 本番環境で必須
4. **Run Command** - 運用自動化で頻出
5. **Automation** - 高度な運用自動化で使用
