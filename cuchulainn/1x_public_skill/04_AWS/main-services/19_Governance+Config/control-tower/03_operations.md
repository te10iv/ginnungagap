# AWS Control Tower：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **Account Factory**：標準アカウント作成
- **ダッシュボード**：コンプライアンス確認
- **ガードレール管理**：有効化・無効化
- **OU管理**：組織構造変更

## よくあるトラブル
### トラブル1：セットアップ失敗
- 症状：ランディングゾーン作成失敗
- 原因：
  - 既存Organizations構成問題
  - 権限不足
  - リージョン未対応
- 確認ポイント：
  - 新規Organizationsで試す
  - 管理アカウント権限確認
  - サポートリージョン確認

### トラブル2：ガードレール違反多発
- 症状：新規アカウントで即座にガードレール違反
- 原因：
  - 既存リソース問題
  - ガードレール理解不足
- 確認ポイント：
  - ガードレール詳細確認
  - 既存リソース修正
  - Account Factory再作成

### トラブル3：ドリフト検知
- 症状：「Drift detected」警告
- 原因：
  - 手動変更
  - Control Tower管理外変更
- 確認ポイント：
  - ドリフト詳細確認
  - Repair実行
  - 手動変更回避

## 監視・ログ
- **ダッシュボード**：コンプライアンス概要
- **CloudTrail**：Control Tower API呼び出し
- **Config**：ガードレール評価
- **SNS**：ガードレール違反通知

## コストでハマりやすい点
- **Control Tower：無料**
- **依存サービスコスト**：
  - Config：設定項目記録
  - CloudTrail：ログ保存
  - S3：Log Archiveストレージ
  - SSO：無料
- **コスト削減策**：
  - Log Archive S3ライフサイクル
  - Config記録対象最小化

## 実務Tips
- **新規環境推奨**：既存環境は移行複雑
- **Account Factory統一**：手動アカウント作成禁止
- **ガードレール理解**：必須は変更不可
- **ドリフト定期確認**：月1回推奨
- **設計時に言語化すると評価が上がるポイント**：
  - 「Control Towerでマルチアカウント環境自動セットアップ、AWSベストプラクティス即座に適用」
  - 「ガードレール（必須・推奨・選択）で組織全体ガバナンス、手動設定不要」
  - 「Account Factory で標準化されたアカウント作成、SSO・CloudTrail・Config自動設定」
  - 「Security OU（Log Archive・Audit）でログ集約・監査、セキュリティ統制強化」
  - 「ランディングゾーンでOrganizations・Config・SSO統合、ワンストップ管理」
  - 「ライフサイクルイベントで新アカウント作成時自動セットアップ、運用効率化」
  - 「ドリフト検知で手動変更即座に検知、Repair機能で自動修復」

## Control Towerセットアップ手順

1. **前提条件確認**
   - 管理アカウントRoot権限
   - Organizations有効化
   - 対応リージョン（ap-northeast-1等）

2. **ランディングゾーン作成**
   - Control Towerコンソールでセットアップ
   - ホームリージョン選択
   - Security OU・Workloads OU自動作成
   - Log Archive・Auditアカウント自動作成
   - CloudTrail・Config自動設定

3. **SSO設定**
   - ユーザー登録
   - グループ作成（Admins、Developers等）
   - 権限セット割り当て

4. **ガードレール有効化**
   - 必須：自動有効（変更不可）
   - 強く推奨：有効化推奨
   - 選択：必要に応じて有効化

5. **Account Factory設定**
   - ネットワーク設定（VPC有無）
   - リージョン設定

## Account Factory アカウント作成

### コンソール

1. **Control Towerダッシュボード**
2. **Account Factory → Enroll account**
3. **必要情報入力**
   - Account email
   - Account name
   - SSO user email
   - Organizational Unit
4. **作成実行**（15分程度）

### Service Catalog（CLI）

