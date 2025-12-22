# AWS Auto Scaling 学習に役立つ参考資料

## 📚 参考書

### AWS認定資格試験テキスト AWS認定 ソリューションアーキテクト - アソシエイト
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4815616698
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4815616698
- **出版社**: SBクリエイティブ
- **発行年月日**: 2023年3月
- **価格**: ¥2,970
- **概要**: AWS認定資格対策本。Auto Scalingの基本（起動設定、スケーリングポリシー、ELB連携）を体系的に解説。初学者向け。
- **評価**:
  - **良い点**: 
    - Auto Scalingの基本概念を体系的に学べる
    - スケーリングポリシー（ターゲット追跡、ステップスケーリング）の違いを理解できる
    - ELB、CloudWatchとの連携も解説
    - 図解が多く理解しやすい
  - **悪い点**: 
    - Auto Scaling特化ではなくAWS全般の本
    - 高度な設定（Warm Pool、Predictive Scaling等）は説明が少ない
- **向いている人**: AWS初学者、Auto Scalingの基本を理解したい人

### AWS運用入門 - DevOpsチームとして知っておくべき運用の基本
- **URL_1（目次ページ）**: 不明
- **URL_2（公式トップ or 販売トップ）**: https://www.amazon.co.jp/dp/4297119072
- **URL_3（Amazon商品ページ）**: https://www.amazon.co.jp/dp/4297119072
- **出版社**: 技術評論社
- **発行年月日**: 2020年5月
- **価格**: ¥3,278
- **概要**: AWS運用に特化した書籍。Auto Scalingを使った可用性設計、コスト最適化を実務観点で解説。中級者向け。
- **評価**:
  - **良い点**: 
    - Auto Scalingを使った実務的な可用性設計パターンを学べる
    - スケーリングポリシーの設定例が実践的
    - ELB、CloudWatch Alarmsとの連携も詳細
  - **悪い点**: 
    - 2020年発行のため、新機能（Warm Pool等）は未掲載
    - Auto Scaling特化ではなく、AWS運用全般の本
- **向いている人**: AWS運用担当者、可用性設計を学びたい人

---

## 🎥 参考 Udemy 動画

### これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **タイトル**: これだけでOK！ AWS認定ソリューションアーキテクト - アソシエイト試験突破講座
- **URL**: https://www.udemy.com/course/aws-associate/
- **制作者（講師名）**: 鈴木 憲一（アルシエ）
- **言語**: 日本語
- **発行年月日**: 2019年（定期更新あり）
- **価格**: 定価 ¥27,800 / セール時 ¥1,600〜¥2,000
- **概要**: AWS認定資格対策講座。Auto Scalingの基本機能（起動テンプレート、スケーリングポリシー、ELB連携）をハンズオン形式で学習。初学者向け。
- **評価**:
  - **良い点**: 
    - Auto Scalingの基本操作を動画で確認できる
    - ハンズオン環境での実演が分かりやすい
    - 日本語で丁寧な解説
  - **悪い点**: 
    - Auto Scaling特化ではないため、深い内容は少ない
    - Warm Pool、Predictive Scaling等の高度な機能は未カバー
- **向いている人**: AWS初学者、Auto Scalingの基本操作を動画で学びたい人

---

## 📺 参考 YouTube

### AWS Black Belt Online Seminar - Amazon EC2 Auto Scaling
- **チャンネル名**: AWS Japan 公式チャンネル
- **動画タイトル**: Amazon EC2 Auto Scaling
- **URL**: https://www.youtube.com/@awsjapan
- **言語**: 日本語
- **概要**: AWS公式のAuto Scaling解説動画。基本概念から実践的な使い方（スケーリングポリシー、Warm Pool、Predictive Scaling）まで網羅。無料で最新情報を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式の一次情報で信頼性が高い
    - Auto Scalingの全機能を体系的に学べる
    - 無料で視聴可能
    - スライド資料もダウンロード可能
  - **悪い点**: 
    - 動画が長い（1時間程度）
    - ハンズオンはないため、実際の操作は別途必要
- **向いている人**: Auto Scalingを体系的に学びたい全レベルの学習者

---

