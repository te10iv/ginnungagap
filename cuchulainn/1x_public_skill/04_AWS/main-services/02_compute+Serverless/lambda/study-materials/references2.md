# AWS Lambda 学習に役立つ参考資料（初心者・実務直前向け 追加版）

> 💡 **このドキュメントは `references.md` の補足資料です**  
> 来月からLambdaを使う案件に入る初心者向けに、より実践的・具体的な学習資料を追加しています。

---

## 🎯 Lambda を初めて学ぶ人へ：学習ロードマップ

### ステップ1：Lambdaとは何か理解する（1〜2時間）
1. AWS Black Belt「AWS Lambda 基礎編」（30分）
2. AWS公式「Lambda とは」ドキュメント（30分）
3. くろかわこうへいさんの初心者向け動画（10分）

### ステップ2：実際に触ってみる（2〜4時間）
1. AWS Hands-on for Beginners - サーバーレス編（2時間）
2. コンソールで簡単な関数を作成（1時間）
3. CloudWatch Logsでログを確認（30分）

### ステップ3：頻出パターンを学ぶ（4〜8時間）
1. API Gateway + Lambda（2時間）
2. S3トリガー（1時間）
3. EventBridge定期実行（1時間）
4. DynamoDB連携（2時間）

### ステップ4：ハマりポイントを事前に知る（2時間）
1. IAM権限設定
2. タイムアウト・メモリ設定
3. VPC Lambdaの注意点

---

## 📚 【超初心者向け】Lambdaとは何か理解する資料

### ⭐ AWS公式「AWS Lambdaとは」
- **タイトル**: AWS Lambda とは
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
- **運営元**: AWS公式
- **概要**: Lambda公式ドキュメントの概要ページ。Lambdaが何なのか、何ができるのかを最も正確に理解できる。**初心者向け。**
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確な情報
    - 図解付きでLambdaの仕組みを理解できる
    - サーバーレスの概念を基礎から学べる
    - 日本語版あり
  - **悪い点**: 
    - 文章が長め
    - 実際の操作イメージは別途必要
- **向いている人**: Lambda初学者、正確な概念を理解したい人
- **学習時間**: 30分

### ⭐ AWS Hands-on for Beginners - サーバーレス編
- **タイトル**: AWS Hands-on for Beginners - サーバーレス編
- **URL**: https://aws.amazon.com/jp/aws-jp-introduction/aws-jp-webinar-hands-on/
- **運営元**: AWS Japan公式
- **概要**: **Lambda初学者に最適なハンズオン。** Lambda関数の作成から実行、API Gateway連携まで実際に手を動かして学べる。**完全無料、日本語。**
- **評価**:
  - **良い点**: 
    - Lambda初学者に最も推奨される教材
    - AWS公式で無料
    - 日本語で非常に丁寧な解説
    - 動画とテキストの両方で学べる
    - 実際にAWS環境で手を動かせる
    - API Gateway、DynamoDB連携も学べる
  - **悪い点**: 
    - なし（初学者には最適）
- **向いている人**: Lambda初学者、実際に手を動かして学びたい人
- **学習時間**: 2〜3時間

### くろかわこうへい - AWS Lambda 超入門
- **チャンネル名**: くろかわこうへい
- **動画タイトル**: AWS Lambda超入門（複数の短編動画）
- **URL**: https://www.youtube.com/@cloud-tech
- **言語**: 日本語
- **概要**: **Lambda初学者向けの短編動画シリーズ。** 各10〜15分程度で、Lambdaの基本概念を分かりやすく解説。**完全無料。**
- **評価**:
  - **良い点**: 
    - 各動画が10〜15分と短く、スキマ時間で学べる
    - 初心者に非常に分かりやすい日本語解説
    - 図解が多い
    - 無料
    - 「とりあえずLambdaとは何か知りたい」に最適
  - **悪い点**: 
    - 深い内容は別途学習が必要
    - 体系的な学習には他の教材も併用推奨
- **向いている人**: Lambda初学者、短時間でサクッと概要を知りたい人
- **学習時間**: 各10〜15分

### AWS公式 Lambda チュートリアル
- **タイトル**: Lambda 入門
- **URL**: https://aws.amazon.com/lambda/getting-started/
- **運営元**: AWS公式
- **概要**: Lambda公式の入門ページ。**初学者が最初に見るべきページ。** 基本概念、ユースケース、始め方を簡潔に紹介。
- **評価**:
  - **良い点**: 
    - AWS公式で信頼性が高い
    - 簡潔にまとまっている
    - 日本語版あり
    - ユースケースが明確
  - **悪い点**: 
    - 概要のみで、詳細は別途学習が必要
