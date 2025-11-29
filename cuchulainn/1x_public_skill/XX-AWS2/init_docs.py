import os

# ① リポジトリのベースディレクトリ（好きな名前でOK）
BASE_DIR = "services"

# ② サービス一覧（ディレクトリ名, 表示名）
services = [
    ("ec2", "EC2"),
    ("auto-scaling", "Auto Scaling"),
    ("elb", "Elastic Load Balancing（ALB/NLB）"),
    ("lambda", "Lambda"),
    ("ecs", "ECS"),
    ("ecr", "ECR"),
    ("fargate", "Fargate"),
    ("s3", "S3"),
    ("s3-glacier-archive", "S3 Glacier / Archive"),
    ("ebs", "EBS"),
    ("efs", "EFS"),
    ("rds", "RDS"),
    ("aurora", "Aurora"),
    ("dynamodb", "DynamoDB"),
    ("elasticache", "ElastiCache"),
    ("vpc", "VPC"),
    ("subnet", "サブネット（Public / Private）"),
    ("route-table", "Route Table"),
    ("igw", "Internet Gateway（IGW）"),
    ("nat-gateway", "NAT Gateway"),
    ("vpc-endpoint", "VPC Endpoint（Gateway/Interface）"),
    ("privatelink", "PrivateLink"),
    ("transit-gateway", "Transit Gateway"),
    ("direct-connect", "Direct Connect"),
    ("site-to-site-vpn", "Site-to-Site VPN"),
    ("client-vpn", "Client VPN"),
    ("route53", "Route 53"),
    ("cloudfront", "CloudFront"),
    ("api-gateway", "API Gateway"),
    ("global-accelerator", "Global Accelerator"),
    ("iam", "IAM"),
    ("kms", "KMS"),
    ("secrets-manager", "Secrets Manager"),
    ("cognito", "Cognito"),
    ("waf", "WAF"),
    ("shield-advanced", "Shield Advanced"),
    ("organizations", "Organizations"),
    ("cloudwatch", "CloudWatch"),
    ("cloudwatch-logs", "CloudWatch Logs"),
    ("cloudtrail", "CloudTrail"),
    ("config", "Config"),
    ("ssm", "Systems Manager（SSM）"),
    ("control-tower", "Control Tower"),
    ("trusted-advisor", "Trusted Advisor"),
    ("codecommit", "CodeCommit"),
    ("codebuild", "CodeBuild"),
    ("codedeploy", "CodeDeploy"),
    ("codepipeline", "CodePipeline"),
    ("sqs", "SQS"),
    ("sns", "SNS"),
    ("eventbridge", "EventBridge"),
    ("step-functions", "Step Functions"),
    ("athena", "Athena"),
]

# ③ 作成するドキュメントの種類（ファイル名）
doc_types = [
    "01_overview.md",
    "02_managedconsole_setup.md",
    "03_cloudformation.md",
    "04_terraform.md",
    "05_operations.md",
]

# ④ 簡単なテンプレ（最初から見出しを入れておく）

# "ファイル名": """  
# ここに好きなMarkdownの文章  
# 改行いくらでもOK  
# """

templates = {
    "01_overview.md": """# {name} 概要

## 1. サービスの役割

## 2. 主なユースケース

## 3. 他サービスとの関係

## 4. 料金のざっくりイメージ

## 5. 初心者がまず覚えるべきポイント

""",
    "02_console_setup.md": """# {name} 構築手順（コンソール操作）

## 1. 前提条件

## 2. 構成イメージ

## 3. 手順

### 3-1. コンソールにログイン

### 3-2. リソースの作成

### 3-3. 動作確認

## 4. よくあるエラーと対処

""",
    "03_cloudformation.md": """# {name} 構築手順（CloudFormation）

## 1. 前提条件

## 2. テンプレートの全体像

```yaml
# ここに CloudFormation テンプレートを書く
```

"""
}

# ⑤ 実際にディレクトリとファイルを作成する処理

os.makedirs(BASE_DIR, exist_ok=True)

for svc_dir_name, svc_display_name in services:
    svc_dir = os.path.join(BASE_DIR, svc_dir_name)
    os.makedirs(svc_dir, exist_ok=True)

    for doc in doc_types:
        path = os.path.join(svc_dir, doc)

        if not os.path.exists(path):
            # 対応するテンプレがあれば使う。なければシンプルなタイトルだけ。
            template = templates.get(doc, "# {name}\n\n")
            content = template.format(name=svc_display_name)

            with open(path, "w", encoding="utf-8") as f:
                f.write(content)

            print("created:", path)
        else:
            print("exists :", path)

