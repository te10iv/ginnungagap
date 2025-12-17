# AWS Auto Scaling：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **起動テンプレート / 起動設定**：EC2設定
  - **VPC + Subnet**：インスタンス配置場所
  - **CloudWatch**：メトリクス監視
  - **ALB / NLB**：ターゲットグループ連携

## 内部的な仕組み（ざっくり）
- **なぜAuto Scalingが必要なのか**：負荷変動対応、可用性確保、コスト最適化
- **ヘルスチェック**：EC2ステータス or ELBヘルスチェック
- **スケーリングポリシー**：
  - ターゲット追跡：メトリクス目標値維持
  - ステップスケーリング：閾値ごとに段階的
  - スケジュール：時間指定
- **クールダウン期間**：スケール後の待機時間（デフォルト300秒）
- **制約**：
  - リージョン・AZ単位
  - 最大台数上限あり

## よくある構成パターン
### パターン1：基本的なWebアプリ構成
- 構成概要：
  - ALB（Publicサブネット）
  - Auto Scaling Group（Privateサブネット、2AZ）
  - 最小2、希望3、最大10
  - ターゲット追跡（CPU 70%）
- 使う場面：Webアプリケーション、標準構成

### パターン2：時間帯別スケジュール
- 構成概要：
  - 営業時間（9:00-18:00）：最小5台
  - 夜間（18:00-9:00）：最小2台
  - スケジュールスケーリング
- 使う場面：業務システム、アクセスパターンが明確

### パターン3：マルチAZ高可用性
- 構成概要：
  - 3つのAZに分散
  - 最小台数 = AZ数（各AZに最低1台確保）
  - ヘルスチェック：ELB
- 使う場面：本番環境、高可用性要件

### パターン4：スポットインスタンス併用
- 構成概要：
  - オンデマンド：2台（最小保証）
  - スポット：0〜8台（コスト削減）
  - Spot Fleet活用
- 使う場面：コスト最優先、中断許容

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：複数AZに分散、最小台数 ≧ AZ数
- **セキュリティ**：Privateサブネット配置、Security Group設計
- **コスト**：
  - 最小台数は必要最小限
  - スポットインスタンス活用
  - スケールインポリシー
- **拡張性**：最大台数の設計、段階的スケール

## 他サービスとの関係
- **ALB との関係**：ターゲットグループに自動登録/削除
- **CloudWatch との関係**：メトリクス監視、スケーリングトリガー
- **EC2 との関係**：起動テンプレートで統一設定
- **EBS との関係**：ルートボリューム設定、終了時削除

## Terraformで見るとどうなる？
```hcl
# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "web-asg"
  vpc_zone_identifier = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 2
  desired_capacity = 3
  max_size         = 10

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-server-asg"
    propagate_at_launch = true
  }
}

# ターゲット追跡スケーリングポリシー
resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "target-tracking-cpu"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# スケジュールスケーリング（営業時間）
resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name  = "scale-up-business-hours"
  min_size               = 5
  max_size               = 10
  desired_capacity       = 5
  recurrence             = "0 9 * * MON-FRI"  # 平日9:00
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# スケジュールスケーリング（夜間）
resource "aws_autoscaling_schedule" "scale_down" {
  scheduled_action_name  = "scale-down-night"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 18 * * MON-FRI"  # 平日18:00
  autoscaling_group_name = aws_autoscaling_group.web.name
}
```

主要リソース：
- `aws_autoscaling_group`：Auto Scaling Group
- `aws_launch_template`：起動テンプレート
- `aws_autoscaling_policy`：スケーリングポリシー
- `aws_autoscaling_schedule`：スケジュールスケーリング
