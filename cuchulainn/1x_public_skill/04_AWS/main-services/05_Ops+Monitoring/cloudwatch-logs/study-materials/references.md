# Amazon CloudWatch Logs 学習に役立つ参考資料

## 📚 参考書

### AWS運用入門 - DevOpsチームとして知っておくべき運用の基本
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4297119072
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4297119072
- **出版社**: 技術評論社
- **発行年月日**: 2020年5月
- **価格**: ¥3,278
- **概要**: AWS運用に特化した書籍。CloudWatch Logsを使ったログ収集・分析・監視設計を実務観点で解説。中級者向け。
- **評価**:
  - **良い点**: 
    - CloudWatch Logsを使った実務的なログ管理パターンを学べる
    - ログの収集、フィルタリング、アラート設定など実践的
    - Lambda、SNSとの連携も解説
  - **悪い点**: 
    - 2020年発行のため、Logs Insightsの高度な機能は説明が薄い
    - CloudWatch Logs特化ではなく、AWS運用全般の本
- **向いている人**: AWS運用担当者、ログ管理設計を学びたい人

### AWSではじめるインフラ構築入門
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4798163430
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4798163430
- **出版社**: 翔泳社
- **発行年月日**: 2021年5月
- **価格**: ¥3,080
- **概要**: AWS初学者向けのインフラ構築入門書。CloudWatch Logsの基本設定をハンズオン形式で学べる。初学者向け。
- **評価**:
  - **良い点**: 
    - CloudWatch Logsの基本設定を手を動かして学べる
    - 図解が多く初学者に優しい
    - EC2、Lambda等のログをCloudWatch Logsに送る方法を学べる
  - **悪い点**: 
    - Logs Insightsのクエリ等、高度な分析機能は説明が少ない
    - CloudWatch Logs特化ではない
- **向いている人**: AWS初学者、ハンズオンでログ収集を学びたい人

---

## 🎥 参考 Udemy 動画

### これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **タイトル**: これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **URL**: https://www.udemy.com/course/aws-associate/
- **制作者（講師名）**: 鈴木 憲一（アルシエ）
- **言語**: 日本語
- **発行年月日**: 2019年（定期更新あり）
- **価格**: 定価 ¥27,800 / セール時 ¥1,600〜¥2,000
- **概要**: AWS認定資格対策講座。CloudWatch Logsの基本（ログ収集、ロググループ、メトリクスフィルター）をハンズオン形式で学習。初学者向け。
- **評価**:
  - **良い点**: 
    - CloudWatch Logsの基本操作を動画で確認できる
    - ハンズオン環境での実演が分かりやすい
    - 日本語で丁寧な解説
  - **悪い点**: 
    - CloudWatch Logs特化ではないため、深い内容は少ない
    - Logs Insightsのクエリ等、高度な分析機能は未カバー
- **向いている人**: AWS初学者、CloudWatch Logsの基本操作を動画で学びたい人

### AWS Monitoring and Logging (英語)
- **タイトル**: AWS Monitoring and Logging
- **URL**: https://www.udemy.com/course/aws-monitoring-and-logging/
- **制作者（講師名）**: Stephane Maarek
- **言語**: 英語
- **発行年月日**: 2021年（定期更新あり）
- **価格**: 定価 $84.99 / セール時 $12.99〜$19.99
- **概要**: CloudWatch Logs特化の監視・ログ解析講座。Logs Insights、サブスクリプションフィルター、Lambdaとの連携など高度な機能まで網羅。中級者向け。
- **評価**:
  - **良い点**: 
    - CloudWatch Logs全機能を深く解説
    - Logs Insightsのクエリ言語を実践的に学べる
    - Kinesis Data Firehose、Lambda等との連携も詳細
    - メトリクスフィルターの実践的な使い方
  - **悪い点**: 
    - 英語のため日本語話者にはハードルが高い
    - 高度な内容が多く初学者には難しい
- **向いている人**: CloudWatch Logs中級者、英語で学習できる人、高度なログ分析を学びたい人

---

## 📺 参考 YouTube

### AWS Black Belt Online Seminar - Amazon CloudWatch Logs
- **チャンネル名**: AWS Japan 公式チャンネル
- **動画タイトル**: Amazon CloudWatch
- **URL**: https://www.youtube.com/watch?v=6XJlMLpJMIk
- **言語**: 日本語
- **概要**: AWS公式のCloudWatch解説動画（CloudWatch Logsも含む）。基本概念から実践的な使い方まで網羅。無料で最新情報を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式の一次情報で信頼性が高い
    - ログ収集、Logs Insights、メトリクスフィルターを体系的に学べる
    - 無料で視聴可能
    - スライド資料もダウンロード可能
  - **悪い点**: 
    - 動画が長い（1時間程度）
    - ハンズオンはないため、実際の操作は別途必要
