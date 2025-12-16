# AWS Certified Advanced Networking - Specialty 詳細学習ガイド

## 📋 目次

1. [資格概要](#1-資格概要)
2. [学習ロードマップ](#2-学習ロードマップ)
3. [ドメイン1: ネットワーク設計](#3-ドメイン1-ネットワーク設計-30)
4. [ドメイン2: ネットワーク実装](#4-ドメイン2-ネットワーク実装-26)
5. [ドメイン3: ネットワーク管理と運用](#5-ドメイン3-ネットワーク管理と運用-20)
6. [ドメイン4: ネットワークセキュリティ、コンプライアンス](#6-ドメイン4-ネットワークセキュリティコンプライアンス-24)
7. [試験対策](#7-試験対策)
8. [参考資料](#8-参考資料)

---

## 1. 資格概要

### 1-1. 基本情報
- **資格名**: AWS Certified Advanced Networking - Specialty
- **試験コード**: ANS-C01
- **試験時間**: 170分（2時間50分）
- **問題数**: 65問
- **合格ライン**: 750点/1000点
- **受験料**: $300 USD
- **有効期限**: 3年間
- **試験形式**: 選択問題（単一選択・複数選択）

### 1-2. 対象者
- ネットワークエンジニア（5年以上のネットワーク実務経験）
- クラウドネットワークアーキテクト
- インフラエンジニア（ネットワーク専門）
- CCNP/CCIEレベルのネットワーク知識保持者

### 1-3. 前提知識
- **必須**: AWS Certified Solutions Architect - Associate
- **推奨**: AWS実務経験2年以上、ネットワーク実務経験3年以上
- **技術知識**: 
  - TCP/IP、OSIモデル
  - BGP、OSPF等のルーティングプロトコル
  - VPN、MPLS
  - DNS、DHCP
  - ネットワークセキュリティ

### 1-4. 試験範囲

| ドメイン | 比重 |
|---------|------|
| ドメイン1: ネットワーク設計 | 30% |
| ドメイン2: ネットワーク実装 | 26% |
| ドメイン3: ネットワーク管理と運用 | 20% |
| ドメイン4: ネットワークセキュリティ、コンプライアンス | 24% |

---

## 2. 学習ロードマップ

### 2-1. 学習フェーズ（推奨12週間）

#### Week 1-2: 基礎固め
- [ ] 公式試験ガイド精読
- [ ] AWS Networking Fundamentals復習
- [ ] TCP/IP、BGP基礎の復習
- [ ] 既存のSAAの知識の強化

#### Week 3-4: Transit Gateway & Direct Connect
- [ ] Transit Gateway深掘り（ルーティング、アタッチメント）
- [ ] Direct Connect詳細（VIF、BGP、冗長性）
- [ ] ハンズオン（Transit Gateway構築）

#### Week 5-6: Route 53 & DNS
- [ ] Route 53ルーティングポリシー全種類
- [ ] Route 53 Resolver（ハイブリッドDNS）
- [ ] DNSSEC

#### Week 7-8: VPN & PrivateLink
- [ ] Site-to-Site VPN、Client VPN
- [ ] VPN CloudHub
- [ ] PrivateLink（エンドポイントサービス）

#### Week 9-10: セキュリティ & 運用
- [ ] Network Firewall
- [ ] VPCフローログ分析
- [ ] CloudWatch、Reachability Analyzer

#### Week 11: 総合演習
- [ ] ハンズオン（エンドツーエンド構築）
- [ ] 模擬試験（複数回）
- [ ] 弱点分野の復習

#### Week 12: 最終調整
- [ ] クイックリファレンス暗記
- [ ] 模擬試験で安定して80%以上
- [ ] 試験直前チェックリスト確認

### 2-2. 学習時間の目安

| 前提知識レベル | 学習時間 | 期間 |
|--------------|---------|------|
| SAA保持・ネットワーク経験3年以上 | 80-100時間 | 2-3ヶ月 |
| SAA保持・ネットワーク経験1年 | 120-150時間 | 3-4ヶ月 |
| SAA保持・ネットワーク経験なし | 150-200時間 | 4-6ヶ月 |

---

## 3. ドメイン1: ネットワーク設計（30%）

### 3-1. AWS Transit Gateway詳細

#### 概要
- **目的**: VPC、VPN、Direct Connectを集約するネットワークハブ
- **スケール**: 最大5,000 VPCアタッチメント、50Gbps per VPC
- **機能**: ルーティング、セグメンテーション、マルチキャスト

#### アタッチメントの種類と設計

##### 1. VPCアタッチメント
```
構成:
- 各AZに1つのサブネット指定（推奨: /28以上）
- Transit Gatewayが自動的にENI作成
- サブネットはTransit Gateway専用推奨

制限:
- アタッチメントあたり最大50Gbps
- クロスゾーントラフィック: 追加料金なし

ベストプラクティス:
- 高可用性のため複数AZにサブネット配置
- Transit Gateway専用サブネットを作成
- 適切なCIDRサイズ（/28 = 16 IP、推奨）
```

##### 2. VPNアタッチメント
```
構成:
- Site-to-Site VPN接続
- 2つのIPsecトンネル（冗長性）
- BGPまたは静的ルーティング

帯域:
- トンネルあたり最大1.25Gbps
- ECMP（Equal-Cost Multi-Path）で複数VPN集約可能

ECMP例:
VPN 1: トンネル1 (1.25Gbps) + トンネル2 (1.25Gbps)
VPN 2: トンネル1 (1.25Gbps) + トンネル2 (1.25Gbps)
合計: 5Gbps スループット
```

##### 3. Direct Connect Gatewayアタッチメント
```
構成:
- Transit Virtual Interface (Transit VIF)
- Direct Connect Gateway経由
- 複数リージョンのTransit Gatewayに接続可能

制限:
- Direct Connect Gatewayあたり最大3 Transit Gateway
- アタッチメントあたり最大50Gbps（Direct Connect帯域に依存）

設計パターン:
オンプレミス
  ↓ (Private VIF)
Direct Connect
  ↓ (Transit VIF)
Direct Connect Gateway
  ↓
Transit Gateway (us-east-1)
Transit Gateway (us-west-2)
```

##### 4. Transit Gateway Peeringアタッチメント
```
用途: リージョン間のTransit Gateway接続
構成:
- リージョンAのTransit Gateway ←→ リージョンBのTransit Gateway
- ルートテーブルで明示的にルート追加必要

帯域: 最大50Gbps per peering
レイテンシー: AWSバックボーン経由（低レイテンシー）

ユースケース:
- マルチリージョンアプリケーション
- 災害対策
- グローバル展開
```

##### 5. Transit Gateway Connectアタッチメント
```
用途: SD-WAN統合
プロトコル: GRE + BGP
構成:
- VPCアタッチメント上に構築
- GREトンネル（最大4本）
- BGPセッション（最大4セッション）

帯域:
- GREトンネルあたり最大5Gbps
- 合計最大20Gbps（4トンネル）

対応SD-WANベンダー:
- Cisco SD-WAN
- VMware SD-WAN
- Silver Peak
```

#### ルートテーブル設計

##### ルートテーブルの基本概念
```
アソシエーション（Association）:
- アタッチメントとルートテーブルの紐付け
- 1アタッチメント = 1ルートテーブル

プロパゲーション（Propagation）:
- ルートの自動追加
- BGPで学習したルートを自動反映

例:
VPN接続がBGPで 192.168.0.0/16 を広告
→ プロパゲーション有効なルートテーブルに自動追加
```

##### 設計パターン1: フルメッシュ（デフォルト）
```yaml
ルートテーブル: Default
アソシエーション:
  - VPC-A (10.0.0.0/16)
  - VPC-B (10.1.0.0/16)
  - VPC-C (10.2.0.0/16)
  - VPN-1 (192.168.0.0/16)

プロパゲーション: すべて有効

結果:
- すべてのVPCが相互通信可能
- VPNから全VPCにアクセス可能
```

##### 設計パターン2: ハブ&スポーク
```yaml
ハブルートテーブル: Hub-Route-Table
アソシエーション:
  - VPC-Hub (10.0.0.0/16) # 共有サービスVPC

プロパゲーション:
  - VPC-Spoke-A (10.1.0.0/16)
  - VPC-Spoke-B (10.2.0.0/16)
  - VPN-1

スポークルートテーブル: Spoke-Route-Table
アソシエーション:
  - VPC-Spoke-A
  - VPC-Spoke-B

プロパゲーション:
  - VPC-Hub

ルート:
  - 0.0.0.0/0 → VPC-Hub

結果:
- スポーク同士は直接通信不可
- すべての通信がハブ経由
- ハブでトラフィック検査・ロギング可能
```

##### 設計パターン3: セグメンテーション（環境分離）
```yaml
本番環境ルートテーブル: Production-Route-Table
アソシエーション:
  - VPC-Prod-A (10.0.0.0/16)
  - VPC-Prod-B (10.0.1.0/16)
プロパゲーション: Production VPCs only

開発環境ルートテーブル: Development-Route-Table
アソシエーション:
  - VPC-Dev-A (10.1.0.0/16)
  - VPC-Dev-B (10.1.1.0/16)
プロパゲーション: Development VPCs only

共有サービスルートテーブル: Shared-Route-Table
アソシエーション:
  - VPC-Shared (10.10.0.0/16) # DNS、ActiveDirectory等
プロパゲーション: 全環境

結果:
- 本番環境と開発環境は完全分離
- 共有サービスVPCには両方からアクセス可能
```

#### Appliance Mode

##### 概要
```
用途: ステートフルなネットワークアプライアンス統合
必要性: 
- ファイアウォール
- IDS/IPS
- NAT
等のステートフル検査

問題:
Transit Gatewayはデフォルトで送信元と宛先のAZが異なる場合、
戻りトラフィックのルーティングが非対称になる可能性がある

解決:
Appliance Modeを有効化
→ 同じAZ内でトラフィックをルーティング
```

##### 設定例
```bash
aws ec2 modify-transit-gateway-vpc-attachment \
  --transit-gateway-attachment-id tgw-attach-xxxxx \
  --options ApplianceModeSupport=enable
```

##### アーキテクチャ例
```
VPC-Spoke-A (10.1.0.0/16)
  ↓
Transit Gateway
  ↓ (Appliance Mode有効)
VPC-Inspection (10.10.0.0/16)
  - AZ-a: Firewall Instance (10.10.1.10)
  - AZ-b: Firewall Instance (10.10.2.10)
  ↓
Transit Gateway
  ↓
VPC-Spoke-B (10.2.0.0/16)

トラフィックフロー:
1. Spoke-A (AZ-a) → TGW → Inspection (AZ-a) → Firewall → TGW → Spoke-B
2. 戻りトラフィックも同じAZ経由（Appliance Mode）
```

#### マルチキャスト

##### 概要
```
機能: UDP マルチキャストトラフィックのルーティング
用途:
- ビデオストリーミング
- 株価配信
- IoTデバイス管理

プロトコル: IGMP (Internet Group Management Protocol)
```

##### 設定
```bash
# マルチキャストドメイン作成
aws ec2 create-transit-gateway-multicast-domain \
  --transit-gateway-id tgw-xxxxx \
  --options StaticSourcesSupport=enable

# VPCをマルチキャストドメインに関連付け
aws ec2 associate-transit-gateway-multicast-domain \
  --transit-gateway-multicast-domain-id tgw-mcast-domain-xxxxx \
  --transit-gateway-attachment-id tgw-attach-xxxxx \
  --subnet-ids subnet-xxxxx

# グループメンバー登録
aws ec2 register-transit-gateway-multicast-group-members \
  --transit-gateway-multicast-domain-id tgw-mcast-domain-xxxxx \
  --group-ip-address 239.1.1.1 \
  --network-interface-ids eni-xxxxx
```

#### 試験頻出ポイント
- ✅ ルートプロパゲーションは**BGPルートを自動追加**
- ✅ アソシエーションは**アタッチメントとルートテーブルの紐付け**
- ✅ Appliance Modeは**ステートフル検査用**
- ✅ ECMP（Equal-Cost Multi-Path）で**複数VPNを負荷分散**
- ✅ クロスリージョンは**Transit Gateway Peering**

---

### 3-2. AWS Direct Connect詳細

#### Direct Connect接続タイプ

##### Dedicated Connection（専用接続）
```
帯域オプション:
- 1 Gbps
- 10 Gbps
- 100 Gbps

特徴:
- 物理ポート専有
- 顧客が直接ポートをリクエスト
- LOA-CFA（Letter of Authorization）発行

プロビジョニング時間: 通常1-2週間
```

##### Hosted Connection（ホステッド接続）
```
帯域オプション:
- 50 Mbps、100 Mbps、200 Mbps、300 Mbps、400 Mbps、500 Mbps
- 1 Gbps、2 Gbps、5 Gbps、10 Gbps

特徴:
- AWSパートナー経由
- より柔軟な帯域選択
- 低容量から開始可能

プロビジョニング時間: 数日（パートナーによる）
```

#### 仮想インターフェース（VIF）詳細

##### 1. Private VIF
```
用途: VPC接続（プライベート通信）
接続先:
- Virtual Private Gateway (VGW)
- Direct Connect Gateway

VLAN: 必須（802.1Q）
BGP: 必須
ASN: プライベートASN（64512-65534）または自社ASN

IPアドレス:
- AWSが提供: /30または/31 CIDR
- 例: 169.254.0.0/30
  - 169.254.0.1: AWS側
  - 169.254.0.2: 顧客側

BFD（Bidirectional Forwarding Detection）:
- 有効化推奨
- 障害検出時間を短縮（デフォルト30秒 → 数秒）
```

##### 2. Public VIF
```
用途: AWSパブリックサービス接続（S3、DynamoDB、API等）
接続先: AWSパブリックエンドポイント

VLAN: 必須
BGP: 必須
ASN: パブリックASNまたはプライベートASN

IPアドレス:
- 顧客が所有するパブリックIP（/31）
- またはAWSが提供

BGP広告:
- 顧客がパブリックIPを広告
- AWSが全リージョンのパブリックIPを広告

ユースケース:
- S3への高速アップロード
- DynamoDBへの大量アクセス
- パブリックAPI呼び出し
```

##### 3. Transit VIF
```
用途: Transit Gateway接続
接続先: Direct Connect Gateway → Transit Gateway

VLAN: 必須
BGP: 必須

特徴:
- 複数リージョンのTransit Gatewayに接続可能
- 最大3つのTransit Gatewayをアソシエート
- Private VIFより柔軟

設計例:
オンプレミス
  ↓ (Transit VIF)
Direct Connect Gateway
  ├→ Transit Gateway (us-east-1) → VPCs
  ├→ Transit Gateway (us-west-2) → VPCs
  └→ Transit Gateway (eu-west-1) → VPCs
```

#### Direct Connect Gateway

##### 概要
```
役割: 複数リージョンのVPC/Transit Gatewayへの接続を集約
制限:
- Virtual Private Gateway: 最大10
- Transit Gateway: 最大3
- リージョンまたぎ可能

メリット:
- 1つのPrivate/Transit VIFで複数リージョンをカバー
- 管理の簡素化
```

##### 関連付けプロポーザル
```
プロセス:
1. Direct Connect Gatewayを作成
2. VGWまたはTransit Gatewayへの関連付けをプロポーズ
3. 対象アカウントで承認
4. 関連付け完了

クロスアカウント対応: 可能
```

#### BGP設定詳細

##### BGP ASN
```
AWS側:
- デフォルト: 64512
- カスタムASN: 設定可能（VGW作成時）

顧客側:
- プライベートASN: 64512-65534、4200000000-4294967294
- パブリックASN: 登録済みASN
```

##### AS-PATH Prepending（経路制御）
```
目的: トラフィックの優先経路を制御

設定例:
プライマリDirect Connect:
- AS-PATH: 65001

セカンダリDirect Connect:
- AS-PATH: 65001 65001 65001 (意図的に長くする)

結果:
- プライマリが優先される
- プライマリ障害時にセカンダリに切り替え
```

##### BGP Community Tags
```
AWS BGP Communities（パブリックVIF向け）:
- 7224:7100: Low preference (backup path)
- 7224:7200: Medium preference
- 7224:7300: High preference (primary path)
- 7224:9100: リージョンスコープ（同一リージョン）
- 7224:9200: 大陸スコープ
- 7224:9300: グローバルスコープ

設定例:
顧客からAWSへの広告に Community 7224:7300 を付与
→ AWSはこのパスを優先経路として扱う
```

##### Local Preference（VGW側）
```
AWS側の設定:
- DX経由のルート: Local Preference 100
- VPN経由のルート: Local Preference 200

結果:
- VPN経路が優先される（通常はDX優先が望ましい）

対処:
- AS-PATH Prepending で調整
- VPNをバックアップ専用に設計
```

#### 冗長性設計

##### 最高レベルの冗長性（推奨）
```
構成:
- 2つのDirect Connectロケーション
- 各ロケーションで2つの接続
- 異なるエッジルーターに終端

結果: 4つのDirect Connect接続（2 x 2）
SLA: 99.99%

コスト:
- ポート料金 × 4
- データ転送料 × 4
```

##### LAG（Link Aggregation Group）
```
機能: 複数の接続を束ねて帯域増強
制約:
- すべての接続が同じ帯域
- 最大4接続
- 同じDirect Connectロケーション

例:
LAG構成: 4 × 10Gbps = 40Gbps
※ただし、1接続障害時は30Gbpsに低下

設定:
aws directconnect create-lag \
  --location EqDC2 \
  --number-of-connections 4 \
  --connections-bandwidth 10Gbps \
  --lag-name MyLAG
```

#### MACSec（レイヤー2暗号化）
```
対応: 10Gbps / 100Gbps Dedicated Connection
プロトコル: 802.1AE（MACsec）
暗号化: AES-GCM-256

設定:
- Direct Connectロケーションでサポート必須
- CAK/CKN（Pre-Shared Key）設定
- 顧客側ルーターでMACsec設定

メリット:
- レイヤー2での暗号化（低オーバーヘッド）
- IPsecより高速

用途:
- コンプライアンス要件（HIPAA、PCI-DSS等）
```

#### 試験頻出ポイント
- ✅ **Private VIF**: VPC接続、VGW/DX Gateway経由
- ✅ **Transit VIF**: Transit Gateway接続、複数リージョン対応
- ✅ **冗長性**: 2 × 2構成（2ロケーション × 2接続）
- ✅ **BGP AS-PATH**: 経路制御に使用
- ✅ **LAG**: 同一帯域、同一ロケーション制約
- ✅ **MACSec**: 10/100Gbps専用、レイヤー2暗号化

---

### 3-3. Amazon Route 53詳細

#### ルーティングポリシー完全解説

##### 1. Simple（シンプル）
```
動作:
- 1レコード名に複数のIPアドレス設定可能
- ランダムに1つを返却
- ヘルスチェックなし

設定例:
Name: www.example.com
Type: A
Value: 192.0.2.1, 192.0.2.2, 192.0.2.3

クライアント挙動:
- ランダムに1つのIPアドレスを取得
- 障害時の自動切り替えなし

用途:
- 小規模サイト
- 高可用性不要
```

##### 2. Weighted（重み付け）
```
動作:
- 重みに基づいてトラフィックを分散
- ヘルスチェック対応

設定例:
レコード1:
  Name: www.example.com
  Type: A
  Value: 192.0.2.1
  Weight: 70
  SetID: Web-Server-1

レコード2:
  Name: www.example.com
  Type: A
  Value: 192.0.2.2
  Weight: 30
  SetID: Web-Server-2

結果:
- 70%のトラフィック → 192.0.2.1
- 30%のトラフィック → 192.0.2.2

用途:
- A/Bテスト
- Blue/Greenデプロイ
- 段階的リリース
- ロードバランシング
```

##### 3. Latency（レイテンシーベース）
```
動作:
- ユーザーに最も近い（低レイテンシーの）リージョンに誘導
- AWS リージョンごとにレコード設定

設定例:
レコード1:
  Name: www.example.com
  Type: A
  Value: 192.0.2.1
  Region: us-east-1
  SetID: US-East

レコード2:
  Name: www.example.com
  Type: A
  Value: 198.51.100.1
  Region: ap-northeast-1
  SetID: Tokyo

結果:
- 米国ユーザー → us-east-1
- 日本ユーザー → ap-northeast-1

測定:
- Route 53がリージョン間レイテンシーを定期測定
- 最低レイテンシーのリージョンを選択

用途:
- グローバルアプリケーション
- 低レイテンシー要件
```

##### 4. Failover（フェイルオーバー）
```
動作:
- プライマリ/セカンダリ構成
- ヘルスチェックでプライマリ監視
- プライマリ障害時にセカンダリに切り替え

設定例:
プライマリレコード:
  Name: www.example.com
  Type: A
  Value: 192.0.2.1
  Failover: Primary
  HealthCheckID: hc-xxxxx
  SetID: Primary

セカンダリレコード:
  Name: www.example.com
  Type: A
  Value: 198.51.100.1
  Failover: Secondary
  SetID: Secondary

動作:
1. プライマリが正常 → 192.0.2.1 を返却
2. プライマリが異常 → 198.51.100.1 を返却

用途:
- アクティブ/パッシブDR
- 災害対策
```

##### 5. Geolocation（地理的位置）
```
動作:
- ユーザーの地理的位置でルーティング
- 国、大陸、デフォルトの3レベル

設定例:
レコード1:
  Name: www.example.com
  Type: A
  Value: 192.0.2.1
  Location: Asia / Japan
  SetID: Japan

レコード2:
  Name: www.example.com
  Type: A
  Value: 198.51.100.1
  Location: North America / United States
  SetID: US

レコード3（デフォルト）:
  Name: www.example.com
  Type: A
  Value: 203.0.113.1
  Location: Default
  SetID: Default

結果:
- 日本からのアクセス → 192.0.2.1
- 米国からのアクセス → 198.51.100.1
- その他 → 203.0.113.1

用途:
- コンテンツローカライゼーション
- 地域制限（ジオブロッキング）
- 法規制対応
```

##### 6. Geoproximity（地理的近接性）
```
動作:
- 地理的位置 + Bias（バイアス値）で制御
- Biasで影響範囲を調整（-99〜+99）

設定例:
レコード1:
  Name: www.example.com
  Type: A
  Value: 192.0.2.1
  Coordinates: 北緯35.6895, 東経139.6917 (東京)
  Bias: +50  # 範囲を拡大
  SetID: Tokyo

レコード2:
  Name: www.example.com
  Type: A
  Value: 198.51.100.1
  Coordinates: 北緯37.7749, 西経122.4194 (サンフランシスコ)
  Bias: -50  # 範囲を縮小
  SetID: SF

Bias効果:
- +50: 東京の影響範囲が拡大（アジア全域）
- -50: SFの影響範囲が縮小（カリフォルニア州のみ）

用途:
- トラフィックシフト
- 段階的なリージョン移行
```

##### 7. Multi-value Answer（複数値応答）
```
動作:
- 最大8個のIPアドレスを返却
- 各レコードにヘルスチェック設定可能
- クライアント側で選択

設定例:
レコード1:
  Name: www.example.com
  Type: A
  Value: 192.0.2.1
  HealthCheckID: hc-1
  SetID: Web-1

レコード2〜8: 同様

結果:
- ヘルスチェックが正常なレコードのみ返却
- クライアントがランダムに選択

用途:
- シンプルな負荷分散
- 可用性向上
```

#### Route 53 Resolver詳細

##### Inbound Endpoint（インバウンドエンドポイント）

```
用途: オンプレミス → VPC の DNS クエリ解決

構成:
1. VPC内に2つ以上のENI作成（高可用性）
2. 各ENIにプライベートIPアドレス自動割り当て
3. セキュリティグループで DNS（UDP/TCP 53）許可

設定例:
aws route53resolver create-resolver-endpoint \
  --creator-request-id unique-string \
  --security-group-ids sg-xxxxx \
  --direction INBOUND \
  --ip-addresses \
    SubnetId=subnet-xxxxx,Ip=10.0.1.10 \
    SubnetId=subnet-yyyyy,Ip=10.0.2.10

オンプレミスDNS設定:
forwarder 10.0.1.10
forwarder 10.0.2.10

クエリフロー:
オンプレミスアプリ
  ↓ (DNS クエリ: db.example.local)
オンプレミスDNS
  ↓ (転送)
Resolver Inbound Endpoint (10.0.1.10)
  ↓
Route 53 Private Hosted Zone
  ↓ (応答: 10.0.10.100)
```

##### Outbound Endpoint（アウトバウンドエンドポイント）

```
用途: VPC → オンプレミス の DNS クエリ転送

構成:
1. VPC内に2つ以上のENI作成
2. Resolver Rule作成（転送ルール）
3. ドメイン名とターゲットDNS指定

設定例:
# Outbound Endpoint作成
aws route53resolver create-resolver-endpoint \
  --creator-request-id unique-string \
  --security-group-ids sg-xxxxx \
  --direction OUTBOUND \
  --ip-addresses \
    SubnetId=subnet-xxxxx \
    SubnetId=subnet-yyyyy

# Resolver Rule作成
aws route53resolver create-resolver-rule \
  --creator-request-id unique-string \
  --rule-type FORWARD \
  --domain-name example.local \
  --target-ips Ip=10.20.0.53,Port=53 Ip=10.20.1.53,Port=53 \
  --resolver-endpoint-id rslvr-out-xxxxx

# VPCに関連付け
aws route53resolver associate-resolver-rule \
  --resolver-rule-id rslvr-rr-xxxxx \
  --vpc-id vpc-xxxxx

クエリフロー:
VPC内EC2
  ↓ (DNS クエリ: server.example.local)
Route 53 Resolver
  ↓ (Resolver Rule にマッチ)
Outbound Endpoint
  ↓ (転送)
オンプレミスDNS (10.20.0.53)
  ↓ (応答)
```

##### Resolver Query Logging
```
機能: DNS クエリログの記録
配信先:
- CloudWatch Logs
- S3
- Kinesis Data Firehose

ログ内容:
- クエリ名
- クエリタイプ（A、AAAA、MX等）
- 送信元IP
- クエリタイムスタンプ
- 応答コード

用途:
- セキュリティ監査
- トラブルシューティング
- コンプライアンス
```

#### DNSSEC（DNS Security Extensions）

##### 概要
```
目的: DNS応答の改ざん防止、真正性検証
仕組み:
1. ゾーンに公開鍵/秘密鍵ペア作成
2. DNSレコードに電子署名
3. クライアントが署名を検証

Route 53での対応:
- 署名: ✅ 対応
- 検証: ✅ 対応
- KSK（Key-Signing Key）管理: ✅ 対応
```

##### 設定手順
```
1. DNSSEC有効化:
aws route53 enable-hosted-zone-dnssec \
  --hosted-zone-id Z1234567890ABC

2. KSK作成（CloudHSM連携）:
- KMS CMKを使用
- またはCloudHSMで鍵管理

3. DS（Delegation Signer）レコード取得:
aws route53 get-dnssec \
  --hosted-zone-id Z1234567890ABC

4. 親ゾーンにDSレコード登録:
- ドメインレジストラに登録
- 例: example.com の DS レコードを .com ゾーンに登録

5. 検証:
dig +dnssec www.example.com
```

##### 制約
```
非対応:
- CloudFront ディストリビューション
- Alias レコード（一部）

対応:
- A、AAAA、CNAME、MX、TXT等の標準レコード
```

#### ヘルスチェック

##### エンドポイントヘルスチェック
```
チェック対象:
- IPアドレス（EC2、ELB等）
- ドメイン名

プロトコル:
- HTTP/HTTPS
- TCP

設定例:
aws route53 create-health-check \
  --caller-reference unique-string \
  --health-check-config \
    IPAddress=192.0.2.1,Port=80,Type=HTTP,ResourcePath=/health,\
    RequestInterval=30,FailureThreshold=3

パラメータ:
- RequestInterval: 30秒または10秒
- FailureThreshold: 連続失敗回数（デフォルト3回）
- HealthThreshold: 正常判定の成功回数

チェッカーの場所:
- 世界中の複数のRoute 53ヘルスチェッカー（15箇所以上）
- 過半数が正常 → ヘルシー
```

##### 算出ヘルスチェック
```
用途: 複数のヘルスチェックを組み合わせ
演算子:
- AND
- OR
- NOT

設定例:
HealthCheck-A: Web Server 1
HealthCheck-B: Web Server 2
HealthCheck-C: Database

算出ヘルスチェック:
(HealthCheck-A OR HealthCheck-B) AND HealthCheck-C

結果:
- いずれかのWebサーバー + DBが正常 → ヘルシー
```

##### CloudWatch Alarmベースのヘルスチェック
```
用途: CloudWatchメトリクスでヘルスチェック
例:
- ELBの健全なターゲット数
- RDSの接続数
- カスタムメトリクス

設定:
1. CloudWatch Alarmを作成
2. ヘルスチェックをAlarmと関連付け

aws route53 create-health-check \
  --caller-reference unique-string \
  --health-check-config \
    Type=CLOUDWATCH_METRIC,\
    AlarmIdentifier=CloudWatchRegion=us-east-1,Name=MyAlarm
```

#### Traffic Flow

##### 概要
```
機能: 視覚的なDNSルーティングポリシー設計
メリット:
- 複雑なルーティングを図で設計
- バージョン管理
- 再利用可能

料金: ポリシーレコードあたり$50/月
```

##### 設計例
```
レベル1: Geolocation（地域判定）
  ├→ Asia
  │   └→ Latency（アジア内で最適リージョン）
  │       ├→ ap-northeast-1 (Tokyo)
  │       └→ ap-southeast-1 (Singapore)
  ├→ Europe
  │   └→ Failover
  │       ├→ Primary: eu-west-1
  │       └→ Secondary: eu-central-1
  └→ Default
      └→ Weighted
          ├→ us-east-1 (70%)
          └→ us-west-2 (30%)
```

#### 試験頻出ポイント
- ✅ **7つのルーティングポリシー**を全て理解
- ✅ **Resolver Endpoint**: Inbound（オンプレ→VPC）、Outbound（VPC→オンプレ）
- ✅ **DNSSEC**: CloudFront非対応、親ゾーンへのDS登録必須
- ✅ **Alias レコード**: AWSリソース用、料金無料
- ✅ **ヘルスチェック**: 世界中のチェッカー、過半数判定

---

続きは次のレスポンスで作成します！

**進捗**: ドメイン1（ネットワーク設計）の3つの主要トピック（Transit Gateway、Direct Connect、Route 53）を完成させました。