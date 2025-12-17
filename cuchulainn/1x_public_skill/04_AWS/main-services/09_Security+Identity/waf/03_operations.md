# AWS WAF：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **Web ACL管理**：ルール追加・削除
- **ブロック確認**：サンプルリクエスト
- **ログ分析**：Athena / CloudWatch Logs Insights
- **IP制限**：動的ブロックリスト

## よくあるトラブル
### トラブル1：正常リクエストがブロックされる（誤検知）
- 症状：ユーザーから「アクセスできない」報告
- 原因：
  - マネージドルール過検知
  - レートベースルール閾値低すぎ
- 確認ポイント：
  - CloudWatch Logsで詳細確認
  - サンプルリクエスト確認
  - ルール除外設定
  - カウントモードでテスト

### トラブル2：攻撃を検知できない
- 症状：SQLインジェクション攻撃成功
- 原因：
  - ルール未設定
  - ルール順序ミス
  - カスタムルール不足
- 確認ポイント：
  - 必須ルール追加（Core Rule Set）
  - ルール優先度確認
  - ペネトレーションテスト

### トラブル3：高額課金
- 症状：月末にWAF課金が数万円
- 原因：
  - 大量リクエスト
  - 多数のマネージドルール
- 確認ポイント：
  - リクエスト数削減
  - 不要なルール削除
  - CloudFront併用（リクエスト削減）

## 監視・ログ
- **CloudWatch Metrics**：
  - `AllowedRequests`：許可リクエスト数
  - `BlockedRequests`：ブロックリクエスト数
  - `CountedRequests`：カウントリクエスト数
- **WAFログ**：詳細リクエストログ
- **サンプルリクエスト**：ブロック理由確認

## コストでハマりやすい点
- **Web ACL**：$5/月
- **ルール**：$1/月/ルール
- **リクエスト**：$0.60/百万リクエスト
- **マネージドルール**：
  - Core Rule Set：$10/月
  - 他：$10〜$30/月
- **ログ**：Kinesis Data Firehose課金
- **コスト削減策**：
  - 必要最小限のルール
  - CloudFront併用（キャッシュでリクエスト削減）
  - レートベースルール活用

## 実務Tips
- **マネージドルール推奨**：Core Rule Set必須
- **レートベースルール必須**：DDoS対策
- **カウントモード**：本番適用前にテスト
- **ログ有効化**：Athena分析
- **ルール優先度**：
  1. ホワイトリストIP（Allow）
  2. ブラックリストIP（Block）
  3. レートベース（Block）
  4. マネージドルール
  5. デフォルト（Allow）
- **設計時に言語化すると評価が上がるポイント**：
  - 「AWS WAFでWebアプリ保護、SQLインジェクション・XSS攻撃対策」
  - 「マネージドルール（Core Rule Set）で一般的な攻撃パターンブロック」
  - 「レートベースルール（1,000req/5分）でDDoS対策、過負荷防止」
  - 「CloudWatch Logs統合でブロック理由分析、誤検知調整」
  - 「地域ブロックで不要なアクセス遮断、攻撃リスク低減」
  - 「CloudFront + WAF（エッジ）+ ALB + WAF（リージョン）で多層防御」
  - 「カウントモードで事前テスト、誤検知なく本番適用」

## 主要なマネージドルール

| ルール | 用途 | 料金 |
|--------|------|------|
| Core Rule Set | 一般的な攻撃 | $10/月 |
| Known Bad Inputs | 既知の脆弱性 | $10/月 |
| SQL Database | SQLインジェクション | $10/月 |
| Linux OS | Linuxシステム攻撃 | $10/月 |
| PHP Application | PHP脆弱性 | $10/月 |
| WordPress | WordPress攻撃 | $10/月 |

## レートベースルール例

```hcl
# 1,000リクエスト/5分でブロック
resource "aws_wafv2_web_acl" "main" {
  # ...
  
  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {
        custom_response {
          response_code = 429
          custom_response_body_key = "too_many_requests"
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
        
        # 特定URIのみ
        scope_down_statement {
          byte_match_statement {
            search_string = "/api/"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "STARTS_WITH"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRuleMetric"
      sampled_requests_enabled   = true
    }
  }
}
```

## ログ分析（Athena）

