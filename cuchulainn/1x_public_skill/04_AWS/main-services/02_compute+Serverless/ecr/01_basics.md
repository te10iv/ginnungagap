# Amazon ECR：まずこれだけ（Lv1）

## このサービスの一言説明
- Amazon ECR は「**Dockerコンテナイメージを保存・管理するプライベートレジストリ**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- ECRリポジトリを **作成できる**
- **Dockerイメージをpush/pullできる**
- 「コンテナアプリにはECRが必要」と判断できる

## まず覚えること（最小セット）
- **ECRリポジトリ**：Dockerイメージ保存場所
- **イメージタグ**：バージョン管理（latest、v1.0.0等）
- **認証**：`aws ecr get-login-password` でDocker認証
- **イメージURI**：`[account-id].dkr.ecr.[region].amazonaws.com/[repo-name]:[tag]`
- **プライベートレジストリ**：IAMで厳密なアクセス制御

## できるようになること
- □ マネジメントコンソールでECRリポジトリを作成できる
- □ Docker CLIでイメージをpushできる
- □ ECS/Fargateでイメージをpullできる
- □ イメージスキャンを有効化できる

## まずやること（Hands-on）
- ECRリポジトリ作成
- Dockerイメージをビルド（`docker build -t my-app .`）
- AWS CLIで認証（`aws ecr get-login-password | docker login`）
- イメージにタグ付け・push
- ECS/Fargateタスク定義でイメージ指定

## 関連するAWSサービス（名前だけ）
- **ECS / Fargate**：ECRイメージを実行
- **CodeBuild**：CI/CDでイメージビルド・push
- **Lambda（Container Image）**：コンテナイメージのLambda関数
- **VPCエンドポイント**：プライベート接続（NAT Gateway不要）
- **IAM**：リポジトリアクセス制御
