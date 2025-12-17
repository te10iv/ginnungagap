# Amazon ECS：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **タスク定義のリビジョン管理**：バージョン管理
- **サービス更新**：ローリングアップデート
- **ECS Exec**：実行中コンテナへのシェルアクセス
- **CloudWatch Container Insights**：詳細メトリクス

## よくあるトラブル
### トラブル1：タスク起動失敗（CannotPullContainerError）
- 症状：タスクが起動せず「CannotPullContainerError」
- 原因：
  - タスク実行ロールにECR権限がない
  - VPCエンドポイントがない（Private）
  - NAT Gatewayがない（Private）
  - イメージタグが存在しない
- 確認ポイント：
  - タスク実行ロールに `AmazonECSTaskExecutionRolePolicy` アタッチ
  - VPCエンドポイント（ecr.api, ecr.dkr, s3）確認
  - ECRイメージ存在確認

### トラブル2：タスクが起動しない（リソース不足）
- 症状：「Insufficient memory」「Insufficient CPU」エラー
- 原因：
  - Fargate：タスク定義のCPU/メモリが大きすぎる
  - EC2：クラスター内のリソース不足
- 確認ポイント：
  - タスク定義のCPU/メモリ確認（Fargate上限：4vCPU, 30GB）
  - EC2クラスターのリソース確認

### トラブル3：サービスのタスクが希望数に達しない
- 症状：希望タスク数3だが2台しか起動しない
- 原因：
  - ヘルスチェック失敗
  - Security Groupでヘルスチェックがブロック
  - サブネットのIP不足
  - サービスクォータ上限
- 確認ポイント：
  - タスクのヘルスステータス確認
  - Security GroupでALBからの通信許可
  - サブネットの利用可能IP確認

## 監視・ログ
- **CloudWatch Metrics**：
  - `CPUUtilization`：CPU使用率
  - `MemoryUtilization`：メモリ使用率
  - `RunningTaskCount`：実行中タスク数
  - `DesiredTaskCount`：希望タスク数
- **CloudWatch Logs**：コンテナの標準出力/エラー出力
- **CloudWatch Container Insights**：
  - タスクレベル・コンテナレベルの詳細メトリクス
  - パフォーマンス分析
- **CloudWatch Alarm**：タスク数・CPU/メモリ閾値監視

## コストでハマりやすい点
- **Fargate課金**：vCPU時間 + GB時間
  - 1vCPU = $0.04048/時間（東京）
  - 1GB = $0.004445/時間
  - 例：0.25vCPU + 0.5GB = 月$9
- **過剰スペック**：CPU/メモリは必要最小限
- **削除忘れ**：開発環境のサービスが稼働継続
- **ALB課金**：LCU課金（リクエスト数・接続数）
- **VPCエンドポイント**：NAT Gateway代替でコスト削減
- **コスト削減策**：
  - Spot Fargate（最大70%削減、中断許容）
  - 適切なCPU/メモリサイジング
  - 開発環境は使用時のみ起動

## 実務Tips
- **Fargate推奨**：サーバー管理不要、スケーラブル
- **Privateサブネット配置**：セキュリティ強化
- **タスクロールとタスク実行ロールの違い**：
  - **タスク実行ロール**：ECS自体の権限（ECR pull、CloudWatch Logs等）
  - **タスクロール**：コンテナアプリの権限（S3、DynamoDB等）
- **環境変数管理**：
  - 平文：環境変数
  - 機密情報：Secrets Manager / Parameter Store
- **ヘルスチェック設計**：
  - ALBヘルスチェック：/health パス
  - ECSヘルスチェック：コンテナレベル
- **ローリングアップデート**：
  - 最小ヘルシー率：50%（デフォルト）
  - 最大率：200%（デフォルト）
- **ECS Exec活用**：SSH不要でコンテナにシェルアクセス
- **Service Discovery**：マイクロサービス間通信
- **Blue/Greenデプロイ**：CodeDeployと連携
- **Container Insights有効化**：詳細メトリクス収集
- **ログドライバー**：awslogs推奨（CloudWatch Logs）
- **設計時に言語化すると評価が上がるポイント**：
  - 「Fargate起動タイプでサーバー管理不要、運用コスト削減」
  - 「Privateサブネット配置でセキュリティ強化、VPCエンドポイント経由でECRアクセス」
  - 「Auto ScalingでCPU 70%維持、負荷に応じて自動増減」
  - 「Secrets Managerで機密情報管理、環境変数に平文保存しない」
  - 「Container Insights有効化で詳細メトリクス収集、パフォーマンス分析」
  - 「ローリングアップデートで無停止デプロイ、最小ヘルシー率50%維持」
  - 「Spot Fargateでコスト最大70%削減、中断許容なバッチ処理に活用」

## ECS Fargate vs EC2起動タイプ

| 項目 | Fargate | EC2 |
|------|---------|-----|
| サーバー管理 | 不要 | 必要 |
| 課金 | vCPU時間 + メモリ時間 | EC2インスタンス時間 |
| スケーリング | 即座 | EC2起動時間必要 |
| 柔軟性 | 制約あり（最大4vCPU） | 高い |
| コスト | 小規模有利 | 大規模有利（リザーブド） |
| 用途 | 推奨（サーバーレス） | 特殊要件・大規模環境 |

## タスク定義のCPU/メモリ組み合わせ（Fargate）

| CPU | メモリ選択肢 |
|-----|------------|
| 0.25 vCPU | 0.5GB, 1GB, 2GB |
| 0.5 vCPU | 1GB〜4GB |
| 1 vCPU | 2GB〜8GB |
| 2 vCPU | 4GB〜16GB |
| 4 vCPU | 8GB〜30GB |

## ECS Exec有効化

タスク定義で設定：
```json
{
  "enableExecuteCommand": true
}
```

実行：
```bash
aws ecs execute-command \
  --cluster main-cluster \
  --task [task-id] \
  --container app \
  --interactive \
  --command "/bin/sh"
```
