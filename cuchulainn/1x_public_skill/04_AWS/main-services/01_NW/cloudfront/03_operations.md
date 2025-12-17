# Amazon CloudFront：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **Invalidation（無効化）**：キャッシュをクリアして最新コンテンツを配信
- **Cache Policy / Origin Request Policy**：キャッシュ動作の詳細設定
- **CloudWatch メトリクス**：リクエスト数、エラー率、キャッシュヒット率

## よくあるトラブル
### トラブル1：更新したコンテンツが反映されない
- 症状：S3やALBでコンテンツ更新したのに古いコンテンツが表示される
- 原因：CloudFrontのキャッシュが残っている（TTL期間中）
- 確認ポイント：
  - CloudFrontのTTL設定確認
  - Invalidation（キャッシュ無効化）を実行
  - `/*` で全キャッシュクリア、または個別パス指定
- 対策：
  - Invalidationを実行（月1,000パスまで無料）
  - バージョニング（`app.js?v=2.0`）でキャッシュバイパス

### トラブル2：カスタムドメインでHTTPS接続できない
- 症状：`https://www.example.com`でERR_SSL_VERSION_OR_CIPHER_MISMATCH
- 原因：
  - ACM証明書がus-east-1で作成されていない
  - Distributionに証明書が設定されていない
  - Route 53のエイリアスレコードが間違っている
- 確認ポイント：
  - ACM証明書がus-east-1リージョンにあるか確認
  - Distributionの「代替ドメイン名」にドメイン設定
  - Distributionの「カスタムSSL証明書」でACM証明書選択
  - Route 53でエイリアスレコード設定

### トラブル3：オリジンにアクセスできない（504 Gateway Timeout）
- 症状：CloudFrontでアクセスするとタイムアウトエラー
- 原因：
  - オリジン（ALB/S3）が停止・削除されている
  - Security Groupでcloudfront.amazonaws.comからのアクセスがブロック
  - オリジンのレスポンスが遅い（30秒以上）
- 確認ポイント：
  - オリジンの状態確認（ALBがactive、S3バケット存在）
  - Security Groupで CloudFrontからのHTTP/HTTPS許可
  - オリジンのレスポンス時間確認（CloudWatch Logs）

## 監視・ログ
- **CloudWatch Metrics**：
  - `Requests`：リクエスト総数
  - `BytesDownloaded`：ダウンロードバイト数
  - `4xxErrorRate / 5xxErrorRate`：エラー率
  - `CacheHitRate`：キャッシュヒット率（高いほど良い）
- **アクセスログ**：S3バケットに保存（どのファイルがアクセスされたか）
- **リアルタイムログ**：Kinesis Data Streamsでリアルタイム分析
- **CloudWatch Alarm**：エラー率・リクエスト数の閾値監視

## コストでハマりやすい点
- **データ転送料**：リージョン・転送先で変動
  - 北米・欧州：$0.085/GB（最初の10TB）
  - 日本・香港：$0.114/GB
  - インド・南米：$0.170/GB
- **HTTPSリクエスト**：$0.01/10,000リクエスト
- **Invalidation**：月1,000パスまで無料、超過分は$0.005/パス
- **専有IP（Dedicated IP）**：$600/月（通常はSNI使用で無料）
- **コスト削減策**：
  - リージョンクラス：「北米+欧州+アジア」で安く（全世界より20%削減）
  - キャッシュヒット率向上：TTL長め、Query String制御
  - S3 Transfer Acceleration不使用（CloudFrontで十分）

## 実務Tips
- **OAI必須**：S3オリジンは必ずOAI使用（直接アクセス防止）
- **ACM証明書はus-east-1**：CloudFront用証明書は必ずバージニアリージョン
- **Invalidationは計画的に**：デプロイ時に自動実行、月1,000パス制限に注意
- **バージョニング推奨**：`app.js?v=1.0.0`でキャッシュ問題回避
- **Cache Policy活用**：ManagedCachingOptimized等のマネージドポリシー使用
- **カスタムヘッダー**：ALBオリジンで`X-Custom-Header`を検証（CloudFront経由のみ許可）
- **地理的制限**：特定国からのアクセスをブロック（コンプライアンス対応）
- **WAF統合**：DDoS対策、SQLインジェクション防止
- **キャッシュヒット率向上**：
  - Query Stringは必要最小限
  - Cookieは必要なものだけフォワード
  - Headersは最小限
- **Lambda@Edge**：
  - エッジでの認証処理
  - A/Bテスト
  - ヘッダー追加・変更
- **設計時に言語化すると評価が上がるポイント**：
  - 「OAI使用でS3への直接アクセスを防止、セキュリティを強化」
  - 「キャッシュTTLを最適化し、キャッシュヒット率を向上（オリジン負荷削減）」
  - 「ACM証明書はus-east-1で作成し、カスタムドメインでHTTPS化」
  - 「WAF統合でDDoS対策、SQLインジェクション・XSS攻撃を防止」
  - 「リージョンクラスで北米+欧州+アジアに限定し、コスト20%削減」
  - 「アクセスログをS3保存し、アクセス傾向・異常検知を実施」
