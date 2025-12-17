# Amazon Cognito：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **ユーザー管理**：AdminCreateUser、AdminDeleteUser
- **トークン検証**：JWT検証
- **MFA設定**：TOTP、SMS
- **パスワードリセット**：ForgotPassword

## よくあるトラブル
### トラブル1：トークン検証エラー
- 症状：「Invalid token」エラー
- 原因：
  - トークン期限切れ
  - トークン改ざん
  - 署名検証失敗
- 確認ポイント：
  - トークン有効期限確認
  - JWT署名検証ライブラリ使用
  - リフレッシュトークンで更新

### トラブル2：MFA設定エラー
- 症状：MFA設定できない
- 原因：
  - SNS権限不足（SMS MFA）
  - 電話番号フォーマットミス
- 確認ポイント：
  - SNS IAMロール確認
  - 電話番号形式確認（+81-90-xxxx-xxxx）

### トラブル3：高額課金
- 症状：月末にCognito課金が高額
- 原因：
  - 大量のMAU
  - アカウント乗っ取り保護（有料）
- 確認ポイント：
  - MAU数確認
  - Advanced Security無効化検討
  - 不要なユーザー削除

## 監視・ログ
- **CloudWatch Metrics**：
  - サインイン成功・失敗
  - トークン更新
  - MFA成功・失敗
- **CloudWatch Logs**：Lambda トリガーログ
- **Cognito Advanced Security**：リスクベース認証

## コストでハマりやすい点
- **MAU課金**：
  - 0〜50,000 MAU：無料
  - 50,001〜100,000：$0.0055/MAU
  - 100,001〜1,000,000：$0.0046/MAU
- **Advanced Security**：
  - $0.05/MAU（リスクベース認証）
- **SMS MFA**：$0.00645/SMS（SNS課金）
- **コスト削減策**：
  - TOTP MFA推奨（無料）
  - Advanced Security無効化
  - 不要なユーザー削除

## 実務Tips
- **ユーザープール vs アイデンティティプール**：
  - ユーザープール：認証（サインイン）
  - アイデンティティプール：AWS認証情報取得
- **MFA推奨**：TOTP（Google Authenticator等）
- **パスワードポリシー強化**：8文字以上、複雑性要件
- **トークン有効期限**：
  - アクセストークン：1時間
  - IDトークン：1時間
  - リフレッシュトークン：30日
- **Lambda トリガー活用**：
  - Pre SignUp：メールドメイン検証
  - Post Confirmation：ウェルカムメール
  - Pre Authentication：IP制限
- **設計時に言語化すると評価が上がるポイント**：
  - 「Cognitoユーザープールでユーザー管理、サインアップ・サインイン統合」
  - 「MFA有効化（TOTP）でアカウント保護、セキュリティ強化」
  - 「API Gateway Authorizer統合でJWT検証、サーバーレス認証」
  - 「Lambda トリガーでカスタマイズ、Pre SignUpでメールドメイン検証」
  - 「アイデンティティプールで一時的AWS認証情報、S3直接アップロード」
  - 「Advanced Security（オプション）でリスクベース認証、不審なログイン検知」
  - 「ホストされたUIで簡単実装、カスタムドメイン対応」

## ユーザー操作（AWS CLI）

```bash
# ユーザー作成（管理者）
aws cognito-idp admin-create-user \
  --user-pool-id ap-northeast-1_xxxxx \
  --username user@example.com \
  --user-attributes Name=email,Value=user@example.com Name=email_verified,Value=true \
  --temporary-password TempPassword123!

# ユーザー削除
aws cognito-idp admin-delete-user \
  --user-pool-id ap-northeast-1_xxxxx \
  --username user@example.com

# ユーザー一覧
aws cognito-idp list-users \
  --user-pool-id ap-northeast-1_xxxxx

# パスワードリセット
aws cognito-idp admin-reset-user-password \
  --user-pool-id ap-northeast-1_xxxxx \
  --username user@example.com

# MFA有効化
aws cognito-idp admin-set-user-mfa-preference \
  --user-pool-id ap-northeast-1_xxxxx \
  --username user@example.com \
  --software-token-mfa-settings Enabled=true,PreferredMfa=true
```

## サインアップ・サインイン（Python）

```python
import boto3
import hmac
import hashlib
import base64

client = boto3.client('cognito-idp')

USER_POOL_ID = 'ap-northeast-1_xxxxx'
CLIENT_ID = 'xxxxx'
CLIENT_SECRET = 'xxxxx'  # クライアントシークレットあれば

def get_secret_hash(username):
    """シークレットハッシュ計算"""
    message = bytes(username + CLIENT_ID, 'utf-8')
    secret = bytes(CLIENT_SECRET, 'utf-8')
    dig = hmac.new(secret, msg=message, digestmod=hashlib.sha256).digest()
    return base64.b64encode(dig).decode()

# サインアップ
def sign_up(username, password, email):
    response = client.sign_up(
        ClientId=CLIENT_ID,
        SecretHash=get_secret_hash(username),
        Username=username,
        Password=password,
        UserAttributes=[
            {'Name': 'email', 'Value': email}
        ]
    )
    return response

# 確認コード送信
def confirm_sign_up(username, confirmation_code):
    response = client.confirm_sign_up(
        ClientId=CLIENT_ID,
        SecretHash=get_secret_hash(username),
        Username=username,
        ConfirmationCode=confirmation_code
    )
    return response

# サインイン
def sign_in(username, password):
    response = client.initiate_auth(
        ClientId=CLIENT_ID,
        AuthFlow='USER_PASSWORD_AUTH',
        AuthParameters={
            'USERNAME': username,
            'PASSWORD': password,
            'SECRET_HASH': get_secret_hash(username)
        }
    )
    return response['AuthenticationResult']

# トークン更新
def refresh_token(refresh_token, username):
    response = client.initiate_auth(
        ClientId=CLIENT_ID,
        AuthFlow='REFRESH_TOKEN_AUTH',
        AuthParameters={
            'REFRESH_TOKEN': refresh_token,
            'SECRET_HASH': get_secret_hash(username)
        }
    )
    return response['AuthenticationResult']
```

