# AWS Transit Gateway：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS Transit Gateway は「**複数のVPCとオンプレミスを中央ハブで接続するネットワークハブ**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- Transit Gatewayを **作成できる**
- **VPC Peeringとの違いを説明できる**
- 「複数VPC接続にはこれが必要」と判断できる

## まず覚えること（最小セット）
- **Transit Gateway（TGW）**：複数VPC・オンプレを接続する中央ハブ
- **アタッチメント**：VPC・VPN・Direct Connectとの接続単位
- **ルートテーブル**：TGW内の通信経路制御
- **スケーラビリティ**：数千のVPC接続可能
- **リージョン間接続**：TGW Peeringで複数リージョン接続

## できるようになること
- □ マネジメントコンソールでTransit Gatewayを作成できる
- □ VPCアタッチメントを作成できる
- □ TGWルートテーブルを設定できる
- □ VPC側のルートテーブルにTGW向けルートを追加できる

## まずやること（Hands-on）
- Transit Gatewayを作成
- 2つのVPCアタッチメントを作成
- TGWルートテーブルで相互通信許可
- 各VPCのルートテーブルに他VPC向けルートをTGW経由に設定
- EC2間で疎通確認

## 関連するAWSサービス（名前だけ）
- **VPC**：TGWにアタッチするネットワーク
- **Direct Connect / Site-to-Site VPN**：オンプレミス接続
- **Route 53 Resolver**：VPC間DNS解決
- **Network Manager**：TGWのグローバル管理・可視化
- **RAM（Resource Access Manager）**：TGWを他AWSアカウントと共有
