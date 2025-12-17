# AWS Direct Connect：まずこれだけ（Lv1）

## このサービスの一言説明
- AWS Direct Connect は「**オンプレミスとAWSを専用線で直接接続する**」サービス

## ゴール（ここまでできたら合格）
- Direct Connectの **概要を説明できる**
- **VPN接続との違いを説明できる**
- 「このユースケースにはDirect Connectが必要」と判断できる

## まず覚えること（最小セット）
- **Direct Connect（DX）**：オンプレ ↔ AWS間の専用線接続
- **ロケーション**：AWS Direct Connectロケーション（データセンター）
- **仮想インターフェース（VIF）**：論理接続（Private VIF: VPC、Public VIF: S3/DynamoDB等）
- **専用接続 vs ホスト接続**：1Gbps〜100Gbps（専用）、50Mbps〜10Gbps（ホスト）
- **帯域保証**：インターネット経由と違い、安定した帯域を確保

## できるようになること
- □ Direct Connectの用途を説明できる
- □ 専用接続とホスト接続の違いを説明できる
- □ Private VIF と Public VIF の違いを説明できる
- □ VPN接続との使い分けができる

## まずやること（Hands-on）
※ Direct Connectは物理配線が必要なため、検証環境での構築は困難
- AWSドキュメントでDirect Connect構成図を確認
- ロケーション一覧を確認
- 料金体系（ポート時間 + データ転送）を理解

## 関連するAWSサービス（名前だけ）
- **VPC / VGW（Virtual Private Gateway）**：Private VIF接続先
- **Transit Gateway**：複数VPC接続時のハブ
- **Direct Connect Gateway**：複数リージョンのVPC接続
- **Site-to-Site VPN**：Direct Connectのバックアップ
- **Route 53 Resolver**：オンプレ ↔ VPC間DNS解決
