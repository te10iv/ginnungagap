# NAT Gateway：まずこれだけ（Lv1）

## このサービスの一言説明
- NAT Gateway は「**Privateサブネットからインターネットへの片方向接続**」を提供するAWSサービス

## ゴール（ここまでできたら合格）
- NAT Gatewayを **作成できる**
- **NAT Gatewayの役割を説明できる**
- 「Privateサブネットにはこれが必要」と判断できる

## まず覚えること（最小セット）
- **NAT Gateway**：プライベートIPをパブリックIPに変換してインターネット接続
- **配置場所**：Publicサブネットに配置（IGW経由で通信）
- **Elastic IP**：NAT Gatewayには固定パブリックIPが必要
- **片方向通信**：アウトバウンドのみ（インバウンド接続は不可）
- **マネージドサービス**：AWS管理で自動スケール・冗長化

## できるようになること
- □ マネジメントコンソールでNAT Gatewayを作成できる
- □ Elastic IPを割り当てられる
- □ Privateサブネットのルートテーブルに設定できる
- □ PrivateサブネットのEC2からインターネット疎通確認できる

## まずやること（Hands-on）
- Elastic IPを1つ割り当て
- マネコンでNAT GatewayをPublicサブネットに作成
- Privateサブネットのルートテーブルに 0.0.0.0/0 → NAT Gateway を設定
- PrivateサブネットのEC2から curl でインターネット疎通確認

## 関連するAWSサービス（名前だけ）
- **Elastic IP**：NAT Gatewayに必須
- **Public Subnet**：NAT Gatewayの配置場所
- **Internet Gateway**：NAT Gatewayの通信に必要
- **Route Table**：Privateサブネットから0.0.0.0/0向けのルート設定
- **VPC Endpoint**：NAT Gateway不要でAWSサービスにアクセス（コスト削減）
