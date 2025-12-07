# VPC Endpoint（Gateway/Interface） 概要

## 1. サービスの役割

VPC Endpointは、VPC内のリソースがAWSサービスにプライベートに接続するためのサービスです。インターネットゲートウェイ、NAT Gateway、VPN接続を経由せずに、AWSのパブリックサービス（S3、DynamoDBなど）にアクセスできます。Gateway型とInterface型の2種類があります。

## 2. 主なユースケース

- プライベートサブネットからS3やDynamoDBへのアクセス（インターネット経由なし）
- セキュリティ要件が厳しい環境でのAWSサービスへのアクセス
- NAT Gatewayのコスト削減（VPC Endpoint経由ならデータ転送料金が安い）
- インターネットに接続できないプライベートサブネットからのAWSサービスアクセス
- コンプライアンス要件を満たすためのプライベート接続

## 3. 他サービスとの関係

- **VPC**: VPC内にVPC Endpointを作成
- **Subnet**: Interface型はサブネットに配置、Gateway型はルートテーブルに関連付け
- **Route Table**: Gateway型はルートテーブルにルートを追加
- **Security Group**: Interface型はセキュリティグループで制御
- **S3, DynamoDB**: Gateway型で対応しているサービス
- **EC2, Lambda**: VPC Endpoint経由でAWSサービスにアクセスするリソース

## 4. 料金のざっくりイメージ

- **Gateway型**: 無料（S3、DynamoDBなど）
- **Interface型**: 約$0.01/時間（約$7/月）+ データ転送料金（NAT Gatewayより安い）
- データ転送料金はNAT Gateway経由より安価

## 5. 初心者がまず覚えるべきポイント

- **Gateway型**: S3、DynamoDBなど特定のサービスに対応、無料、ルートテーブルにルートを追加
- **Interface型**: より多くのAWSサービスに対応、有料、ENIとして動作、セキュリティグループで制御
- NAT Gatewayのコスト削減に有効（特にS3、DynamoDBへのアクセスが多い場合）
- インターネット経由しないため、セキュリティが向上
- Interface型は複数のAZに配置して高可用性を確保
- ポリシーでアクセス制御が可能

