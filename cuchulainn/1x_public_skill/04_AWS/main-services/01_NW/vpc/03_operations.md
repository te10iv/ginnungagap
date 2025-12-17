# Amazon VPC：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **VPC Flow Logs**：ネットワークトラフィックのログ記録（セキュリティ分析・トラブルシューティング）
- **CIDR追加**：既存VPCにセカンダリCIDRを追加（IPアドレス枯渇対策）
- **VPC Peering / Transit Gateway**：VPC間通信の構築

## よくあるトラブル
### トラブル1：EC2にインターネット接続できない
- 症状：PublicサブネットのEC2からインターネットに出られない
- 原因：
  - Internet Gatewayがアタッチされていない
  - ルートテーブルに0.0.0.0/0 → IGWのルートがない
  - EC2にパブリックIPが割り当てられていない
  - Security Groupでアウトバウンド通信がブロックされている
- 確認ポイント：
  - VPCにIGWがアタッチされているか
  - サブネットのルートテーブル確認
  - EC2のパブリックIP有無
  - Security Groupのアウトバウンドルール

### トラブル2：VPC Peeringで通信できない
- 症状：Peering接続は確立しているのに通信できない
- 原因：
  - 両側のルートテーブルにPeering経由のルートがない
  - Security GroupでソースIPを制限している
  - CIDRブロックが重複している
- 確認ポイント：
  - 双方のVPCでルートテーブル設定を確認
  - Security Groupのインバウンドルール
  - VPCのCIDR範囲が重複していないか

### トラブル3：IPアドレスが足りない
- 症状：新しいリソースを起動できない（IP枯渇）
- 原因：CIDRブロックが小さすぎた（例：/24で256個中251個しか使えない）
- 確認ポイント：
  - サブネットの利用可能IP数を確認
  - セカンダリCIDRの追加を検討
  - 不要なENI・IPの削除

## 監視・ログ
- **VPC Flow Logs**：CloudWatch Logs または S3 に保存
  - Accept/Reject の通信を記録
  - セキュリティ監査、異常通信の検知
- **CloudWatch Metrics**：
  - VPC自体のメトリクスは少ない
  - NAT Gateway の BytesIn/OutToDestination

## コストでハマりやすい点
- **NAT Gateway**：時間課金 + データ転送課金（1AZで月$32〜）
  - Multi-AZだと2倍のコスト
  - 削除忘れで課金継続
- **VPC Flow Logs**：CloudWatch Logs のストレージ料金
  - S3保存の方が安価
  - 不要なログは無効化
- **Elastic IP**：割り当てたまま未使用だと課金
- **使っていないNATゲートウェイ**：削除し忘れ

## 実務Tips
- **CIDR設計は最初が肝心**：後から変更は困難、広めに取る（/16推奨）
- **オンプレとの接続を考慮**：CIDR重複を避ける（10.0.0.0/16は避ける企業も多い）
- **Privateサブネットは必須**：DBやアプリサーバーは必ずPrivateに配置
- **Security GroupとNACLの使い分け**：SG優先、NACLは補助的に
- **タグ付けルール**：Name, Environment, Project タグで管理
- **設計時に言語化すると評価が上がるポイント**：
  - 「Multi-AZ構成で可用性を確保しました」
  - 「CIDR設計は将来の拡張を考慮し/16で設計」
  - 「コスト削減のため開発環境はシングルNAT Gateway」
  - 「セキュリティ要件に応じてPrivateサブネットを3層構成」
