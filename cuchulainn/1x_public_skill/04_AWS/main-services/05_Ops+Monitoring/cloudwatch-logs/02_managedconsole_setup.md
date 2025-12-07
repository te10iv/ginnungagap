# CloudWatch Logs マネージドコンソールでのセットアップ

## 作成するもの

CloudWatch Logsのロググループを作成し、EC2インスタンスからアプリケーションログを送信します。ログを集約して監視できるようにします。

## セットアップ手順

1. **CloudWatch Logsコンソールを開く**
   - CloudWatchコンソールで「ログ」→「ロググループ」を選択

2. **ロググループを作成**
   - 「ロググループを作成」をクリック
   - **ロググループ名**: `/aws/ec2/my-app` を入力
   - **保持期間**: 7日間を選択
   - 「ロググループを作成」をクリック

3. **CloudWatch Logsエージェントを設定（EC2インスタンス内で実行）**
   - EC2インスタンスにSSH接続
   - 以下のコマンドを実行：
   ```bash
   # CloudWatch Logsエージェントをインストール
   sudo yum install -y amazon-cloudwatch-agent
   
   # 設定ファイルを作成
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
   ```
   - ウィザードに従って設定（ログファイルのパス、ロググループ名などを指定）

4. **エージェントを起動**
   ```bash
   sudo systemctl start amazon-cloudwatch-agent
   sudo systemctl enable amazon-cloudwatch-agent
   ```

5. **ログを確認**
   - CloudWatch Logsコンソールでログストリームを確認

## 補足

- IAMロールでEC2インスタンスにCloudWatch Logsへの書き込み権限を付与する必要があります
- ログインサイトでリアルタイムにログを監視できます

