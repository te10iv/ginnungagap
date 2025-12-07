# Site-to-Site VPN マネージドコンソールでのセットアップ

## 作成するもの

Site-to-Site VPN接続を作成し、オンプレミス環境とVPC間をVPNで接続します。Virtual Private GatewayとCustomer Gatewayを設定します。

## セットアップ手順

1. **Virtual Private Gatewayを作成**
   - VPCコンソールで「Virtual Private Gateway」を選択
   - 「Virtual Private Gatewayを作成」をクリック
   - **名前タグ**: `my-vpg` を入力
   - **ASN**: デフォルト（64512）のまま
   - 「Virtual Private Gatewayを作成」をクリック

2. **VPCにアタッチ**
   - 作成したVPGを選択
   - 「アクション」→「VPCにアタッチ」をクリック
   - **VPC**: 接続するVPCを選択
   - 「Virtual Private Gatewayをアタッチ」をクリック

3. **Customer Gatewayを作成**
   - VPCコンソールで「Customer Gateway」を選択
   - 「Customer Gatewayを作成」をクリック
   - **名前タグ**: `my-cgw` を入力
   - **ルーティング**: 静的または動的を選択
   - **IPアドレス**: オンプレミス側のVPNデバイスのパブリックIPアドレスを入力
   - **BGP ASN**: オンプレミス側のASNを入力（動的ルーティングの場合）
   - 「Customer Gatewayを作成」をクリック

4. **VPN接続を作成**
   - VPCコンソールで「Site-to-Site VPN接続」を選択
   - 「VPN接続を作成」をクリック
   - **名前タグ**: `my-vpn-connection` を入力
   - **Virtual Private Gateway**: 作成したVPGを選択
   - **Customer Gateway**: 作成したCGWを選択
   - **ルーティングオプション**: 静的または動的を選択
   - **静的ルート**: 静的ルーティングの場合、オンプレミスのCIDRブロックを入力
   - 「VPN接続を作成」をクリック

5. **ルートテーブルを設定**
   - VPCのルートテーブルにオンプレミスへのルートを追加

## 補足

- オンプレミス側のVPNデバイスも設定が必要です
- 冗長性のため、複数のVPN接続を推奨します

