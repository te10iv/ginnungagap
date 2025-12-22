# Amazon CloudWatch 学習に役立つ参考資料

## 📚 参考書

### ⭐ AWS認定資格試験テキスト AWS認定 ソリューションアーキテクト - アソシエイト
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4815616698
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4815616698
- **出版社**: SBクリエイティブ
- **発行年月日**: 2023年3月
- **価格**: ¥2,970
- **概要**: AWS認定資格対策本。CloudWatchの監視・アラーム設定について基本から解説。初学者向け。
- **評価**:
  - **良い点**: 
    - CloudWatchの基本概念（メトリクス、アラーム、ダッシュボード）を体系的に学べる
    - 実務でよく使う機能に絞って解説
    - 図解が多く理解しやすい
  - **悪い点**: 
    - CloudWatch特化ではなくAWS全般の本のため、深堀りは少ない
    - Logs Insights、Container Insights等の高度な機能の説明は薄い
- **向いている人**: AWS初学者、CloudWatchの基本を理解したい人

### AWS運用入門 - DevOpsチームとして知っておくべき運用の基本
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4297119072
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4297119072
- **出版社**: 技術評論社
- **発行年月日**: 2020年5月
- **価格**: ¥3,278
- **概要**: AWS運用に特化した書籍。CloudWatchを使った監視設計・アラート設計を実務観点で解説。中級者向け。
- **評価**:
  - **良い点**: 
    - CloudWatchを使った実務的な監視設計パターンを学べる
    - アラームの閾値設定、通知設計など実践的
    - Systems Manager、CloudTrailとの連携も解説
  - **悪い点**: 
    - 2020年発行のため、新機能（RUM、Evidently等）は未掲載
    - ページ数の都合上、各サービスの深堀りは限定的
- **向いている人**: AWS運用担当者、監視設計を学びたい人

---

## 🎥 参考 Udemy 動画

### これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **タイトル**: これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **URL**: https://www.udemy.com/course/aws-associate/
- **制作者（講師名）**: 鈴木 憲一（アルシエ）
- **言語**: 日本語
- **発行年月日**: 2019年（定期更新あり）
- **価格**: 定価 ¥27,800 / セール時 ¥1,600〜¥2,000
- **概要**: AWS認定資格対策講座。CloudWatchの基本機能（メトリクス、アラーム、ログ）をハンズオン形式で学習。初学者向け。
- **評価**:
  - **良い点**: 
    - CloudWatchの基本操作を動画で確認できる
    - ハンズオン環境での実演が分かりやすい
    - 日本語で丁寧な解説
  - **悪い点**: 
    - CloudWatch特化ではないため、深い内容は少ない
    - 高度な機能（Logs Insights、Contributor Insights等）は未カバー
- **向いている人**: AWS初学者、CloudWatchの基本操作を動画で学びたい人

### AWS Monitoring and Logging (英語)
- **タイトル**: AWS Monitoring and Logging
- **URL**: https://www.udemy.com/course/aws-monitoring-and-logging/
- **制作者（講師名）**: Stephane Maarek
- **言語**: 英語
- **発行年月日**: 2021年（定期更新あり）
- **価格**: 定価 $84.99 / セール時 $12.99〜$19.99
- **概要**: CloudWatch特化の監視・ログ解析講座。Logs Insights、Container Insights、Contributor Insightsなど高度な機能まで網羅。中級者向け。
- **評価**:
  - **良い点**: 
    - CloudWatch全機能を深く解説
    - Logs InsightsのクエリやLambdaとの連携など実践的
    - X-Ray、CloudTrailとの連携も詳細
  - **悪い点**: 
    - 英語のため日本語話者にはハードルが高い
    - 高度な内容が多く初学者には難しい
- **向いている人**: CloudWatch中級者、英語で学習できる人、高度な監視設計を学びたい人

---

## 📺 参考 YouTube

### AWS Black Belt Online Seminar - Amazon CloudWatch
- **チャンネル名**: AWS Japan 公式チャンネル
- **動画タイトル**: Amazon CloudWatch
- **URL**: https://www.youtube.com/watch?v=6XJlMLpJMIk
- **言語**: 日本語
- **概要**: AWS公式のCloudWatch解説動画。基本概念から実践的な使い方まで網羅。無料で最新情報を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式の一次情報で信頼性が高い
    - 基本から応用まで体系的に学べる
    - 無料で視聴可能
    - スライド資料もダウンロード可能
  - **悪い点**: 
    - 動画が長い（1時間程度）
    - ハンズオンはないため、実際の操作は別途必要
- **向いている人**: CloudWatchを体系的に学びたい全レベルの学習者

