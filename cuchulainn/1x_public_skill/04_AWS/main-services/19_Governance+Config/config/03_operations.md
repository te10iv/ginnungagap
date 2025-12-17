# AWS Config：運用とベストプラクティス（Lv3）

## 日常運用でよくやること
- コンプライアンスダッシュボード確認
- 設定変更履歴確認
- ルール違反確認・対応
- 自動修復結果確認

## トラブルシューティング
### よくあるエラーと対処
- **ルール評価失敗**：
  - IAMロール権限確認
  - Lambda関数確認（カスタムルール）
- **自動修復失敗**：
  - Systems Manager Automation実行ログ確認
  - IAMロール権限確認
- **設定記録失敗**：
  - S3バケット権限確認
  - IAMロール権限確認

## モニタリング
- **Config Dashboard**：
  - コンプライアンス状況
  - ルール違反数
- **CloudWatch Metrics**：
  - ルール評価数
  - コンプライアンス違反数
- **SNS通知**：
  - 設定変更通知
  - ルール違反通知

## 定期メンテナンス
- ルール定義定期レビュー
- IAMロール定期レビュー
- S3設定履歴定期削除（ライフサイクル）
- コンプライアンス違反定期確認

## セキュリティベストプラクティス
- **IAM最小権限**：
  - Configロール権限最小化
  - S3バケット権限最小化
- **S3暗号化**：SSE-S3 / SSE-KMS
- **SNS暗号化**：KMS暗号化
- **CloudTrail有効化**：API呼び出し記録
- **自動修復慎重に**：本番環境では手動確認推奨

## コスト最適化
- **Config Rules評価：$0.001/評価**
- **設定項目記録：$0.003/項目**
- **不要なルール削除**
- **記録対象リソース最適化**（all_supported=false）
- **S3ライフサイクル設定**（古い履歴削除）

## よく使うCLIコマンド
```bash
# Config有効化状態確認
aws configservice describe-configuration-recorders
aws configservice describe-configuration-recorder-status

# Config Rules一覧
aws configservice describe-config-rules

# ルール評価結果
aws configservice describe-compliance-by-config-rule

# リソースコンプライアンス
aws configservice describe-compliance-by-resource \
  --resource-type AWS::S3::Bucket

# 設定履歴取得
aws configservice get-resource-config-history \
  --resource-type AWS::S3::Bucket \
  --resource-id my-bucket

# ルール評価実行
aws configservice start-config-rules-evaluation \
  --config-rule-names my-rule

# Conformance Pack一覧
aws configservice describe-conformance-packs

# Conformance Pack コンプライアンス
aws configservice describe-conformance-pack-compliance \
  --conformance-pack-name security-best-practices
```

## よく使うPythonコード（boto3）
```python
import boto3

config = boto3.client('config')

# ルール評価結果
response = config.describe_compliance_by_config_rule()
for rule in response['ComplianceByConfigRules']:
    print(f"Rule: {rule['ConfigRuleName']}")
    print(f"  Compliance: {rule['Compliance']['ComplianceType']}")

# リソースコンプライアンス
response = config.describe_compliance_by_resource(
    ResourceType='AWS::S3::Bucket'
)
for item in response['ComplianceByResources']:
    print(f"Resource: {item['ResourceId']}")
    print(f"  Compliance: {item['Compliance']['ComplianceType']}")

# 設定履歴取得
response = config.get_resource_config_history(
    resourceType='AWS::S3::Bucket',
    resourceId='my-bucket',
    limit=10
)
for item in response['configurationItems']:
    print(f"Time: {item['configurationItemCaptureTime']}")
    print(f"Config: {item['configuration']}")
```

## カスタムルールLambdaサンプル
```python
import json
import boto3

config = boto3.client('config')

def lambda_handler(event, context):
    # イベントからリソース情報取得
    invoking_event = json.loads(event['invokingEvent'])
    configuration_item = invoking_event['configurationItem']
    
    # コンプライアンス判定
    compliance_type = 'COMPLIANT'
    annotation = 'Resource is compliant'
    
    # 例：S3バケット名に"test"が含まれていたら非準拠
    if configuration_item['resourceType'] == 'AWS::S3::Bucket':
        bucket_name = configuration_item['resourceName']
        if 'test' in bucket_name.lower():
            compliance_type = 'NON_COMPLIANT'
            annotation = 'Bucket name contains "test"'
    
    # 評価結果送信
    config.put_evaluations(
        Evaluations=[{
            'ComplianceResourceType': configuration_item['resourceType'],
            'ComplianceResourceId': configuration_item['resourceId'],
            'ComplianceType': compliance_type,
            'Annotation': annotation,
            'OrderingTimestamp': configuration_item['configurationItemCaptureTime']
        }],
        ResultToken=event['resultToken']
    )
    
    return {'statusCode': 200}
```

## Conformance Packサンプル
```yaml
Resources:
  S3BucketServerSideEncryptionEnabled:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: s3-bucket-server-side-encryption-enabled
      Source:
        Owner: AWS
        SourceIdentifier: S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED
  
  S3BucketPublicReadProhibited:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: s3-bucket-public-read-prohibited
      Source:
        Owner: AWS
        SourceIdentifier: S3_BUCKET_PUBLIC_READ_PROHIBITED
  
  RootAccountMfaEnabled:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: root-account-mfa-enabled
      Source:
        Owner: AWS
        SourceIdentifier: ROOT_ACCOUNT_MFA_ENABLED
```

## 障害対応
- **ルール評価失敗**：
  1. CloudWatch Logsでエラー確認
  2. IAMロール権限確認
  3. Lambda関数確認（カスタムルール）
  4. 手動評価実行
- **自動修復失敗**：
  1. Systems Manager Automation実行履歴確認
  2. IAMロール権限確認
  3. 手動修復実行
