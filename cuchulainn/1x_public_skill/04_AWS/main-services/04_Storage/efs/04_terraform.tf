# EFSファイルシステムを作成し、複数のEC2インスタンスから共有アクセスできるようにします。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs (at least 2 subnets in different AZs)"
  type        = list(string)
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Security group for EFS"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS access"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-sg"
  }
}

resource "aws_efs_file_system" "my_efs" {
  creation_token = "my-efs"
  encrypted      = true

  performance_mode = "generalPurpose"

  tags = {
    Name = "my-efs"
  }
}

resource "aws_efs_mount_target" "mount_target" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.my_efs.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

output "file_system_id" {
  description = "EFS File System ID"
  value       = aws_efs_file_system.my_efs.id
}

output "dns_name" {
  description = "EFS DNS Name"
  value       = aws_efs_file_system.my_efs.dns_name
}
