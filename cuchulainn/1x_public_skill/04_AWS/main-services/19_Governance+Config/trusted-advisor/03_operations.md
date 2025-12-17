# AWS Trusted Advisor：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **ダッシュボード確認**：週次推奨
- **チェックリフレッシュ**：手動更新
- **推奨事項対応**：優先度付け
- **コスト最適化**：RI購入推奨等

## よくあるトラブル
### トラブル1：チェック結果が古い
- 症状：推奨事項が現状と異なる
- 原因：
  - 自動更新週1回
  - リフレッシュ未実行
- 確認ポイント：
  - 手動リフレッシュ実行
  - 更新日時確認

### トラブル2：有料チェック見えない
- 症状：7項目しか表示されない
- 原因：
  - サポートプラン Basic / Developer
- 確認ポイント：
  - サポートプラン確認
  - Business / Enterprise必要

### トラブル3：通知来ない
- 症状：CloudWatch Eventsトリガーされない
- 原因：
  - イベントパターンミス
  - リフレッシュ未実行
- 確認ポイント：
  - イベントパターン確認
  - 手動リフレッシュで確認

## 監視・ログ
- **ダッシュボード**：チェック結果概要
- **CloudWatch Events**：チェック完了イベント
- **CloudTrail**：Trusted Advisor API呼び出し

## コストでハマりやすい点
- **Trusted Advisor：無料（7項目）**
- **Business / Enterprise：全項目無料**
  - Business：月$100〜
  - Enterprise：月$15,000〜
- **コスト削減効果**：
  - 未使用リソース削除
  - RI購入推奨
  - Right Sizing推奨

## 実務Tips
- **週次確認習慣化**：月曜朝推奨
- **優先度付け**：セキュリティ > コスト > その他
- **自動対応慎重**：誤削除リスク
- **組織全体監視**：全アカウント集約
- **設計時に言語化すると評価が上がるポイント**：
  - 「Trusted Advisorで週次ベストプラクティスチェック、コスト削減・セキュリティ改善」
  - 「未使用EIP・EBS自動検知でコスト削減、月数千円〜数万円節約」
  - 「IAMアクセスキーローテーション警告で認証情報漏洩リスク低減」
  - 「サービスクォータ警告で上限到達事前検知、サービス停止回避」
  - 「CloudWatch Events統合で推奨事項即座にSlack/Email通知」
  - 「Lambda自動修復で未使用リソース即座に削除、運用工数削減」
  - 「Business / Enterpriseサポートで全115+チェック、完全なベストプラクティス適用」

## Trusted Advisor操作（CLI）

```bash
# チェック一覧
aws support describe-trusted-advisor-checks \
  --language en

# チェック結果取得
aws support describe-trusted-advisor-check-result \
  --check-id Qch7DwouX1

# チェックリフレッシュ
aws support refresh-trusted-advisor-check \
  --check-id Qch7DwouX1

# リフレッシュステータス確認
aws support describe-trusted-advisor-check-refresh-statuses \
  --check-ids Qch7DwouX1
```

**注意**：`support` APIはBusiness / Enterpriseサポート必要

## 主要なチェック項目

### コスト最適化（無料チェック含む）

| チェック | 説明 | 無料 |
|---------|------|------|
| Unassociated Elastic IP Addresses | 未使用EIP | ✓ |
| Idle Load Balancers | アイドルLB | - |
| Underutilized Amazon EBS Volumes | 低使用率EBS | - |
| Unassociated Elastic Load Balancers | 未関連付けALB/NLB | - |
| Amazon RDS Idle DB Instances | アイドルRDS | - |
| Amazon EC2 Reserved Instance Optimization | RI最適化 | - |
| Low Utilization Amazon EC2 Instances | 低使用率EC2 | - |
| Underutilized Amazon Redshift Clusters | 低使用率Redshift | - |

### セキュリティ（無料チェック含む）

