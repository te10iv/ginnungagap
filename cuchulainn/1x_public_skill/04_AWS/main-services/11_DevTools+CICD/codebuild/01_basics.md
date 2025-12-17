# AWS CodeBuild：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS CodeBuild は「**マネージドビルドサービス**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- ビルドプロジェクトを **作成できる**
- **buildspec.ymlを理解できる**
- 「アプリビルド自動化にはCodeBuildが必要」と判断できる

## まず覚えること（最小セット）
- **サーバーレス**：インフラ管理不要
- **従量課金**：ビルド時間のみ課金
- **buildspec.yml**：ビルド手順定義
- **統合**：CodePipeline、CodeCommit、GitHub等
- **環境**：Docker、Lambda、EC2等

## できるようになること
- □ ビルドプロジェクト作成できる
- □ buildspec.yml作成できる
- □ ビルド実行できる
- □ ビルドログ確認できる

## まずやること（Hands-on）
- CodeBuildプロジェクト作成
- buildspec.yml作成（簡単なビルド）
- ビルド実行
- CloudWatch Logsでログ確認

## 関連するAWSサービス（名前だけ）
- **CodePipeline**：CI/CD統合
- **CodeCommit / GitHub**：ソース
- **S3**：アーティファクト保存
- **ECR**：コンテナイメージ保存
- **CloudWatch Logs**：ログ保存
