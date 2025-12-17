# Amazon CloudFront：仕組みと設計の基本（Lv2）

## このサービスは「何の上に成り立っているか」
- 依存サービス：
  - **オリジン（S3/ALB/カスタム）**：配信元コンテンツ
  - **Route 53**：カスタムドメイン設定
  - **ACM（us-east-1）**：HTTPS化の証明書（バージニアリージョン必須）
  - **WAF**：セキュリティフィルタリング

## 内部的な仕組み（ざっくり）
- **なぜCloudFrontが必要なのか**：オリジンから遠い地域へのアクセスを高速化
- **キャッシュの仕組み**：初回アクセス時にオリジンから取得、以降はエッジから配信
- **キャッシュヒット率**：高いほどオリジン負荷削減・高速化
- **制約**：ACM証明書はus-east-1リージョンで作成必須

## よくある構成パターン
### パターン1：S3静的サイト配信
- 構成概要：
  - オリジン：S3バケット（静的サイトホスティング）
  - CloudFront Distribution
  - Route 53エイリアスレコード
  - ACM証明書（HTTPS）
- 使う場面：静的サイト（HTML/CSS/JS）、画像配信

### パターン2：ALB + CloudFront（動的コンテンツ）
- 構成概要：
  - オリジン：ALB（EC2/ECS）
  - CloudFront Distribution（キャッシュTTL短め）
  - カスタムヘッダーでALB→CloudFront経由のみ許可
- 使う場面：Webアプリケーション、API

### パターン3：マルチオリジン構成
- 構成概要：
  - /static/* → S3オリジン（静的ファイル）
  - /api/* → ALBオリジン（動的API）
  - デフォルト → ALBオリジン
- 使う場面：静的/動的コンテンツ混在

### パターン4：OAI（Origin Access Identity）でS3アクセス制限
- 構成概要：
  - S3バケットはプライベート
  - CloudFront OAI経由のみアクセス許可
  - 直接S3アクセス不可
- 使う場面：セキュリティ重視、S3への直接アクセス防止

## 設計でよく考えるポイント
- **可用性（AZ / Multi-AZ）**：CloudFront自体は自動冗長化（エッジロケーション400+拠点）
- **セキュリティ**：OAI、カスタムヘッダー、WAF、地理的制限
- **コスト**：データ転送料が主（リージョン・転送量で変動）、リクエスト数課金
- **拡張性**：自動スケール、リージョンクラス（全世界 or 北米+欧州+アジア）

## 他サービスとの関係
- **S3 との関係**：静的コンテンツのオリジン、OAIで直接アクセス制限
- **ALB との関係**：動的コンテンツのオリジン、カスタムヘッダーで経路制御
- **Route 53 との関係**：エイリアスレコードでカスタムドメイン設定
- **WAF との関係**：DDoS対策、SQLインジェクション防止
- **Lambda@Edge との関係**：エッジでのリクエスト/レスポンス処理

## Terraformで見るとどうなる？
```hcl
# S3オリジンのDistribution
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id   = "S3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"
  aliases             = ["www.example.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.main.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# OAI
resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "OAI for S3 bucket"
}
```

主要リソース：
- `aws_cloudfront_distribution`：Distribution本体
- `aws_cloudfront_origin_access_identity`：OAI（S3アクセス制限）
- `aws_cloudfront_cache_policy`：キャッシュポリシー
