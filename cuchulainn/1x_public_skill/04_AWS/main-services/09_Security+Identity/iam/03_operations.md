# AWS IAM：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **IAMロール作成**：AWSサービス用
- **ポリシーアタッチ**：権限付与
- **アクセスキー管理**：定期ローテーション
- **IAM Access Analyzer**：過剰権限検出

## よくあるトラブル
### トラブル1：Access Denied エラー
- 症状：「AccessDenied」エラー
- 原因：
  - 権限不足
  - 明示的Deny
  - サービスロール未アタッチ
- 確認ポイント：
  - IAMポリシーシミュレーター使用
  - CloudTrailでAPI呼び出し確認
  - 明示的Deny確認

### トラブル2：ルートユーザー使用
- 症状：セキュリティベストプラクティス違反
- 原因：
  - IAMユーザー未作成
  - 管理者用IAMユーザー未使用
- 確認ポイント：
  - 管理者IAMユーザー作成
  - MFA有効化
  - ルートユーザーアクセスキー削除

### トラブル3：過剰権限
- 症状：必要以上の権限付与
- 原因：
  - `*`（全リソース）使用
  - 管理ポリシー乱用
- 確認ポイント：
  - IAM Access Analyzer使用
  - 最小権限の原則適用
  - 未使用権限削除

## 監視・ログ
- **CloudTrail**：IAM操作ログ
- **IAM Credential Report**：認証情報レポート
- **IAM Access Analyzer**：過剰権限分析
- **CloudWatch Events**：IAM変更イベント

## コストでハマりやすい点
- **IAM自体**：無料
- **関連コスト**：
  - CloudTrailログ保存
  - IAM Access Analyzer（無料枠超過分）

## 実務Tips
- **IAMロール推奨**：アクセスキー不要、自動ローテーション
- **最小権限の原則**：必要最小限の権限のみ
- **ルートユーザー使用禁止**：
  - MFA有効化必須
  - アクセスキー削除
  - 緊急時のみ使用
- **IAMグループ活用**：チーム別権限管理
- **管理ポリシー vs カスタムポリシー**：
  - 管理ポリシー：AWS提供、標準的
  - カスタムポリシー：細かい制御
- **タグベースアクセス制御（ABAC）**：タグで権限制御
- **セッションポリシー**：一時的権限制限
- **設計時に言語化すると評価が上がるポイント**：
  - 「IAMロールでアクセスキー不要、自動ローテーション・セキュリティ強化」
  - 「最小権限の原則で必要最小限の権限のみ付与、攻撃リスク低減」
  - 「IAM Access Analyzerで過剰権限検出、定期的な権限見直し」
  - 「タグベースアクセス制御で環境別権限管理、柔軟な権限設計」
  - 「クロスアカウントロールでマルチアカウント環境の権限管理、External ID で安全な委任」
  - 「IAM Credential Report で未使用認証情報検出、定期削除」
  - 「CloudTrail統合でIAM操作監査、セキュリティインシデント調査」

## ポリシー例

### S3バケット読み取り専用
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:ListBucket"
    ],
    "Resource": [
      "arn:aws:s3:::my-bucket",
      "arn:aws:s3:::my-bucket/*"
    ]
  }]
}
```

### DynamoDB特定テーブルアクセス
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ],
    "Resource": "arn:aws:dynamodb:ap-northeast-1:123456789012:table/Users"
  }]
}
```

### タグベースアクセス制御
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "ec2:*",
    "Resource": "*",
    "Condition": {
      "StringEquals": {
        "ec2:ResourceTag/Environment": "dev"
      }
    }
  }]
}
```

### MFA必須
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "*",
    "Resource": "*",
    "Condition": {
      "Bool": {
        "aws:MultiFactorAuthPresent": "true"
      }
    }
  }]
}
```

## IAMロール vs IAMユーザー

| 項目 | IAMロール | IAMユーザー |
|------|----------|-----------|
| 用途 | AWSサービス・アプリ | 人間 |
| 認証情報 | 一時的 | 永続的 |
| ローテーション | 自動 | 手動 |
| アクセスキー | 不要 | 必要（CLI/SDK） |
| 推奨 | ✓ | △ |

## ポリシー評価順序

1. **明示的Deny**：最優先
2. **Organizations SCP**：アカウント全体制限
3. **リソースベースポリシー**：S3バケットポリシー等
4. **IAMポリシー**：アイデンティティベース
5. **セッションポリシー**：一時的制限

**結論**：明示的Denyが最強、すべてのAllowを上書き

## IAM Access Analyzer活用

```bash
# Access Analyzer有効化
aws accessanalyzer create-analyzer \
  --analyzer-name my-analyzer \
  --type ACCOUNT

# 分析結果取得
aws accessanalyzer list-findings \
  --analyzer-arn arn:aws:access-analyzer:ap-northeast-1:123456789012:analyzer/my-analyzer
```

## IAM Credential Report

```bash
# レポート生成
aws iam generate-credential-report

# レポート取得
aws iam get-credential-report > credential-report.csv
```

**確認項目**：
- 未使用アクセスキー
- パスワード最終使用日
- MFA有効化状況
- アクセスキー最終使用日

## クロスアカウントアクセス手順

### アカウントB（信頼される側）
```hcl
# IAMロール作成
resource "aws_iam_role" "cross_account" {
  name = "cross-account-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::123456789012:root"  # アカウントA
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "sts:ExternalId" = "unique-external-id"
        }
      }
    }]
  })
}
```

### アカウントA（信頼する側）
```bash
# ロール引き受け
aws sts assume-role \
  --role-arn arn:aws:iam::987654321098:role/cross-account-role \
  --role-session-name session1 \
  --external-id unique-external-id

# 一時認証情報取得
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
export AWS_SESSION_TOKEN=xxx

# アカウントBのリソースアクセス
aws s3 ls
```

## IAMポリシーシミュレーター

```bash
# ポリシーシミュレーション
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:role/ec2-role \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::my-bucket/file.txt
```

## IAMベストプラクティス

1. **ルートユーザー保護**：
   - MFA有効化
   - アクセスキー削除
   - 緊急時のみ使用

2. **IAMユーザーではなくIAMロール**：
   - EC2、Lambda等はIAMロール
   - アクセスキー不要

3. **最小権限の原則**：
   - 必要最小限の権限
   - 定期的な権限見直し

4. **グループ活用**：
   - 個別ユーザーではなくグループに権限付与

5. **強力なパスワードポリシー**：
   - 最小12文字
   - 複雑性要件

6. **MFA有効化**：
   - すべてのユーザー
   - 特に管理者

7. **アクセスキーローテーション**：
   - 90日ごと
   - 未使用キー削除

8. **CloudTrail有効化**：
   - IAM操作ログ記録

9. **IAM Access Analyzer**：
   - 過剰権限検出
   - 定期レビュー

10. **タグ活用**：
    - コスト配分
    - アクセス制御（ABAC）

## 管理ポリシー例

| ポリシー | 用途 |
|---------|------|
| AdministratorAccess | フルアクセス（本番環境注意） |
| PowerUserAccess | IAM除くフルアクセス |
| ReadOnlyAccess | 全サービス読み取り専用 |
| SecurityAudit | セキュリティ監査用 |
| ViewOnlyAccess | コンソール表示のみ |

## IAMロール信頼ポリシー例

### EC2用
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

### Lambda用
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

### クロスアカウント
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::123456789012:root"
    },
    "Action": "sts:AssumeRole",
    "Condition": {
      "StringEquals": {
        "sts:ExternalId": "unique-external-id"
      }
    }
  }]
}
```
