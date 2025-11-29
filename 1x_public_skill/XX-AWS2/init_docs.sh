#!/usr/bin/env bash
set -e

# ① リポジトリのベースディレクトリ
BASE_DIR="services"

# ② サービス一覧（「ディレクトリ名|表示名」）
services=(
  "ec2|EC2"
  "auto-scaling|Auto Scaling"
  "elb|Elastic Load Balancing（ALB/NLB）"
  "lambda|Lambda"
  "ecs|ECS"
  "ecr|ECR"
  "fargate|Fargate"
  "s3|S3"
  "s3-glacier-archive|S3 Glacier / Archive"
  "ebs|EBS"
  "efs|EFS"
  "rds|RDS"
  "aurora|Aurora"
  "dynamodb|DynamoDB"
  "elasticache|ElastiCache"
  "vpc|VPC"
  "subnet|サブネット（Public / Private）"
  "route-table|Route Table"
  "igw|Internet Gateway（IGW）"
  "nat-gateway|NAT Gateway"
  "vpc-endpoint|VPC Endpoint（Gateway/Interface）"
  "privatelink|PrivateLink"
  "transit-gateway|Transit Gateway"
  "direct-connect|Direct Connect"
  "site-to-site-vpn|Site-to-Site VPN"
  "client-vpn|Client VPN"
  "route53|Route 53"
  "cloudfront|CloudFront"
  "api-gateway|API Gateway"
  "global-accelerator|Global Accelerator"
  "iam|IAM"
  "kms|KMS"
  "secrets-manager|Secrets Manager"
  "cognito|Cognito"
  "waf|WAF"
  "shield-advanced|Shield Advanced"
  "organizations|Organizations"
  "cloudwatch|CloudWatch"
  "cloudwatch-logs|CloudWatch Logs"
  "cloudtrail|CloudTrail"
  "config|Config"
  "ssm|Systems Manager（SSM）"
  "control-tower|Control Tower"
  "trusted-advisor|Trusted Advisor"
  "codecommit|CodeCommit"
  "codebuild|CodeBuild"
  "codedeploy|CodeDeploy"
  "codepipeline|CodePipeline"
  "sqs|SQS"
  "sns|SNS"
  "eventbridge|EventBridge"
  "step-functions|Step Functions"
  "athena|Athena"
)

# ③ 作成するドキュメントの種類
doc_types=(
  "01_overview.md"
  "02_managedconsole_setup.md"
  "03_cloudformation.md"
  "04_terraform.md"
  "05_operations.md"
)

mkdir -p "$BASE_DIR"

for entry in "${services[@]}"; do
  IFS='|' read -r svc_dir_name svc_display_name <<< "$entry"

  svc_dir="$BASE_DIR/$svc_dir_name"
  mkdir -p "$svc_dir"

  for doc in "${doc_types[@]}"; do
    path="$svc_dir/$doc"

    if [[ -e "$path" ]]; then
      echo "exists : $path"
      continue
    fi

    case "$doc" in
      "01_overview.md")
        cat > "$path" <<EOF
# $svc_display_name 概要

## 1. サービスの役割

## 2. 主なユースケース

## 3. 他サービスとの関係

## 4. 料金のざっくりイメージ

## 5. 初心者がまず覚えるべきポイント

EOF
        ;;
      "02_managedconsole_setup.md")
        cat > "$path" <<EOF
# $svc_display_name 構築手順（コンソール操作）

## 1. 前提条件

## 2. 構成イメージ

## 3. 手順

### 3-1. コンソールにログイン

### 3-2. リソースの作成

### 3-3. 動作確認

## 4. よくあるエラーと対処

EOF
        ;;
      "03_cloudformation.md")
        cat > "$path" <<EOF
# $svc_display_name 構築手順（CloudFormation）

## 1. 前提条件

## 2. テンプレートの全体像

```yaml
# ここに CloudFormation テンプレートを書く
