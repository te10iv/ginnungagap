# ECR マネージドコンソールでのセットアップ

## 作成するもの

ECRリポジトリを作成し、Dockerコンテナイメージを保存します。ECSやEKSで使用するコンテナイメージを管理します。

## セットアップ手順

1. **ECRコンソールを開く**
   - AWSマネージメントコンソールで「ECR」を検索して選択

2. **リポジトリを作成**
   - 「リポジトリを作成」をクリック
   - **可視性設定**: プライベートを選択
   - **リポジトリ名**: `my-app` を入力
   - **タグの不変性**: 無効（デフォルト）
   - **スキャン設定**: 基本スキャンを有効化（オプション）
   - 「リポジトリを作成」をクリック

3. **イメージをプッシュ（ローカル環境で実行）**
   - リポジトリを選択
   - 「プッシュコマンドを表示」をクリック
   - 表示されたコマンドをローカル環境で実行：
   ```bash
   # ログイン
   aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com
   
   # イメージをビルド
   docker build -t my-app .
   
   # タグ付け
   docker tag my-app:latest <アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/my-app:latest
   
   # プッシュ
   docker push <アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/my-app:latest
   ```

4. **確認**
   - リポジトリにイメージが表示されることを確認

## 補足

- リポジトリURIをメモしておき、ECSタスク定義で使用します
- イメージの脆弱性スキャンが自動的に実行されます

