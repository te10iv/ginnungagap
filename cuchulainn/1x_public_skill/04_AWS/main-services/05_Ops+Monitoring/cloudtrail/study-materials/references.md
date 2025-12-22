# AWS CloudTrail 学習に役立つ参考資料

## 📚 参考書

### AWS認定資格試験テキスト AWS認定 セキュリティ - スペシャリスト
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4815620636
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4815620636
- **出版社**: SBクリエイティブ
- **発行年月日**: 2023年4月
- **価格**: ¥3,300
- **概要**: AWS認定セキュリティ資格対策本。CloudTrailの監査ログ、Organizations統合、Insights等を詳細解説。中級者向け。
- **評価**:
  - **良い点**: 
    - CloudTrailのセキュリティ・監査観点での使い方を体系的に学べる
    - Organizations統合、CloudWatch Logs統合など実践的
    - CloudTrail Insightsの異常検知機能も解説
  - **悪い点**: 
    - セキュリティ資格対策本のため、CloudTrail特化ではない
    - 2023年発行のため、最新機能（Lake等）は未掲載の可能性
- **向いている人**: セキュリティ・監査担当者、CloudTrailを深く学びたい中級者

### AWS運用入門 - DevOpsチームとして知っておくべき運用の基本
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4297119072
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4297119072
- **出版社**: 技術評論社
- **発行年月日**: 2020年5月
- **価格**: ¥3,278
- **概要**: AWS運用に特化した書籍。CloudTrailを使った操作ログ監査、セキュリティ監視を実務観点で解説。中級者向け。
- **評価**:
  - **良い点**: 
    - CloudTrailを使った実務的な監査設計パターンを学べる
    - CloudWatch Logs、Athenaとの連携も解説
    - 運用で重要なログ分析方法を学べる
  - **悪い点**: 
    - 2020年発行のため、新機能（Lake等）は未掲載
    - CloudTrail特化ではなく、AWS運用全般の本
- **向いている人**: AWS運用担当者、監査・セキュリティ設計を学びたい人

---

## 🎥 参考 Udemy 動画

### AWS Certified Security - Specialty（英語）
- **タイトル**: AWS Certified Security - Specialty
- **URL**: https://www.udemy.com/course/aws-certified-security-specialty/
- **制作者（講師名）**: Stephane Maarek
- **言語**: 英語
- **発行年月日**: 2020年（定期更新あり）
- **価格**: 定価 $84.99 / セール時 $12.99〜$19.99
- **概要**: AWSセキュリティ認定対策講座。CloudTrailの全機能（Insights、Organizations統合、分析）を詳細解説。中級者向け。
- **評価**:
  - **良い点**: 
    - CloudTrailのセキュリティ・監査機能を深く学べる
    - CloudTrail Insightsの異常検知を実践的に学べる
    - Athena、GuardDuty等との連携も詳細
  - **悪い点**: 
    - 英語のため日本語話者にはハードルが高い
    - セキュリティ資格対策なので、CloudTrail特化ではない
- **向いている人**: セキュリティ中級者、英語で学習できる人、AWS認定資格を目指す人

### これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **タイトル**: これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **URL**: https://www.udemy.com/course/aws-associate/
- **制作者（講師名）**: 鈴木 憲一（アルシエ）
- **言語**: 日本語
- **発行年月日**: 2019年（定期更新あり）
- **価格**: 定価 ¥27,800 / セール時 ¥1,600〜¥2,000
- **概要**: AWS認定資格対策講座。CloudTrailの基本（証跡作成、ログ確認）をハンズオン形式で学習。初学者向け。
- **評価**:
  - **良い点**: 
    - CloudTrailの基本操作を動画で確認できる
    - 証跡の作成、S3保存、CloudWatch Logs統合を学べる
    - 日本語で丁寧な解説
  - **悪い点**: 
    - CloudTrail特化ではないため、基本のみ
    - Insights、Organizations統合等の高度な機能は未カバー
- **向いている人**: AWS初学者、CloudTrailの基本操作を動画で学びたい人

---

## 📺 参考 YouTube

### AWS Black Belt Online Seminar - AWS CloudTrail
- **チャンネル名**: AWS Japan 公式チャンネル
- **動画タイトル**: AWS CloudTrail
- **URL**: https://www.youtube.com/watch?v=OhduJLT8I2M
- **言語**: 日本語
- **概要**: AWS公式のCloudTrail解説動画。基本概念から実践的な使い方（Insights、Organizations統合）まで網羅。無料で最新情報を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式の一次情報で信頼性が高い
    - 基本から応用まで体系的に学べる
    - 無料で視聴可能
    - スライド資料もダウンロード可能
    - 最新機能（Lake等）も更新される
  - **悪い点**: 
    - 動画が長い（1時間程度）
    - ハンズオンはないため、実際の操作は別途必要