```bash
# Service Catalog製品ID取得
aws servicecatalog search-products \
  --filters FullTextSearch="AWS Control Tower Account Factory"

# アカウント作成
aws servicecatalog provision-product \
  --product-id prod-xxxxx \
  --provisioning-artifact-id pa-xxxxx \
  --provisioned-product-name "dev-account" \
  --provisioning-parameters \
    Key=AccountEmail,Value=aws-dev@example.com \
    Key=AccountName,Value="Development Account" \
    Key=ManagedOrganizationalUnit,Value="Workloads (ou-xxxxx)" \
    Key=SSOUserEmail,Value=admin@example.com \
    Key=SSOUserFirstName,Value=Admin \
    Key=SSOUserLastName,Value=User
```

## 主要なガードレール

### 必須（Mandatory）- 変更不可

| ガードレール | 説明 |
|------------|------|
| MFA有効化 | Rootユーザー・IAMユーザーMFA必須 |
| CloudTrail有効 | 全アカウントCloudTrail有効 |
| Config有効 | 全アカウントConfig有効 |
| ログ保持 | Log Archiveアカウントにログ集約 |

### 強く推奨（Strongly Recommended）

| ガードレール | 説明 |
|------------|------|
| S3暗号化 | S3バケット暗号化必須 |
| EBS暗号化 | EBSボリューム暗号化必須 |
| RDS暗号化 | RDSインスタンス暗号化必須 |
| パブリックアクセス制限 | S3パブリックアクセスブロック |

### 選択（Elective）

| ガードレール | 説明 |
|------------|------|
| リージョン制限 | 特定リージョンのみ許可 |
| インスタンスタイプ制限 | 許可されたインスタンスタイプのみ |
| ルートアカウント操作禁止 | Rootユーザー操作拒否 |

## ガードレール管理

```bash
# ガードレール一覧（手動確認）
# → Control Towerコンソール → Guardrails

# ガードレール有効化（コンソール推奨）
# → Guardrail詳細 → Enable guardrail on OUs
```

## ドリフト検知・修復

```bash
# ドリフト検知（自動）
# → Control Towerダッシュボード → Drift status

# ドリフト修復
# → ダッシュボード → Re-register OU
# または Repair landing zone
```

**ドリフト原因例**：
- SCPの手動変更
- CloudTrailの無効化
- Configの無効化

## ランディングゾーン構造

```
Management Account（請求）
│
├── Security OU
│   ├── Log Archive Account（全ログ集約）
│   └── Audit Account（監査・セキュリティ）
│
├── Sandbox OU（実験・検証）
│   └── 検証アカウント
│
└── Workloads OU（本番ワークロード）
    ├── Development
    ├── Staging
    └── Production
```

## SSO統合

### ユーザーグループ設計

```
- AWSAdministrators（全権限）
  → AdministratorAccess

- AWSDevelopers（開発者）
  → PowerUserAccess

- AWSReadOnly（読み取りのみ）
  → ReadOnlyAccess

- AWSBilling（請求確認）
  → Billing
```

### 権限セット割り当て

```bash
# SSO Permission Set作成（コンソール推奨）
# → AWS SSO → Permission sets → Create permission set

# グループに権限セット割り当て
# → AWS SSO → AWS accounts → Assign users
```

## ライフサイクルイベント活用

### 新アカウント作成時の自動セットアップ

```python
import boto3
import json

def lambda_handler(event, context):
    # Control Tower Lifecycle Event
    detail = event['detail']
    
    if detail['eventName'] == 'CreateManagedAccount':
        account_id = detail['serviceEventDetails']['createManagedAccountStatus']['account']['accountId']
        
        # 自動セットアップ処理
        # - VPC作成
        # - セキュリティグループ設定
        # - IAMロール作成
        # - タグ付け
        # etc...
        
        print(f'Setting up new account: {account_id}')
    
    return {'statusCode': 200}
```

## Control Tower vs 手動Organizations

