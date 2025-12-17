# AWS CodeCommit：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS CodeCommit は「**マネージドGitリポジトリ**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- リポジトリを **作成できる**
- **git clone / push / pull できる**
- 「ソースコード管理にCodeCommitが使える」と判断できる

## まず覚えること（最小セット）
- **Gitベース**：標準Git操作
- **プライベートリポジトリ**：デフォルトプライベート
- **認証**：IAM、HTTPS、SSH
- **統合**：CodePipeline、CodeBuild等
- **料金**：5ユーザー/月まで無料

## できるようになること
- □ リポジトリ作成できる
- □ git clone / push / pull できる
- □ ブランチ作成できる
- □ プルリクエスト（承認ルール）設定できる

## まずやること（Hands-on）
- CodeCommitリポジトリ作成
- Git認証情報設定（IAM）
- git clone
- ファイル追加、commit、push

## 関連するAWSサービス（名前だけ）
- **CodePipeline**：CI/CD統合
- **CodeBuild**：ビルド
- **Lambda**：トリガー
- **SNS**：通知
- **IAM**：アクセス制御
