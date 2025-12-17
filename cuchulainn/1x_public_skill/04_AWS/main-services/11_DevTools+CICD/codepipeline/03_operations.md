# AWS CodePipeline：運用とベストプラクティス（Lv3）

## 日常運用でよくやること
- パイプライン実行監視
- 失敗時の原因調査
- 手動承認処理
- パイプライン実行履歴確認

## トラブルシューティング
### よくあるエラーと対処
- **パイプライン失敗**：
  - 各ステージログ確認
  - IAMロール権限確認
  - アーティファクトS3確認
- **ソースステージ失敗**：
  - CodeCommit/GitHubアクセス確認
  - ブランチ名確認
- **ビルドステージ失敗**：
  - CodeBuild ログ確認
  - buildspec.yml確認
- **デプロイステージ失敗**：
  - CodeDeploy ログ確認
  - appspec.yml確認

## モニタリング
- **CloudWatchメトリクス**：
  - パイプライン成功率
  - パイプライン実行時間
- **CloudWatch Events**：
  - パイプライン実行開始
  - パイプライン失敗
  - 手動承認待ち
- **CloudWatch Alarms**：
  - パイプライン失敗アラート

## 定期メンテナンス
- パイプライン実行履歴確認
- IAMロール定期レビュー
- S3アーティファクト定期削除
- 不要なパイプライン削除

## セキュリティベストプラクティス
- **IAM最小権限**：
  - CodePipelineロール権限最小化
  - ステージごとに最小権限
- **S3暗号化**：アーティファクトS3暗号化必須
- **手動承認**：本番デプロイ前必須
- **CloudTrail有効化**：API呼び出し記録

## コスト最適化
- **$1/アクティブパイプライン/月**
- **非アクティブ（30日以上）：無料**
- **不要なパイプライン削除**
- **S3アーティファクトライフサイクル設定**

## よく使うCLIコマンド
```bash
# パイプライン一覧
aws codepipeline list-pipelines

# パイプライン詳細
aws codepipeline get-pipeline --name my-pipeline

# パイプライン実行
aws codepipeline start-pipeline-execution --name my-pipeline

# パイプライン実行状態
aws codepipeline get-pipeline-state --name my-pipeline

# パイプライン実行履歴
aws codepipeline list-pipeline-executions --pipeline-name my-pipeline

# 手動承認
aws codepipeline put-approval-result \
  --pipeline-name my-pipeline \
  --stage-name Approval \
  --action-name ManualApproval \
  --result status=Approved,summary="Approved by admin" \
  --token <token>
```

## よく使うPythonコード（boto3）
```python
import boto3

codepipeline = boto3.client('codepipeline')

# パイプライン実行
response = codepipeline.start_pipeline_execution(
    name='my-pipeline'
)
execution_id = response['pipelineExecutionId']
print(f"Execution ID: {execution_id}")

# パイプライン実行状態確認
response = codepipeline.get_pipeline_state(name='my-pipeline')
for stage in response['stageStates']:
    print(f"Stage: {stage['stageName']}, Status: {stage.get('latestExecution', {}).get('status', 'N/A')}")

# 手動承認
response = codepipeline.put_approval_result(
    pipelineName='my-pipeline',
    stageName='Approval',
    actionName='ManualApproval',
    result={
        'summary': 'Approved by automated script',
        'status': 'Approved'
    },
    token='<token>'
)
print("Approval submitted")
```

## パイプライン定義サンプル（JSON）
```json
{
  "pipeline": {
    "name": "my-pipeline",
    "roleArn": "arn:aws:iam::123456789012:role/codepipeline-role",
    "artifactStore": {
      "type": "S3",
      "location": "my-pipeline-artifacts"
    },
    "stages": [
      {
        "name": "Source",
        "actions": [{
          "name": "Source",
          "actionTypeId": {
            "category": "Source",
            "owner": "AWS",
            "provider": "CodeCommit",
            "version": "1"
          },
          "configuration": {
            "RepositoryName": "my-repo",
            "BranchName": "main"
          },
          "outputArtifacts": [{"name": "source_output"}]
        }]
      },
      {
        "name": "Build",
        "actions": [{
          "name": "Build",
          "actionTypeId": {
            "category": "Build",
            "owner": "AWS",
            "provider": "CodeBuild",
            "version": "1"
          },
          "configuration": {
            "ProjectName": "my-build-project"
          },
          "inputArtifacts": [{"name": "source_output"}],
          "outputArtifacts": [{"name": "build_output"}]
        }]
      },
      {
        "name": "Deploy",
        "actions": [{
          "name": "Deploy",
          "actionTypeId": {
            "category": "Deploy",
            "owner": "AWS",
            "provider": "CodeDeploy",
            "version": "1"
          },
          "configuration": {
            "ApplicationName": "my-app",
            "DeploymentGroupName": "my-group"
          },
          "inputArtifacts": [{"name": "build_output"}]
        }]
      }
    ]
  }
}
```

## 障害対応
- **パイプライン失敗**：
  1. CloudWatch Logsで各ステージログ確認
  2. IAMロール権限確認
  3. ソースコード確認
  4. 手動で各ステージ再実行
- **手動承認タイムアウト**：
  1. CloudWatch Eventsで承認通知確認
  2. 承認者に連絡
  3. 必要に応じてパイプライン再実行
