# senario

## Step1


ステップ	ゴール / 構成イメージ	主な AWS サービス
------------------------------------------------
1	VPC + EC2 1台（超最小構成）	★VPC, ★EC2, ★IAM, ★Security Group, ★SSM ★apacheでwebページ表示


## 構成図（完成イメージ）


## 成果物



## 補足情報（パラメータ）

### IP Addressing

VPC（10.0.0.0/16）

Public Subnet（ALB 用）
10.0.1.0/24（ap-northeast-1a）
10.0.2.0/24（ap-northeast-1c）

Private-App Subnet（Fargate 用）
10.0.11.0/24（1a）
10.0.12.0/24（1c）

Private-DB Subnet（RDS 用）
10.0.21.0/24（1a）
10.0.22.0/24（1c）
