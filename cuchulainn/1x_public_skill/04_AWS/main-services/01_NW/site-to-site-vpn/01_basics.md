# Site-to-Site VPN：まずこれだけ（Lv1）

## このサービスの一言説明
- Site-to-Site VPN は「**オンプレミスとAWSをインターネット経由で暗号化接続する**」サービス

## ゴール（ここまでできたら合格）
- Site-to-Site VPNを **作成できる**
- **Direct Connectとの違いを説明できる**
- 「このユースケースにはSite-to-Site VPNが必要」と判断できる

## まず覚えること（最小セット）
- **Site-to-Site VPN**：オンプレ ↔ AWS間のIPsec VPN接続
- **Virtual Private Gateway (VGW)**：VPC側のVPNエンドポイント
- **Customer Gateway (CGW)**：オンプレ側のVPN機器情報
- **VPN Connection**：VGWとCGWを接続するVPNトンネル
- **冗長構成**：2つのトンネルが自動作成される（Active/Standby）

## できるようになること
- □ マネジメントコンソールでSite-to-Site VPNを作成できる
- □ Customer Gatewayの設定をダウンロードできる
- □ オンプレ側ルーターでVPN設定ができる
- □ VPNトンネルの状態を確認できる

## まずやること（Hands-on）
- Customer Gatewayを作成（オンプレ側ルーターのパブリックIP）
- Virtual Private Gatewayを作成してVPCにアタッチ
- VPN Connectionを作成
- 設定ファイルをダウンロードしてオンプレ側ルーターに設定
- VPNトンネル状態確認（UP）

## 関連するAWSサービス（名前だけ）
- **VPC / VGW**：VPN接続先
- **Transit Gateway**：複数VPC接続のハブ
- **Direct Connect**：専用線接続（Site-to-Site VPNのバックアップ）
- **CloudWatch**：VPNトンネル状態監視
- **Route 53 Resolver**：オンプレ ↔ VPC間DNS解決
