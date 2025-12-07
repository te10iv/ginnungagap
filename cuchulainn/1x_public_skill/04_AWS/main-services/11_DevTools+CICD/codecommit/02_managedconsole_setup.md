# CodeCommit マネージドコンソールでのセットアップ

## 作成するもの

CodeCommitリポジトリを作成し、ソースコードを管理します。Gitリポジトリとして使用します。

## セットアップ手順

1. **CodeCommitコンソールを開く**
   - AWSマネージメントコンソールで「CodeCommit」を検索して選択

2. **リポジトリを作成**
   - 「リポジトリを作成」をクリック
   - **リポジトリ名**: `my-repository` を入力
   - **説明**: 任意の説明を入力
   - 「作成」をクリック

3. **リポジトリに接続（ローカル環境で実行）**
   - リポジトリを選択
   - 「接続」をクリック
   - 表示されたコマンドをローカル環境で実行：
   ```bash
   # Git認証情報を設定
   git config --global credential.helper '!aws codecommit credential-helper $@'
   git config --global credential.UseHttpPath true
   
   # リポジトリをクローン
   git clone https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/my-repository
   ```

4. **ファイルをコミット**
   ```bash
   cd my-repository
   echo "# My Project" > README.md
   git add README.md
   git commit -m "Initial commit"
   git push origin main
   ```

## 補足

- IAMでリポジトリへのアクセスを制御します
- 標準的なGitコマンドで操作できます

