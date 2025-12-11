# カスタムリソース（Custom Resources）

CloudFormationの機能をLambdaで拡張

---

## 🎯 カスタムリソースとは

CloudFormationがネイティブサポートしていないリソースやロジックを、**Lambda関数**で実装できる機能。

### 使用ケース

- ✅ CloudFormationが未対応のAWSサービス
- ✅ サードパーティAPIとの連携（Slack、GitHub等）
- ✅ 複雑な初期化処理（DB初期データ投入等）
- ✅ カスタムバリデーション
- ✅ 動的な値の生成（ランダム文字列等）

---

## 🏗️ 基本構造

### テンプレート定義

```yaml
Resources:
  # Lambda関数（カスタムリソースのロジック）
  CustomResourceFunction:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: python3.11
      Handler: index.lambda_handler
      Code:
        ZipFile: |
          import json
          import cfnresponse
          
          def lambda_handler(event, context):
              print(json.dumps(event))
              
              request_type = event['RequestType']  # Create/Update/Delete
              properties = event['ResourceProperties']
              
              try:
                  if request_type == 'Create':
                      # 作成処理
                      result = create_resource(properties)
                  elif request_type == 'Update':
                      # 更新処理
                      result = update_resource(properties)
                  elif request_type == 'Delete':
                      # 削除処理
                      result = delete_resource(properties)
                  
                  # 成功レスポンス
                  cfnresponse.send(event, context, cfnresponse.SUCCESS, {
                      'Message': 'Success',
                      'Result': result
                  })
              except Exception as e:
                  print(f"Error: {e}")
                  # 失敗レスポンス
                  cfnresponse.send(event, context, cfnresponse.FAILED, {
                      'Message': str(e)
                  })
      Role: !GetAtt LambdaExecutionRole.Arn

  # カスタムリソース
  MyCustomResource:
    Type: Custom::MyResource
    Properties:
      ServiceToken: !GetAtt CustomResourceFunction.Arn
      CustomProperty1: value1
      CustomProperty2: value2

Outputs:
  CustomResourceResult:
    Value: !GetAtt MyCustomResource.Result
```

---

## 📤 cfnresponse ヘルパー

CloudFormationへのレスポンス送信を簡略化するヘルパーライブラリ。

### 基本的な使用方法

```python
import cfnresponse

def lambda_handler(event, context):
    try:
        # 処理成功
        cfnresponse.send(
            event,
            context,
            cfnresponse.SUCCESS,
            responseData={'Key': 'Value'},
            physicalResourceId='custom-resource-id-123'
        )
    except Exception as e:
        # 処理失敗
        cfnresponse.send(
            event,
            context,
            cfnresponse.FAILED,
            responseData={'Error': str(e)}
        )
```

### パラメータ

| パラメータ | 説明 |
|-----------|------|
| **event** | CloudFormationからのイベント |
| **context** | Lambda context |
| **responseStatus** | `cfnresponse.SUCCESS` または `cfnresponse.FAILED` |
| **responseData** | 出力データ（Outputs で使用） |
| **physicalResourceId** | リソースの物理ID（省略時は自動生成） |

---

## 🎯 実践例

### 例1: ランダム文字列生成

**ユースケース**: パスワード、S3バケット名等のランダム生成

```yaml
Resources:
  RandomStringFunction:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: python3.11
      Handler: index.lambda_handler
      Code:
        ZipFile: |
          import random
          import string
          import cfnresponse
          
          def lambda_handler(event, context):
              try:
                  if event['RequestType'] == 'Delete':
                      cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
                      return
                  
                  length = int(event['ResourceProperties'].get('Length', 16))
                  include_symbols = event['ResourceProperties'].get('IncludeSymbols', 'false') == 'true'
                  
                  chars = string.ascii_letters + string.digits
                  if include_symbols:
                      chars += '!@#$%^&*'
                  
                  random_string = ''.join(random.choice(chars) for _ in range(length))
                  
                  cfnresponse.send(event, context, cfnresponse.SUCCESS, {
                      'RandomString': random_string
                  })
              except Exception as e:
                  cfnresponse.send(event, context, cfnresponse.FAILED, {
                      'Error': str(e)
                  })
      Role: !GetAtt LambdaRole.Arn

  RandomPassword:
    Type: Custom::RandomString
    Properties:
      ServiceToken: !GetAtt RandomStringFunction.Arn
      Length: 32
      IncludeSymbols: 'true'

Outputs:
  GeneratedPassword:
    Value: !GetAtt RandomPassword.RandomString
```

### 例2: Slack通知

**ユースケース**: スタック作成完了をSlack通知

```yaml
Resources:
  SlackNotificationFunction:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: python3.11
      Handler: index.lambda_handler
      Code:
        ZipFile: |
          import json
          import urllib3
          import cfnresponse
          
          http = urllib3.PoolManager()
          
          def lambda_handler(event, context):
              try:
                  webhook_url = event['ResourceProperties']['WebhookUrl']
                  message = event['ResourceProperties']['Message']
                  
                  if event['RequestType'] in ['Create', 'Update']:
                      # Slack投稿
                      payload = {
                          'text': f"🚀 CloudFormation: {message}",
                          'username': 'CloudFormation Bot'
                      }
                      
                      response = http.request(
                          'POST',
                          webhook_url,
                          body=json.dumps(payload),
                          headers={'Content-Type': 'application/json'}
                      )
                  
                  cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
              except Exception as e:
                  cfnresponse.send(event, context, cfnresponse.FAILED, {
                      'Error': str(e)
                  })
      Role: !GetAtt LambdaRole.Arn

  DeploymentNotification:
    Type: Custom::SlackNotification
    DependsOn: MyApplication  # 全リソース作成後に通知
    Properties:
      ServiceToken: !GetAtt SlackNotificationFunction.Arn
      WebhookUrl: !Ref SlackWebhookUrl
      Message: !Sub 'Stack ${AWS::StackName} deployed successfully!'
```

