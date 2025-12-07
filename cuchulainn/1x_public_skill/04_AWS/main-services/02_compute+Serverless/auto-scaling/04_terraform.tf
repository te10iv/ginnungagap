# Auto Scalingグループを作成し、EC2インスタンス数を自動的にスケールします。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "key_pair_name" {
  description = "EC2 Key Pair Name"
  type        = string
}

variable "target_group_arn" {
  description = "Target Group ARN"
  type        = string
}

resource "aws_security_group" "asg_sg" {
  name        = "asg-sg"
  description = "Security group for Auto Scaling Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asg-sg"
  }
}

resource "aws_launch_template" "my_launch_template" {
  name          = "my-launch-template"
  image_id      = "ami-0c3fd0f5d33134a76" # Amazon Linux 2023
  instance_type = "t3.micro"
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "asg-instance"
    }
  }
}

resource "aws_autoscaling_group" "my_asg" {
  name                = "my-asg"
  vpc_zone_identifier  = var.subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "target_tracking_policy" {
  name                   = "target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group Name"
  value       = aws_autoscaling_group.my_asg.name
}
