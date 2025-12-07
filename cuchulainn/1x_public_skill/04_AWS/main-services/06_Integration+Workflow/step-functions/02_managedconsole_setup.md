# Step Functions マネージドコンソールでのセットアップ

## 作成するもの

Step Functionsステートマシンを作成し、複数のLambda関数を順次実行するワークフローを構築します。

## セットアップ手順

1. **Step Functionsコンソールを開く**
   - AWSマネージメントコンソールで「Step Functions」を検索して選択

2. **ステートマシンを作成**
   - 「ステートマシンを作成」をクリック
   - **タイプ**: 標準を選択

3. **定義を記述**
   - ビジュアルエディタまたはJSONで定義を記述
   - シンプルな例（JSON）：
   ```json
   {
     "Comment": "A simple workflow",
     "StartAt": "HelloWorld",
     "States": {
       "HelloWorld": {
         "Type": "Task",
         "Resource": "arn:aws:lambda:REGION:ACCOUNT:function:my-lambda-function",
         "End": true
       }
     }
   }
   ```

4. **実行ロールを設定**
   - **実行ロール**: 新しいロールを作成（自動的にLambda実行権限が付与される）

5. **確認と作成**
   - 設定を確認
   - 「ステートマシンを作成」をクリック

6. **実行**
   - ステートマシンを選択
   - 「実行を開始」をクリック
   - 実行結果を確認

## 補足

- ビジュアルエディタでワークフローを視覚的に作成できます
- 複数のLambda関数を順次実行、並列実行、条件分岐などが可能です

