# AWS Secrets Manager：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **シークレット作成**：PutSecretValue
- **シークレット取得**：GetSecretValue
- **ローテーション設定**：RotateSecret
- **バージョン管理**：AWSCURRENT等

## よくあるトラブル
### トラブル1：シークレット取得エラー
- 症状：「AccessDeniedException」
- 原因：
  - IAM権限不足
  - リソースポリシー未設定
  - シークレット削除済み
- 確認ポイント：
  - IAMロールに `secretsmanager:GetSecretValue` 権限付与
  - リソースポリシー確認
  - シークレットステータス確認

### トラブル2：ローテーション失敗
- 症状：ローテーション失敗通知
- 原因：
  - Lambda関数エラー
  - RDS接続エラー
  - VPC設定ミス
- 確認ポイント：
  - CloudWatch LogsでLambdaエラー確認
  - Lambda VPC設定確認
  - RDS Security Group確認

### トラブル3：高額課金
- 症状：月末にSecrets Manager課金が高額
- 原因：
  - 大量のシークレット
  - 大量のAPI呼び出し
- 確認ポイント：
  - 不要なシークレット削除
  - キャッシュ活用（Lambda層）
  - Parameter Store検討（コスト削減）

## 監視・ログ
- **CloudTrail**：Secrets Manager操作ログ
- **CloudWatch Events**：ローテーション成功・失敗
- **Lambda Logs**：ローテーション関数ログ

## コストでハマりやすい点
- **シークレット**：$0.40/月
- **API呼び出し**：$0.05/10,000リクエスト
- **レプリケーション**：リージョンごとに課金
- **コスト削減策**：
  - キャッシュ活用（5分〜1時間）
  - Parameter Store検討（設定値は無料）
  - 不要なシークレット削除

## 実務Tips
- **RDS統合推奨**：自動ローテーション簡単
- **バージョン管理活用**：ロールバック可能
- **キャッシュ実装**：API呼び出し削減
- **JSON形式推奨**：複数値を1シークレットに格納
- **VPCエンドポイント**：プライベート接続、データ転送料削減
- **自動ローテーション**：30〜90日推奨
- **設計時に言語化すると評価が上がるポイント**：
  - 「Secrets Managerで認証情報管理、ハードコード排除・セキュリティ強化」
  - 「RDS自動ローテーション（30日ごと）で定期的なパスワード更新」
  - 「バージョン管理でロールバック可能、障害時の復旧迅速化」
  - 「VPCエンドポイントでプライベート接続、インターネット経由不要」
  - 「Lambda統合でアプリ起動時にシークレット取得、環境変数にハードコード不要」
  - 「KMS暗号化で保管時暗号化、コンプライアンス対応」
  - 「CloudTrail統合でシークレットアクセス監査、セキュリティインシデント調査」

## シークレット操作（AWS CLI）

```bash
# シークレット作成
aws secretsmanager create-secret \
  --name db-password \
  --description "Database password" \
  --secret-string '{"username":"admin","password":"MyPassword123!"}'

# シークレット取得
aws secretsmanager get-secret-value \
  --secret-id db-password

# シークレット更新
aws secretsmanager put-secret-value \
  --secret-id db-password \
  --secret-string '{"username":"admin","password":"NewPassword456!"}'

# シークレット削除（7〜30日待機期間）
aws secretsmanager delete-secret \
  --secret-id db-password \
  --recovery-window-in-days 30

# シークレット復元
aws secretsmanager restore-secret \
  --secret-id db-password

# ローテーション設定
aws secretsmanager rotate-secret \
  --secret-id db-password \
  --rotation-lambda-arn arn:aws:lambda:ap-northeast-1:123456789012:function:rotate-secret \
  --rotation-rules AutomaticallyAfterDays=30
```

## Lambda統合例（Python）

```python
import boto3
import json
import os

secretsmanager = boto3.client('secretsmanager')

def get_secret(secret_name):
    """シークレット取得（キャッシュなし）"""
    response = secretsmanager.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# Lambda関数例
def lambda_handler(event, context):
    # シークレット取得
    secret = get_secret(os.environ['DB_SECRET_ARN'])
    
    # データベース接続
    import pymysql
    connection = pymysql.connect(
        host=secret['host'],
        user=secret['username'],
        password=secret['password'],
        database=secret['dbname']
    )
    
    # クエリ実行
    # ...
    
    return {'statusCode': 200}
```