```sql
-- WAFログテーブル作成
CREATE EXTERNAL TABLE waf_logs (
  timestamp bigint,
  formatversion int,
  webaclid string,
  terminatingruleid string,
  terminatingruletype string,
  action string,
  httpsourcename string,
  httpsourceid string,
  rulegrouplist array<struct<
    rulegroupid:string,
    terminatingrule:struct<ruleid:string,action:string>,
    nonterminatingmatchingrules:array<struct<ruleid:string,action:string>>
  >>,
  ratebasedrulelist array<struct<ratelimitedruleid:string,limitkey:string,maxrateallowed:int>>,
  nonterminatingmatchingrules array<struct<ruleid:string,action:string>>,
  httprequest struct<
    clientip:string,
    country:string,
    headers:array<struct<name:string,value:string>>,
    uri:string,
    args:string,
    httpversion:string,
    httpmethod:string,
    requestid:string
  >
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://my-waf-logs/';

-- ブロックされたIP TOP 10
SELECT
  httprequest.clientip,
  COUNT(*) as block_count
FROM waf_logs
WHERE action = 'BLOCK'
GROUP BY httprequest.clientip
ORDER BY block_count DESC
LIMIT 10;

-- ブロック理由分析
SELECT
  terminatingruleid,
  COUNT(*) as count
FROM waf_logs
WHERE action = 'BLOCK'
GROUP BY terminatingruleid
ORDER BY count DESC;
```

## カウントモードテスト

```hcl
# カウントモード（ブロックせず記録のみ）
rule {
  name     = "TestRule"
  priority = 1

  override_action {
    count {}  # Blockの代わりにCount
  }

  statement {
    managed_rule_group_statement {
      vendor_name = "AWS"
      name        = "AWSManagedRulesCommonRuleSet"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "TestRuleMetric"
    sampled_requests_enabled   = true
  }
}
```

**手順**：
1. カウントモードでルール追加
2. 数日間運用してログ確認
3. 誤検知なし確認後、ブロックモードに変更

## ルール除外設定

```hcl
# 特定ルールを除外
rule {
  name     = "AWS-AWSManagedRulesCommonRuleSet"
  priority = 1

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      vendor_name = "AWS"
      name        = "AWSManagedRulesCommonRuleSet"

      # 特定ルールを除外
      excluded_rule {
        name = "SizeRestrictions_BODY"
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "CoreRuleSetMetric"
    sampled_requests_enabled   = true
  }
}
```

## CloudFront vs ALB WAF

| 項目 | CloudFront（CLOUDFRONT） | ALB（REGIONAL） |
|------|------------------------|----------------|
| スコープ | グローバル（エッジ） | リージョナル |
| レイテンシー | 低い | やや高い |
| 地域ブロック | エッジで遮断 | リージョンで遮断 |
| コスト | 同じ | 同じ |
| 推奨用途 | 静的・動的コンテンツ | Webアプリ |

## ベストプラクティス

1. **マネージドルール使用**：Core Rule Set必須
2. **レートベースルール**：DDoS対策
3. **ログ有効化**：Athena分析
4. **カウントモードテスト**：誤検知防止
5. **ルール優先度設計**：Allow → Block順
6. **地域ブロック**：不要な地域遮断
7. **CloudWatch Alarm**：ブロック急増検知
8. **定期的なルールレビュー**：最新脅威対応
9. **Shield Advanced統合**：重要システム
10. **多層防御**：CloudFront + ALB両方にWAF

## WAF vs Shield

| 項目 | WAF | Shield |
|------|-----|--------|
| 対象 | アプリケーション層（L7） | ネットワーク層（L3/L4） |
| 攻撃種類 | SQLi、XSS、DDoS（L7） | DDoS（L3/L4） |
| 料金 | $5/月 + ルール | Standard無料、Advanced $3,000/月 |
| 用途 | Webアプリ保護 | DDoS対策 |

**推奨**：WAF（必須） + Shield Standard（無料、自動）

## カスタムレスポンス

```hcl
# カスタムHTMLレスポンス
resource "aws_wafv2_web_acl" "main" {
  # ...

  custom_response_body {
    key          = "too_many_requests"
    content      = "<html><body><h1>Too Many Requests</h1><p>Please try again later.</p></body></html>"
    content_type = "TEXT_HTML"
  }
}
```
