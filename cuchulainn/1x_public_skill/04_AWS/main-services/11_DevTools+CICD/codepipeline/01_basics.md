# AWS CodePipeline：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS CodePipeline は「**CI/CDパイプライン自動化**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- パイプラインを **作成できる**
- **ソース→ビルド→デプロイ の流れを理解できる**
- 「CI/CD自動化にはCodePipelineが必要」と判断できる

## まず覚えること（最小セット）
- **ステージ**：Source、Build、Deploy等
- **アクション**：各ステージの処理単位
- **アーティファクト**：ステージ間のデータ受け渡し
- **統合**：CodeCommit、CodeBuild、CodeDeploy、GitHub等
- **自動実行**：コミット時自動トリガー

## できるようになること
- □ パイプライン作成できる
- □ ソース→ビルド→デプロイ連携できる
- □ 手動承認ステージ追加できる
- □ パイプライン実行履歴確認できる

## まずやること（Hands-on）
- CodePipelineパイプライン作成
- Source：CodeCommit
- Build：CodeBuild
- Deploy：CodeDeploy
- パイプライン実行

## 関連するAWSサービス（名前だけ）
- **CodeCommit / GitHub**：ソース
- **CodeBuild**：ビルド
- **CodeDeploy**：デプロイ
- **S3**：アーティファクト保存
- **SNS**：通知
- **Lambda**：カスタムアクション
