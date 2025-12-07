# Athena マネージドコンソールでのセットアップ

## 作成するもの

AthenaでS3のログファイルをクエリできるようにします。CloudTrailログやVPC Flow Logsを分析します。

## セットアップ手順

1. **Athenaコンソールを開く**
   - AWSマネージメントコンソールで「Athena」を検索して選択

2. **クエリエディタの設定**
   - 初回アクセス時、S3バケットを設定するよう求められます
   - 「設定」をクリック
   - **クエリ結果の場所**: S3バケットを選択（新しいバケットを作成可能）
   - 「保存」をクリック

3. **データベースを作成**
   - クエリエディタで以下を実行：
   ```sql
   CREATE DATABASE my_database;
   ```

4. **テーブルを作成（CloudTrailログの例）**
   - クエリエディタで以下を実行：
   ```sql
   CREATE EXTERNAL TABLE cloudtrail_logs (
     eventtime string,
     useridentity struct<type:string,principalid:string,arn:string>,
     eventname string,
     sourceipaddress string
   )
   PARTITIONED BY (date string)
   STORED AS parquet
   LOCATION 's3://your-cloudtrail-bucket/AWSLogs/';
   ```

5. **クエリを実行**
   - クエリエディタで以下を実行：
   ```sql
   SELECT eventname, COUNT(*) as count
   FROM cloudtrail_logs
   WHERE date = '2024/01/01'
   GROUP BY eventname
   ORDER BY count DESC;
   ```

## 補足

- データカタログ（Glue）でスキーマを管理できます
- パーティション分割でクエリのコストを削減できます