## キャッシュ実装例（Python）

```python
import boto3
import json
import time

class SecretCache:
    def __init__(self, ttl=300):  # 5分キャッシュ
        self.cache = {}
        self.ttl = ttl
        self.client = boto3.client('secretsmanager')
    
    def get_secret(self, secret_id):
        current_time = time.time()
        
        # キャッシュチェック
        if secret_id in self.cache:
            cached_secret, cached_time = self.cache[secret_id]
            if current_time - cached_time < self.ttl:
                return cached_secret
        
        # API呼び出し
        response = self.client.get_secret_value(SecretId=secret_id)
        secret = json.loads(response['SecretString'])
        
        # キャッシュ保存
        self.cache[secret_id] = (secret, current_time)
        
        return secret

# 使用例
secret_cache = SecretCache(ttl=300)  # 5分キャッシュ

def lambda_handler(event, context):
    secret = secret_cache.get_secret('db-password')
    # ...
```

## Secrets Manager vs Parameter Store

| 項目 | Secrets Manager | Parameter Store |
|------|----------------|----------------|
| 用途 | パスワード、APIキー | 設定値、DB接続先 |
| 料金 | $0.40/月 | Standard無料 |
| ローテーション | 自動（RDS統合） | 手動 |
| バージョン管理 | 詳細 | 簡易 |
| 暗号化 | 自動（KMS） | オプション |
| サイズ | 64KB | 8KB（Advanced） |
| 推奨用途 | 認証情報 | 設定値 |

## 自動ローテーション（RDS）の仕組み

1. **AWSCURRENT**：現在のパスワード
2. **Lambda起動**：30日ごと
3. **AWSPENDING作成**：新パスワード生成
4. **RDS更新**：新パスワード設定
5. **テスト**：新パスワードで接続確認
6. **完了**：AWSPENDING → AWSCURRENT

## ローテーションLambda関数（概要）

```python
def lambda_handler(event, context):
    token = event['Token']
    step = event['Step']
    
    if step == "createSecret":
        # 新パスワード生成
        create_secret(token)
    
    elif step == "setSecret":
        # RDSにパスワード設定
        set_secret(token)
    
    elif step == "testSecret":
        # 新パスワードでテスト接続
        test_secret(token)
    
    elif step == "finishSecret":
        # ローテーション完了
        finish_secret(token)
```

## IAM権限例

### シークレット取得
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "secretsmanager:GetSecretValue"
    ],
    "Resource": "arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:db-password-*"
  }]
}
```

### ローテーションLambda
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage"
      ],
      "Resource": "arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:db-password-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetRandomPassword"
      ],
      "Resource": "*"
    }
  ]
}
```

## ベストプラクティス

1. **自動ローテーション有効化**：30〜90日推奨
2. **JSON形式使用**：複数値を1シークレットに
3. **キャッシュ実装**：API呼び出し削減
4. **VPCエンドポイント**：プライベート接続
5. **最小権限の原則**：IAMロール設計
6. **CloudTrail有効化**：アクセス監査
7. **削除保護**：30日復旧期間
8. **タグ活用**：コスト配分、管理
9. **バージョン管理**：ロールバック準備
10. **RDS統合推奨**：自動ローテーション簡単

## エラーハンドリング例

```python
import boto3
from botocore.exceptions import ClientError

def get_secret_safe(secret_id):
    client = boto3.client('secretsmanager')
    
    try:
        response = client.get_secret_value(SecretId=secret_id)
        return json.loads(response['SecretString'])
    
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print(f"Secret {secret_id} not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print(f"Invalid request for secret {secret_id}")
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print(f"Invalid parameter for secret {secret_id}")
        elif e.response['Error']['Code'] == 'DecryptionFailure':
            print(f"Decryption failed for secret {secret_id}")
        elif e.response['Error']['Code'] == 'InternalServiceError':
            print(f"Internal service error for secret {secret_id}")
        else:
            print(f"Unknown error: {e}")
        
        return None
```
