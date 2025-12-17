# AWS Organizations：運用とベストプラクティス（Lv3）

## 日常運用でよくやること
- アカウント作成
- OU管理
- SCP適用・更新
- 一括請求確認

## トラブルシューティング
### よくあるエラーと対処
- **SCP拒否エラー**：
  - SCP内容確認
  - OU階層確認
  - IAMポリシーとSCPの違い理解
- **アカウント作成失敗**：
  - メールアドレス重複確認
  - アカウント数上限確認
- **OU移動失敗**：
  - SCP競合確認
  - 権限確認

## モニタリング
- **CloudTrail**：
  - 組織API呼び出し
  - SCP変更履歴
  - アカウント作成履歴
- **Cost Explorer**：
  - アカウント別コスト
  - OU別コスト
- **Trusted Advisor**：
  - 組織全体推奨事項

## 定期メンテナンス
- SCP定期レビュー
- OU構造定期レビュー
- 不要なアカウント削除（90日プロセス）
- アカウントタグ定期更新

## セキュリティベストプラクティス
- **管理アカウント保護**：
  - MFA必須
  - ルートユーザー使用禁止
  - アクセスキー削除
  - 最小権限IAMユーザー
- **SCP設計**：
  - リージョン制限
  - ルートユーザー制限
  - S3暗号化必須
  - 特定サービス制限
- **CloudTrail組織証跡**：全アカウント監査
- **Config組織ルール**：全アカウントコンプライアンス
- **SSO推奨**：IAMユーザー最小化

## コスト最適化
- **Organizations：無料**
- **一括請求でボリュームディスカウント**
- **RI/Savings Plans共有**
- **不要なアカウント削除**

## よく使うCLIコマンド
```bash
# 組織情報
aws organizations describe-organization

# アカウント一覧
aws organizations list-accounts

# OU一覧
aws organizations list-organizational-units-for-parent \
  --parent-id r-xxxx

# アカウント作成
aws organizations create-account \
  --email aws-new@example.com \
  --account-name new-account

# アカウントステータス確認
aws organizations describe-create-account-status \
  --create-account-request-id car-xxxx

# OU作成
aws organizations create-organizational-unit \
  --parent-id r-xxxx \
  --name NewOU

# アカウントOU移動
aws organizations move-account \
  --account-id 123456789012 \
  --source-parent-id ou-xxxx-source \
  --destination-parent-id ou-xxxx-dest

# SCP一覧
aws organizations list-policies --filter SERVICE_CONTROL_POLICY

# SCP作成
aws organizations create-policy \
  --name my-scp \
  --description "My SCP" \
  --type SERVICE_CONTROL_POLICY \
  --content file://scp.json

# SCP適用
aws organizations attach-policy \
  --policy-id p-xxxx \
  --target-id ou-xxxx

# SCP解除
aws organizations detach-policy \
  --policy-id p-xxxx \
  --target-id ou-xxxx
```

## よく使うPythonコード（boto3）
```python
import boto3

orgs = boto3.client('organizations')

# アカウント一覧
response = orgs.list_accounts()
for account in response['Accounts']:
    print(f"Account: {account['Name']} ({account['Id']})")
    print(f"  Email: {account['Email']}")
    print(f"  Status: {account['Status']}")

# アカウント作成
response = orgs.create_account(
    Email='aws-new@example.com',
    AccountName='new-account',
    RoleName='OrganizationAccountAccessRole'
)
request_id = response['CreateAccountStatus']['Id']
print(f"Request ID: {request_id}")

# アカウント作成ステータス確認
response = orgs.describe_create_account_status(
    CreateAccountRequestId=request_id
)
print(f"Status: {response['CreateAccountStatus']['State']}")

# OU一覧
response = orgs.list_organizational_units_for_parent(
    ParentId='r-xxxx'
)
for ou in response['OrganizationalUnits']:
    print(f"OU: {ou['Name']} ({ou['Id']})")

# SCP適用状況確認
response = orgs.list_policies_for_target(
    TargetId='ou-xxxx',
    Filter='SERVICE_CONTROL_POLICY'
)
for policy in response['Policies']:
    print(f"Policy: {policy['Name']} ({policy['Id']})")
```

## SCPサンプル
### リージョン制限
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": "*",
    "Resource": "*",
    "Condition": {
      "StringNotEquals": {
        "aws:RequestedRegion": ["ap-northeast-1", "us-east-1"]
      }
    }
  }]
}
```

### S3暗号化必須
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": "s3:PutObject",
    "Resource": "*",
    "Condition": {
      "StringNotEquals": {
        "s3:x-amz-server-side-encryption": ["AES256", "aws:kms"]
      }
    }
  }]
}
```

### ルートユーザー制限
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": "*",
    "Resource": "*",
    "Condition": {
      "StringLike": {
        "aws:PrincipalArn": "arn:aws:iam::*:root"
      }
    }
  }]
}
```

### EC2インスタンスタイプ制限
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": "ec2:RunInstances",
    "Resource": "arn:aws:ec2:*:*:instance/*",
    "Condition": {
      "StringNotLike": {
        "ec2:InstanceType": ["t3.*", "t4g.*"]
      }
    }
  }]
}
```

## OU構造サンプル
```
Root
├── Security (OU)
│   ├── Log Archive (Account)
│   └── Security Audit (Account)
├── Infrastructure (OU)
│   ├── Network (Account)
│   └── Shared Services (Account)
└── Workloads (OU)
    ├── Development (OU)
    │   ├── Dev-App1 (Account)
    │   └── Dev-App2 (Account)
    └── Production (OU)
        ├── Prod-App1 (Account)
        └── Prod-App2 (Account)
```

## 障害対応
- **SCP拒否エラー**：
  1. CloudTrailでエラー詳細確認
  2. SCP内容確認
  3. OU階層確認（継承）
  4. 必要に応じてSCP更新
- **アカウントアクセス不可**：
  1. 管理アカウントからAssumeRole
  2. OrganizationAccountAccessRole確認
  3. 必要に応じてSupport問い合わせ
