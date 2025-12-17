# VPC Endpoint：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **エンドポイントポリシー**：S3バケット制限、DynamoDBテーブル制限
- **Private DNS有効化**：標準のAWSサービスエンドポイントを自動解決（インターフェース型）
- **Security Group設定**：インターフェース型の通信制御

## よくあるトラブル
### トラブル1：S3にアクセスできない
- 症状：ゲートウェイ型エンドポイント作成後もS3アクセスNG
- 原因：
  - ルートテーブルにエンドポイントが関連付けられていない
  - エンドポイントポリシーが厳しすぎる
  - S3バケットポリシーでVPCエンドポイント経由を拒否
- 確認ポイント：
  - ルートテーブルで`pl-xxxxx`（S3プレフィックスリスト）のルート確認
  - エンドポイントポリシーで`"Effect": "Allow"`確認
  - S3バケットポリシーで`aws:SourceVpce`条件確認

### トラブル2：ECRからイメージをPullできない
- 症状：ECS/FargateタスクがPrivateサブネットでイメージPull失敗
- 原因：
  - ECR API/DKRエンドポイントがない
  - S3ゲートウェイエンドポイントがない（イメージレイヤー取得に必要）
  - Security Groupで443ポートがブロックされている
  - Private DNS有効化されていない
- 確認ポイント：
  - 3つのエンドポイント確認：ecr.api、ecr.dkr、s3
  - Security Groupで443許可
  - Private DNS有効化（`PrivateDnsEnabled: true`）

### トラブル3：SSM Session Managerに接続できない
- 症状：PrivateサブネットのEC2にセッションマネージャー接続不可
- 原因：
  - 必要な3つのエンドポイントがない（ssm、ssmmessages、ec2messages）
  - Security Groupで443ポートがブロックされている
  - IAM Roleが不足
- 確認ポイント：
  - 3つのエンドポイント存在確認
  - Security Groupで443許可
  - EC2にSSMマネージド用IAM Roleがアタッチされているか

## 監視・ログ
- **VPC Flow Logs**：エンドポイント経由の通信を記録
  - ENI単位でフロー確認（インターフェース型）
- **CloudWatch Metrics**：
  - エンドポイント固有のメトリクスは少ない
  - ENIのメトリクスで確認（インターフェース型）
- **CloudTrail**：エンドポイント作成/削除の記録

## コストでハマりやすい点
- **ゲートウェイ型**：無料（S3・DynamoDB専用）
- **インターフェース型**：$0.01/時間/AZ（月$7/AZ）+ データ処理料$0.01/GB
  - Multi-AZ構成（2AZ）で月$14〜
  - 複数サービス（ECR 2つ + SSM 3つ = 5つ）で月$35〜
- **NAT Gatewayとの比較**：
  - NAT Gateway：$0.062/時間（月$45）+ $0.062/GB
  - VPCエンドポイント：$0.01/時間（月$7）+ $0.01/GB
  - データ転送量が多い場合はVPCエンドポイントが有利
- **削除忘れ**：不要なインターフェース型エンドポイントは削除

## 実務Tips
- **S3/DynamoDBは必ず作成**：無料なので全環境で作成推奨
- **ECR環境は必須**：ECS/Fargate Privateサブネット配置時
- **SSM用エンドポイント**：Privateサブネットからセッションマネージャー使用時
- **Private DNS有効化推奨**：標準エンドポイント名で接続可能（コード変更不要）
- **Security Group設計**：インターフェース型は443ポート許可必須
- **エンドポイントポリシー**：デフォルトは全許可、必要に応じて制限
- **Multi-AZ配置**：本番環境は各AZにインターフェース型エンドポイント配置
- **コスト最適化**：
  - 開発環境はシングルAZでコスト削減
  - 使用頻度低いサービスはNAT Gateway経由
  - データ転送量でNAT GatewayとVPCエンドポイントを比較
- **命名規則**：`{service}-{type}-endpoint-{env}`（例：s3-gateway-endpoint-prod）
- **設計時に言語化すると評価が上がるポイント**：
  - 「S3/DynamoDBはゲートウェイ型エンドポイントで無料アクセス」
  - 「ECR環境はエンドポイント3つ（api + dkr + s3）でNAT Gateway不要」
  - 「SSMセッションマネージャー用に3つのエンドポイント（ssm + ssmmessages + ec2messages）を配置」
  - 「Multi-AZ構成で各AZにインターフェース型エンドポイント配置し、AZ障害耐性を確保」
  - 「データ転送コストを考慮し、VPCエンドポイントとNAT Gatewayを使い分け」

## 主要AWSサービスのエンドポイント一覧

### ゲートウェイ型（無料）
- S3: `com.amazonaws.<region>.s3`
- DynamoDB: `com.amazonaws.<region>.dynamodb`

### インターフェース型（有料）
- **ECR**: `ecr.api`, `ecr.dkr` + S3ゲートウェイ型
- **SSM**: `ssm`, `ssmmessages`, `ec2messages`
- **Secrets Manager**: `secretsmanager`
- **CloudWatch**: `logs`, `monitoring`
- **Lambda**: `lambda`
- **STS**: `sts`