### AWSの基本・仕組み・重要用語が全部わかる教科書
- **チャンネル名**: キノコード / プログラミング学習動画のYouTuber
- **動画タイトル**: CloudWatch関連の解説動画（複数）
- **URL**: https://www.youtube.com/@kinocode
- **言語**: 日本語
- **概要**: AWS初学者向けの無料解説動画チャンネル。CloudWatchの基本を短時間で学べる。
- **評価**:
  - **良い点**: 
    - 10〜20分程度の短い動画で要点を学べる
    - 初学者向けで分かりやすい
    - 無料
  - **悪い点**: 
    - CloudWatch特化チャンネルではない
    - 深い内容や高度な機能は未カバー
- **向いている人**: AWS初学者、短時間でCloudWatchの概要を知りたい人

---

## 🌐 参考サイト（ブログ・公式ドキュメント・技術記事）

### ⭐ Amazon CloudWatch 公式ドキュメント
- **タイトル**: Amazon CloudWatch ユーザーガイド
- **URL**: https://docs.aws.amazon.com/cloudwatch/
- **運営元**: AWS公式
- **概要**: CloudWatchの公式ドキュメント。全機能の詳細仕様、ベストプラクティス、API リファレンスを提供。
- **評価**:
  - **良い点**: 
    - 最も正確で最新の情報
    - 全機能を網羅
    - コードサンプル、CLI/SDK例が豊富
    - 日本語版も充実
  - **悪い点**: 
    - ボリュームが多く、初学者には情報量が多すぎる
    - 体系的な学習パスは示されていない
- **向いている人**: 全レベル（特に正確な仕様を確認したい人）

### ⭐ AWS Black Belt Online Seminar - Amazon CloudWatch 資料
- **タイトル**: AWS Black Belt Online Seminar - Amazon CloudWatch
- **URL**: https://aws.amazon.com/jp/blogs/news/webinar-bb-amazon-cloudwatch-2023/
- **運営元**: AWS Japan公式
- **概要**: AWS公式のCloudWatch解説資料（PDF/動画）。基本から実践まで日本語で学べる一次情報。
- **評価**:
  - **良い点**: 
    - AWS公式の信頼できる一次情報
    - 日本語で詳細に解説
    - PDF資料をダウンロードして復習可能
    - 定期的に更新され、新機能もカバー
  - **悪い点**: 
    - 動画が長い（60分程度）
    - ハンズオン環境は自分で用意が必要
- **向いている人**: CloudWatchを体系的に学びたい全レベルの学習者

### Classmethod（クラスメソッド）DevelopersIO - CloudWatch記事
- **タイトル**: CloudWatch関連記事（複数）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド株式会社（AWS Premier Tier Services Partner）
- **概要**: AWS専門のブログメディア。CloudWatch関連の実践的な記事が多数。
- **評価**:
  - **良い点**: 
    - 実務で使えるTips、ハマりポイントが豊富
    - ほぼ毎日更新され、新機能も迅速にキャッチアップ
    - 日本語で分かりやすい
    - 具体的なユースケースが多い
  - **悪い点**: 
    - 記事数が膨大で、初学者は何から読むべきか迷う
    - 記事の質にややバラつきあり
- **向いている人**: 実務でCloudWatchを使う人、具体的な設定例を探している人

### AWS Well-Architected Framework - 監視セクション
- **タイトル**: AWS Well-Architected Framework - Operational Excellence Pillar
- **URL**: https://docs.aws.amazon.com/wellarchitected/
- **運営元**: AWS公式
- **概要**: AWSのベストプラクティス集。監視設計のベストプラクティスとしてCloudWatchの活用方法を解説。
- **評価**:
  - **良い点**: 
    - AWS公式のベストプラクティス
    - 監視設計の考え方を学べる
    - CloudWatch以外の監視ツールとの使い分けも解説
  - **悪い点**: 
    - 初学者には抽象度が高い
    - 具体的な設定手順は少ない
- **向いている人**: 中級者以上、監視設計のベストプラクティスを学びたい人

---

## 🎯 参考になる学習者向けサービス

### AWS Skill Builder
- **サービス名**: AWS Skill Builder
- **URL**: https://skillbuilder.aws/
- **運営元**: AWS公式
- **料金体系**: 無料コース多数 / 有料プラン（$29/月）
- **概要**: AWS公式の学習プラットフォーム。CloudWatch関連のラーニングパス、ハンズオンラボあり。
- **評価**:
  - **良い点**: 
    - AWS公式で信頼性が高い
    - ハンズオン環境が提供される
    - 無料コースも充実
    - 最新情報に随時アップデート
  - **悪い点**: 
    - 英語コンテンツが多い（日本語は一部のみ）
    - 有料プランでないと全機能使えない
