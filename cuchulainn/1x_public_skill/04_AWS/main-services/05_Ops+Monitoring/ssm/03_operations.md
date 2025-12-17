# AWS Systems Manager（SSM）：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **Session Manager**：SSH不要アクセス
- **Run Command**：一括コマンド実行
- **Parameter Store**：設定管理
- **Patch Manager**：自動パッチ適用

## よくあるトラブル
### トラブル1：Session Managerで接続できない
- 症状：「We couldn't start the session」エラー
- 原因：
  - IAMロール未アタッチ
  - SSMエージェント停止
  - アウトバウンド通信不可（HTTPS:443）
  - VPCエンドポイント未設定（Private Subnet）
- 確認ポイント：
  - IAMロール `AmazonSSMManagedInstanceCore` アタッチ確認
  - SSMエージェントステータス確認：`sudo systemctl status amazon-ssm-agent`
  - セキュリティグループでHTTPS:443アウトバウンド許可
  - Private SubnetならVPCエンドポイント設定（ssm、ssmmessages、ec2messages）

### トラブル2：Parameter Store値が取得できない
- 症状：アプリケーション起動エラー
- 原因：
  - IAM権限不足
  - KMS復号化権限不足（SecureString）
  - パラメータ名ミス
- 確認ポイント：
  - IAMロールで `ssm:GetParameter` 許可
  - KMSキー使用権限確認
  - パラメータ名確認（/myapp/db/password）

### トラブル3：Patch Manager適用失敗
- 症状：パッチが適用されない
- 原因：
  - Maintenance Window時間外
  - ターゲット設定ミス
  - IAMロール権限不足
- 確認ポイント：
  - Maintenance Window時間確認
  - ターゲットタグ確認
  - SSMサービスロール確認

## 監視・ログ
- **Session Manager**：
  - CloudWatch Logs：セッションログ
  - S3：セッション記録
  - CloudTrail：接続履歴
- **Run Command**：
  - コマンド履歴
  - 実行結果（S3保存可）
- **Patch Manager**：
  - コンプライアンス状態
  - パッチ適用履歴

## コストでハマりやすい点
- **Parameter Store**：
  - Standard：無料（最大4KB、スループット標準）
  - Advanced：$0.05/パラメータ/月（最大8KB、高スループット）
  - API呼び出し：Standard無料、Advanced課金あり
- **その他機能**：
  - Session Manager：無料
  - Run Command：無料
  - Patch Manager：無料
  - Automation：無料
- **CloudWatch Logs**：ログ保存料（オプション）
- **S3**：出力保存料（オプション）
- **コスト削減策**：
  - Parameter Store：Standard推奨
  - 不要なAdvancedパラメータ削除

## 実務Tips
- **Session Manager推奨**：SSH鍵管理不要、セキュア
- **CloudWatch Logs統合**：セッションログ記録必須
- **Private Subnet + VPCエンドポイント**：
  - `com.amazonaws.region.ssm`
  - `com.amazonaws.region.ssmmessages`
  - `com.amazonaws.region.ec2messages`
- **IAMロール設計**：
  - EC2：`AmazonSSMManagedInstanceCore`
  - カスタムポリシー：最小権限
- **Run Command活用**：
  - タグでターゲット指定
  - S3に出力保存
  - CloudWatch Events連携
- **Parameter Store vs Secrets Manager**：
  - Parameter Store：設定値、DB接続先等
  - Secrets Manager：パスワード、APIキー（自動ローテーション）
- **Patch Manager**：
  - Maintenance Window設定
  - パッチベースライン（承認ルール）
  - コンプライアンス監視
- **設計時に言語化すると評価が上がるポイント**：
  - 「Session ManagerでSSH不要、IAM認証でセキュアアクセス、CloudTrail記録」
  - 「Private Subnet + VPCエンドポイントでインターネット経由不要、セキュリティ強化」
  - 「Run Commandで複数サーバーに一括コマンド、タグ指定で柔軟な運用」
  - 「Parameter StoreでDB接続情報の中央管理、KMS暗号化」
  - 「Patch Managerで自動パッチ適用、Maintenance Window設定で計画的運用」
  - 「CloudWatch Logsでセッションログ記録、監査証跡確保」

## Session Manager接続手順

### AWSマネジメントコンソール
1. EC2 → インスタンス選択
2. 「接続」ボタン → 「Session Manager」タブ
3. 「接続」クリック

