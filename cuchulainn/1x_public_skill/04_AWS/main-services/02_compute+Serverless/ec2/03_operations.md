# Amazon EC2：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **Systems Manager Session Manager**：SSH不要でEC2接続
- **CloudWatch監視**：CPU/メモリ/ディスク使用率
- **AMI作成**：バックアップ、スケールアウト用テンプレート
- **インスタンスタイプ変更**：停止→変更→起動

## よくあるトラブル
### トラブル1：EC2にSSH接続できない
- 症状：`ssh: connect to host xxx port 22: Connection timed out`
- 原因：
  - Security Groupで22番ポートが開放されていない
  - パブリックIPが割り当てられていない（Publicサブネット）
  - キーペアが間違っている
  - NACLでブロックされている
- 確認ポイント：
  - Security Groupで自分のIPから22番ポート許可
  - EC2のパブリックIP確認
  - キーペアの権限確認（`chmod 400 keypair.pem`）
  - NACLの設定確認

### トラブル2：ディスク容量不足
- 症状：`No space left on device`エラー
- 原因：
  - ルートボリュームが満杯
  - ログファイルの肥大化
  - 不要なファイルの蓄積
- 確認ポイント：
  - `df -h` でディスク使用率確認
  - `du -sh /*` で大きなディレクトリ特定
  - ログローテーション設定確認
  - EBSボリューム拡張検討

### トラブル3：インスタンスが起動しない（Status Check失敗）
- 症状：Status Check 1/2 または 2/2 が失敗
- 原因：
  - AMI破損
  - カーネルパニック
  - ネットワーク設定ミス
  - EBSボリューム障害
- 確認ポイント：
  - System Log確認（マネコン→Actions→Instance Settings→Get System Log）
  - 別のAZで起動テスト
  - AMIから新規インスタンス起動
  - EBSスナップショットから復旧

## 監視・ログ
- **CloudWatch Metrics（基本）**：
  - `CPUUtilization`：CPU使用率
  - `NetworkIn / NetworkOut`：ネットワーク転送量
  - `DiskReadBytes / DiskWriteBytes`：ディスクI/O
  - `StatusCheckFailed`：ヘルスチェック
- **CloudWatch Metrics（詳細）**：
  - メモリ使用率、ディスク使用率（CloudWatch Agent必要）
- **CloudWatch Logs**：
  - `/var/log/messages`、アプリケーションログ
- **Systems Manager**：
  - インベントリ収集
  - パッチ適用状況

## コストでハマりやすい点
- **インスタンス課金**：
  - 停止中は課金停止（EBSは課金継続）
  - 終了で課金完全停止
- **インスタンスタイプ選定ミス**：
  - 過剰スペック（t3.xlarge → t3.micro で月$60削減）
  - リザーブドインスタンス（1年契約で40%削減）
- **Elastic IP未使用**：EC2に関連付けていないEIPは課金（$0.005/h）
- **EBS削除忘れ**：EC2終了時にEBSも削除するか設定
- **スポットインスタンス活用**：最大90%削減（中断可能なワークロード）
- **コスト削減策**：
  - 開発環境は営業時間外に停止
  - Compute Savings Plans
  - Auto Scaling で無駄な起動を削減

## 実務Tips
- **Privateサブネット配置推奨**：セキュリティ強化
- **IAM Role必須**：アクセスキーをEC2に保存しない
- **Systems Manager Session Manager**：SSHポート開放不要
- **User Data活用**：起動時のソフトウェアインストール自動化
- **タグ付けルール**：Name、Environment、Project、Owner タグ
- **AMI定期作成**：バックアップ、スケールアウト用
- **CloudWatch Agent**：メモリ・ディスク監視
- **パッチ管理**：Systems Manager Patch Manager
- **起動テンプレート使用**：バージョン管理、Auto Scaling統一
- **インスタンスタイプ選定**：
  - **汎用**：t3（バースト）、m5（バランス）
  - **コンピューティング最適化**：c5（CPU集約）
  - **メモリ最適化**：r5（メモリ集約）
  - **ストレージ最適化**：i3（高IOPS）
- **停止 vs 終了**：
  - **停止**：EBS保持、再起動可能、EBS課金継続
  - **終了**：EBS削除（設定による）、再起動不可、課金停止
- **設計時に言語化すると評価が上がるポイント**：
  - 「Privateサブネット配置でセキュリティ強化、Systems Manager経由で接続」
  - 「Multi-AZ構成でEC2を複数AZに分散、単一AZ障害に対応」
  - 「Auto Scalingで負荷に応じて自動増減、コスト最適化」
  - 「リザーブドインスタンスで1年契約、40%コスト削減」
  - 「スポットインスタンスでバッチ処理、最大90%コスト削減」
  - 「IAM Roleでアクセスキー不要、セキュリティリスク削減」
  - 「CloudWatch Agent でメモリ・ディスク監視、詳細メトリクス収集」
  - 「AMI定期作成でバックアップ、ディザスタリカバリ対策」

## インスタンスタイプの選び方

| 用途 | インスタンスタイプ | 特徴 |
|------|------------------|------|
| 汎用・開発 | t3.micro / t3.small | バースト性能、低コスト |
| 汎用・本番 | m5.large / m5.xlarge | バランス型 |
| Webサーバー | t3.medium / c5.large | CPU重視 |
| APサーバー | m5.xlarge / r5.large | メモリ重視 |
| DB | r5.xlarge〜 | メモリ・ディスクI/O重視 |
| バッチ処理 | c5.xlarge / スポット | CPU重視、コスト削減 |
| 機械学習 | p3 / g4dn | GPU |
