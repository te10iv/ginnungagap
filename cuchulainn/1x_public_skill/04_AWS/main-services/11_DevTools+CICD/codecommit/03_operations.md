# AWS CodeCommit：運用とベストプラクティス（Lv3）

## 日常運用でよくやること
- Git操作（clone、push、pull）
- プルリクエスト作成・レビュー・承認
- ブランチ管理
- アクセス権限管理

## トラブルシューティング
### よくあるエラーと対処
- **認証エラー**：
  - Git認証情報確認（IAM）
  - SSHキー確認
  - IAMポリシー確認
- **プッシュ拒否**：
  - ブランチ保護設定確認
  - 承認ルール確認
  - IAM権限確認
- **大容量ファイルエラー**：
  - Git LFS使用
  - ファイルサイズ確認（2GB制限）

## モニタリング
- **CloudWatchメトリクス**：
  - リポジトリサイズ
  - プッシュ回数
- **CloudWatch Events**：
  - プッシュイベント
  - プルリクエストイベント
- **CloudTrail**：
  - API呼び出し履歴
  - 承認ルール変更履歴

## 定期メンテナンス
- IAM権限定期レビュー
- 承認ルール定期レビュー
- 不要ブランチ削除
- リポジトリサイズ確認

## セキュリティベストプラクティス
- **IAM最小権限**：
  - 読み取り専用ユーザー
  - プッシュ権限最小化
- **MFA必須**：本番環境推奨
- **承認ルール**：
  - mainブランチ：2名承認
  - developブランチ：1名承認
- **ブランチ保護**：main直接プッシュ禁止
- **CloudTrail有効化**：API呼び出し記録

## コスト最適化
- **5ユーザー/月：無料**
- **不要なリポジトリ削除**
- **大容量ファイルはS3使用**

## よく使うCLIコマンド
```bash
# リポジトリ一覧
aws codecommit list-repositories

# リポジトリ作成
aws codecommit create-repository --repository-name my-repo

# リポジトリ削除
aws codecommit delete-repository --repository-name my-repo

# ブランチ一覧
aws codecommit list-branches --repository-name my-repo

# プルリクエスト一覧
aws codecommit list-pull-requests --repository-name my-repo

# Git認証情報作成（IAMユーザー）
aws iam create-service-specific-credential \
  --user-name my-user \
  --service-name codecommit.amazonaws.com
```

## よく使うPythonコード（boto3）
```python
import boto3

codecommit = boto3.client('codecommit')

# リポジトリ一覧
response = codecommit.list_repositories()
for repo in response['repositories']:
    print(f"Repository: {repo['repositoryName']}")

# リポジトリ作成
response = codecommit.create_repository(
    repositoryName='my-repo',
    repositoryDescription='My application repository'
)
print(f"Repository ARN: {response['repositoryMetadata']['Arn']}")

# プルリクエスト作成
response = codecommit.create_pull_request(
    title='Feature: New feature',
    description='This PR adds a new feature',
    targets=[{
        'repositoryName': 'my-repo',
        'sourceReference': 'refs/heads/feature-branch',
        'destinationReference': 'refs/heads/main'
    }]
)
print(f"Pull Request ID: {response['pullRequest']['pullRequestId']}")
```

## Git設定サンプル
```bash
# HTTPS認証設定
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

# clone
git clone https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/my-repo

# SSH設定（~/.ssh/config）
Host git-codecommit.*.amazonaws.com
  User APKAEIBAERJR2EXAMPLE
  IdentityFile ~/.ssh/codecommit_rsa
```

## 承認ルールテンプレートサンプル
```json
{
  "Version": "2018-11-08",
  "DestinationReferences": ["refs/heads/main"],
  "Statements": [{
    "Type": "Approvers",
    "NumberOfApprovalsNeeded": 2,
    "ApprovalPoolMembers": [
      "arn:aws:sts::123456789012:assumed-role/Approvers/*"
    ]
  }]
}
```

## 障害対応
- **認証エラー**：
  1. IAMユーザー確認
  2. Git認証情報再生成
  3. SSHキー確認
- **プッシュ拒否**：
  1. ブランチ保護設定確認
  2. 承認ルール確認
  3. プルリクエスト経由でマージ