- **向いている人**: CloudWatch Logsを体系的に学びたい全レベルの学習者

### サーバーワークス - AWS CloudWatch Logs Insights 解説
- **チャンネル名**: サーバーワークス公式チャンネル
- **動画タイトル**: CloudWatch Logs関連の解説動画（複数）
- **URL**: https://www.youtube.com/@ServerWorks_official
- **言語**: 日本語
- **概要**: AWSパートナー企業による解説動画。CloudWatch Logs Insightsの実践的な使い方を学べる。
- **評価**:
  - **良い点**: 
    - 実務で使える具体的なクエリ例が豊富
    - 日本語で分かりやすい
    - 無料
  - **悪い点**: 
    - 動画数が限定的
    - 体系的な学習には他の教材も必要
- **向いている人**: Logs Insightsの実践的な使い方を知りたい人

---

## 🌐 参考サイト（ブログ・公式ドキュメント・技術記事）

### ⭐ Amazon CloudWatch Logs 公式ドキュメント
- **タイトル**: Amazon CloudWatch Logs ユーザーガイド
- **URL**: https://docs.aws.amazon.com/cloudwatch/
- **運営元**: AWS公式
- **概要**: CloudWatch Logsの公式ドキュメント。全機能の詳細仕様、Logs Insightsクエリシンタックス、API リファレンスを提供。
- **評価**:
  - **良い点**: 
    - 最も正確で最新の情報
    - Logs Insightsクエリの全構文を網羅
    - コードサンプル、CLI/SDK例が豊富
    - 日本語版も充実
  - **悪い点**: 
    - ボリュームが多く、初学者には情報量が多すぎる
    - 体系的な学習パスは示されていない
- **向いている人**: 全レベル（特に正確な仕様・クエリ構文を確認したい人）

### ⭐ Amazon CloudWatch Logs Insights クエリシンタックス
- **タイトル**: CloudWatch Logs Insights query syntax
- **URL**: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html
- **運営元**: AWS公式
- **概要**: Logs Insightsのクエリ言語の公式リファレンス。全コマンド、関数、フィルター構文を詳細解説。
- **評価**:
  - **良い点**: 
    - クエリ言語の全構文を網羅
    - サンプルクエリが豊富
    - 最も正確な情報
  - **悪い点**: 
    - リファレンスなので、学習パスは示されていない
    - 初学者には抽象度が高い
- **向いている人**: Logs Insightsクエリを書く人、正確な構文を確認したい人

### Classmethod（クラスメソッド）DevelopersIO - CloudWatch Logs記事
- **タイトル**: CloudWatch Logs関連記事（複数）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド株式会社（AWS Premier Tier Services Partner）
- **概要**: AWS専門のブログメディア。CloudWatch Logs関連の実践的な記事が多数。Logs Insightsクエリ例が豊富。
- **評価**:
  - **良い点**: 
    - 実務で使えるLogs Insightsクエリ例が豊富
    - ハマりポイント、コスト削減Tips等が充実
    - ほぼ毎日更新され、新機能も迅速にキャッチアップ
    - 日本語で分かりやすい
  - **悪い点**: 
    - 記事数が膨大で、初学者は何から読むべきか迷う
    - 記事の質にややバラつきあり
- **向いている人**: 実務でCloudWatch Logsを使う人、Logs Insightsクエリ例を探している人

### AWS Black Belt Online Seminar - Amazon CloudWatch Logs 資料
- **タイトル**: AWS Black Belt Online Seminar - Amazon CloudWatch
- **URL**: https://aws.amazon.com/jp/blogs/news/webinar-bb-amazon-cloudwatch-2023/
- **運営元**: AWS Japan公式
- **概要**: AWS公式のCloudWatch解説資料（CloudWatch Logsも含む）。基本から実践まで日本語で学べる一次情報。
- **評価**:
  - **良い点**: 
    - AWS公式の信頼できる一次情報
    - 日本語で詳細に解説
    - PDF資料をダウンロードして復習可能
    - Logs Insightsのクエリ例も掲載
  - **悪い点**: 
    - CloudWatch全般の資料なので、Logs特化ではない
    - 動画が長い（60分程度）
- **向いている人**: CloudWatch Logsを体系的に学びたい全レベルの学習者

---

## 🎯 参考になる学習者向けサービス

