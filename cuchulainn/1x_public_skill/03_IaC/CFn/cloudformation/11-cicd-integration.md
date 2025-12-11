# CI/CD統合パターン

CloudFormationとCI/CDパイプラインの統合

---

## 🔄 CI/CDとCloudFormation

### CI/CDで実現すること

- ✅ テンプレートの自動検証（cfn-lint、Checkov）
- ✅ Pull Request時の変更セット自動作成
- ✅ マージ時の自動デプロイ
- ✅ セキュリティスキャン
- ✅ コスト試算
- ✅ 承認フロー（本番環境）

---

## 🛠️ GitHub Actions統合

### Pattern 1: Pull Request時の検証

```yaml
name: CloudFormation Validate

on:
  pull_request:
    branches: [main]
    paths:
      - 'cloudformation/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install cfn-lint
        run: pip install cfn-lint
      
      - name: Validate Templates
        run: |
          for file in cloudformation/*.yaml; do
            echo "Validating $file"
            cfn-lint "$file"
          done
      
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: ap-northeast-1
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
      
      - name: Create Change Set
        run: |
          aws cloudformation create-change-set \
            --stack-name my-stack \
            --change-set-name pr-${{ github.event.pull_request.number }} \
            --template-body file://cloudformation/template.yaml \
            --capabilities CAPABILITY_NAMED_IAM
      
      - name: Wait for Change Set
        run: |
          aws cloudformation wait change-set-create-complete \
            --stack-name my-stack \
            --change-set-name pr-${{ github.event.pull_request.number }}
      
      - name: Describe Change Set
        id: changeset
        run: |
          aws cloudformation describe-change-set \
            --stack-name my-stack \
            --change-set-name pr-${{ github.event.pull_request.number }} \
            --output json > changeset.json
          cat changeset.json
      
      - name: Comment PR
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const changeset = JSON.parse(fs.readFileSync('changeset.json'));
            
            let comment = '## CloudFormation Change Set\n\n';
            
            for (const change of changeset.Changes) {
              const rc = change.ResourceChange;
              comment += `### ${rc.Action}: ${rc.LogicalResourceId} (${rc.ResourceType})\n`;
              
              if (rc.Replacement === 'True') {
                comment += '⚠️ **This resource will be REPLACED (recreated)**\n';
              }
              
              comment += '\n';
            }
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

### Pattern 2: マージ時の自動デプロイ

