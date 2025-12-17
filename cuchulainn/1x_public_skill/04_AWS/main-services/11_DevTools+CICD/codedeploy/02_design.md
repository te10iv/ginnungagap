# AWS CodeDeploy：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **EC2 / Lambda / ECS**：デプロイ対象
  - **S3**：アーティファクト保存
  - **ALB / NLB**：Blue/Greenデプロイ
  - **Auto Scaling**：スケール統合
  - **IAM**：権限管理

## 内部的な仕組み（ざっくり）
- **なぜCodeDeployが必要なのか**：デプロイ自動化、ダウンタイム削減、ロールバック
- **CodeDeploy Agent**：EC2/オンプレミスで実行
- **デプロイタイプ**：
  - **In-place**：既存インスタンス上書き（ダウンタイムあり）
  - **Blue/Green**：新環境作成→切り替え（ダウンタイムなし）
- **デプロイ設定**：
  - `AllAtOnce`：全インスタンス同時
  - `HalfAtATime`：半分ずつ
  - `OneAtATime`：1台ずつ
- **制約**：
  - デプロイグループ：最大1,000インスタンス

## よくある構成パターン
### パターン1：EC2 In-place
- 構成概要：
  - CodeDeploy（In-place）
  - EC2インスタンス
  - OneAtATime
- 使う場面：開発・検証環境

### パターン2：EC2 Blue/Green
- 構成概要：
  - CodeDeploy（Blue/Green）
  - ALB
  - Auto Scaling
  - 新環境作成→切り替え
- 使う場面：本番環境

### パターン3：Lambda デプロイ
- 構成概要：
  - CodeDeploy（Lambda）
  - Canary / Linear デプロイ
  - CloudWatch Alarms統合
  - 自動ロールバック
- 使う場面：サーバーレス

### パターン4：ECS Blue/Green
- 構成概要：
  - CodeDeploy（ECS）
  - ALB
  - Fargate
  - タスクセット切り替え
- 使う場面：コンテナアプリ

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：
  - Blue/Green推奨
  - ALB統合
  - Auto Scaling統合
- **セキュリティ**：
  - IAMロール（最小権限）
  - S3暗号化
  - CodeDeploy Agent更新
- **コスト**：
  - **EC2/オンプレミス：無料**
  - **Lambda/ECS：$0.02/更新**
- **拡張性**：最大1,000インスタンス

## 他サービスとの関係
- **CodePipeline との関係**：デプロイステージ
- **ALB との関係**：Blue/Greenトラフィック切り替え
- **Auto Scaling との関係**：スケールイベント統合
- **CloudWatch との関係**：メトリクス、自動ロールバック

## Terraformで見るとどうなる？
```hcl
# IAMロール（CodeDeploy）
resource "aws_iam_role" "codedeploy" {
  name = "codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRole"
}

# IAMロール（EC2）
resource "aws_iam_role" "ec2" {
  name = "ec2-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ec2" {
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject"
      ]
      Resource = "${aws_s3_bucket.artifacts.arn}/*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ec2-codedeploy-profile"
  role = aws_iam_role.ec2.name
}

# CodeDeployアプリケーション（EC2）
resource "aws_codedeploy_app" "ec2_app" {
  name             = "my-app"
  compute_platform = "Server"  # EC2/オンプレミス
}

# デプロイグループ（In-place）
resource "aws_codedeploy_deployment_group" "inplace" {
  app_name              = aws_codedeploy_app.ec2_app.name
  deployment_group_name = "inplace-group"
  service_role_arn      = aws_iam_role.codedeploy.arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "production"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  alarm_configuration {
    enabled = true
    alarms  = [aws_cloudwatch_metric_alarm.deployment_failure.alarm_name]
  }
}

# デプロイグループ（Blue/Green）
resource "aws_codedeploy_deployment_group" "bluegreen" {
  app_name              = aws_codedeploy_app.ec2_app.name
  deployment_group_name = "bluegreen-group"
  service_role_arn      = aws_iam_role.codedeploy.arn

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_scaling_groups = [aws_autoscaling_group.web.name]

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.blue.name
    }
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

# Lambdaデプロイ
resource "aws_codedeploy_app" "lambda_app" {
  name             = "lambda-app"
  compute_platform = "Lambda"
}

resource "aws_codedeploy_deployment_group" "lambda" {
  app_name              = aws_codedeploy_app.lambda_app.name
  deployment_group_name = "lambda-group"
  service_role_arn      = aws_iam_role.codedeploy.arn

  deployment_config_name = "CodeDeployDefault.LambdaLinear10PercentEvery1Minute"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  alarm_configuration {
    enabled = true
    alarms  = [aws_cloudwatch_metric_alarm.lambda_error.alarm_name]
  }
}

# ECSデプロイ
resource "aws_codedeploy_app" "ecs_app" {
  name             = "ecs-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs" {
  app_name              = aws_codedeploy_app.ecs_app.name
  deployment_group_name = "ecs-group"
  service_role_arn      = aws_iam_role.codedeploy.arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.main.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.main.arn]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }
}
```

主要リソース：
- `aws_codedeploy_app`：アプリケーション
- `aws_codedeploy_deployment_group`：デプロイグループ
