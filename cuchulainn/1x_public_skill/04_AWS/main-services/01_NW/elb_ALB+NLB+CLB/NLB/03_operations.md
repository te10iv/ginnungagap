# Network Load Balancer (NLB)：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **ターゲット登録/削除**：Auto Scalingで自動化
- **ヘルスチェック**：TCP/HTTP/HTTPSプロトコル選択可能
- **Cross-Zone Load Balancing**：AZ間の均等分散（有効化推奨）
- **Connection Tracking**：フローハッシュによるターゲット選択

## よくあるトラブル
### トラブル1：ターゲットがUnhealthyになる
- 症状：NLBのターゲットステータスが「unhealthy」
- 原因：
  - ターゲットのSecurity Groupでヘルスチェックがブロック
  - アプリケーションが起動していない
  - ヘルスチェックポートが間違っている
- 確認ポイント：
  - ターゲットのSecurity GroupでNLBサブネットのCIDRから許可
  - ヘルスチェックプロトコル確認（TCP/HTTP/HTTPS）
  - EC2で該当ポートがListenしているか確認（netstat -tuln）

### トラブル2：NLBにアクセスできない（タイムアウト）
- 症状：NLBのDNS名またはElastic IPにアクセスできない
- 原因：
  - ターゲットが全てUnhealthy
  - ターゲットのSecurity Groupでクライアント元IPがブロック
  - サブネットのルートテーブルにIGWがない（Internet-facing）
- 確認ポイント：
  - ターゲットグループのヘルスステータス確認
  - ターゲットのSecurity GroupでソースIP許可（0.0.0.0/0 or 特定IP）
  - PublicサブネットのルートテーブルにIGWへのルート確認

### トラブル3：クライアントIPでアクセス制限できない
- 症状：Security GroupでクライアントIPを制限したいがNLBのIPになる
- 原因：NLBはL4なのでクライアントIPを変換しない（そのまま通す）
- 確認ポイント：
  - ターゲットのSecurity Groupでソース指定（クライアントIPレンジ）
  - NLB経由の場合、クライアントIPはそのまま見える（ALBと違う）

## 監視・ログ
- **CloudWatch Metrics**：
  - `ActiveFlowCount`：アクティブフロー数
  - `NewFlowCount`：新規フロー数
  - `ProcessedBytes`：処理バイト数
  - `HealthyHostCount / UnHealthyHostCount`：正常/異常ターゲット数
  - `TCP_Target_Reset_Count`：TCP RST受信数
- **アクセスログ**：S3バケットに保存（2023年以降対応）
- **VPC Flow Logs**：NLB ENIの通信ログ

## コストでハマりやすい点
- **NLB時間課金**：$0.0225/時間（月$16、ALBよりやや安い）
- **NLCU（Network Load Balancer Capacity Unit）課金**：
  - 新規フロー数、アクティブフロー数、処理バイト数
  - 1 NLCU = $0.006/時間（ALBのLCUより安い）
- **Elastic IP**：割り当てたまま未使用だと課金（$0.005/時間）
- **データ転送料**：NLB→インターネットのアウトバウンド（$0.114/GB〜）
- **削除忘れ**：使っていないNLBは削除（月$16の無駄）

## 実務Tips
- **ALBとNLBの使い分け**：
  - **ALB**：HTTP/HTTPS、パスルーティング、WAF統合、WebSocket
  - **NLB**：TCP/UDP、超低レイテンシー、固定IP、クライアントIP保持
- **固定IPが必要な場合**：各AZにElastic IP割り当て
- **Cross-Zone Load Balancing有効化**：デフォルトオフ（有効化推奨）
- **ヘルスチェック設計**：
  - TCP：ポート接続確認（速い）
  - HTTP/HTTPS：パス指定可能（推奨）
- **Security Group設計**：
  - NLB自体にSG設定不可
  - ターゲット側でソースIPまたはNLBサブネットCIDRで制御
- **PrivateLink活用**：Internal NLBでVPC Endpoint Service作成
- **TLS Termination**：NLBでTLS終端可能（ACM証明書使用）
- **Connection Tracking**：同じクライアントは同じターゲットに振り分け（Sticky Session不要）
- **設計時に言語化すると評価が上がるポイント**：
  - 「超低レイテンシー要件のためNLBを採用（マイクロ秒単位）」
  - 「固定IP要件のため、各AZにElastic IPを割り当て」
  - 「クライアントIPを保持したいためNLBを採用（X-Forwarded-For不要）」
  - 「TCP/UDP通信のためNLBを使用（ゲームサーバー、IoTゲートウェイ）」
  - 「PrivateLinkでInternal NLBを使用し、マルチアカウント接続を実現」
  - 「NLB → ALB 2段構成で固定IP + HTTP機能を両立」

## ALBとNLBの比較表

| 項目 | ALB | NLB |
|------|-----|-----|
| OSI層 | L7（HTTP/HTTPS） | L4（TCP/UDP） |
| レイテンシー | ミリ秒 | マイクロ秒 |
| 固定IP | ✗ | ✓（Elastic IP） |
| パスルーティング | ✓ | ✗ |
| WAF統合 | ✓ | ✗（NLB→ALB構成で可能） |
| クライアントIP | X-Forwarded-For | そのまま保持 |
| Security Group | 設定可能 | 設定不可 |
| 用途 | Web/API | TCP/UDP、低レイテンシー |
| 料金 | $0.0243/h + LCU | $0.0225/h + NLCU |
