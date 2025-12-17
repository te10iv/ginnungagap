# AWS Systems Manager（SSM）：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS Systems Manager（SSM）は「**EC2・オンプレサーバーの管理・運用**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- Session Managerで **EC2にSSH不要でアクセスできる**
- **Run Commandでコマンド実行できる**
- 「サーバー運用にはSSMが必要」と判断できる

## まず覚えること（最小セット）
- **Session Manager**：SSH不要、ブラウザからサーバー接続
- **Run Command**：複数サーバーに一括コマンド実行
- **Parameter Store**：設定値・秘密情報の保存
- **Patch Manager**：自動パッチ適用
- **SSMエージェント**：EC2にインストール（Amazon Linux 2はプリインストール）

## できるようになること
- □ Session ManagerでEC2に接続できる
- □ Run Commandでコマンド実行できる
- □ Parameter Storeに値を保存・取得できる
- □ Patch Managerでパッチ適用できる

## まずやること（Hands-on）
- IAMロール作成（AmazonSSMManagedInstanceCore）
- EC2にIAMロールアタッチ
- Session ManagerでEC2接続
- Run Commandでコマンド実行（例：`df -h`）

## 関連するAWSサービス（名前だけ）
- **EC2**：管理対象
- **IAM**：アクセス制御
- **CloudWatch**：ログ保存
- **S3**：コマンド出力保存
- **EventBridge**：自動化トリガー
