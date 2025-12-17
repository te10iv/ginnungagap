# AWS Control Tower：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS Control Tower は「**マルチアカウント環境のセットアップと統制を自動化**」するAWSサービス

## ゴール（ここまでできたら合格）
- Landing Zoneを **セットアップできる**
- **Account Factoryでアカウント作成できる**
- 「マルチアカウントガバナンスにはControl Towerが便利」と判断できる

## まず覚えること（最小セット）
- **Landing Zone**：マルチアカウント環境の基盤
- **Account Factory**：標準化されたアカウント作成
- **ガードレール**：統制ルール（予防的/検出的）
- **OU（組織単位）**：アカウントのグループ
- **ベースライン**：自動設定（CloudTrail、Config等）

## できるようになること
- □ Landing Zoneをセットアップできる
- □ Account Factoryでアカウント作成できる
- □ ガードレールを有効化できる
- □ ダッシュボードでコンプライアンス確認できる

## まずやること（Hands-on）
- Control Tower有効化（Landing Zoneセットアップ）
- Account Factoryでアカウント作成
- ガードレール確認

## 関連するAWSサービス（名前だけ）
- **Organizations**：組織管理
- **SSO**：シングルサインオン
- **CloudTrail**：組織ログ
- **Config**：組織ルール
- **Service Catalog**：Account Factory