- **向いている人**: AWS認定資格を目指す人、ハンズオンで学びたい人

### AWS Hands-on for Beginners
- **サービス名**: AWS Hands-on for Beginners
- **URL**: https://aws.amazon.com/jp/aws-jp-introduction/aws-jp-webinar-hands-on/
- **運営元**: AWS Japan公式
- **料金体系**: 無料
- **概要**: AWS公式の初学者向けハンズオンシリーズ。CloudWatch関連のハンズオンあり。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 日本語で丁寧な解説
    - 実際にAWS環境で手を動かせる
    - 初学者に優しい設計
  - **悪い点**: 
    - 基本的な内容が中心
    - 高度な機能は別途学習が必要
- **向いている人**: AWS初学者、CloudWatchを実際に触ってみたい人

---

## 🏫 スクールの講座・カリキュラム

### RaiseTech - AWS フルコース
- **講座名**: AWS フルコース
- **URL**: https://raise-tech.net/courses/aws-full-course
- **運営元**: RaiseTech株式会社
- **受講形式**: ライブ授業（オンライン）
- **価格**: ¥448,000（分割払い可）
- **概要**: AWS実務スキルを習得する16週間のコース。CloudWatchを使った監視設計を実践的に学ぶ。
- **評価**:
  - **良い点**: 
    - 現役エンジニアによるライブ授業
    - CloudWatchを使った実践的な監視設計を学べる
    - 質問し放題のサポート
    - 就職・転職支援あり
  - **悪い点**: 
    - 料金が高額
    - CloudWatch特化ではなくAWS全般のコース
    - 受講期間が長い（16週間）
- **向いている人**: AWS実務スキルを体系的に学びたい人、転職を目指す人

---

## 🛠️ その他ハンズオン（実技・構築力が身につくもの）

### ⭐ AWS Workshops - CloudWatch Workshop
- **タイトル**: Amazon CloudWatch Workshop
- **URL**: https://catalog.workshops.aws/
- **提供元**: AWS公式
- **価格**: 無料
- **概要**: AWS公式のCloudWatchハンズオンワークショップ。実際のAWS環境で監視設計を実践。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 実際のAWS環境で手を動かせる
    - メトリクス、ログ、アラーム、ダッシュボードを包括的に学べる
    - ステップバイステップで初学者にも優しい
  - **悪い点**: 
    - 英語のみ（日本語版なし）
    - AWS環境の構築は自分で行う必要がある
- **向いている人**: ハンズオンで学びたい人、英語で学習できる人

### Qwiklabs - CloudWatch関連ラボ
- **タイトル**: CloudWatch関連の複数ラボ
- **URL**: https://www.cloudskillsboost.google/
- **提供元**: Google Cloud (Qwiklabs)
- **価格**: 無料ラボ / 有料ラボ（クレジット制）
- **概要**: ハンズオン学習プラットフォーム。CloudWatch関連のラボが複数提供されている。
- **評価**:
  - **良い点**: 
    - 実際のAWS環境が自動で用意される
    - ステップバイステップのガイド付き
    - 複数のシナリオを学べる
  - **悪い点**: 
    - 有料ラボが多い
    - AWS公式ではないため、最新情報への追従が遅い場合がある
- **向いている人**: ハンズオン環境を自分で用意したくない人、体系的に学びたい人

---

## 📝 補足：CloudWatch学習のポイント

### 重要トピックと教材の対応

1. **基本概念（メトリクス、アラーム、ダッシュボード）**
   - → AWS Black Belt、公式ドキュメント、Udemy日本語講座

2. **Logs Insights（ログ分析クエリ）**
   - → 公式ドキュメント、Classmethod記事、Udemy英語講座

3. **Container Insights / Lambda Insights**
   - → AWS Black Belt、公式ドキュメント

4. **カスタムメトリクス・CloudWatch Agent**
   - → 公式ドキュメント、AWS運用入門書籍

5. **Systems Manager / CloudTrail / X-Ray との連携**
   - → AWS運用入門書籍、Udemy英語講座

### おすすめ学習パス

**初学者（CloudWatch初めて）**
1. AWS Black Belt動画（1時間）
2. AWS Hands-on for Beginners（2時間）
3. Udemy日本語講座（10時間）

**中級者（実務で使いたい）**
1. AWS運用入門書籍
2. 公式ドキュメント（必要箇所）
3. Classmethod記事で実践Tips収集
4. AWS Workshops でハンズオン

**上級者（監視設計を極める）**
1. Udemy英語講座（高度な機能）
2. Well-Architected Framework
3. 公式ドキュメント（全体を深く）
