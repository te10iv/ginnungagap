# EBSボリュームを作成し、EC2インスタンスにアタッチします。

variable "instance_id" {
  description = "EC2 Instance ID"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
}

resource "aws_ebs_volume" "my_ebs_volume" {
  availability_zone = var.availability_zone
  size              = 10
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "my-ebs-volume"
  }
}

resource "aws_volume_attachment" "ebs_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.my_ebs_volume.id
  instance_id = var.instance_id
}

output "volume_id" {
  description = "EBS Volume ID"
  value       = aws_ebs_volume.my_ebs_volume.id
}
