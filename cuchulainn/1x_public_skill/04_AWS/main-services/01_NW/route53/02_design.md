# Amazon Route 53：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **ドメインレジストラ**：ドメイン購入・ネームサーバー設定
  - **AWSリソース（ALB/CloudFront等）**：エイリアスレコードのターゲット
  - **ACM**：HTTPS用SSL/TLS証明書

## 内部的な仕組み（ざっくり）
- **なぜネームサーバー設定が必要なのか**：ドメインのDNS解決をRoute 53に委譲するため
- **エイリアスレコードとCNAMEの違い**：エイリアスはAWSリソース専用で無料、CNAMEは有料
- **TTL（Time To Live）**：DNSキャッシュの有効期限（短いと変更反映早い、長いとクエリ削減）
- **制約**：ゾーンApex（example.com）にはCNAME不可、エイリアスレコード推奨

## よくある構成パターン
### パターン1：ALB向けエイリアスレコード
- 構成概要：
  - Aレコード（エイリアス）：example.com → ALB
  - Aレコード（エイリアス）：www.example.com → ALB
- 使う場面：Webアプリケーションの基本構成

### パターン2：CloudFront + S3静的サイト
- 構成概要：
  - Aレコード（エイリアス）：example.com → CloudFront Distribution
- 使う場面：静的サイト配信、グローバル高速化

### パターン3：マルチリージョン構成（レイテンシールーティング）
- 構成概要：
  - example.com → 東京リージョンのALB（日本ユーザー）
  - example.com → バージニアリージョンのALB（米国ユーザー）
- 使う場面：グローバルサービス、低レイテンシー要件

### パターン4：フェイルオーバー構成
- 構成概要：
  - プライマリ：東京リージョンのALB（ヘルスチェック有効）
  - セカンダリ：大阪リージョンのALB（プライマリ障害時）
- 使う場面：DR構成、高可用性

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：Route 53自体は100% SLA、フェイルオーバー機能で冗長化
- **セキュリティ**：DNSSEC対応、プライベートホストゾーン（VPC内DNS）
- **コスト**：ホストゾーン $0.50/月、クエリ数課金、エイリアスレコードは無料
- **拡張性**：ルーティングポリシー（レイテンシー、地理的、加重）で柔軟な制御

## 他サービスとの関係
- **ALB との関係**：エイリアスレコードでALBのDNS名を設定
- **CloudFront との関係**：エイリアスレコードでCloudFront Distributionを設定
- **ACM との関係**：DNS検証でRoute 53レコード自動追加
- **S3 との関係**：静的サイトホスティング時にエイリアスレコード設定

## Terraformで見るとどうなる？
```hcl
# ホストゾーン
resource "aws_route53_zone" "main" {
  name = "example.com"

  tags = {
    Name = "example.com"
  }
}

# ALB向けエイリアスレコード
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# 通常のAレコード
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.example.com"
  type    = "A"
  ttl     = 300
  records = ["203.0.113.10"]
}
```

主要リソース：
- `aws_route53_zone`：ホストゾーン
- `aws_route53_record`：DNSレコード（A, CNAME, エイリアス等）
- `aws_route53_health_check`：ヘルスチェック