```yaml
name: Deploy CloudFormation

on:
  push:
    branches: [main]
    paths:
      - 'cloudformation/**'
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment'
        required: true
        type: choice
        options:
          - dev
          - stg
          - prod

jobs:
  deploy-dev:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: development
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: ap-northeast-1
          role-to-assume: ${{ secrets.AWS_ROLE_ARN_DEV }}
      
      - name: Deploy Stack
        run: |
          aws cloudformation deploy \
            --stack-name myapp-dev \
            --template-file cloudformation/template.yaml \
            --parameter-overrides file://cloudformation/parameters/dev.json \
            --capabilities CAPABILITY_NAMED_IAM \
            --no-fail-on-empty-changeset
      
      - name: Get Outputs
        run: |
          aws cloudformation describe-stacks \
            --stack-name myapp-dev \
            --query 'Stacks[0].Outputs' \
            --output table

  deploy-prod:
    runs-on: ubuntu-latest
    if: github.event.inputs.environment == 'prod'
    environment: production
    needs: deploy-dev
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: ap-northeast-1
          role-to-assume: ${{ secrets.AWS_ROLE_ARN_PROD }}
      
      - name: Create Change Set
        run: |
          aws cloudformation create-change-set \
            --stack-name myapp-prod \
            --change-set-name deploy-${{ github.sha }} \
            --template-body file://cloudformation/template.yaml \
            --parameters file://cloudformation/parameters/prod.json \
            --capabilities CAPABILITY_NAMED_IAM
      
      - name: Wait for Approval
        run: echo "Waiting for manual approval..."
      
      - name: Execute Change Set
        run: |
          aws cloudformation execute-change-set \
            --stack-name myapp-prod \
            --change-set-name deploy-${{ github.sha }}
      
      - name: Wait for Completion
        run: |
          aws cloudformation wait stack-update-complete \
            --stack-name myapp-prod
      
      - name: Notify Slack
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Production deployment completed'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🔧 AWS CodePipeline統合

### Pipeline構成

```yaml
Resources:
  Pipeline:
    Type: AWS::CodePipeline::Pipeline
    Properties:
      RoleArn: !GetAtt CodePipelineRole.Arn
      ArtifactStore:
        Type: S3
        Location: !Ref ArtifactBucket
      Stages:
        # Source Stage
        - Name: Source
          Actions:
            - Name: SourceAction
              ActionTypeId:
                Category: Source
                Owner: ThirdParty
                Provider: GitHub
                Version: '1'
              Configuration:
                Owner: my-org
                Repo: my-repo
                Branch: main
                OAuthToken: !Sub '{{resolve:secretsmanager:github-token}}'
              OutputArtifacts:
                - Name: SourceOutput
        
        # Validate Stage
        - Name: Validate
          Actions:
            - Name: CFNLint
              ActionTypeId:
                Category: Test
                Owner: AWS
                Provider: CodeBuild
                Version: '1'
              Configuration:
                ProjectName: !Ref CFNLintProject
              InputArtifacts:
                - Name: SourceOutput
        
        # Deploy to Dev
        - Name: DeployDev
          Actions:
            - Name: CreateChangeSet
              ActionTypeId:
                Category: Deploy
                Owner: AWS
                Provider: CloudFormation
                Version: '1'
              Configuration:
                ActionMode: CHANGE_SET_REPLACE
                StackName: myapp-dev
                ChangeSetName: pipeline-changeset
                TemplatePath: SourceOutput::template.yaml
                ParameterOverrides: file://parameters/dev.json
                Capabilities: CAPABILITY_NAMED_IAM
                RoleArn: !GetAtt CloudFormationRole.Arn
              InputArtifacts:
                - Name: SourceOutput
            
            - Name: ExecuteChangeSet
              ActionTypeId:
                Category: Deploy
                Owner: AWS
                Provider: CloudFormation
                Version: '1'
              Configuration:
                ActionMode: CHANGE_SET_EXECUTE
                StackName: myapp-dev
                ChangeSetName: pipeline-changeset
              RunOrder: 2
        
        # Deploy to Prod (Manual Approval)
        - Name: DeployProd
          Actions:
            - Name: ApprovalGate
              ActionTypeId:
                Category: Approval
                Owner: AWS
                Provider: Manual
                Version: '1'
              Configuration:
                CustomData: 'Please review the change set before approval'
            
            - Name: DeployProduction
              ActionTypeId:
                Category: Deploy
                Owner: AWS
                Provider: CloudFormation
                Version: '1'
              Configuration:
                ActionMode: CREATE_UPDATE
                StackName: myapp-prod
                TemplatePath: SourceOutput::template.yaml
                ParameterOverrides: file://parameters/prod.json
                Capabilities: CAPABILITY_NAMED_IAM
                RoleArn: !GetAtt CloudFormationRole.Arn
              InputArtifacts:
                - Name: SourceOutput
              RunOrder: 2

  # CodeBuild for cfn-lint
  CFNLintProject:
    Type: AWS::CodeBuild::Project
    Properties:
      Name: cfn-lint-validation
      ServiceRole: !GetAtt CodeBuildRole.Arn
      Artifacts:
        Type: CODEPIPELINE
      Environment:
        Type: LINUX_CONTAINER
        ComputeType: BUILD_GENERAL1_SMALL
        Image: aws/codebuild/standard:5.0
      Source:
        Type: CODEPIPELINE
        BuildSpec: |
          version: 0.2
          phases:
            install:
              commands:
                - pip install cfn-lint
            build:
              commands:
                - cfn-lint template.yaml
```

---

## 🔐 セキュリティスキャン統合

### Checkov統合

```yaml
name: Security Scan

on: [pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: cloudformation/
          framework: cloudformation
          output_format: cli
          soft_fail: true
      
      - name: Upload Results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: results.sarif
```

---

## 💡 ベストプラクティス

### ✅ DO

1. **本番デプロイには必ず承認ゲート**
2. **変更セットを自動作成してPRにコメント**
3. **cfn-lint、Checkovでセキュリティチェック**
4. **デプロイ後に自動テスト実行**
5. **Slack/Teams通知で可視化**

### ❌ DON'T

1. 本番環境への直接デプロイ（CI/CD経由必須）
2. 変更セット確認なしのマージ
3. セキュリティスキャン未実施

---

## 📚 学習リソース

- [GitHub Actions CloudFormation](https://github.com/aws-actions/aws-cloudformation-github-deploy)
- [AWS CodePipeline](https://docs.aws.amazon.com/ja_jp/codepipeline/latest/userguide/welcome.html)

---

**CI/CD統合で、CloudFormationデプロイを完全自動化！🚀**