| 項目 | Control Tower | 手動Organizations |
|------|--------------|------------------|
| セットアップ | 自動（15分） | 手動（数日） |
| ガードレール | 組み込み | 手動設定 |
| Account Factory | あり | なし |
| ベストプラクティス | 自動適用 | 手動実装 |
| ドリフト検知 | あり | なし |
| 学習コスト | 低 | 高 |

**推奨**：新規環境 → Control Tower

## Account Factory vs 手動アカウント作成

| 項目 | Account Factory | 手動作成 |
|------|----------------|---------|
| SSO統合 | 自動 | 手動 |
| CloudTrail | 自動 | 手動 |
| Config | 自動 | 手動 |
| ガードレール | 自動適用 | 手動設定 |
| 標準化 | 強制 | 手動管理 |

**推奨**：Account Factory必須使用

## ベストプラクティス

1. **新規環境でセットアップ**：既存環境移行は複雑
2. **Account Factory統一**：手動アカウント作成禁止
3. **ガードレール全理解**：必須は変更不可理解
4. **SSO統合**：IAMユーザー最小化
5. **Security OU保護**：手動変更禁止
6. **ドリフト月次確認**：定期監査
7. **カスタムガードレール慎重**：Config Rules活用
8. **OU設計事前検討**：後から変更困難
9. **Log Archive S3ライフサイクル**：コスト削減
10. **ライフサイクルイベント活用**：自動化推進

## トラブルシューティング

### ランディングゾーン Repair

```
1. ダッシュボード → Drift detected確認
2. Landing zone settings → Repair
3. 修復実行（30分程度）
```

### OU Re-register

```
1. OUs → 対象OU選択
2. Re-register OU
3. ガードレール再適用
```

### Account Factory失敗

```
1. Service Catalog → Provisioned products → 失敗製品確認
2. エラーメッセージ確認
3. 再作成（前回と異なるメールアドレス）
```

## ランディングゾーンアップデート

```
1. Control Towerダッシュボード
2. Update available通知確認
3. Update landing zone実行
4. 新機能・ガードレール追加
```

**頻度**：3-6ヶ月に1回

## コスト試算例（100アカウント）

```
- Control Tower：無料
- Config：100アカウント × 50リソース × $0.003 = $15/月
- CloudTrail：$5/月（組織トレイル）
- S3（Log Archive）：100GB × $0.023 = $2.3/月
- SSO：無料
合計：約$22/月
```

**メリット**：手動管理工数大幅削減（数百時間/年）

## 移行パス（既存環境）

### オプション1：Control Tower新規環境

```
1. 新しい管理アカウントでControl Towerセットアップ
2. 既存アカウントを新Organizations配下に移行
3. ガードレール段階的適用
```

### オプション2：Account Factoryで段階移行

```
1. 既存Organizations上にControl Tower構築
2. 新規アカウントはAccount Factoryで作成
3. 既存アカウントは段階的にEnroll
```

**推奨**：オプション1（クリーンスタート）

## Control Tower Lifecycle Events

| イベント | タイミング | 用途 |
|---------|----------|------|
| `CreateManagedAccount` | アカウント作成成功 | 自動セットアップ |
| `UpdateManagedAccount` | アカウント更新 | 設定同期 |
| `SetupLandingZone` | ランディングゾーン作成 | 初期設定 |
| `UpdateLandingZone` | ランディングゾーン更新 | バージョンアップ |

## カスタマイゼーション

### Account Factory Customization（AFC）

```yaml
# カスタムテンプレート
Resources:
  CustomVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
  
  CustomSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Custom security group
      VpcId: !Ref CustomVPC
```

**用途**：Account Factory作成時に自動実行

## まとめ

- **Control Tower = Organizations + Config + CloudTrail + SSO統合**
- **Account Factory でアカウント標準化**
- **ガードレールで自動ガバナンス**
- **新規環境で最大効果**
- **既存環境移行は計画的に**