- **向いている人**: Lambda初学者、まず全体像を掴みたい人
- **学習時間**: 10〜15分

---

## 🛠️ 【最初に覚える】基本操作・知識

### Lambda関数の作成（コンソール）

#### AWS公式ドキュメント - Lambda関数の作成
- **タイトル**: コンソールで Lambda 関数を作成する
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html
- **運営元**: AWS公式
- **概要**: **初学者が最初に実践すべき操作。** コンソールでLambda関数を作成する手順を詳細解説。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - スクリーンショット付きで分かりやすい
    - Python、Node.jsのサンプルコードあり
  - **悪い点**: 
    - ドキュメント形式なので、動画の方が分かりやすい人もいる
- **向いている人**: Lambda初学者、公式手順で確実に学びたい人
- **学習時間**: 30分

#### Classmethod - Lambda関数の作成（初心者向け記事）
- **タイトル**: 【初心者向け】AWS Lambda関数を作成してみた
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **初心者向けに非常に丁寧に解説。** Lambda関数の作成手順をスクリーンショット付きで説明。
- **評価**:
  - **良い点**: 
    - 初心者目線で非常に分かりやすい
    - つまずきポイントを事前に説明
    - 日本語
    - 無料
  - **悪い点**: 
    - 公式ドキュメントではないため、最新情報は公式で確認推奨
- **向いている人**: Lambda初学者、日本語の分かりやすい記事で学びたい人
- **学習時間**: 30分

### Lambda のテスト方法

#### AWS公式ドキュメント - Lambda関数のテスト
- **タイトル**: Lambda 関数をテストする
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/testing-functions.html
- **運営元**: AWS公式
- **概要**: **Lambda開発で最も重要な操作の一つ。** コンソールでのテスト実行方法を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式で正確
    - テストイベントの作成方法を詳細解説
    - 各ランタイムのテスト方法を網羅
  - **悪い点**: 
    - ドキュメント形式
- **向いている人**: Lambda初学者、テスト方法を確実に理解したい人
- **学習時間**: 20分

#### Classmethod - Lambda テストイベントの作り方
- **タイトル**: Lambda テストイベントの作成方法
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **初心者がよく迷うポイントを丁寧に解説。** テストイベントJSONの書き方を具体例で学べる。
- **評価**:
  - **良い点**: 
    - 初心者の「?」に寄り添った解説
    - 具体的なJSONサンプルが豊富
    - 日本語で分かりやすい
  - **悪い点**: 
    - なし
- **向いている人**: テストイベントの作り方で迷っている初学者
- **学習時間**: 15分

### CloudWatch Logs でログを確認

#### ⭐ AWS公式ドキュメント - Lambda と CloudWatch Logs
- **タイトル**: CloudWatch Logs を使用した Lambda ログ記録
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html
- **運営元**: AWS公式
- **概要**: **Lambda開発で必須の知識。** CloudWatch Logsでログを確認する方法を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式で正確
    - ログの確認方法、ロググループ・ストリームの概念を理解できる
    - print文（Python）、console.log（Node.js）の使い方も解説
  - **悪い点**: 
    - ドキュメント形式
- **向いている人**: Lambda初学者、ログ確認方法を学びたい人
- **学習時間**: 30分

#### Classmethod - CloudWatch Logs 初心者向け
- **タイトル**: 【初心者向け】Lambda のログを CloudWatch Logs で確認する
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **初学者が最初に躓くログ確認方法を丁寧に解説。** スクリーンショット付きで分かりやすい。
- **評価**:
  - **良い点**: 
    - 初心者目線で非常に分かりやすい
    - ログの見方を一から説明
    - エラーログの読み方も解説
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、ログの確認方法で迷っている人
- **学習時間**: 20分

### エラー時の確認ポイント

#### Classmethod - Lambda よくあるエラーと対処法
- **タイトル**: Lambda よくあるエラーと対処法（まとめ）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **Lambda初学者が必ず遭遇するエラーをまとめた記事。** 実務前に必読。
- **評価**:
  - **良い点**: 
    - 初学者が遭遇するエラーを網羅
    - 各エラーの原因と対処法を具体的に説明
    - 日本語で分かりやすい
    - 無料
  - **悪い点**: 
    - 記事数が多いので、関連記事を複数読む必要あり
