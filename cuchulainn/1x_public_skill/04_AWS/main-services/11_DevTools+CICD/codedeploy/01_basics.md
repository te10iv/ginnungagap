# AWS CodeDeploy：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS CodeDeploy は「**アプリケーションデプロイ自動化**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- デプロイグループを **作成できる**
- **appspec.yml を理解できる**
- 「デプロイ自動化にはCodeDeployが使える」と判断できる

## まず覚えること（最小セット）
- **デプロイ対象**：EC2、Lambda、ECS/Fargate、オンプレミス
- **appspec.yml**：デプロイ定義ファイル
- **デプロイタイプ**：In-place（上書き）、Blue/Green（切り替え）
- **ロールバック**：自動・手動ロールバック
- **統合**：CodePipeline

## できるようになること
- □ デプロイグループ作成できる
- □ appspec.yml作成できる
- □ EC2にデプロイできる
- □ ロールバックできる

## まずやること（Hands-on）
- CodeDeployアプリケーション作成
- デプロイグループ作成（EC2）
- appspec.yml作成
- デプロイ実行

## 関連するAWSサービス（名前だけ）
- **EC2 / Lambda / ECS**：デプロイ対象
- **S3**：アーティファクト保存
- **CodePipeline**：CI/CD統合
- **IAM**：権限管理
- **CloudWatch**：メトリクス
