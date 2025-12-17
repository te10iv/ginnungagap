# AWS Lambda：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **CloudWatch Logs**：関数実行ログ確認
- **バージョニング**：コードのバージョン管理
- **エイリアス**：dev/staging/prod環境切り替え
- **レイヤー**：共通ライブラリの再利用
- **同時実行数制御**：Reserved Concurrency / Provisioned Concurrency

## よくあるトラブル
### トラブル1：Lambda関数がタイムアウトする
- 症状：「Task timed out after 3.00 seconds」エラー
- 原因：
  - タイムアウト設定が短すぎる（デフォルト3秒）
  - 処理が遅い（外部API呼び出し、DB処理）
  - コールドスタート（初回起動）
  - VPC Lambda時のENI作成遅延
- 確認ポイント：
  - タイムアウト設定確認（最大15分）
  - CloudWatch Logsで処理時間確認
  - 外部API呼び出しのタイムアウト設定
  - VPC Lambdaの場合、VPCエンドポイント活用

### トラブル2：同時実行数制限エラー
- 症状：「Rate Exceeded」「TooManyRequestsException」
- 原因：
  - リージョン全体の同時実行数上限（デフォルト1,000）
  - 関数の Reserved Concurrency設定
  - 急激なトラフィック増加
- 確認ポイント：
  - CloudWatch Metricsで同時実行数確認
  - AWS Supportで上限緩和申請
  - SQSでスロットリング制御

### トラブル3：VPC Lambda からインターネットアクセスできない
- 症状：外部API呼び出しがタイムアウト
- 原因：
  - VPC Lambdaは NAT Gateway or VPCエンドポイント必須
  - Private Subnetに配置されているがNAT Gatewayがない
- 確認ポイント：
  - NAT Gateway設定確認
  - VPCエンドポイント活用（S3/DynamoDB等）
  - Lambda を VPC外に配置検討

## 監視・ログ
- **CloudWatch Metrics**：
  - `Invocations`：実行回数
  - `Duration`：実行時間
  - `Errors`：エラー回数
  - `Throttles`：スロットリング回数
  - `ConcurrentExecutions`：同時実行数
- **CloudWatch Logs**：
  - `/aws/lambda/[function-name]`
  - print/console.log でログ出力
- **X-Ray**：分散トレーシング、ボトルネック特定
- **CloudWatch Alarm**：エラー率・実行時間閾値監視

## コストでハマりやすい点
- **無料枠**：月100万リクエスト + 40万GB秒
- **課金要素**：
  - リクエスト数：$0.20/100万リクエスト
  - 実行時間×メモリ：$0.0000166667/GB秒
- **VPC Lambda**：NAT Gateway課金（月$32〜）
- **Provisioned Concurrency**：常時起動で高額（$0.015/GB時）
- **コスト削減策**：
  - メモリサイズ最適化（実行時間とトレードオフ）
  - タイムアウト短縮
  - VPCエンドポイント活用
  - 不要な実行削減（イベントフィルター）

## 実務Tips
- **メモリサイズ調整**：メモリ増やすとCPUも増える（実行時間短縮）
- **タイムアウト設定**：適切な値（3秒〜15分）、デフォルト3秒は短すぎ
- **環境変数**：設定値はハードコードせず環境変数使用
- **IAM Role最小権限**：必要最小限の権限のみ
- **レイヤー活用**：共通ライブラリは共有レイヤーに
- **バージョン管理**：本番デプロイ時はバージョン固定
- **エイリアス活用**：
  - $LATEST：開発用
  - prod：本番用（バージョン固定）
- **コールドスタート対策**：
  - Provisioned Concurrency（高額）
  - 定期実行でウォームアップ
  - SnapStart（Java 11+）
- **VPC Lambda注意**：
  - インターネットアクセス必要ならNAT Gateway
  - AWSサービスアクセスならVPCエンドポイント
  - 不要ならVPC配置しない
- **デッドレターキュー（DLQ）**：エラー時のメッセージ保存（SQS/SNS）
- **非同期処理**：SQS経由で確実な処理
- **設計時に言語化すると評価が上がるポイント**：
  - 「サーバーレス構成でサーバー管理不要、運用コスト削減」
  - 「Auto Scalingで自動スケール、急激なトラフィック増加に対応」
  - 「従量課金で使った分だけ課金、アイドル時間のコスト削減」
  - 「VPCエンドポイント活用でNAT Gateway不要、コスト削減」
  - 「Reserved Concurrency設定で他関数への影響を防止」
  - 「X-Ray統合でボトルネック特定、パフォーマンス改善」
  - 「レイヤーで共通ライブラリ管理、デプロイパッケージサイズ削減」

## Lambda vs EC2

| 項目 | Lambda | EC2 |
|------|--------|-----|
| サーバー管理 | 不要 | 必要 |
| スケーリング | 自動 | Auto Scaling設定必要 |
| 課金 | 実行時間×メモリ | 起動時間 |
| 起動時間 | 即座（コールドスタート除く） | 数分 |
| 実行時間制限 | 最大15分 | 制限なし |
| 用途 | イベント駆動、短時間処理 | 長時間処理、常時起動 |
| コスト | 従量課金（低トラフィック有利） | 固定課金（高トラフィック有利） |

## メモリサイズと実行時間のトレードオフ

- メモリ増やすとCPUも増える → 実行時間短縮 → コスト削減の可能性
- 例：512MBで10秒 vs 1024MBで5秒 → 後者が安い場合も
- Power Tuningツール活用推奨