- **向いている人**: Lambda初学者、エラー対処法を事前に知りたい人
- **学習時間**: 30〜60分

#### AWS公式ドキュメント - Lambda トラブルシューティング
- **タイトル**: Lambda トラブルシューティング
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/troubleshooting.html
- **運営元**: AWS公式
- **概要**: Lambda公式のトラブルシューティングガイド。エラーコード一覧と対処法を網羅。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - エラーコードごとに対処法が記載
    - 日本語版あり
  - **悪い点**: 
    - 情報量が多く、初学者には難しい部分も
- **向いている人**: エラーが発生したときに参照する公式リファレンス
- **学習時間**: エラー発生時に該当箇所を参照

### IAM ロールの基本

#### ⭐ AWS公式ドキュメント - Lambda 実行ロール
- **タイトル**: Lambda 実行ロール
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html
- **運営元**: AWS公式
- **概要**: **Lambda開発で最も重要な概念の一つ。** Lambda実行ロールとは何か、どう設定するかを学べる。**初学者必読。**
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - 実行ロールの概念を基礎から理解できる
    - マネージドポリシーの使い方も解説
    - 日本語版あり
  - **悪い点**: 
    - IAMの基礎知識がある程度必要
- **向いている人**: Lambda初学者、IAMロールを理解したい人
- **学習時間**: 30〜45分

#### Classmethod - Lambda IAMロール 初心者向け解説
- **タイトル**: 【初心者向け】Lambda の IAM ロールを理解する
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **初学者が最も躓くIAMロールを分かりやすく解説。** 図解付きで概念を理解できる。
- **評価**:
  - **良い点**: 
    - 初心者目線で非常に分かりやすい
    - 図解が豊富
    - 実際の設定例も掲載
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、IAMロールで迷っている人
- **学習時間**: 30分

---

## 🎯 【実務で頻出】ユースケース別 学習資料

### API Gateway + Lambda

#### ⭐ AWS公式 チュートリアル - Lambda と API Gateway
- **タイトル**: チュートリアル: REST API と Lambda プロキシ統合を使用する
- **URL**: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html
- **運営元**: AWS公式
- **概要**: **実務で最頻出のパターン。** API Gateway + Lambda で REST API を構築するチュートリアル。**初学者必修。**
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - ステップバイステップで構築できる
    - Lambda プロキシ統合を理解できる
    - 日本語版あり
  - **悪い点**: 
    - 少し長い（1時間程度必要）
- **向いている人**: Lambda初学者、REST APIを構築したい人
- **学習時間**: 1〜2時間

#### AWS Hands-on - サーバーレス Web アプリケーション構築
- **タイトル**: サーバーレス Web アプリケーションを構築する
- **URL**: https://aws.amazon.com/jp/getting-started/hands-on/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/
- **運営元**: AWS公式
- **概要**: **実務に近い形でサーバーレスアプリを構築。** Lambda + API Gateway + DynamoDB + Cognito を使った完全なWebアプリ構築ハンズオン。
- **評価**:
  - **良い点**: 
    - AWS公式で無料
    - 実務に近い構成を学べる
    - 日本語版あり
    - Lambda、API Gateway、DynamoDB、Cognitoの連携を実践
  - **悪い点**: 
    - 時間がかかる（4〜5時間）
    - 各サービスの基礎知識がある程度必要
- **向いている人**: Lambda中級者、実務に近い構成を学びたい人
- **学習時間**: 4〜5時間

#### Classmethod - API Gateway + Lambda 初心者向け
- **タイトル**: 【初心者向け】API Gateway + Lambda で REST API を作る
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **初学者に最も分かりやすい API Gateway + Lambda 記事。** スクリーンショット豊富で迷わない。
- **評価**:
  - **良い点**: 
    - 初心者目線で非常に分かりやすい
    - つまずきポイントを事前に説明
    - CORSの設定方法も解説
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、API Gateway連携で迷っている人
- **学習時間**: 30〜60分

### S3 トリガー

#### AWS公式チュートリアル - S3 トリガーで Lambda 実行
- **タイトル**: チュートリアル: Amazon S3 で AWS Lambda を使用する
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example.html
- **運営元**: AWS公式
- **概要**: **実務で頻出のパターン。** S3にファイルがアップロードされたときにLambdaを実行する方法を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - ステップバイステップで構築できる
    - Python、Node.jsのサンプルコードあり
    - 日本語版あり
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、S3トリガーを学びたい人
- **学習時間**: 1時間

