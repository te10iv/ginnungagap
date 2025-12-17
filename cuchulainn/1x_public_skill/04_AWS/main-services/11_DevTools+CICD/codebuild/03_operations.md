# AWS CodeBuild：運用とベストプラクティス（Lv3）

## 日常運用でよくやること
- ビルド実行・監視
- ビルドログ確認
- ビルド時間確認・最適化
- buildspec.yml更新

## トラブルシューティング
### よくあるエラーと対処
- **ビルド失敗**：
  - CloudWatch Logsでエラー詳細確認
  - buildspec.yml確認
  - IAMロール権限確認
- **タイムアウト**：
  - ビルドタイムアウト値確認
  - ビルド最適化（キャッシュ等）
- **VPC接続失敗**：
  - セキュリティグループ確認
  - NAT Gateway確認
  - VPCエンドポイント確認

## モニタリング
- **CloudWatchメトリクス**：
  - ビルド成功率
  - ビルド時間
  - ビルド数
- **CloudWatch Logs**：
  - ビルドログ
  - エラーログ
- **CloudWatch Alarms**：
  - ビルド失敗アラート

## 定期メンテナンス
- buildspec.yml定期レビュー
- IAMロール定期レビュー
- ビルド時間定期確認・最適化
- 不要なプロジェクト削除

## セキュリティベストプラクティス
- **IAM最小権限**：
  - 必要なリソースのみアクセス
- **S3暗号化**：アーティファクトS3暗号化必須
- **Secrets Manager / Parameter Store**：認証情報管理
- **VPC配置**：プライベートリソースアクセス時
- **CloudTrail有効化**：API呼び出し記録

## コスト最適化
- **Linux：$0.005/分（一般）**
- **キャッシュ活用**：ビルド時間短縮
- **適切なコンピュートタイプ**：SMALL/MEDIUM/LARGE
- **不要なビルド削減**：プルリクエストのみ等

## よく使うCLIコマンド
```bash
# ビルド開始
aws codebuild start-build --project-name my-project

# ビルド状態確認
aws codebuild batch-get-builds --ids <build-id>

# ビルド履歴
aws codebuild list-builds-for-project --project-name my-project

# プロジェクト一覧
aws codebuild list-projects

# ビルドログ取得
aws logs get-log-events \
  --log-group-name /aws/codebuild/my-project \
  --log-stream-name <stream-name>
```

## よく使うPythonコード（boto3）
```python
import boto3
import time

codebuild = boto3.client('codebuild')

# ビルド開始
response = codebuild.start_build(
    projectName='my-project',
    environmentVariablesOverride=[
        {
            'name': 'ENVIRONMENT',
            'value': 'staging',
            'type': 'PLAINTEXT'
        }
    ]
)
build_id = response['build']['id']
print(f"Build ID: {build_id}")

# ビルド完了待機
while True:
    response = codebuild.batch_get_builds(ids=[build_id])
    build = response['builds'][0]
    status = build['buildStatus']
    print(f"Status: {status}")
    
    if status in ['SUCCEEDED', 'FAILED', 'STOPPED']:
        break
    
    time.sleep(10)

# ビルド詳細
if status == 'SUCCEEDED':
    print(f"Duration: {build['endTime'] - build['startTime']}")
    print(f"Artifacts: {build.get('artifacts', {}).get('location', 'N/A')}")
else:
    print(f"Failure: {build.get('buildStatus', 'Unknown')}")
```

## buildspec.ymlサンプル
### 基本
```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      python: 3.11
    commands:
      - pip install -r requirements.txt
  
  pre_build:
    commands:
      - echo "Running tests..."
      - pytest tests/
  
  build:
    commands:
      - echo "Building application..."
      - python setup.py build
  
  post_build:
    commands:
      - echo "Build completed"

artifacts:
  files:
    - '**/*'
  base-directory: dist

cache:
  paths:
    - '/root/.cache/pip/**/*'
```

### Dockerビルド
```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo "Logging in to Amazon ECR..."
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - REPOSITORY_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPOSITORY
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=${COMMIT_HASH:=latest}
  
  build:
    commands:
      - echo "Building Docker image..."
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  
  post_build:
    commands:
      - echo "Pushing Docker image..."
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo "Writing image definitions file..."
      - printf '[{"name":"app","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json

cache:
  paths:
    - '/var/run/docker.sock'
```

### マルチステージ
```yaml
version: 0.2

phases:
  install:
    commands:
      - echo "Installing dependencies..."
      - npm install
  
  pre_build:
    commands:
      - echo "Running unit tests..."
      - npm run test
      - echo "Running linting..."
      - npm run lint
  
  build:
    commands:
      - echo "Building application..."
      - npm run build
  
  post_build:
    commands:
      - echo "Running integration tests..."
      - npm run test:integration

artifacts:
  files:
    - '**/*'
  base-directory: build

reports:
  test_report:
    files:
      - 'test-results.xml'
    file-format: 'JUNITXML'

cache:
  paths:
    - 'node_modules/**/*'
```

## パフォーマンスチューニング
- **キャッシュ活用**：S3キャッシュ、ローカルキャッシュ
- **並列ビルド**：複数プロジェクト並列実行
- **適切なコンピュートタイプ**：ビルド内容に応じて選択
- **Git clone depth**：浅いclone（git_clone_depth=1）

## 障害対応
- **ビルド失敗**：
  1. CloudWatch Logsでエラー確認
  2. buildspec.yml確認
  3. IAMロール権限確認
  4. ローカルで再現確認
- **タイムアウト**：
  1. ビルドタイムアウト値確認
  2. ビルド最適化（キャッシュ）
  3. コンピュートタイプ見直し