| チェック | 説明 | 無料 |
|---------|------|------|
| Security Groups - Unrestricted Access | SG無制限アクセス | ✓ |
| IAM Access Key Rotation | IAMキーローテーション | - |
| IAM Use | IAMユーザー使用状況 | ✓ |
| MFA on Root Account | Root MFA | ✓ |
| Amazon S3 Bucket Permissions | S3バケット権限 | ✓ |
| Amazon EBS Public Snapshots | EBSパブリックスナップショット | ✓ |
| Amazon RDS Public Snapshots | RDSパブリックスナップショット | ✓ |
| CloudFront Custom SSL Certificates | CloudFront SSL | - |

### 耐障害性

| チェック | 説明 |
|---------|------|
| Amazon RDS Backups | RDSバックアップ |
| Amazon RDS Multi-AZ | RDS Multi-AZ |
| Amazon S3 Bucket Versioning | S3バージョニング |
| Amazon EBS Snapshots | EBSスナップショット |
| Amazon EC2 Availability Zone Balance | EC2 AZバランス |
| VPN Tunnel Redundancy | VPN冗長性 |

### パフォーマンス

| チェック | 説明 |
|---------|------|
| High Utilization Amazon EC2 Instances | 高使用率EC2 |
| Amazon EBS Provisioned IOPS (SSD) Volume Attachment Configuration | EBS IOPS最適化 |
| Large Number of Rules in an EC2 Security Group | SG大量ルール |
| Large Number of EC2 Security Group Rules Applied to an Instance | インスタンスSG大量 |

### サービスクォータ

| チェック | 説明 |
|---------|------|
| Service Limits | サービス上限 |
| VPC | VPC上限 |
| Elastic IP | EIP上限 |
| IAM Roles | IAMロール上限 |

## 無料チェック（7項目）

1. **Security Groups - Unrestricted Access**
2. **IAM Use**
3. **MFA on Root Account**
4. **Amazon S3 Bucket Permissions**
5. **Amazon EBS Public Snapshots**
6. **Amazon RDS Public Snapshots**
7. **Service Limits**

**推奨**：最低限これらは週次確認

## Lambda自動対応例

### 未使用EIPリリース

```python
import boto3

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    # 未使用EIP一覧取得
    addresses = ec2.describe_addresses()
    
    for address in addresses['Addresses']:
        # AssociationIdがなければ未使用
        if 'AssociationId' not in address:
            allocation_id = address['AllocationId']
            
            # EIPリリース
            print(f'Releasing EIP: {allocation_id}')
            ec2.release_address(AllocationId=allocation_id)
    
    return {'statusCode': 200}
```

### 低使用率EC2停止

```python
import boto3
from datetime import datetime, timedelta

ec2 = boto3.client('ec2')
cloudwatch = boto3.client('cloudwatch')

def lambda_handler(event, context):
    # EC2インスタンス一覧
    instances = ec2.describe_instances()
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            
            # CloudWatch CPU使用率確認（過去7日間）
            end_time = datetime.utcnow()
            start_time = end_time - timedelta(days=7)
            
            stats = cloudwatch.get_metric_statistics(
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                StartTime=start_time,
                EndTime=end_time,
                Period=86400,  # 1日
                Statistics=['Average']
            )
            
            # 平均CPU < 5% なら停止
            avg_cpu = sum(s['Average'] for s in stats['Datapoints']) / len(stats['Datapoints'])
            
            if avg_cpu < 5.0:
                print(f'Stopping low utilization instance: {instance_id} (CPU: {avg_cpu}%)')
                ec2.stop_instances(InstanceIds=[instance_id])
    
    return {'statusCode': 200}
```

## Slack通知例

```python
import boto3
import json
import urllib.request

def lambda_handler(event, context):
    # Trusted Advisorイベント
    detail = event['detail']
    check_name = detail['check-name']
    status = detail['status']
    
    # Slack Webhook URL
    webhook_url = "https://hooks.slack.com/services/xxx/yyy/zzz"
    
    message = {
        "text": f"⚠️ Trusted Advisor Alert",
        "attachments": [{
            "color": "danger" if status == "ERROR" else "warning",
            "fields": [
                {"title": "Check", "value": check_name, "short": False},
                {"title": "Status", "value": status, "short": True}
            ]
        }]
    }
    
    req = urllib.request.Request(
        webhook_url,
        data=json.dumps(message).encode('utf-8'),
        headers={'Content-Type': 'application/json'}
    )
    
    urllib.request.urlopen(req)
    
    return {'statusCode': 200}
```