#### Classmethod - S3 トリガー Lambda 初心者向け
- **タイトル**: 【初心者向け】S3 トリガーで Lambda を実行する
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **S3トリガーの設定方法を初心者向けに丁寧に解説。** よくあるハマりポイントも説明。
- **評価**:
  - **良い点**: 
    - 初心者目線で分かりやすい
    - IAM権限の設定も詳しく説明
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、S3トリガーで迷っている人
- **学習時間**: 30分

### EventBridge / 定期実行

#### AWS公式チュートリアル - EventBridge で Lambda 定期実行
- **タイトル**: チュートリアル: EventBridge を使用してスケジュールで Lambda 関数を実行する
- **URL**: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-run-lambda-schedule.html
- **運営元**: AWS公式
- **概要**: **実務で頻出のパターン。** EventBridgeを使ってLambdaを定期実行する方法を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - cron式、rate式の書き方を学べる
    - ステップバイステップで設定できる
    - 日本語版あり
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、定期実行を学びたい人
- **学習時間**: 30分

#### Classmethod - Lambda 定期実行 初心者向け
- **タイトル**: 【初心者向け】Lambda を定期実行する（EventBridge）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **Lambda定期実行の設定方法を初心者向けに解説。** cron式の書き方も分かりやすく説明。
- **評価**:
  - **良い点**: 
    - 初心者目線で分かりやすい
    - cron式のサンプルが豊富
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、定期実行で迷っている人
- **学習時間**: 20分

### DynamoDB 連携

#### AWS公式チュートリアル - Lambda と DynamoDB
- **タイトル**: チュートリアル: Lambda と DynamoDB ストリームを使用する
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/with-ddb-example.html
- **運営元**: AWS公式
- **概要**: **実務で頻出のパターン。** Lambda から DynamoDB にデータを書き込む・読み込む方法を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - boto3（Python）、AWS SDK（Node.js）の使い方を学べる
    - ステップバイステップで構築できる
    - 日本語版あり
  - **悪い点**: 
    - DynamoDBの基礎知識がある程度必要
- **向いている人**: Lambda初学者、DynamoDB連携を学びたい人
- **学習時間**: 1〜2時間

#### Classmethod - Lambda + DynamoDB 初心者向け
- **タイトル**: 【初心者向け】Lambda から DynamoDB にアクセスする
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **Lambda + DynamoDB連携を初心者向けに丁寧に解説。** IAM権限の設定も詳しく説明。
- **評価**:
  - **良い点**: 
    - 初心者目線で分かりやすい
    - サンプルコードが豊富
    - IAM権限の設定を詳しく説明
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、DynamoDB連携で迷っている人
- **学習時間**: 30〜60分

### SQS 連携

#### AWS公式チュートリアル - Lambda と SQS
- **タイトル**: チュートリアル: Lambda と Amazon SQS を使用する
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/with-sqs-example.html
- **運営元**: AWS公式
- **概要**: **実務で頻出のパターン。** SQSキューをトリガーにLambdaを実行する方法を学べる。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - バッチ処理の実装方法を学べる
    - ステップバイステップで構築できる
    - 日本語版あり
  - **悪い点**: 
    - SQSの基礎知識がある程度必要
- **向いている人**: Lambda初学者、SQS連携を学びたい人
- **学習時間**: 1時間

---

## ⚠️ 【初心者が必ずハマる】ポイントと対処法

### IAM 権限不足

#### ⭐ Classmethod - Lambda IAM権限エラー 完全ガイド
- **タイトル**: Lambda IAM権限不足エラーの原因と対処法（まとめ）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **Lambda初学者が最も躓くIAM権限エラーを徹底解説。** 実務前に必読。
- **評価**:
  - **良い点**: 
    - 初学者が遭遇する全パターンを網羅
    - 各エラーの原因と対処法を具体的に説明
    - 「最小権限の原則」も解説
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、IAM権限エラーで迷っている人
- **学習時間**: 30〜60分

#### AWS公式ドキュメント - Lambda アクセス許可
- **タイトル**: Lambda のアクセス許可
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/lambda-permissions.html
- **運営元**: AWS公式
- **概要**: Lambda IAM権限の公式リファレンス。実行ロール、リソースベースポリシーを詳細解説。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - 実行ロールとリソースベースポリシーの違いを理解できる
    - 日本語版あり
  - **悪い点**: 
    - 情報量が多く、初学者には難しい部分も
