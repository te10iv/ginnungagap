# EC2インスタンスを起動し、基本的なWebサーバーとして使用できるようにします。

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Public Subnet ID"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 Key Pair Name"
  type        = string
}

resource "aws_security_group" "my_sg" {
  name        = "my-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "my-sg"
  }
}

resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0c3fd0f5d33134a76" # Amazon Linux 2023 (ap-northeast-1)
  instance_type = "t3.micro"
  key_name      = var.key_pair_name
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.my_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "my-ec2-instance"
  }
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.my_ec2_instance.id
}

output "public_ip" {
  description = "Public IP Address"
  value       = aws_instance.my_ec2_instance.public_ip
}
