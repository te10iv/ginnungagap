# NAT Gateway：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **削除と再作成**：コスト削減のため非稼働時間に削除（開発環境）
- **CloudWatch メトリクス監視**：BytesOutToDestination、PacketsDropCount
- **Elastic IP の管理**：NAT Gateway削除時にEIPも解放（課金対策）

## よくあるトラブル
### トラブル1：Privateサブネットからインターネット接続できない
- 症状：PrivateサブネットのEC2から curl や yum update ができない
- 原因：
  - NAT GatewayがPublicサブネットに配置されていない
  - NAT GatewayのElastic IPが割り当てられていない
  - Privateルートテーブルに 0.0.0.0/0 → NAT Gateway のルートがない
  - NAT Gatewayの状態が「available」でない
  - PublicサブネットのルートテーブルにIGWへのルートがない
- 確認ポイント：
  - NAT Gatewayの状態確認（マネコンで「available」）
  - NAT GatewayがPublicサブネットに配置されているか
  - Elastic IP割り当て確認
  - Privateルートテーブルで 0.0.0.0/0 → nat-xxxxx を確認
  - Publicルートテーブルで 0.0.0.0/0 → igw-xxxxx を確認

### トラブル2：AZ障害でPrivateサブネット全滅
- 症状：1つのAZが障害時に全PrivateサブネットがInternet接続不可
- 原因：シングルNAT Gateway構成（1つのAZにのみ配置）
- 確認ポイント：
  - NAT Gateway配置AZの確認
  - 各AZのPrivateサブネットのルートテーブル確認
- 対策：各AZにNAT Gatewayを配置（Multi-AZ構成）

### トラブル3：予想外の高額課金
- 症状：月末に予想外のNAT Gateway課金（$100以上）
- 原因：
  - NAT Gateway削除忘れ（時間課金 $0.062/h → 月$45）
  - データ転送量が多い（$0.062/GB）
  - 複数のNAT Gatewayを稼働（Multi-AZ構成で2倍）
- 確認ポイント：
  - Cost Explorerで「NAT Gateway」でフィルタ
  - CloudWatchでBytesOutToDestinationを確認
  - 不要なNAT Gatewayの削除
  - VPCエンドポイント活用検討

## 監視・ログ
- **CloudWatch Metrics**（重要）：
  - `BytesInFromDestination`：インターネットから受信
  - `BytesOutToDestination`：インターネットへ送信（課金対象）
  - `PacketsDropCount`：帯域制限によるパケット破棄
  - `ActiveConnectionCount`：アクティブな接続数
- **VPC Flow Logs**：NAT Gateway経由の通信を記録
- **アラート設定**：BytesOutToDestinationが閾値超過時に通知

## コストでハマりやすい点
- **時間課金**：$0.062/時間（月約$45）
- **データ処理課金**：$0.062/GB（送信データ量）
- **Multi-AZ構成**：AZごとにNAT Gateway → 2AZで月$90〜
- **削除忘れ**：開発環境で放置すると月$45の無駄
- **Elastic IP課金**：NAT Gateway削除後もEIPが残ると課金（$0.005/時間）
- **コスト削減策**：
  - VPCエンドポイント活用（S3/DynamoDB/ECR等）
  - 開発環境は非稼働時に削除
  - インスタンスをPrivate配置せずPublicに（セキュリティとトレードオフ）

## 実務Tips
- **Multi-AZ構成が基本**：本番環境は必ず各AZにNAT Gateway配置
- **ルートテーブルの分離**：各AZのPrivateサブネットは同AZのNAT Gatewayを使う
- **VPCエンドポイント優先**：S3/DynamoDB/ECR等はエンドポイント経由でコスト削減
- **開発環境はシングルNAT**：コスト削減のため1つのみ（障害許容）
- **削除時の注意**：NAT Gateway削除 → Elastic IP解放 の順（課金対策）
- **帯域上限**：最大45Gbps（自動スケール）
- **CloudWatch監視必須**：BytesOutToDestinationでコスト監視
- **代替案検討**：
  - NAT Instance（コスト削減、管理負担増）
  - VPCエンドポイント（AWS内通信）
  - Public配置（セキュリティリスク）
- **設計時に言語化すると評価が上がるポイント**：
  - 「Multi-AZ構成で各AZにNAT Gatewayを配置し、AZ障害耐性を確保」
  - 「コスト最適化のため、S3/DynamoDBはVPCエンドポイント経由」
  - 「開発環境はシングルNAT構成でコスト削減（月$45削減）」
  - 「CloudWatchでデータ転送量を監視し、コスト異常を早期検知」
