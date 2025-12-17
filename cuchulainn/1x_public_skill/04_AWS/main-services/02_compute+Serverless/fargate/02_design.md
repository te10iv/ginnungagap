# AWS Fargate：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **ECS / EKS**：オーケストレーション
  - **VPC + Subnet**：タスク配置場所
  - **ECR**：コンテナイメージ
  - **IAM Role**：タスク実行ロール・タスクロール

## 内部的な仕組み（ざっくり）
- **なぜFargateが必要なのか**：サーバー管理不要、自動スケール、セキュリティ強化
- **タスクレベル分離**：各タスクが独立したマイクロVM
- **自動スケーリング**：即座にタスク起動（EC2起動待ち不要）
- **ネットワークモード**：awsvpc（各タスクに ENI 割り当て）
- **制約**：
  - 最大：4vCPU、30GB
  - ストレージ：20GB（エフェメラル）
  - GPUは使用不可

## よくある構成パターン
### パターン1：Webアプリケーション（標準構成）
- 構成概要：
  - ALB（Publicサブネット）
  - Fargateタスク（Privateサブネット、2AZ）
  - Auto Scaling（CPU 70%）
  - ECRイメージ
- 使う場面：Webアプリケーション、API

### パターン2：バッチ処理
- 構成概要：
  - EventBridgeスケジュール
  - Fargateタスク（サービスではなく単発実行）
  - 完了後自動停止
- 使う場面：定期バッチ、非同期処理

### パターン3：Spot Fargate（コスト最適化）
- 構成概要：
  - 通常Fargate：最小2タスク
  - Spot Fargate：0〜8タスク（最大70%削減）
  - 中断許容なワークロード
- 使う場面：コスト優先、バッチ処理

### パターン4：マイクロサービス
- 構成概要：
  - 複数のFargateサービス（API、Web、Worker等）
  - Service Discoveryで内部通信
  - App Meshでサービスメッシュ
- 使う場面：マイクロサービスアーキテクチャ

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：複数AZにタスク分散
- **セキュリティ**：
  - Privateサブネット配置
  - VPCエンドポイント活用
  - タスクレベル分離
- **コスト**：
  - vCPU/メモリの従量課金
  - Spot Fargate活用（最大70%削減）
  - 適切なサイジング
- **拡張性**：Auto Scaling、即座にスケール

## 他サービスとの関係
- **ECS との関係**：Fargateは ECS の起動タイプ
- **EKS との関係**：Kubernetes でも Fargate 使用可能
- **Lambda との関係**：
  - Lambda：イベント駆動、最大15分
  - Fargate：長時間実行、常時稼働
- **EC2 との関係**：
  - Fargate：サーバーレス
  - EC2：サーバー管理必要

## Terraformで見るとどうなる？
```hcl
# タスク定義（Fargate）
resource "aws_ecs_task_definition" "app" {
  family                   = "app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"   # 0.25 vCPU
  memory                   = "512"   # 0.5 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "app"
    image     = "${aws_ecr_repository.app.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/app"
        "awslogs-region"        = "ap-northeast-1"
        "awslogs-stream-prefix" = "fargate"
      }
    }
  }])
}

# ECSサービス（Fargate）
resource "aws_ecs_service" "app" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  platform_version = "LATEST"  # Fargateプラットフォームバージョン

  network_configuration {
    subnets          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
    security_groups  = [aws_security_group.ecs_task.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 80
  }
}

# Spot Fargate
resource "aws_ecs_service" "app_spot" {
  name            = "app-service-spot"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 4

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets         = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
    security_groups = [aws_security_group.ecs_task.id]
  }
}
```

主要リソース：
- `aws_ecs_task_definition`（requires_compatibilities: FARGATE）
- `aws_ecs_service`（launch_type: FARGATE）
- `capacity_provider`：FARGATE / FARGATE_SPOT