### AWS Skill Builder
- **サービス名**: AWS Skill Builder
- **URL**: https://skillbuilder.aws/
- **運営元**: AWS公式
- **料金体系**: 無料コース多数 / 有料プラン（$29/月）
- **概要**: AWS公式の学習プラットフォーム。CloudWatch Logs関連のラーニングパス、ハンズオンラボあり。
- **評価**:
  - **良い点**: 
    - AWS公式で信頼性が高い
    - ハンズオン環境が提供される
    - Logs Insightsのクエリ実習もできる
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
- **概要**: AWS公式の初学者向けハンズオンシリーズ。CloudWatch Logs関連のハンズオンあり。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 日本語で丁寧な解説
    - 実際にAWS環境で手を動かせる
    - 初学者に優しい設計
  - **悪い点**: 
    - 基本的な内容が中心
    - Logs Insightsの高度な機能は別途学習が必要
- **向いている人**: AWS初学者、CloudWatch Logsを実際に触ってみたい人

---

## 🛠️ その他ハンズオン（実技・構築力が身につくもの）

### ⭐ AWS Workshops - CloudWatch Logs Workshop
- **タイトル**: Amazon CloudWatch Workshop
- **URL**: https://catalog.workshops.aws/
- **提供元**: AWS公式
- **価格**: 無料
- **概要**: AWS公式のCloudWatch Logsハンズオンワークショップ。Logs Insightsクエリ、サブスクリプションフィルター、Lambda連携を実践。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 実際のAWS環境で手を動かせる
    - Logs Insightsクエリを実際に書いて学べる
    - ステップバイステップで初学者にも優しい
  - **悪い点**: 
    - 英語のみ（日本語版なし）
    - AWS環境の構築は自分で行う必要がある
- **向いている人**: ハンズオンで学びたい人、英語で学習できる人

### CloudWatch Logs Insights サンプルクエリ集（公式）
- **タイトル**: Sample queries for CloudWatch Logs Insights
- **URL**: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax-examples.html
- **提供元**: AWS公式
- **価格**: 無料
- **概要**: AWS公式のLogs Insightsサンプルクエリ集。ALB、Lambda、VPC Flow Logs等の実践的なクエリ例を提供。
- **評価**:
  - **良い点**: 
    - AWS公式で信頼性が高い
    - 実務でよく使うクエリパターンが網羅
    - コピー&ペーストで即使える
    - 無料
  - **悪い点**: 
    - サンプル集なので、体系的な学習には不向き
    - クエリの解説は最小限
- **向いている人**: Logs Insightsクエリを書く人、実践的なクエリ例を探している人

---

## 📝 補足：CloudWatch Logs学習のポイント

### 重要トピックと教材の対応

1. **基本概念（ロググループ、ログストリーム、保持期間）**
   - → AWS Black Belt、公式ドキュメント、Udemy日本語講座

2. **ログ収集（EC2、Lambda、ECS等からの収集）**
   - → AWS運用入門書籍、AWSインフラ構築入門書籍

3. **Logs Insights（クエリ言語、ログ分析）**
   - → 公式ドキュメント（クエリシンタックス）、Classmethod記事、Udemy英語講座

4. **メトリクスフィルター（ログからメトリクス生成）**
   - → 公式ドキュメント、AWS運用入門書籍

5. **サブスクリプションフィルター（Lambda、Kinesis連携）**
   - → Udemy英語講座、公式ドキュメント

6. **コスト最適化（保持期間設定、S3アーカイブ）**
   - → Classmethod記事、Well-Architected Framework

### おすすめ学習パス

**初学者（CloudWatch Logs初めて）**
1. AWS Black Belt動画（CloudWatch Logsセクション、30分）
2. AWS Hands-on for Beginners（ログ収集、2時間）
3. 公式ドキュメント（基本概念）

**中級者（Logs Insightsを使いたい）**
1. 公式ドキュメント（Logs Insightsクエリシンタックス）
2. サンプルクエリ集（公式）でクエリ例を学習
3. Classmethod記事で実践Tips収集
4. AWS Workshops でハンズオン

**上級者（高度なログ分析・連携）**
1. Udemy英語講座（サブスクリプションフィルター、Lambda連携）
2. 公式ドキュメント（全体を深く）
3. Classmethod記事で最新Tips収集

### よく使うLogs Insightsクエリパターン

CloudWatch Logs学習では、以下のクエリパターンを理解することが重要：

1. **基本フィルタリング**: `fields @timestamp, @message | filter @message like /ERROR/`
2. **統計・集計**: `stats count(*) by bin(5m)`
3. **ソート・制限**: `sort @timestamp desc | limit 100`
4. **正規表現**: `parse @message /\[(?<level>\w+)\]/`
5. **ALBログ分析**: `fields @timestamp, request, status | filter status >= 400`
