# Amazon ECR：運用と実務視点（Lv3）

## 運用で必ず使う機能
- **イメージスキャン**：脆弱性検出（Critical/High/Medium/Low）
- **ライフサイクルポリシー**：古いイメージ自動削除
- **イメージタグ管理**：セマンティックバージョニング（v1.0.0）
- **リポジトリ複製**：リージョン間レプリケーション

## よくあるトラブル
### トラブル1：イメージをpushできない
- 症状：`denied: User: xxx is not authorized to perform: ecr:PutImage`
- 原因：
  - IAM権限不足
  - Docker認証失敗（トークン期限切れ）
  - リポジトリが存在しない
- 確認ポイント：
  - IAMポリシーで `ecr:PutImage`, `ecr:InitiateLayerUpload` 等確認
  - `aws ecr get-login-password` で再認証（12時間有効）
  - リポジトリ作成確認

### トラブル2：ECS/Fargateでイメージをpullできない
- 症状：タスク起動失敗「CannotPullContainerError」
- 原因：
  - タスク実行ロールにECR権限がない
  - VPCエンドポイントが設定されていない（Private）
  - NAT Gatewayがない（Private）
  - イメージタグが存在しない
- 確認ポイント：
  - タスク実行ロールに `AmazonECSTaskExecutionRolePolicy` アタッチ
  - VPCエンドポイント（ecr.api, ecr.dkr, s3）確認
  - イメージタグ存在確認

### トラブル3：イメージスキャンで脆弱性検出
- 症状：Criticalレベルの脆弱性が検出される
- 原因：
  - ベースイメージが古い
  - パッケージに既知の脆弱性
- 確認ポイント：
  - スキャン結果でCVE確認
  - ベースイメージ更新（alpine:latest → alpine:3.18）
  - パッケージ更新（apt-get upgrade）

## 監視・ログ
- **CloudWatch Metrics**：
  - リポジトリ固有のメトリクスは少ない
- **イメージスキャン結果**：
  - Critical / High / Medium / Low の脆弱性数
- **CloudTrail**：
  - push/pull履歴
  - リポジトリ作成/削除
- **EventBridge**：
  - イメージpush完了イベント
  - スキャン完了イベント

## コストでハマりやすい点
- **ストレージ課金**：$0.10/GB/月
  - イメージ肥大化（1GB → 100MB で月$0.09削減）
  - ライフサイクルポリシー未設定で古いイメージ蓄積
- **データ転送料**：
  - 同一リージョン内：無料
  - インターネット向け：$0.09/GB
  - リージョン間：$0.02/GB
- **イメージスキャン**：無料（基本スキャン）
- **コスト削減策**：
  - ライフサイクルポリシーで古いイメージ削除（最新10個のみ保持）
  - マルチステージビルドでイメージサイズ削減
  - 不要なレイヤー削減

## 実務Tips
- **イメージタグ戦略**：
  - **latest**：開発用、本番非推奨
  - **セマンティックバージョニング**：v1.0.0、v1.0.1
  - **Git commit SHA**：トレーサビリティ
  - **ビルド番号**：build-123
- **ライフサイクルポリシー必須**：最新10〜30個のみ保持
- **イメージスキャン有効化**：push時に自動スキャン推奨
- **マルチステージビルド**：イメージサイズ削減
  ```dockerfile
  # ビルドステージ
  FROM golang:1.20 AS builder
  WORKDIR /app
  COPY . .
  RUN go build -o app

  # 実行ステージ
  FROM alpine:3.18
  COPY --from=builder /app/app /app
  CMD ["/app"]
  ```
- **VPCエンドポイント推奨**：
  - ecr.api：ECR API呼び出し
  - ecr.dkr：Dockerレジストリ操作
  - s3：イメージレイヤー取得
- **リポジトリポリシー**：最小権限の原則
- **イミュータブルタグ**：本番環境は `image_tag_mutability = "IMMUTABLE"` 推奨
- **クロスアカウント共有**：リポジトリポリシーでプリンシパル指定
- **リージョン間レプリケーション**：DR対策、グローバル展開
- **設計時に言語化すると評価が上がるポイント**：
  - 「イメージスキャンでpush時に脆弱性自動検出、セキュリティ強化」
  - 「ライフサイクルポリシーで最新10個のみ保持、ストレージコスト削減」
  - 「VPCエンドポイント経由でプライベート接続、NAT Gateway不要」
  - 「マルチステージビルドでイメージサイズを1GB → 100MBに削減」
  - 「セマンティックバージョニングでタグ管理、デプロイ履歴明確化」
  - 「リポジトリポリシーで他アカウントにイメージ共有、組織全体で統一管理」

## Docker操作コマンド（ECR）

```bash
# ECR認証
aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.ap-northeast-1.amazonaws.com

# イメージタグ付け
docker tag my-app:latest \
  123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/my-app:v1.0.0

# イメージpush
docker push \
  123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/my-app:v1.0.0

# イメージpull
docker pull \
  123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/my-app:v1.0.0
```

## イメージサイズ削減Tips

- **Alpine Linuxベース**：軽量（5MB）
- **マルチステージビルド**：ビルドツール除外
- **不要ファイル削除**：キャッシュ・一時ファイル
- **.dockerignore**：不要ファイルをビルドから除外
- **レイヤー削減**：RUN命令を結合

例：
```dockerfile
# 悪い例（レイヤー多い）
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2

# 良い例（レイヤー少ない）
RUN apt-get update && \
    apt-get install -y package1 package2 && \
    rm -rf /var/lib/apt/lists/*
```
