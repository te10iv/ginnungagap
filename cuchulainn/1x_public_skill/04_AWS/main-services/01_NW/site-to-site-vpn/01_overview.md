# Site-to-Site VPN 概要

## 1. サービスの役割

Site-to-Site VPNは、オンプレミス環境とAWS VPC間をインターネット経由でIPsec VPN接続するサービスです。専用線（Direct Connect）よりも低コストで、比較的簡単に設定できるため、小規模な接続やDirect Connectのバックアップとして使用されます。

## 2. 主なユースケース

- オンプレミス環境とAWS間の接続（小規模〜中規模）
- Direct Connectのバックアップ接続
- 一時的な接続やテスト環境
- リモートオフィスとAWS間の接続
- コストを抑えつつセキュアな接続が必要な場合

## 3. 他サービスとの関係

- **VPC**: VPCにVirtual Private Gateway（VGW）をアタッチ
- **Customer Gateway**: オンプレミス側のVPNデバイスを設定
- **Route Table**: VPCのルートテーブルでオンプレミスへのルーティングを設定
- **Direct Connect**: バックアップ接続として使用
- **EC2, RDS**: Site-to-Site VPN経由でオンプレミス環境と通信

## 4. 料金のざっくりイメージ

- Virtual Private Gateway: 無料
- VPN接続: 約$0.05/時間（約$36/月）
- データ転送料金: GBあたり$0.05（アウトバウンド）
- **注意**: Direct Connectより安いが、パフォーマンスは劣る

## 5. 初心者がまず覚えるべきポイント

- Direct Connectより低コストで簡単に設定可能
- インターネット経由のため、レイテンシーや帯域幅が不安定になる可能性
- 冗長性のため、複数のVPN接続を推奨
- 静的ルーティングと動的ルーティング（BGP）の両方に対応
- オンプレミス側にVPN対応のルーターが必要
- Direct Connectのバックアップとして使用するのが一般的

