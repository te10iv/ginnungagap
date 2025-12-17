# AWS Step Functions：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS Step Functions は「**サーバーレスワークフローオーケストレーション**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- ステートマシンを **作成できる**
- **Lambda関数を順次実行できる**
- 「ワークフローにはStep Functionsが必要」と判断できる

## まず覚えること（最小セット）
- **ステートマシン**：ワークフロー定義（JSON）
- **ステート**：Task、Choice、Parallel、Wait等
- **Task**：Lambda関数実行、AWS サービス呼び出し
- **Standard vs Express**：長時間 vs 高スループット
- **ASL**：Amazon States Language（JSON記法）

## できるようになること
- □ ステートマシンを作成できる
- □ Lambda関数を順次実行できる
- □ 条件分岐（Choice）を設定できる
- □ エラーハンドリング（Retry、Catch）ができる

## まずやること（Hands-on）
- Lambda関数2つ作成
- ステートマシン作成（順次実行）
- テスト実行
- 実行履歴確認

## 関連するAWSサービス（名前だけ）
- **Lambda**：タスク実行
- **DynamoDB**：状態保存
- **SNS / SQS**：非同期統合
- **EventBridge**：ワークフロートリガー
- **CloudWatch**：ログ・メトリクス
