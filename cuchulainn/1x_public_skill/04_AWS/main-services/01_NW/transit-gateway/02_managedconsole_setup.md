# Transit Gateway マネージドコンソールでのセットアップ

## 作成するもの

Transit Gatewayを作成し、複数のVPCを接続します。ハブ&スポーク構成で、VPC間の通信を一元管理できるようにします。

## セットアップ手順

1. **Transit Gatewayコンソールを開く**
   - VPCコンソールで「Transit Gateway」を選択

2. **Transit Gatewayを作成**
   - 「Transit Gatewayを作成」をクリック
   - **名前タグ**: `my-transit-gateway` を入力
   - **説明**: 任意の説明を入力
   - **ASN**: デフォルト（64512）のまま
   - **DNSサポート**: 有効（デフォルト）
   - **VPN ECMPサポート**: 有効（デフォルト）
   - **デフォルトルートテーブル関連付け**: 有効（デフォルト）
   - 「Transit Gatewayを作成」をクリック

3. **VPCをアタッチ**
   - 作成したTransit Gatewayを選択
   - 「Transit Gatewayアタッチメント」タブで「Transit Gatewayアタッチメントを作成」をクリック
   - **Transit Gateway ID**: 作成したTransit Gatewayを選択
   - **アタッチメントタイプ**: VPCを選択
   - **VPC**: 接続するVPCを選択
   - **サブネット**: VPC内のサブネットを選択（複数選択可能）
   - **ルートテーブル**: 各サブネットのルートテーブルを選択
   - 「Transit Gatewayアタッチメントを作成」をクリック

4. **ルートテーブルを設定**
   - 「ルートテーブル」タブでルートテーブルを選択
   - 「ルート」タブで「ルートを追加」をクリック
   - 接続されたVPCへのルートを追加

## 補足

- 複数のVPCを接続する場合、各VPCをアタッチする必要があります
- ルートテーブルで細かいルーティング制御が可能です

