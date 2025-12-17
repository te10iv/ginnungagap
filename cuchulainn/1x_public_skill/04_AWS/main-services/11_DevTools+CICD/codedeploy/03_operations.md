# AWS CodeDeploy：運用とベストプラクティス（Lv3）

## 日常運用でよくやること
- デプロイ実行・監視
- ロールバック実行
- デプロイ履歴確認
- CodeDeploy Agent更新

## トラブルシューティング
### よくあるエラーと対処
- **デプロイ失敗**：
  - CodeDeploy Agentステータス確認
  - IAMロール権限確認
  - appspec.ymlシンタックス確認
- **タイムアウト**：
  - スクリプト実行時間確認
  - タイムアウト値調整
- **ロールバック失敗**：
  - 前回デプロイ履歴確認
  - S3アーティファクト確認

## モニタリング
- **CloudWatchメトリクス**：
  - デプロイ成功率
  - デプロイ時間
- **CloudWatch Logs**：
  - CodeDeploy Agent ログ
  - デプロイスクリプトログ
- **CloudWatch Alarms**：
  - デプロイ失敗アラート
  - 自動ロールバックトリガー

## 定期メンテナンス
- CodeDeploy Agent定期更新
- デプロイ履歴定期確認
- IAMロール定期レビュー
- appspec.yml定期レビュー

## セキュリティベストプラクティス
- **IAM最小権限**：
  - CodeDeployロール権限最小化
  - EC2インスタンスロール権限最小化
- **S3暗号化**：アーティファクトS3暗号化必須
- **VPC配置**：プライベートサブネット推奨
- **CloudTrail有効化**：API呼び出し記録

## コスト最適化
- **EC2/オンプレミス：無料**
- **Lambda/ECS：$0.02/更新**
- **不要なデプロイグループ削除**
- **S3アーティファクトライフサイクル設定**

## よく使うCLIコマンド
```bash
# デプロイ作成
aws deploy create-deployment \
  --application-name my-app \
  --deployment-group-name my-group \
  --s3-location bucket=my-bucket,key=app.zip,bundleType=zip

# デプロイ状態確認
aws deploy get-deployment --deployment-id d-XXXXX

# デプロイ履歴
aws deploy list-deployments --application-name my-app

# ロールバック
aws deploy create-deployment \
  --application-name my-app \
  --deployment-group-name my-group \
  --s3-location bucket=my-bucket,key=previous-app.zip,bundleType=zip
```

## よく使うPythonコード（boto3）
```python
import boto3

codedeploy = boto3.client('codedeploy')

# デプロイ作成
response = codedeploy.create_deployment(
    applicationName='my-app',
    deploymentGroupName='my-group',
    revision={
        'revisionType': 'S3',
        's3Location': {
            'bucket': 'my-bucket',
            'key': 'app.zip',
            'bundleType': 'zip'
        }
    },
    deploymentConfigName='CodeDeployDefault.OneAtATime',
    description='Automated deployment'
)

deployment_id = response['deploymentId']
print(f"Deployment ID: {deployment_id}")

# デプロイ状態確認
response = codedeploy.get_deployment(deploymentId=deployment_id)
status = response['deploymentInfo']['status']
print(f"Deployment status: {status}")
```

## appspec.yml サンプル
```yaml
version: 0.0
os: linux
files:
  - source: /
    destination: /var/www/html
hooks:
  BeforeInstall:
    - location: scripts/install_dependencies.sh
      timeout: 300
      runas: root
  AfterInstall:
    - location: scripts/change_permissions.sh
      timeout: 300
      runas: root
  ApplicationStart:
    - location: scripts/start_server.sh
      timeout: 300
      runas: root
  ApplicationStop:
    - location: scripts/stop_server.sh
      timeout: 300
      runas: root
  ValidateService:
    - location: scripts/validate_service.sh
      timeout: 300
      runas: root
```

## 障害対応
- **デプロイ失敗**：
  1. CloudWatch Logsでエラー確認
  2. appspec.ymlシンタックス確認
  3. IAMロール権限確認
  4. CodeDeploy Agentログ確認
  5. 必要に応じてロールバック
- **ロールバック失敗**：
  1. 前回デプロイ履歴確認
  2. S3アーティファクト確認
  3. 手動ロールバック実行