- **向いている人**: Lambda中級者、IAM権限を深く理解したい人
- **学習時間**: 1時間

### タイムアウト

#### Classmethod - Lambda タイムアウト対策
- **タイトル**: Lambda タイムアウトの原因と対処法
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **Lambda初学者がよく遭遇するタイムアウトエラーを解説。** 対処法を具体的に説明。
- **評価**:
  - **良い点**: 
    - タイムアウトの原因を分かりやすく説明
    - タイムアウト値の設定方法を解説
    - 非同期処理の活用方法も紹介
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、タイムアウトで困っている人
- **学習時間**: 20分

#### AWS公式ドキュメント - Lambda 制限
- **タイトル**: Lambda のクォータ
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
- **運営元**: AWS公式
- **概要**: Lambda の制限値（タイムアウト、メモリ等）の公式リファレンス。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - 全制限値を一覧で確認できる
    - 日本語版あり
  - **悪い点**: 
    - リファレンスなので、対処法は別途学習が必要
- **向いている人**: 制限値を確認したい人
- **学習時間**: 10分

### メモリ不足

#### Classmethod - Lambda メモリ設定のベストプラクティス
- **タイトル**: Lambda メモリ設定の考え方とコスト最適化
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **Lambdaメモリ設定の基本を解説。** 適切なメモリ値の決め方を学べる。
- **評価**:
  - **良い点**: 
    - メモリとCPUの関係を分かりやすく説明
    - コスト最適化の観点も解説
    - Lambda Power Tuningの紹介
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、メモリ設定で迷っている人
- **学習時間**: 30分

### VPC Lambda の罠

#### ⭐ Classmethod - VPC Lambda 初心者が知るべきこと
- **タイトル**: VPC Lambda で初心者がハマるポイント（まとめ）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **VPC Lambda の注意点を徹底解説。** 初学者が必ずハマるポイントを事前に知れる。**実務前に必読。**
- **評価**:
  - **良い点**: 
    - VPC Lambdaの罠を網羅
    - NAT Gatewayの必要性を分かりやすく説明
    - セキュリティグループの設定も詳しく解説
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: VPC Lambda を使う予定の初学者
- **学習時間**: 30〜60分

#### AWS公式ドキュメント - VPC での Lambda の設定
- **タイトル**: Lambda 関数を VPC に接続する
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html
- **運営元**: AWS公式
- **概要**: VPC Lambda の公式ドキュメント。Hyperplane ENIの仕組みも解説。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - Hyperplane ENIの仕組みを理解できる
    - 日本語版あり
  - **悪い点**: 
    - 技術的に少し難しい
- **向いている人**: VPC Lambda を深く理解したい中級者
- **学習時間**: 1時間

### コールドスタート

#### ⭐ Classmethod - Lambda コールドスタート 完全ガイド
- **タイトル**: Lambda コールドスタートとは？原因と対策（まとめ）
- **URL**: https://dev.classmethod.jp/
- **運営元**: クラスメソッド
- **概要**: **Lambda初学者が必ず知るべきコールドスタートを徹底解説。** 対策方法も具体的に紹介。
- **評価**:
  - **良い点**: 
    - コールドスタートの仕組みを分かりやすく説明
    - 対策方法（Provisioned Concurrency、SnapStart等）を詳しく解説
    - ランタイム選択の重要性も説明
    - 日本語
  - **悪い点**: 
    - なし
- **向いている人**: Lambda初学者、コールドスタートを理解したい人
- **学習時間**: 30〜60分

#### AWS公式ドキュメント - Lambda SnapStart
- **タイトル**: Lambda SnapStart
- **URL**: https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html
- **運営元**: AWS公式
- **概要**: Java Lambda のコールドスタート対策機能 SnapStart の公式ドキュメント。
- **評価**:
  - **良い点**: 
    - AWS公式で最も正確
    - SnapStart の仕組みを理解できる
    - 日本語版あり
  - **悪い点**: 
    - Java限定
- **向いている人**: Java Lambda を使う人
- **学習時間**: 30分

---

## 📝 【日本語・無料・短時間】おすすめ学習資料まとめ

### 最初の1時間で学ぶ

1. **くろかわこうへい - Lambda 超入門**（10分）
   - URL: https://www.youtube.com/@cloud-tech
   - Lambda とは何かをサクッと理解

2. **AWS公式 - Lambda とは**（30分）
   - URL: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
   - 正確な概念を理解

3. **AWS公式 - Lambda 入門**（15分）
   - URL: https://aws.amazon.com/lambda/getting-started/
   - ユースケースを把握

