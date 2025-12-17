# Amazon Athena：運用とベストプラクティス（Lv3）

## 日常運用でよくやること
- クエリ実行
- クエリ履歴確認
- コスト確認
- パフォーマンスチューニング

## トラブルシューティング
### よくあるエラーと対処
- **HIVE_PARTITION_SCHEMA_MISMATCH**：
  - パーティションスキーマ不一致
  - `MSCK REPAIR TABLE` 実行
- **EXCEEDED_MEMORY_LIMIT**：
  - メモリ不足
  - クエリ最適化（WHERE句、LIMIT句）
- **SYNTAX_ERROR**：
  - SQL文法エラー
  - クエリ確認

## モニタリング
- **CloudWatchメトリクス**：
  - DataScannedInBytes：スキャン量
  - EngineExecutionTime：実行時間
  - QueryPlanningTime：プランニング時間
- **CloudWatch Logs Insights**：
  - クエリ履歴分析
  - 長時間クエリ特定
- **コストエクスプローラー**：
  - Athenaコスト確認

## 定期メンテナンス
- 不要なクエリ結果削除（S3）
- パーティション追加（新データ）
- Glueテーブル定義更新
- コスト確認・最適化

## セキュリティベストプラクティス
- **IAM最小権限**：
  - 必要なデータベース・テーブルのみアクセス
  - ワークグループ単位で権限分離
- **S3暗号化**：SSE-S3 / SSE-KMS
- **クエリ結果暗号化**：SSE-S3 / SSE-KMS
- **VPC Endpoint**：S3 VPCエンドポイント経由
- **CloudTrail有効化**：API呼び出し記録

## コスト最適化
- **$5/TBスキャン**
- **パーティショニング**：WHERE句でパーティション指定
- **Parquet / ORC**：列指向フォーマットで70-80%削減
- **圧縮**：Snappy、Gzip等
- **CTAS（Create Table As Select）**：結果を最適化形式で保存
- **不要カラム除外**：SELECT * 避ける

## よく使うCLIコマンド
```bash
# クエリ実行
aws athena start-query-execution \
  --query-string "SELECT * FROM my_table LIMIT 10" \
  --query-execution-context Database=my_database \
  --result-configuration OutputLocation=s3://my-query-results/

# クエリ状態確認
aws athena get-query-execution --query-execution-id <execution-id>

# クエリ結果取得
aws athena get-query-results --query-execution-id <execution-id>

# ワークグループ一覧
aws athena list-work-groups

# データベース一覧
aws glue get-databases

# テーブル一覧
aws glue get-tables --database-name my_database

# パーティション修復
aws athena start-query-execution \
  --query-string "MSCK REPAIR TABLE my_table" \
  --query-execution-context Database=my_database \
  --result-configuration OutputLocation=s3://my-query-results/
```

## よく使うPythonコード（boto3）
```python
import boto3
import time

athena = boto3.client('athena')

# クエリ実行
response = athena.start_query_execution(
    QueryString='SELECT * FROM my_table LIMIT 10',
    QueryExecutionContext={'Database': 'my_database'},
    ResultConfiguration={'OutputLocation': 's3://my-query-results/'}
)
execution_id = response['QueryExecutionId']
print(f"Query execution ID: {execution_id}")

# クエリ完了待機
while True:
    response = athena.get_query_execution(QueryExecutionId=execution_id)
    status = response['QueryExecution']['Status']['State']
    print(f"Status: {status}")
    
    if status in ['SUCCEEDED', 'FAILED', 'CANCELLED']:
        break
    
    time.sleep(1)

# クエリ結果取得
if status == 'SUCCEEDED':
    response = athena.get_query_results(QueryExecutionId=execution_id)
    for row in response['ResultSet']['Rows']:
        print([col.get('VarCharValue', '') for col in row['Data']])

# スキャン量確認
stats = response['QueryExecution']['Statistics']
print(f"Data scanned: {stats['DataScannedInBytes'] / (1024**3):.2f} GB")
print(f"Cost estimate: ${stats['DataScannedInBytes'] / (1024**4) * 5:.4f}")
```

## よく使うSQLサンプル
```sql
-- パーティション追加
ALTER TABLE my_table ADD IF NOT EXISTS
PARTITION (year=2024, month=12, day=15)
LOCATION 's3://my-bucket/data/year=2024/month=12/day=15/';

-- パーティション修復
MSCK REPAIR TABLE my_table;

-- CTAS（最適化）
CREATE TABLE my_optimized_table
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://my-bucket/optimized/'
)
AS SELECT * FROM my_table
WHERE year = 2024;

-- パーティショニングしたCTAS
CREATE TABLE my_partitioned_table
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  partitioned_by = ARRAY['year', 'month'],
  external_location = 's3://my-bucket/partitioned/'
)
AS SELECT id, name, created_at, year, month
FROM my_table;
```

## パフォーマンスチューニング
- **パーティショニング**：WHERE句でパーティション指定
- **Parquet / ORC**：列指向フォーマット
- **圧縮**：Snappy推奨
- **CTAS**：結果を最適化形式で保存
- **JOIN最適化**：大きいテーブルを左、小さいテーブルを右
- **集計最適化**：GROUP BY前にWHERE句でフィルタ

## 障害対応
- **クエリタイムアウト**：
  1. クエリ最適化（WHERE句、LIMIT句）
  2. パーティショニング確認
  3. データ形式確認（Parquet推奨）
- **メモリ不足**：
  1. クエリ最適化
  2. JOIN順序確認
  3. 集計最適化
