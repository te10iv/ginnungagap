# Amazon ECS：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **ECR**：コンテナイメージ
  - **VPC + Subnet**：タスク配置場所
  - **IAM Role**：タスク実行ロール・タスクロール
  - **ALB / NLB**：ロードバランサー
  - **CloudWatch Logs**：ログ記録

## 内部的な仕組み（ざっくり）
- **なぜECSが必要なのか**：コンテナオーケストレーション、自動回復、スケーリング
- **起動タイプ**：
  - **Fargate**：サーバーレス、AWS管理、推奨
  - **EC2**：自前管理、より細かい制御
- **タスク定義**：コンテナ設定のテンプレート（イメージ、CPU、メモリ、環境変数等）
- **サービス**：希望タスク数を維持、ALB連携、Auto Scaling
- **制約**：
  - Fargate：最大4vCPU、30GB
  - EC2：インスタンスリソース内

## よくある構成パターン
### パターン1：Fargate + ALB（基本構成）
- 構成概要：
  - ECSクラスター（Fargate）
  - タスク定義（ECRイメージ）
  - サービス（希望タスク数2、ALB連携）
  - ALB（Publicサブネット）
  - タスク（Privateサブネット）
- 使う場面：コンテナアプリケーション基本構成

### パターン2：Auto Scaling統合
- 構成概要：
  - ECSサービス（最小2、希望3、最大10）
  - ターゲット追跡スケーリング（CPU 70%）
  - ALBリクエスト数でスケール
- 使う場面：負荷変動が大きいシステム

### パターン3：マイクロサービス構成
- 構成概要：
  - 複数のタスク定義（API、Web、Worker等）
  - 各サービスで独立してスケール
  - Service Discoveryで内部通信
- 使う場面：マイクロサービスアーキテクチャ

### パターン4：バッチ処理
- 構成概要：
  - ECSタスク（サービスではなく単発実行）
  - EventBridgeでスケジュール実行
  - 完了後自動停止
- 使う場面：定期バッチ、非同期処理

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：複数AZにタスク分散、最小タスク数 ≧ 2
- **セキュリティ**：
  - Privateサブネット配置
  - タスクロールで最小権限
  - Secrets Managerで機密情報管理
- **コスト**：
  - Fargate：CPU/メモリの従量課金
  - EC2：インスタンス課金（リザーブド活用）
  - Spot Fargate活用（最大70%削減）
- **拡張性**：Auto Scaling、ターゲット追跡

## 他サービスとの関係
- **ECR との関係**：タスク定義でイメージ指定
- **ALB との関係**：ターゲットグループに動的登録
- **CloudWatch との関係**：メトリクス監視、ログ記録
- **Service Discovery との関係**：マイクロサービス間通信
- **App Mesh との関係**：サービスメッシュ、高度な通信制御

## Terraformで見るとどうなる？
```hcl
# ECSクラスター
resource "aws_ecs_cluster" "main" {
  name = "main-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# タスク定義
resource "aws_ecs_task_definition" "app" {
  family                   = "app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
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
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = "ap-northeast-1"
        "awslogs-stream-prefix" = "app"
      }
    }

    environment = [{
      name  = "ENV"
      value = "production"
    }]
  }])
}

# ECSサービス
resource "aws_ecs_service" "app" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
    security_groups = [aws_security_group.ecs_task.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}

# Auto Scaling
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
```

主要リソース：
- `aws_ecs_cluster`：ECSクラスター
- `aws_ecs_task_definition`：タスク定義
- `aws_ecs_service`：サービス
- `aws_appautoscaling_target` / `_policy`：Auto Scaling