- **向いている人**: CloudTrailを体系的に学びたい全レベルの学習者

### クラスメソッド - CloudTrail解説動画
- **チャンネル名**: クラスメソッド公式チャンネル
- **動画タイトル**: CloudTrail関連の解説動画（複数）
- **URL**: https://www.youtube.com/@classmethod
- **言語**: 日本語
- **概要**: AWSパートナー企業による解説動画。CloudTrailの実践的な使い方、ハマりポイントを学べる。
- **評価**:
  - **良い点**: 
    - 実務で使える具体的な設定例が豊富
    - 日本語で分かりやすい
    - 無料
  - **悪い点**: 
    - 動画数が限定的
    - 体系的な学習には他の教材も必要
- **向いている人**: CloudTrailの実践的な使い方を知りたい人

---

## 🌐 参考サイト（ブログ・公式ドキュメント・技術記事）

### ⭐ AWS CloudTrail 公式ドキュメント
- **タイトル**: AWS CloudTrail ユーザーガイド
- **URL**: https://docs.aws.amazon.com/cloudtrail/
- **運営元**: AWS公式
- **概要**: CloudTrailの公式ドキュメント。全機能の詳細仕様、ベストプラクティス、API リファレンスを提供。
- **評価**:
  - **良い点**: 
    - 最も正確で最新の情報
    - 全機能を網羅（証跡、Insights、Lake、Organizations統合）
    - Athenaでのログ分析クエリサンプルも豊富
    - 日本語版も充実
  - **悪い点**: 
    - ボリュームが多く、初学者には情報量が多すぎる
    - 体系的な学習パスは示されていない
- **向いている人**: 全レベル（特に正確な仕様を確認したい人）

### ⭐ AWS Black Belt Online Seminar - AWS CloudTrail 資料
- **タイトル**: AWS Black Belt Online Seminar - AWS CloudTrail
- **URL**: https://aws.amazon.com/jp/blogs/news/webinar-bb-aws-cloudtrail-2023/
- **運営元**: AWS Japan公式
- **概要**: AWS公式のCloudTrail解説資料（PDF/動画）。基本から実践まで日本語で学べる一次情報。
- **評価**:
  - **良い点**: 
    - AWS公式の信頼できる一次情報
    - 日本語で詳細に解説
    - PDF資料をダウンロードして復習可能
    - 定期的に更新され、新機能もカバー
  - **悪い点**: 
    - 動画が長い（60分程度）
    - ハンズオン環境は自分で用意が必要
- **向いている人**: CloudTrailを体系的に学びたい全レベルの学習者

### Classmethod（クラスメソッド）DevelopersIO - CloudTrail記事
- **タイトル**: CloudTrail関連記事（複数）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド株式会社（AWS Premier Tier Services Partner）
- **概要**: AWS専門のブログメディア。CloudTrail関連の実践的な記事が多数。Athenaでのログ分析クエリ例が豊富。
- **評価**:
  - **良い点**: 
    - 実務で使えるAthenaクエリ例が豊富
    - ハマりポイント、コスト削減Tips等が充実
    - ほぼ毎日更新され、新機能も迅速にキャッチアップ
    - 日本語で分かりやすい
  - **悪い点**: 
    - 記事数が膨大で、初学者は何から読むべきか迷う
    - 記事の質にややバラつきあり
- **向いている人**: 実務でCloudTrailを使う人、Athenaクエリ例を探している人

### AWS Security Hub - CloudTrail統合
- **タイトル**: AWS Security Hub
- **URL**: https://docs.aws.amazon.com/securityhub/
- **運営元**: AWS公式
- **概要**: AWS Security HubとCloudTrailの統合に関する公式ドキュメント。セキュリティ監視のベストプラクティスを学べる。
- **評価**:
  - **良い点**: 
    - CloudTrailをセキュリティ監視に活用する方法を学べる
    - AWS公式のベストプラクティス
    - GuardDuty、Config等との連携も解説
  - **悪い点**: 
    - セキュリティ中級者向けで、初学者には難しい
    - CloudTrail単体ではなく、Security Hub全体のドキュメント
- **向いている人**: セキュリティ中級者、CloudTrailを使ったセキュリティ監視を学びたい人

---

## 🎯 参考になる学習者向けサービス

### AWS Skill Builder
- **サービス名**: AWS Skill Builder
- **URL**: https://skillbuilder.aws/
- **運営元**: AWS公式
- **料金体系**: 無料コース多数 / 有料プラン（$29/月）
- **概要**: AWS公式の学習プラットフォーム。CloudTrail関連のラーニングパス、ハンズオンラボあり。
- **評価**:
  - **良い点**: 
    - AWS公式で信頼性が高い
    - ハンズオン環境が提供される
    - CloudTrailログのAthena分析実習もできる
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
- **概要**: AWS公式の初学者向けハンズオンシリーズ。CloudTrail関連のハンズオンあり。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 日本語で丁寧な解説
    - 実際にAWS環境で手を動かせる
    - 初学者に優しい設計
  - **悪い点**: 
    - 基本的な内容が中心
    - Insights、Organizations統合等の高度な機能は別途学習が必要
