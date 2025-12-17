# Amazon EC2：まずこれだけ（Lv1）

## このサービスの一言説明
- Amazon EC2 は「**クラウド上の仮想サーバー**」を提供するAWSの中核サービス

## ゴール（ここまでできたら合格）
- EC2インスタンスを **起動できる**
- **インスタンスタイプとAMIの役割を説明できる**
- 「このシステムにはEC2が必要」と判断できる

## まず覚えること（最小セット）
- **EC2インスタンス**：仮想サーバー
- **AMI（Amazon Machine Image）**：OSとソフトウェアのテンプレート
- **インスタンスタイプ**：CPU/メモリ/ネットワークのスペック（例：t3.micro, m5.large）
- **Security Group**：インスタンスレベルのファイアウォール
- **キーペア**：SSH接続用の秘密鍵・公開鍵

## できるようになること
- □ マネジメントコンソールでEC2を起動できる
- □ SSH/RDPで接続できる
- □ インスタンスの起動・停止・終了ができる
- □ Security Groupでポート開放ができる

## まずやること（Hands-on）
- マネコンでEC2を起動（Amazon Linux 2、t3.micro）
- キーペアを作成してダウンロード
- Security Groupで22番ポート（SSH）開放
- SSH接続（`ssh -i keypair.pem ec2-user@[Public IP]`）
- Webサーバー起動（`sudo yum install httpd && sudo systemctl start httpd`）

## 関連するAWSサービス（名前だけ）
- **VPC / Subnet**：EC2の配置場所
- **EBS**：EC2のストレージ（ルートボリューム・追加ボリューム）
- **Elastic IP**：固定パブリックIP
- **ALB / NLB**：複数EC2への負荷分散
- **Auto Scaling**：EC2の自動増減
- **IAM Role**：EC2に権限を付与
