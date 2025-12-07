# SSM Session Managerを設定し、EC2インスタンスにSSH接続なしでアクセスできるようにします。

resource "aws_iam_role" "ssm_instance_role" {
  name = "SSMInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_instance_role.name
}

output "instance_profile_name" {
  description = "IAM Instance Profile Name"
  value       = aws_iam_instance_profile.ssm_instance_profile.name
}