### 例3: DynamoDBへの初期データ投入

```yaml
Resources:
  InitDataFunction:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: python3.11
      Handler: index.lambda_handler
      Code:
        ZipFile: |
          import boto3
          import cfnresponse
          
          dynamodb = boto3.resource('dynamodb')
          
          def lambda_handler(event, context):
              try:
                  table_name = event['ResourceProperties']['TableName']
                  items = event['ResourceProperties']['Items']
                  
                  table = dynamodb.Table(table_name)
                  
                  if event['RequestType'] == 'Create':
                      # データ投入
                      for item in items:
                          table.put_item(Item=item)
                      
                      cfnresponse.send(event, context, cfnresponse.SUCCESS, {
                          'ItemsInserted': len(items)
                      })
                  
                  elif event['RequestType'] == 'Delete':
                      # 削除処理（必要に応じて）
                      cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
                  
                  else:
                      cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
              
              except Exception as e:
                  cfnresponse.send(event, context, cfnresponse.FAILED, {
                      'Error': str(e)
                  })
      Role: !GetAtt LambdaRole.Arn

  PopulateData:
    Type: Custom::InitData
    DependsOn: MyTable
    Properties:
      ServiceToken: !GetAtt InitDataFunction.Arn
      TableName: !Ref MyTable
      Items:
        - id: '1'
          name: 'Item 1'
        - id: '2'
          name: 'Item 2'
```

---

## 🔄 イベント構造

### Createイベント

```json
{
  "RequestType": "Create",
  "RequestId": "unique-request-id",
  "ResponseURL": "pre-signed-url-for-response",
  "StackId": "arn:aws:cloudformation:...",
  "LogicalResourceId": "MyCustomResource",
  "ResourceType": "Custom::MyResource",
  "ResourceProperties": {
    "ServiceToken": "arn:aws:lambda:...",
    "CustomProperty1": "value1"
  }
}
```

### Updateイベント

```json
{
  "RequestType": "Update",
  "PhysicalResourceId": "custom-resource-id-123",
  "OldResourceProperties": {
    "CustomProperty1": "old-value"
  },
  "ResourceProperties": {
    "CustomProperty1": "new-value"
  }
}
```

### Deleteイベント

```json
{
  "RequestType": "Delete",
  "PhysicalResourceId": "custom-resource-id-123"
}
```

---

## 💡 ベストプラクティス

### ✅ DO

1. **必ずcfnresponse.sendを呼ぶ**: タイムアウト回避
2. **Deleteイベントのハンドリング**: スタック削除時のエラー防止
3. **冪等性を保つ**: 同じ処理を複数回実行しても安全
4. **エラーハンドリング**: try-except必須
5. **ログ出力**: CloudWatch Logsで調査可能に
6. **タイムアウト設定**: デフォルト3秒は短すぎ（推奨: 5-15分）

```yaml
CustomResourceFunction:
  Type: AWS::Lambda::Function
  Properties:
    Timeout: 900  # 15分
```

### ❌ DON'T

1. レスポンス未送信（スタックが永遠に待機）
2. 長時間処理（15分超）
3. Secrets/Passwordの平文ログ出力
4. Deleteイベント無視

---

## 🚨 トラブルシューティング

### 問題1: スタックがCREATE_IN_PROGRESSで止まる

**原因**: Lambda関数が `cfnresponse.send` を呼んでいない

**対処**:
```python
# 必ず try-except で囲み、必ずレスポンス送信
try:
    # 処理
    cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
except Exception as e:
    cfnresponse.send(event, context, cfnresponse.FAILED, {'Error': str(e)})
```

### 問題2: Deleteイベントで失敗

**原因**: リソースが既に削除されている

**対処**:
```python
def lambda_handler(event, context):
    if event['RequestType'] == 'Delete':
        # Deleteは常に成功とする（冪等性）
        cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
        return
```

### 問題3: Updateで置換が発生

**原因**: PhysicalResourceIdが変更された

**対処**: PhysicalResourceIdを固定

```python
physical_id = event.get('PhysicalResourceId', 'fixed-id-123')

cfnresponse.send(
    event,
    context,
    cfnresponse.SUCCESS,
    {},
    physicalResourceId=physical_id  # 固定ID
)
```

---

## 📚 学習リソース

- [AWS公式: カスタムリソース](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/template-custom-resources.html)
- [cfnresponse モジュール](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/cfn-lambda-function-code-cfnresponsemodule.html)
- [カスタムリソースのベストプラクティス](https://aws.amazon.com/jp/blogs/infrastructure-and-automation/aws-cloudformation-custom-resource-creation-with-python-aws-lambda-and-crhelper/)

---

**カスタムリソースで、CloudFormationの可能性を無限に拡張！🚀**