### 最初の2〜3時間で手を動かす

1. **AWS Hands-on for Beginners - サーバーレス編**（2〜3時間）
   - URL: https://aws.amazon.com/jp/aws-jp-introduction/aws-jp-webinar-hands-on/
   - 実際に Lambda を触ってみる

### 頻出パターンを学ぶ（各1時間）

1. **API Gateway + Lambda チュートリアル**
   - URL: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html

2. **S3 トリガー Lambda チュートリアル**
   - URL: https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example.html

3. **EventBridge 定期実行チュートリアル**
   - URL: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-run-lambda-schedule.html

4. **DynamoDB 連携チュートリアル**
   - URL: https://docs.aws.amazon.com/lambda/latest/dg/with-ddb-example.html

### ハマりポイントを事前に知る（各30分）

1. **Classmethod - Lambda よくあるエラー**
   - URL: https://dev.classmethod.jp/

2. **Classmethod - IAM 権限エラー対策**
   - URL: https://dev.classmethod.jp/

3. **Classmethod - VPC Lambda の罠**
   - URL: https://dev.classmethod.jp/

4. **Classmethod - コールドスタート対策**
   - URL: https://dev.classmethod.jp/

---

## 💡 実務直前チェックリスト

### Lambda 関数作成
- [ ] コンソールで Lambda 関数を作成できる
- [ ] Python / Node.js のサンプルコードを理解している
- [ ] ランタイムの選び方を理解している

### テスト
- [ ] コンソールでテストイベントを作成できる
- [ ] テストを実行できる
- [ ] テスト結果を読める

### ログ確認
- [ ] CloudWatch Logs でログを確認できる
- [ ] print / console.log でログ出力できる
- [ ] エラーログを読める

### IAM
- [ ] Lambda 実行ロールとは何か理解している
- [ ] マネージドポリシーを使える
- [ ] IAM 権限不足エラーに対処できる

### トリガー設定
- [ ] API Gateway をトリガーに設定できる
- [ ] S3 をトリガーに設定できる
- [ ] EventBridge で定期実行できる

### エラー対処
- [ ] タイムアウトエラーに対処できる
- [ ] メモリ不足エラーに対処できる
- [ ] IAM 権限エラーに対処できる

### その他
- [ ] Lambda の制限値（タイムアウト、メモリ等）を知っている
- [ ] コールドスタートとは何か理解している
- [ ] VPC Lambda の注意点を知っている（使う場合）

---

## 🎓 推奨学習スケジュール（1週間集中）

### Day 1：概念理解（2時間）
- くろかわこうへい動画（10分）
- AWS公式ドキュメント（1時間）
- AWS公式入門ページ（30分）

### Day 2：ハンズオン（3時間）
- AWS Hands-on for Beginners - サーバーレス編（3時間）

### Day 3：基本操作（2時間）
- Lambda 関数作成（30分）
- テスト方法（30分）
- CloudWatch Logs（30分）
- IAM ロール（30分）

### Day 4：API Gateway + Lambda（2時間）
- 公式チュートリアル（1時間）
- Classmethod 記事（30分）
- 自分で実装（30分）

### Day 5：S3 + EventBridge（2時間）
- S3 トリガー（1時間）
- EventBridge 定期実行（1時間）

### Day 6：DynamoDB + SQS（2時間）
- DynamoDB 連携（1時間）
- SQS 連携（1時間）

### Day 7：ハマりポイント学習（2時間）
- IAM 権限エラー（30分）
- タイムアウト・メモリ（30分）
- VPC Lambda（30分）
- コールドスタート（30分）

**合計：15時間**

---

## 📌 最後に：実務で困ったときの参照先

### エラーが出たとき
1. CloudWatch Logs でエラーメッセージを確認
2. AWS公式トラブルシューティング を参照
3. Classmethod でエラーメッセージを検索
4. Stack Overflow で英語検索

### 設定方法が分からないとき
1. AWS公式ドキュメント を参照
2. Classmethod で検索
3. AWS公式チュートリアル を確認

### ベストプラクティスを知りたいとき
1. AWS Well-Architected Framework - サーバーレスレンズ
2. AWS Black Belt Online Seminar
3. Classmethod のベストプラクティス記事

---

以上、Lambda 初心者・実務直前向けの追加資料でした。
この資料と `references.md` を併せて活用することで、
**来月から Lambda を使う案件でも安心してスタートできます。**

頑張ってください！💪