### AWS CLI
```bash
# Session Manager接続
aws ssm start-session --target i-0123456789abcdef

# ポートフォワーディング（RDS接続等）
aws ssm start-session \
  --target i-0123456789abcdef \
  --document-name AWS-StartPortForwardingSession \
  --parameters "portNumber=3306,localPortNumber=3306"

# SCP風ファイル転送
aws ssm start-session \
  --target i-0123456789abcdef \
  --document-name AWS-StartSSHSession
```

## Run Command実行例

### AWS CLI
```bash
# シェルコマンド実行
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=tag:Environment,Values=production" \
  --parameters 'commands=["df -h","free -m"]' \
  --output-s3-bucket-name "my-command-outputs" \
  --output-s3-key-prefix "run-command/"

# コマンド実行状態確認
aws ssm list-command-invocations \
  --command-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# コマンド出力取得
aws ssm get-command-invocation \
  --command-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
  --instance-id i-0123456789abcdef
```

## Parameter Store操作

### パラメータ作成
```bash
# String
aws ssm put-parameter \
  --name "/myapp/db/host" \
  --value "db.example.com" \
  --type "String"

# SecureString（KMS暗号化）
aws ssm put-parameter \
  --name "/myapp/db/password" \
  --value "MySecurePassword123!" \
  --type "SecureString" \
  --key-id "alias/aws/ssm"

# StringList
aws ssm put-parameter \
  --name "/myapp/allowed-ips" \
  --value "10.0.0.1,10.0.0.2,10.0.0.3" \
  --type "StringList"
```

### パラメータ取得
```bash
# 単一パラメータ取得
aws ssm get-parameter \
  --name "/myapp/db/host"

# 複号化して取得（SecureString）
aws ssm get-parameter \
  --name "/myapp/db/password" \
  --with-decryption

# パス配下のパラメータ一括取得
aws ssm get-parameters-by-path \
  --path "/myapp/" \
  --recursive \
  --with-decryption
```

### アプリケーションからの取得例（Python）
```python
import boto3

ssm = boto3.client('ssm')

# パラメータ取得
response = ssm.get_parameter(
    Name='/myapp/db/host',
    WithDecryption=True
)
db_host = response['Parameter']['Value']

# 複数パラメータ一括取得
response = ssm.get_parameters_by_path(
    Path='/myapp/',
    Recursive=True,
    WithDecryption=True
)
params = {p['Name']: p['Value'] for p in response['Parameters']}
```

## VPCエンドポイント設定（Private Subnet用）

```hcl
# SSMエンドポイント
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

# SSM Messagesエンドポイント
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

# EC2 Messagesエンドポイント
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

# VPCエンドポイント用セキュリティグループ
resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Patch Manager設定例

```hcl
# パッチベースライン（Amazon Linux 2）
resource "aws_ssm_patch_baseline" "production" {
  name             = "production-baseline"
  operating_system = "AMAZON_LINUX_2"

  approval_rule {
    approve_after_days = 7  # リリース後7日で自動承認

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Bugfix"]
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }

  tags = {
    Name = "production-baseline"
  }
}

# パッチグループ
resource "aws_ssm_patch_group" "production" {
  baseline_id = aws_ssm_patch_baseline.production.id
  patch_group = "production"
}
```

## Session Manager vs SSH

| 項目 | Session Manager | SSH |
|------|----------------|-----|
| 認証 | IAM | SSH鍵 |
| 鍵管理 | 不要 | 必要 |
| 監査ログ | CloudTrail | syslog |
| セッションログ | CloudWatch Logs | なし |
| ポート開放 | 不要（HTTPS:443アウトバウンドのみ） | 22番ポート |
| 踏み台サーバー | 不要 | 必要（Private Subnet） |
| コスト | 無料 | 踏み台サーバーコスト |

## Parameter Store vs Secrets Manager

| 項目 | Parameter Store | Secrets Manager |
|------|----------------|----------------|
| 用途 | 設定値 | パスワード、APIキー |
| 料金 | Standard無料 | $0.40/シークレット/月 |
| ローテーション | 手動 | 自動（RDS統合） |
| 最大サイズ | 8KB（Advanced） | 64KB |
| バージョニング | あり | あり |
| 推奨用途 | DB接続先、設定値 | DB パスワード、APIキー |
