# Secrets Manager マネージドコンソールでのセットアップ

## 作成するもの

Secrets Managerでデータベースの認証情報を保存し、アプリケーションから安全に取得できるようにします。

## セットアップ手順

1. **Secrets Managerコンソールを開く**
   - AWSマネージメントコンソールで「Secrets Manager」を検索して選択

2. **シークレットを保存**
   - 「シークレットを保存」をクリック

3. **シークレットタイプを選択**
   - **シークレットタイプ**: その他のシークレットタイプを選択
   - **キー/値のペア**: プレーンテキストを選択
   - **シークレットキー/値**: 
     - `username`: `admin`
     - `password`: `your-password`

4. **シークレット名を設定**
   - **シークレット名**: `my-database-credentials` を入力
   - **説明**: 任意の説明を入力

5. **暗号化キーを設定**
   - **AWS KMSキー**: デフォルトのaws/secretsmanagerキーを選択

6. **確認と保存**
   - 設定を確認
   - 「次へ」→「保存」をクリック

7. **シークレットを取得（アプリケーションから）**
   - AWS SDKまたはCLIを使用してシークレットを取得：
   ```bash
   aws secretsmanager get-secret-value --secret-id my-database-credentials
   ```

## 補足

- シークレットは自動的に暗号化されます
- バージョン管理が可能です
- RDSデータベースの認証情報は自動ローテーションに対応しています

