# Application Load Balancer (ALB)：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **ターゲット登録/削除**：Auto Scalingで自動、手動も可能
- **ヘルスチェック調整**：閾値・間隔・タイムアウト
- **アクセスログ**：S3保存、詳細なリクエストログ
- **Connection Draining（登録解除の遅延）**：既存接続を維持したまま削除

## よくあるトラブル
### トラブル1：ターゲットがUnhealthyになる
- 症状：ALBのターゲットステータスが「unhealthy」
- 原因：
  - ヘルスチェックパスが存在しない（404エラー）
  - EC2のSecurity Groupでヘルスチェックがブロック
  - アプリケーションが起動していない
  - ヘルスチェックのタイムアウトが短すぎる
- 確認ポイント：
  - ヘルスチェックパス確認（/health, / 等）
  - EC2のSecurity GroupでALBからの通信許可
  - EC2でcurl http://localhost/health で手動確認
  - ヘルスチェック設定確認（interval, timeout, threshold）

### トラブル2：ALBにアクセスできない（タイムアウト）
- 症状：ブラウザでALBのDNS名にアクセスできない
- 原因：
  - ALBのSecurity Groupで80/443がブロック
  - ターゲットが全てUnhealthy
  - サブネットのルートテーブルにIGWがない
- 確認ポイント：
  - ALBのSecurity Groupで0.0.0.0/0から80/443許可
  - ターゲットグループのヘルスステータス確認
  - PublicサブネットのルートテーブルにIGWへのルート確認

### トラブル3：HTTPS接続できない
- 症状：HTTPSでERR_SSL_VERSION_OR_CIPHER_MISMATCH
- 原因：
  - ACM証明書がALBに設定されていない
  - 証明書のドメイン名とアクセスURL不一致
  - リスナーに443ポートがない
- 確認ポイント：
  - リスナーで443ポート確認
  - ACM証明書がアタッチされているか確認
  - 証明書のドメイン名確認（ワイルドカード含む）

## 監視・ログ
- **CloudWatch Metrics**：
  - `RequestCount`：リクエスト総数
  - `TargetResponseTime`：ターゲットのレスポンス時間
  - `HealthyHostCount / UnHealthyHostCount`：正常/異常ターゲット数
  - `HTTPCode_Target_4XX_Count / 5XX_Count`：エラー数
  - `ActiveConnectionCount`：アクティブ接続数
- **アクセスログ**：S3バケットに保存
  - リクエストURL、レスポンスコード、レスポンス時間
  - クライアントIP、User-Agent
  - Athenaでクエリ分析可能
- **CloudWatch Alarm**：UnHealthyHostCount、5XXエラー率

## コストでハマりやすい点
- **ALB時間課金**：$0.0243/時間（月$18）
- **LCU（Load Balancer Capacity Unit）課金**：
  - 新規接続数、アクティブ接続数、処理バイト数、ルール評価数
  - 1 LCU = $0.008/時間
  - 複雑なルールが多いとLCU増加
- **アクセスログ保存**：S3ストレージ料金
- **データ転送料**：ALB→インターネットのアウトバウンド（$0.114/GB〜）
- **削除忘れ**：使っていないALBは削除（月$18の無駄）
- **コスト削減策**：
  - 開発環境は使用時間外に削除
  - 不要なリスナールール削減
  - CloudFrontでキャッシュしてALBへのリクエスト削減

## 実務Tips
- **必ずMulti-AZ配置**：最低2つのAZ、本番は3つ推奨
- **Security Group設計**：
  - ALB SG: 0.0.0.0/0 → 80/443許可
  - EC2 SG: ALB SG → 80/8080許可（ソースにALB SGを指定）
- **ヘルスチェック設計**：
  - パス：`/health` または `/`
  - Interval：30秒（デフォルト）
  - Healthy threshold：2回連続成功
  - Unhealthy threshold：2回連続失敗
- **HTTP→HTTPS リダイレクト**：リスナールールで301/302リダイレクト
- **Sticky Session（スティッキーセッション）**：セッション維持が必要な場合
- **Connection Draining**：デフォルト300秒、デプロイ時に調整
- **アクセスログ有効化推奨**：トラブルシューティング・アクセス分析
- **WAF統合**：本番環境は必ずWAFを関連付け
- **X-Forwarded-For ヘッダー**：ALB経由でクライアントIPを取得
- **設計時に言語化すると評価が上がるポイント**：
  - 「Multi-AZ構成でALBを3つのAZに配置、単一AZ障害でも稼働継続」
  - 「パスベースルーティングで/api → APIサーバー、/ → Webサーバーに振り分け」
  - 「Auto Scalingと連携し、負荷増加時に自動でターゲット追加」
  - 「ヘルスチェックで異常インスタンスを自動除外、可用性を確保」
  - 「アクセスログをS3保存し、Athenaでアクセス分析・異常検知を実施」
  - 「WAF統合でDDoS対策、SQLインジェクション・XSS攻撃を防止」
  - 「CloudFrontをALBの前段に配置し、グローバル高速化とDDoS対策を強化」