## JWT トークン検証（Python）

```python
import jwt
from jwt import PyJWKClient
import requests

USER_POOL_ID = 'ap-northeast-1_xxxxx'
REGION = 'ap-northeast-1'
JWKS_URL = f'https://cognito-idp.{REGION}.amazonaws.com/{USER_POOL_ID}/.well-known/jwks.json'

def verify_token(token):
    """JWT トークン検証"""
    try:
        # JWKS取得
        jwks_client = PyJWKClient(JWKS_URL)
        signing_key = jwks_client.get_signing_key_from_jwt(token)
        
        # トークン検証
        decoded = jwt.decode(
            token,
            signing_key.key,
            algorithms=['RS256'],
            audience=CLIENT_ID,  # クライアントID
            options={'verify_exp': True}
        )
        
        return decoded
    
    except jwt.ExpiredSignatureError:
        print('Token expired')
        return None
    except jwt.InvalidTokenError:
        print('Invalid token')
        return None
```

## Lambda トリガー例（Pre SignUp）

```python
def lambda_handler(event, context):
    # メールドメイン検証
    email = event['request']['userAttributes']['email']
    
    if not email.endswith('@example.com'):
        raise Exception('Invalid email domain')
    
    # 自動確認
    event['response']['autoConfirmUser'] = True
    event['response']['autoVerifyEmail'] = True
    
    return event
```

## ユーザープール vs アイデンティティプール

| 項目 | ユーザープール | アイデンティティプール |
|------|-------------|-------------------|
| 用途 | 認証（サインイン） | AWS認証情報取得 |
| 出力 | JWT トークン | 一時的AWS認証情報 |
| ユーザー管理 | あり | なし |
| ソーシャルログイン | あり | あり |
| API Gateway | Authorizer | 不可 |
| S3直接アクセス | 不可 | 可 |

## トークン種類

| トークン | 用途 | 有効期限 |
|---------|------|---------|
| IDトークン | ユーザー情報 | 1時間（設定可） |
| アクセストークン | API呼び出し | 1時間（設定可） |
| リフレッシュトークン | トークン更新 | 30日（設定可） |

## MFA タイプ

| タイプ | 料金 | 用途 |
|--------|------|------|
| TOTP | 無料 | Google Authenticator等 |
| SMS | $0.00645/SMS | 電話番号 |
| Email | 無料 | メールアドレス |

**推奨**：TOTP（無料、セキュア）

## Lambda トリガー一覧

| トリガー | タイミング | 用途 |
|---------|----------|------|
| Pre SignUp | サインアップ前 | メールドメイン検証 |
| Post Confirmation | 確認後 | ウェルカムメール |
| Pre Authentication | 認証前 | IP制限 |
| Post Authentication | 認証後 | ログ記録 |
| Pre Token Generation | トークン生成前 | カスタムクレーム追加 |
| User Migration | ユーザー移行 | 既存DB統合 |

## ホストされたUI

```
https://<domain>.auth.<region>.amazoncognito.com/login?
  response_type=code&
  client_id=<client_id>&
  redirect_uri=<redirect_uri>&
  scope=openid+email+profile
```

## カスタムドメイン設定

```hcl
# カスタムドメイン
resource "aws_cognito_user_pool_domain" "custom" {
  domain          = "auth.example.com"
  certificate_arn = aws_acm_certificate.auth.arn
  user_pool_id    = aws_cognito_user_pool.main.id
}

# Route53レコード
resource "aws_route53_record" "auth" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "auth.example.com"
  type    = "A"

  alias {
    name                   = aws_cognito_user_pool_domain.custom.cloudfront_distribution_arn
    zone_id                = "Z2FDTNDATAQYW2"  # CloudFront
    evaluate_target_health = false
  }
}
```

## ベストプラクティス

1. **MFA有効化**：TOTP推奨
2. **強力なパスワードポリシー**：8文字以上、複雑性要件
3. **トークン有効期限短縮**：セキュリティ向上
4. **Lambda トリガー活用**：カスタマイズ
5. **ホストされたUI**：簡単実装
6. **Advanced Security**：リスクベース認証（予算許せば）
7. **CloudWatch Logs**：監視・デバッグ
8. **カスタムドメイン**：ブランディング
9. **アイデンティティプール**：S3直接アクセス
10. **定期的なユーザークリーンアップ**：コスト削減