## 🌐 参考サイト（ブログ・公式ドキュメント・技術記事）

### ⭐ Amazon EC2 Auto Scaling 公式ドキュメント
- **タイトル**: Amazon EC2 Auto Scaling ユーザーガイド
- **URL**: https://docs.aws.amazon.com/autoscaling/
- **運営元**: AWS公式
- **概要**: Auto Scalingの公式ドキュメント。全機能の詳細仕様、ベストプラクティス、API リファレンスを提供。
- **評価**:
  - **良い点**: 
    - 最も正確で最新の情報
    - 全機能を網羅（起動テンプレート、スケーリングポリシー、Warm Pool等）
    - コードサンプル、CLI/SDK例が豊富
    - 日本語版も充実
  - **悪い点**: 
    - ボリュームが多く、初学者には情報量が多すぎる
    - 体系的な学習パスは示されていない
- **向いている人**: 全レベル（特に正確な仕様を確認したい人）

### Classmethod（クラスメソッド）DevelopersIO - Auto Scaling記事
- **タイトル**: Auto Scaling関連記事（複数）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド株式会社（AWS Premier Tier Services Partner）
- **概要**: AWS専門のブログメディア。Auto Scaling関連の実践的な記事が多数。
- **評価**:
  - **良い点**: 
    - 実務で使える具体的な設定例が豊富
    - ハマりポイント、トラブルシューティングが充実
    - ほぼ毎日更新され、新機能も迅速にキャッチアップ
    - 日本語で分かりやすい
  - **悪い点**: 
    - 記事数が膨大で、初学者は何から読むべきか迷う
- **向いている人**: 実務でAuto Scalingを使う人、具体的な設定例を探している人

---

## 🎯 参考になる学習者向けサービス

### AWS Hands-on for Beginners
- **サービス名**: AWS Hands-on for Beginners
- **URL**: https://aws.amazon.com/jp/aws-jp-introduction/aws-jp-webinar-hands-on/
- **運営元**: AWS Japan公式
- **料金体系**: 無料
- **概要**: AWS公式の初学者向けハンズオンシリーズ。Auto Scaling関連のハンズオンあり。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 日本語で丁寧な解説
    - 実際にAWS環境で手を動かせる
    - 初学者に優しい設計
  - **悪い点**: 
    - 基本的な内容が中心
    - 高度な機能は別途学習が必要
- **向いている人**: AWS初学者、Auto Scalingを実際に触ってみたい人

---

## 📝 補足：Auto Scaling学習のポイント

### 重要トピックと教材の対応

1. **基本概念（Auto Scalingグループ、起動テンプレート）**
   - → AWS Black Belt、公式ドキュメント、Udemy日本語講座

2. **スケーリングポリシー（ターゲット追跡、ステップ、シンプル）**
   - → 公式ドキュメント、AWS運用入門書籍

3. **ELB連携**
   - → Udemy日本語講座、公式ドキュメント

4. **CloudWatch連携（メトリクス、アラーム）**
   - → AWS運用入門書籍、公式ドキュメント

5. **Warm Pool（起動高速化）**
   - → AWS Black Belt（最新版）、公式ドキュメント

6. **Predictive Scaling（予測スケーリング）**
   - → AWS Black Belt（最新版）、公式ドキュメント

### おすすめ学習パス

**初学者（Auto Scaling初めて）**
1. AWS Black Belt動画（Auto Scaling、1時間）
2. AWS Hands-on for Beginners（Auto Scaling設定、2時間）
3. 公式ドキュメント（基本概念）

**中級者（実務で使いたい）**
1. AWS運用入門書籍（Auto Scaling章）
2. 公式ドキュメント（スケーリングポリシー詳細）
3. Classmethod記事で実践Tips収集

### スケーリングポリシーの使い分け

| ポリシータイプ | 用途 | 特徴 |
|---------------|------|------|
| **ターゲット追跡** | 最も一般的 | CPU使用率等を目標値に維持 |
| **ステップスケーリング** | 段階的スケール | 負荷に応じて段階的にスケール |
| **シンプルスケーリング** | 基本的 | 1回のアラームで1回スケール |
| **Predictive Scaling** | 予測 | 機械学習で予測してスケール |
