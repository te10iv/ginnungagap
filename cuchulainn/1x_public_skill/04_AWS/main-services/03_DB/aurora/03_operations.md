# Amazon Aurora：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **フェイルオーバー**：手動または自動（< 30秒）
- **バックトラック**：巻き戻し機能（MySQL互換のみ）
- **クローン作成**：高速コピー（Copy-on-Write）
- **Performance Insights**：クエリ分析

## よくあるトラブル
### トラブル1：接続エラー（Too many connections）
- 症状：「Too many connections」エラー
- 原因：
  - 接続数上限超過
  - Lambda等からの大量接続
  - 接続プールミス
- 確認ポイント：
  - CloudWatch Metricsで接続数確認
  - RDS Proxy導入（接続プーリング）
  - パラメータグループでmax_connections調整

### トラブル2：フェイルオーバーでアプリエラー
- 症状：フェイルオーバー後にアプリケーションエラー
- 原因：
  - Writer Endpointの変更検知遅延
  - アプリの再接続ロジック不足
  - トランザクション中断
- 確認ポイント：
  - アプリで再接続ロジック実装
  - RDS Proxy使用（フェイルオーバー時間短縮）
  - トランザクション再試行

### トラブル3：ストレージI/O課金が高額
- 症状：月末にI/O課金が数万円
- 原因：
  - 大量のクエリ実行
  - インデックス不足で全表スキャン
  - バックアップ頻度
- 確認ポイント：
  - CloudWatch MetricsでVolumeReadIOPs確認
  - Performance Insightsでスロークエリ特定
  - Aurora I/O-Optimized検討

## 監視・ログ
- **CloudWatch Metrics**：
  - `CPUUtilization`：CPU使用率
  - `FreeableMemory`：空きメモリ
  - `DatabaseConnections`：接続数
  - `VolumeReadIOPs / VolumeWriteIOPs`：ストレージI/O
  - `AuroraReplicaLag`：レプリケーション遅延
- **Performance Insights**：クエリレベルの分析
- **Enhanced Monitoring**：OS詳細メトリクス
- **CloudWatch Alarm**：CPU・接続数・レプリカラグ監視

## コストでハマりやすい点
- **インスタンス課金**：
  - db.t3.medium：$0.082/時（月$59）
  - db.r5.large：$0.348/時（月$251）
  - RDSの約1.5〜2倍
- **ストレージ課金**：$0.12/GB/月（RDSより高い）
- **I/O課金**：$0.24/100万リクエスト
  - 大量クエリで高額化
  - Aurora I/O-Optimized：I/O無料、ストレージ$0.16/GB
- **バックアップ保存**：クラスター容量分は無料、超過分は課金
- **Global Database**：レプリケーション転送料
- **コスト削減策**：
  - Aurora Serverless v2（負荷変動大）
  - インスタンスタイプ最適化
  - I/O削減（インデックス最適化）
  - リザーブドインスタンス

## 実務Tips
- **3AZ推奨**：Writer + Reader を3つのAZに分散
- **Reader Endpoint活用**：読み取り専用クエリはReader Endpointに振り分け
- **RDS Proxy推奨**：Lambda接続、接続プーリング
- **バックトラック活用**：MySQL互換限定、誤操作時の巻き戻し
- **クローン活用**：本番データでテスト環境構築（高速・低コスト）
- **Aurora Serverless v2**：
  - 負荷変動が大きい環境
  - 開発環境（夜間自動スケールダウン）
- **Global Database**：
  - DR対策（RPO < 1秒、RTO < 1分）
  - グローバル展開（読み取りレイテンシー削減）
- **Performance Insights有効化必須**：スロークエリ特定
- **I/O最適化の判断**：
  - I/O課金 > ストレージ差額 → I/O-Optimized
  - 大量クエリ・分析ワークロード向け
- **エンドポイント使い分け**：
  - **Cluster Endpoint（Writer）**：書き込み
  - **Reader Endpoint**：読み取り（複数Readerに負荷分散）
  - **Instance Endpoint**：特定インスタンス指定
- **設計時に言語化すると評価が上がるポイント**：
  - 「6コピー（3AZ × 2）で自動修復、ディスク障害に強い」
  - 「フェイルオーバー < 30秒で高可用性、RDSより高速」
  - 「Reader Endpoint活用で読み取り負荷分散、プライマリ負荷軽減」
  - 「RDS Proxy併用でLambda接続最適化、接続プール管理」
  - 「Aurora Serverless v2で負荷に応じて自動スケール、コスト最適化」
  - 「Global Databaseでクロスリージョンレプリケーション（< 1秒）、DR対策」
  - 「クローン機能で本番データの高速コピー、テスト環境構築」

## Aurora vs RDS

| 項目 | Aurora | RDS |
|------|--------|-----|
| 性能 | 最大5倍高速 | 標準 |
| 可用性 | 6コピー、自動修復 | Multi-AZ |
| フェイルオーバー | < 30秒 | 数分 |
| ストレージ | 10GB〜128TB自動拡張 | 手動拡張 |
| レプリカ | 最大15台、低レイテンシー | 最大15台、高レイテンシー |
| コスト | 高い（1.5〜2倍） | 低い |
| 用途 | 高性能・高可用性 | 標準ワークロード |

## Aurora I/O課金 vs I/O-Optimized

| 項目 | 標準（I/O課金） | I/O-Optimized |
|------|----------------|---------------|
| ストレージ | $0.12/GB/月 | $0.16/GB/月 |
| I/O | $0.24/100万リクエスト | 無料 |
| 適用判断 | I/O課金 < ストレージ差額 | I/O課金 > ストレージ差額 |
| 用途 | 軽量ワークロード | 大量クエリ・分析 |

## 接続文字列例

```bash
# Writer Endpoint（書き込み）
mysql -h aurora-cluster.cluster-xxxxx.ap-northeast-1.rds.amazonaws.com \
      -P 3306 -u admin -p

# Reader Endpoint（読み取り）
mysql -h aurora-cluster.cluster-ro-xxxxx.ap-northeast-1.rds.amazonaws.com \
      -P 3306 -u admin -p

# Instance Endpoint（特定インスタンス）
mysql -h aurora-instance-1.xxxxx.ap-northeast-1.rds.amazonaws.com \
      -P 3306 -u admin -p
```
