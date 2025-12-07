# AWS + TerraForm + Ansible学習ロードマップ


## 学習の概要
- 以下を覚えたい

- 含めたい要素
    - 主要なAWSサービス（約50個）
    - CI/CD 
    - Ansible(まずは①apache/nginx構築　②zabbix構築 ②' nagios/munin構築 )

### AWS主要サービス（使いこなせるようになるべきサービス）


## AWS主要サービス（カテゴリ別）

### Network
VPC / Subnet / Route Table / IGW / NAT Gateway / Endpoint / Transit Gateway / DX / VPN / CloudFront / Global Accelerator / Route53

### Compute
EC2 / AutoScaling / ALB・NLB / Lambda / ECS / ECR / Fargate

### Storage
S3 / EBS / EFS / Glacier

### Database
RDS / Aurora / DynamoDB / ElastiCache

### Security
IAM / KMS / SecretsManager / Cognito / WAF / Shield / Organizations

### Monitoring
CloudWatch / Logs / Trail / Config / SSM

### DevOps
CodeCommit / CodeBuild / CodeDeploy / CodePipeline / GitHub Actions

### Integration
SQS / SNS / EventBridge / StepFunctions





## Step

ステップ	ゴール / 構成イメージ	主な AWS サービス
------------------------------------------------
1	VPC + EC2 1台（超最小構成）	★VPC, ★EC2, ★IAM, ★Security Group, ★SSM ★apacheでwebページ表示  難易度：C
2	VPC + EC2(web/apache) + RDS	上記 + ★RDS, DB Subnet Group, 　難易度：C
3   上記に加え、 もう一つVPC作ってEC2を1台だけ作り、監視サーバ（zabbix)をAnsibleで作り、EC2(web/nginx)＋RDSを監視する   難易度：A
4	ALB + AutoScaling（3層Web基盤）	★ALB, ★Auto Scaling, Launch Template, Target Group, EventBridgeでRDSやEC2を自動起動、自動停止
5	CloudWatch / SNS / Logs / Trail	★CloudWatch(Logs, Metrics, Alarms), ★SNS, ★CloudTrail, AWS Config(任意)
6	S3 + CloudFront + ACM（静的サイト）	★S3, ★CloudFront, ★ACM, Route53(任意)
7	ECS on Fargate（コンテナ基盤）	★ECS, ★Fargate, ECR, ALB
8	ECS on Fargate（コンテナ基盤）+ DBキャッシュのサービス + Aurora	★ECS
9	Lambda + API Gateway + DynamoDB	+SQS +SNS + StepFunctions ★Lambda, ★API Gateway, ★DynamoDB, IAM ロール SNSでslackに自動通知    難易度：A
10	WAF + Athenaでログ分析  難易度：A
11	WAF / Shield / KMS / Secrets	★WAF, KMS, Secrets Manager, Parameter Store
12	CI/CD 	★GitHub Actions
13	CI/CD + Terraform Remote Backend	★CodePipeline/CodeBuild or GitHub Actions, S3 backend, DynamoDB lock
14 (Networkサービスを覚えるシナリオ　＋Terraformコード)  Network カテゴリのサービスを使って Terraform モジュール作ってほしい


## Terraform 共通モジュール方針

- moduleを使う

例
- module/vpc
- module/ec2
- module/rds
- module/alb
- module/asg
- module/ecs
- module/lambda


## Ansible 要件テンプレ
- 対象OS: Amazon Linux2023
- 必須ロール:
    - role: apache
      tasks: install, config, service enable
    - role: zabbix-agent
    - role: nagios-client


## 構成図（mermaid)

### step1

```step1

```

### 1. 成果物（Artifacts）

- Terraform: VPC, Subnet, Route Table, IGW, SG, EC2
- Ansible: ApacheインストールPlaybook
- AWS構成図（drawio）



### step2