## Trusted Advisor vs Config vs Security Hub

| 項目 | Trusted Advisor | Config | Security Hub |
|------|----------------|--------|-------------|
| 用途 | ベストプラクティス | 設定変更追跡 | セキュリティ統合 |
| チェック頻度 | 週1回 | リアルタイム | リアルタイム |
| 自動修復 | なし | あり | なし |
| 料金 | 無料/有料 | 有料 | 有料 |
| カテゴリ | 5種類 | コンプライアンス | セキュリティ |

**推奨**：全て併用（補完関係）

## チェック結果ステータス

| ステータス | 意味 | アクション |
|----------|------|----------|
| OK（緑） | 問題なし | 対応不要 |
| WARN（黄） | 推奨事項あり | 検討推奨 |
| ERROR（赤） | 調査推奨 | 即座に対応 |
| - | データなし | チェック対象外 |

## リフレッシュ頻度

- **自動リフレッシュ**：週1回
- **手動リフレッシュ**：5分に1回可能
- **推奨**：重要変更後は手動リフレッシュ

## ベストプラクティス

1. **週次確認習慣化**：月曜朝推奨
2. **優先度付け**：ERROR → WARN順
3. **セキュリティ優先**：即座に対応
4. **コスト最適化活用**：月次コスト削減
5. **CloudWatch Events統合**：自動通知
6. **自動対応慎重**：誤削除リスク考慮
7. **サポートプラン検討**：Business推奨
8. **組織全体監視**：全アカウント集約
9. **定期的なレビュー**：四半期ごと
10. **Cost Explorerと併用**：コスト分析

## サポートプラン比較

| プラン | 料金 | Trusted Advisorチェック | 推奨 |
|--------|------|----------------------|------|
| Basic | 無料 | 7項目 | 個人学習 |
| Developer | $29/月〜 | 7項目 | 開発環境 |
| Business | $100/月〜 | 全115+項目 | 本番環境 |
| Enterprise | $15,000/月〜 | 全115+項目 | エンタープライズ |

**推奨**：本番環境 → Business以上

## コスト削減事例

### 未使用リソース削除

```
- 未使用EIP：50個 × $0.005/時間 × 24時間 × 30日 = $180/月
- アイドルEBS：100GB × $0.12/GB/月 = $12/月
- 低使用率EC2：t3.medium停止 × $0.0416/時間 × 24 × 30 = $30/月
合計：約$222/月削減
```

### RI購入推奨

```
- EC2 On-Demand：$100/月
- RI（1年）：$60/月
削減：$40/月（40%削減）
```

## 組織全体監視

```bash
# Organizations統合（コンソール推奨）
# → Trusted Advisor → Organizational view

# 全アカウント推奨事項集約
# → Cost optimization、Security等
```

**メリット**：全アカウント一覧表示、優先度付け

## トラブルシューティング

### チェックリフレッシュ失敗

```
原因：リフレッシュ頻度制限（5分に1回）
対策：5分待機後再実行
```

### API呼び出しエラー

```
原因：サポートプラン不足
対策：Business / Enterprise契約確認
```

## 週次チェックリスト

```
□ ダッシュボード確認
□ ERRORステータス即座に対応
□ WARNステータス検討
□ コスト最適化推奨確認
□ セキュリティ推奨確認
□ サービスクォータ確認
□ 対応履歴記録
```

## まとめ

- **Trusted Advisor = AWSベストプラクティス自動チェック**
- **無料7項目は最低限確認**
- **Business / Enterpriseで全機能**
- **週次確認習慣化でコスト削減・セキュリティ向上**
- **CloudWatch Events統合で自動化**