- **向いている人**: AWS初学者、CloudTrailを実際に触ってみたい人

---

## 🛠️ その他ハンズオン（実技・構築力が身につくもの）

### ⭐ AWS Workshops - CloudTrail Workshop
- **タイトル**: AWS CloudTrail Workshop
- **URL**: https://catalog.workshops.aws/
- **提供元**: AWS公式
- **価格**: 無料
- **概要**: AWS公式のCloudTrailハンズオンワークショップ。証跡設定、Athena分析、Insights設定を実践。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 実際のAWS環境で手を動かせる
    - Athenaでのログ分析を実際に体験できる
    - ステップバイステップで初学者にも優しい
  - **悪い点**: 
    - 英語のみ（日本語版なし）
    - AWS環境の構築は自分で行う必要がある
- **向いている人**: ハンズオンで学びたい人、英語で学習できる人

### CloudTrail Athena クエリサンプル集（公式）
- **タイトル**: Querying AWS CloudTrail logs with Amazon Athena
- **URL**: https://docs.aws.amazon.com/athena/latest/ug/cloudtrail-logs.html
- **提供元**: AWS公式
- **価格**: 無料
- **概要**: AWS公式のCloudTrail Athenaクエリサンプル集。実践的なクエリ例（IAM操作、EC2操作等）を提供。
- **評価**:
  - **良い点**: 
    - AWS公式で信頼性が高い
    - 実務でよく使うクエリパターンが網羅
    - コピー&ペーストで即使える
    - 無料
  - **悪い点**: 
    - サンプル集なので、体系的な学習には不向き
    - クエリの解説は最小限
- **向いている人**: CloudTrailログをAthenaで分析する人、実践的なクエリ例を探している人

---

## 📝 補足：CloudTrail学習のポイント

### 重要トピックと教材の対応

1. **基本概念（証跡、管理イベント、データイベント）**
   - → AWS Black Belt、公式ドキュメント、Udemy日本語講座

2. **証跡設定（S3保存、CloudWatch Logs統合、暗号化）**
   - → 公式ドキュメント、AWS運用入門書籍

3. **CloudTrail Insights（異常検知）**
   - → AWS Black Belt、公式ドキュメント、Udemy英語講座

4. **Organizations統合（組織全体の証跡）**
   - → AWS Black Belt、セキュリティ資格対策本

5. **Athenaでのログ分析**
   - → 公式ドキュメント（Athenaクエリサンプル）、Classmethod記事

6. **CloudTrail Lake（高度なログ分析）**
   - → AWS Black Belt（最新版）、公式ドキュメント

7. **セキュリティ監視（GuardDuty、Security Hub連携）**
   - → セキュリティ資格対策本、Udemy英語講座

### おすすめ学習パス

**初学者（CloudTrail初めて）**
1. AWS Black Belt動画（1時間）
2. AWS Hands-on for Beginners（証跡設定、2時間）
3. 公式ドキュメント（基本概念）

**中級者（Athena分析を使いたい）**
1. 公式ドキュメント（Athenaクエリサンプル）
2. Classmethod記事で実践クエリ例を収集
3. AWS Workshops でハンズオン

**上級者（セキュリティ監視を極める）**
1. Udemy英語講座（CloudTrail Insights、GuardDuty連携）
2. セキュリティ資格対策本
3. AWS Security Hub公式ドキュメント
4. 公式ドキュメント（全体を深く）

### よく使うAthenaクエリパターン

CloudTrail学習では、以下のクエリパターンを理解することが重要：

1. **特定ユーザーの操作履歴**: 
   ```sql
   SELECT eventtime, eventname, useridentity.username 
   FROM cloudtrail_logs 
   WHERE useridentity.username = 'example-user'
   ```

2. **エラーイベント検索**: 
   ```sql
   SELECT * FROM cloudtrail_logs 
   WHERE errorcode IS NOT NULL
   ```

3. **特定リソースへの操作**: 
   ```sql
   SELECT * FROM cloudtrail_logs 
   WHERE resources[1].arn = 'arn:aws:s3:::example-bucket'
   ```

4. **IAM操作履歴**: 
   ```sql
   SELECT * FROM cloudtrail_logs 
   WHERE eventname LIKE '%IAM%'
   ```

5. **時間範囲指定**: 
   ```sql
   SELECT * FROM cloudtrail_logs 
   WHERE eventtime BETWEEN '2024-01-01' AND '2024-12-31'
   ```
