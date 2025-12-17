# Amazon CloudWatch Logs：まずこれだけ（Lv1）

## このサービスの一言説明
- Amazon CloudWatch Logs は「**ログ収集・保存・分析**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- ログをCloudWatch Logsに **送信できる**
- **ログを検索・フィルタできる**
- 「ログ管理にはCloudWatch Logsが必要」と判断できる

## まず覚えること（最小セット）
- **ロググループ**：ログの保存場所
- **ログストリーム**：個別のログソース（EC2インスタンス等）
- **保存期間**：1日〜無期限
- **Logs Insights**：SQLライクなクエリ言語
- **メトリクスフィルター**：ログからメトリクス生成

## できるようになること
- □ ロググループを作成できる
- □ EC2からログを送信できる（CloudWatch Agent）
- □ Logs Insightsでログを検索できる
- □ メトリクスフィルターを作成できる

## まずやること（Hands-on）
- ロググループ作成
- EC2にCloudWatch Agentインストール
- アプリケーションログ送信
- Logs Insightsでエラーログ検索

## 関連するAWSサービス（名前だけ）
- **CloudWatch**：メトリクス・アラーム
- **Lambda**：ログ処理、トリガー
- **S3**：ログエクスポート
- **Kinesis Data Firehose**：リアルタイム転送
- **EventBridge**：ログイベント駆動
