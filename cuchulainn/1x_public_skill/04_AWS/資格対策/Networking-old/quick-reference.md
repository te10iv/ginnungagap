# AWS Advanced Networking Specialty - クイックリファレンス（短時間インプット用）

**目的**: 試験前の最終確認、移動時間での復習用  
**所要時間**: 30-40分で全体を確認

---

## 🎯 試験の基本情報

- **試験時間**: 170分（2時間50分）
- **問題数**: 65問
- **合格ライン**: 750/1000点
- **形式**: 選択問題（複数回答あり）

---

## 📊 ドメイン別出題比重

| ドメイン | 比重 |
|---------|------|
| 1. ネットワーク設計 | 30% |
| 2. ネットワーク実装 | 26% |
| 3. ネットワーク管理と運用 | 20% |
| 4. ネットワークセキュリティ、コンプライアンス | 24% |

---

## 🔴 ドメイン1: ネットワーク設計（30%）

### AWS Transit Gateway

#### 基本概念
- ✅ **役割**: VPC、VPN、Direct Connectを集約するハブ
- ✅ **最大接続数**: 5,000 VPCアタッチメント
- ✅ **ルーティング**: ルートテーブルで制御
- ✅ **帯域**: 最大50Gbps per VPC attachment

#### アタッチメントの種類

| 種類 | 用途 | 特徴 |
|------|------|------|
| **VPC** | VPC接続 | サブネットごとに接続 |
| **VPN** | Site-to-Site VPN | BGPサポート |
| **Direct Connect Gateway** | DX接続 | プライベートVIF経由 |
| **Peering** | 別リージョンのTGW | クロスリージョン |
| **Connect** | SD-WAN統合 | GRE + BGP |

#### ルートテーブル設計

##### パターン1: フルメッシュ（デフォルト）
```
すべてのVPCが相互通信可能
TGW Route Table:
- 10.0.0.0/16 → vpc-attachment-A
- 10.1.0.0/16 → vpc-attachment-B
- 192.168.0.0/16 → vpn-attachment
```

##### パターン2: ハブ&スポーク
```
共有サービスVPCを経由
Spoke Route Table:
- 0.0.0.0/0 → hub-vpc-attachment
Hub Route Table:
- 10.0.0.0/16 → spoke-vpc-A
- 10.1.0.0/16 → spoke-vpc-B
```

##### パターン3: セグメンテーション
```
環境ごとに分離（本番、開発、検証）
Production Route Table:
- 10.0.0.0/8 → production-vpcs only
Development Route Table:
- 10.1.0.0/8 → development-vpcs only
```

#### 試験頻出ポイント
- ✅ **ルートプロパゲーション**: 自動的にルートを追加
- ✅ **アソシエーション**: アタッチメントとルートテーブルの紐付け
- ✅ **Appliance Mode**: ステートフルインスペクション用
- ✅ **マルチキャスト**: UDP マルチキャストサポート

---

### AWS Direct Connect

#### 接続タイプ

| 種類 | 帯域 | 用途 |
|------|------|------|
| **Dedicated Connection** | 1/10/100 Gbps | 専用線 |
| **Hosted Connection** | 50M-10Gbps | パートナー経由 |

#### 仮想インターフェース（VIF）

##### 1. Private VIF
```
用途: VPC接続
接続先: Virtual Private Gateway または Direct Connect Gateway
VLAN: 必須
BGP: 必須
例: オンプレミス → VPC プライベート通信
```

##### 2. Public VIF
```
用途: AWSパブリックサービス接続（S3、DynamoDB等）
接続先: AWS パブリックエンドポイント
VLAN: 必須
BGP: 必須
例: オンプレミス → S3 パブリックIP経由
```

##### 3. Transit VIF
```
用途: Transit Gateway接続
接続先: Direct Connect Gateway → Transit Gateway
VLAN: 必須
BGP: 必須
例: オンプレミス → 複数VPCへの集約接続
```

#### Direct Connect Gateway

```
役割: 複数リージョンのVPC/TGWをDirect Connectで接続
制限:
- 最大10 Virtual Private Gateway
- または3 Transit Gateway
- リージョンをまたぐことが可能
```

#### 冗長性設計

##### 高可用性構成
```
必須要件:
1. 2つのDirect Connect ロケーション
2. 各ロケーションで2つの接続
3. 異なるデバイスに終端

結果: 4つのDirect Connect接続（2x2）
```

##### BGP設定のベストプラクティス
```
AS-PATH Prepending:
- プライマリパス: AS 65000
- セカンダリパス: AS 65000 65000 65000

BGP Community Tags:
- 7224:7100 → Low preference (backup)
- 7224:7200 → Medium preference
- 7224:7300 → High preference (primary)

Local Preference:
- VGW側でローカルプリファレンス設定
```

#### MACSec（Media Access Control Security）
```
機能: レイヤー2暗号化
対応: 10Gbps/100Gbps Dedicated Connection
用途: Direct Connect通信の暗号化
```

#### 試験頻出ポイント
- ✅ **LAG（Link Aggregation Group）**: 複数接続を束ねる
- ✅ **BGP ASN**: カスタムASN使用可能（64512-65534）
- ✅ **Jumbo Frame**: 最大9001 MTU
- ✅ **SLA**: 99.99%（冗長構成時）

---

### VPC設計の高度なトピック

#### VPC IPAM（IP Address Manager）
```
機能: IPアドレス管理の自動化
用途:
- CIDRの一元管理
- 重複防止
- 組織全体での可視化

設定例:
Pool Tier 1: 10.0.0.0/8 (Organization)
  ├── Pool Tier 2: 10.0.0.0/12 (Production)
  │   ├── VPC A: 10.0.0.0/16
  │   └── VPC B: 10.1.0.0/16
  └── Pool Tier 2: 10.16.0.0/12 (Development)
      └── VPC C: 10.16.0.0/16
```

#### Prefix List
```
機能: IPアドレス範囲のグループ化
用途:
- セキュリティグループでの参照
- ルートテーブルでの参照

例:
pl-12345678: 10.0.0.0/8, 192.168.0.0/16
→ セキュリティグループで "pl-12345678" を参照
```

---

### Amazon Route 53

#### ルーティングポリシー完全ガイド

##### 1. Simple（シンプル）
```
1レコード → 1つまたは複数の値（ランダム選択）
用途: 基本的なDNS解決
```

##### 2. Weighted（重み付け）
```
重み付けでトラフィック分散
例:
- record-1: 70% (weight: 70)
- record-2: 30% (weight: 30)
用途: A/Bテスト、Blue/Greenデプロイ
```

##### 3. Latency（レイテンシーベース）
```
最も低レイテンシーのリージョンに誘導
例:
- us-east-1: レコードA
- ap-northeast-1: レコードB
ユーザーの場所に基づいて最適なリージョン選択
```

##### 4. Failover（フェイルオーバー）
```
プライマリ/セカンダリ構成
例:
- Primary: us-east-1 (health check)
- Secondary: us-west-2 (failover)
プライマリ障害時にセカンダリに切り替え
```

##### 5. Geolocation（地理的位置）
```
ユーザーの地理的位置でルーティング
例:
- Asia → ap-northeast-1
- Europe → eu-west-1
- Default → us-east-1
```

##### 6. Geoproximity（地理的近接性）
```
地理的位置 + Bias（バイアス値）
例:
- us-east-1: bias +50 → 範囲拡大
- us-west-2: bias -50 → 範囲縮小
```

##### 7. Multi-value（複数値応答）
```
複数のIPアドレスを返す（最大8個）
各レコードにヘルスチェック可能
用途: シンプルな負荷分散
```

#### Route 53 Resolver

##### インバウンドエンドポイント
```
用途: オンプレミス → VPC のDNSクエリ
構成:
- 2つ以上のENI（高可用性）
- プライベートIPアドレス
- セキュリティグループで制御

例:
オンプレミスDNS → Resolver Inbound Endpoint → Route 53 Private Hosted Zone
```

##### アウトバウンドエンドポイント
```
用途: VPC → オンプレミス のDNSクエリ
構成:
- 2つ以上のENI
- Resolver Rule（転送ルール）

例:
VPC → Resolver Outbound Endpoint → オンプレミスDNS
転送ルール: example.local → 10.0.0.53
```

#### DNSSEC（DNS Security Extensions）
```
機能: DNS応答の真正性を検証
設定:
1. Route 53でDNSSEC有効化
2. KSK（Key-Signing Key）作成
3. DS（Delegation Signer）レコードを親ゾーンに登録

注意: CloudFrontではDNSSECサポートなし
```

#### 試験頻出ポイント
- ✅ **ヘルスチェック**: エンドポイントの死活監視
- ✅ **Alias レコード**: AWSリソースへのエイリアス（料金無料）
- ✅ **Traffic Flow**: 視覚的なルーティングポリシー設計
- ✅ **Private Hosted Zone**: VPC内のプライベートDNS

---

## 🟡 ドメイン2: ネットワーク実装（26%）

### AWS VPN

#### Site-to-Site VPN

##### 構成要素
```
1. Virtual Private Gateway (VGW) または Transit Gateway
2. Customer Gateway (CGW): オンプレミス側の設定
3. VPN Connection: 2つのIPsec トンネル（冗長性）
```

##### BGP設定
```
BGP ASN:
- AWS側: デフォルト 64512（カスタム可能）
- 顧客側: 65000-65534（プライベートASN）

ルート伝播:
- 動的ルーティング（BGP）→ 推奨
- 静的ルーティング → シンプルだが柔軟性低い
```

##### VPN CloudHub
```
用途: 複数拠点のVPN接続を集約
構成:
- 1つのVirtual Private Gateway
- 複数のVPN接続（各拠点）
- BGPで拠点間ルーティング

例:
拠点A ←→ VPN CloudHub ←→ 拠点B
      (VPC経由で拠点間通信可能)
```

##### Accelerated VPN
```
機能: AWS Global Acceleratorを使用してVPN高速化
メリット:
- 低レイテンシー
- パケットロス削減
- グローバルネットワーク利用

追加料金: あり
```

#### Client VPN（リモートアクセスVPN）
```
用途: リモートユーザーのVPCアクセス
認証:
- Active Directory
- SAML 2.0
- 相互認証（証明書）

構成:
- Client VPN Endpoint
- ターゲットネットワーク（VPCサブネット）
- 認可ルール

帯域: 各接続最大10Gbps
```

#### 試験頻出ポイント
- ✅ **2つのトンネル**: 冗長性のため常に2つ
- ✅ **MTU**: 1399バイト（IPsec オーバーヘッド）
- ✅ **IKE/IPsec**: Phase 1/Phase 2 パラメータ
- ✅ **DPD（Dead Peer Detection）**: トンネル死活監視

---

### AWS PrivateLink

#### 基本概念
```
役割: VPCエンドポイント経由でサービスをプライベート公開
メリット:
- インターネット経由不要
- セキュアな通信
- クロスアカウント対応
```

#### 構成

##### サービスプロバイダー側
```
1. NLB（Network Load Balancer）作成
2. VPCエンドポイントサービス作成
3. サービス名を共有（com.amazonaws.vpce.region.vpce-svc-xxxxx）
4. 接続許可の設定
```

##### サービスコンシューマー側
```
1. Interface VPC Endpoint作成
2. サービス名を指定
3. セキュリティグループ設定
4. プライベートDNS有効化（オプション）
```

#### エンドポイントポリシー
```json
{
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

#### 試験頻出ポイント
- ✅ **NLB必須**: PrivateLinkはNLBのみサポート
- ✅ **クロスアカウント**: 異なるAWSアカウント間で共有可能
- ✅ **料金**: $0.01/時間 + データ処理料
- ✅ **AZ単位**: サブネットごとにENI作成

---

### Elastic Load Balancing（ネットワーク観点）

#### NLB（Network Load Balancer）

##### 特徴
```
レイヤー: L4（TCP/UDP/TLS）
性能: 数百万RPS、超低レイテンシー
送信元IP: クライアントIPが保持される
固定IP: Elastic IP割り当て可能
```

##### クロスゾーン負荷分散
```
有効時: すべてのAZのターゲットに均等分散
無効時: 各AZ内のターゲットのみに分散

デフォルト: 無効（NLB）、有効（ALB）

料金: クロスAZデータ転送料金が発生
```

##### Proxy Protocol
```
用途: クライアントIPアドレスをターゲットに伝達
バージョン:
- Proxy Protocol v1（テキスト形式）
- Proxy Protocol v2（バイナリ形式）

設定: ターゲットグループ属性で有効化
```

#### 試験頻出ポイント
- ✅ **ターゲットタイプ**: Instance、IP、Lambda、ALB
- ✅ **ヘルスチェック**: TCP、HTTP、HTTPS
- ✅ **TLS Termination**: NLBでTLS終端可能
- ✅ **Connection Draining**: 登録解除時の既存接続処理

---

## 🟢 ドメイン3: ネットワーク管理と運用（20%）

### VPCフローログ

#### ログフォーマット（重要フィールド）
```
srcaddr: 送信元IPアドレス
dstaddr: 宛先IPアドレス
srcport: 送信元ポート
dstport: 宛先ポート
protocol: プロトコル番号（6=TCP, 17=UDP, 1=ICMP）
packets: パケット数
bytes: バイト数
action: ACCEPT または REJECT
log-status: OK, NODATA, SKIPDATA
```

#### トラブルシューティング

##### REJECTの原因特定
```
パターン1: セキュリティグループ
- インバウンド: REJECT
- アウトバウンド: レコードなし（ステートフル）

パターン2: NACL
- インバウンド: REJECT
- アウトバウンド: REJECT（ステートレス）

判定方法:
両方向REJECTあり → NACL
片方向REJECTのみ → セキュリティグループ
```

#### CloudWatch Logs Insightsクエリ例

##### Top Talkers（通信量上位）
```sql
fields @timestamp, srcaddr, dstaddr, bytes
| stats sum(bytes) as totalBytes by srcaddr, dstaddr
| sort totalBytes desc
| limit 10
```

##### REJECTされた通信
```sql
fields @timestamp, srcaddr, dstaddr, srcport, dstport, action
| filter action = "REJECT"
| stats count() by srcaddr, dstport
| sort count desc
```

#### 試験頻出ポイント
- ✅ **3つの配信先**: CloudWatch Logs、S3、Kinesis Data Firehose
- ✅ **3つのレベル**: VPC、サブネット、ENI
- ✅ **パケット内容は記録されない**: メタデータのみ
- ✅ **5タプル**: 送信元IP/ポート、宛先IP/ポート、プロトコル

---

### Amazon CloudWatch

#### ネットワークメトリクス

##### VPC
```
- BytesIn/BytesOut
- PacketsIn/PacketsOut
- PacketsDroppedBySecurityGroup
```

##### Direct Connect
```
- ConnectionBpsEgress/Ingress
- ConnectionPpsEgress/Ingress
- ConnectionState
- ConnectionLightLevelTx/Rx
```

##### Transit Gateway
```
- BytesIn/BytesOut (per attachment)
- PacketsIn/PacketsOut
- PacketDropCountBlackhole
- PacketDropCountNoRoute
```

##### VPN
```
- TunnelState
- TunnelDataIn/Out
```

#### アラーム設定例
```
Direct Connect光レベル監視:
Metric: ConnectionLightLevelTx
Threshold: < -2.0 dBm
Action: SNS通知

VPNトンネルダウン検知:
Metric: TunnelState
Threshold: == 0 (DOWN)
Duration: 1 data point within 5 minutes
Action: SNS通知 + Lambda自動修復
```

---

### Reachability Analyzer

#### 概要
```
機能: ネットワーク到達可能性の分析
対象: EC2、VPC、Internet Gateway、VPN等
結果: 到達可能/不可 + 詳細パス

メリット:
- パケット送信不要
- 構成のみで判定
- ホップバイホップ分析
```

#### 分析例
```
ソース: EC2インスタンス（10.0.1.10）
宛先: RDSエンドポイント（10.0.2.50:3306）

結果: Reachable ✅
パス:
1. EC2 ENI
2. Security Group (allow outbound)
3. Subnet Route Table
4. NACL (allow outbound)
5. NACL (allow inbound)
6. RDS ENI
7. Security Group (allow inbound 3306)
```

#### 試験頻出ポイント
- ✅ **静的分析**: 実際のパケット送信なし
- ✅ **パス可視化**: ホップバイホップで表示
- ✅ **料金**: 分析1回あたり $0.10

---

## 🔵 ドメイン4: ネットワークセキュリティ（24%）

### AWS Network Firewall

#### ルールタイプ

##### 1. ステートレスルール
```
特徴: 5-tuple（送信元/宛先IP、ポート、プロトコル）で判定
評価: 優先度順
アクション: Pass、Drop、Forward to stateful

例:
Rule 1 (Priority 100): 
  Protocol: TCP
  Source: 0.0.0.0/0
  Destination Port: 443
  Action: Pass
```

##### 2. ステートフルルール
```
特徴: 接続追跡、戻りトラフィック自動許可
形式:
- Domain list（ドメイン名ベース）
- Suricata compatible（IPS/IDSルール）
- Standard 5-tuple

例（Suricata形式）:
alert tcp any any -> any 22 (msg:"SSH Brute Force"; threshold:type threshold, track by_src, count 10, seconds 60; sid:1000001;)
```

#### ルールグループ

##### ドメインリスト例
```
ブロックリスト:
- .malware.com
- .phishing.com
- .tor-exit-node.net

許可リスト:
- .amazonaws.com
- .example.com
```

##### Suricataルール例
```
# SQL Injection検出
alert tcp any any -> any any (msg:"SQL Injection"; content:"UNION SELECT"; nocase; sid:1000002;)

# コマンドインジェクション
alert tcp any any -> any any (msg:"Command Injection"; content:"|3b|/bin/"; sid:1000003;)

# 暗号通貨マイニング通信
alert tcp any any -> any 3333 (msg:"Crypto Mining Stratum"; sid:1000004;)
```

#### 試験頻出ポイント
- ✅ **ステートフル推奨**: ほとんどの用途で推奨
- ✅ **優先順位**: ステートレス → ステートフル
- ✅ **TLS検査**: 可能（証明書インポート必要）
- ✅ **ログ**: Alert、Flow（CloudWatch Logs、S3、Kinesis Data Firehose）

---

### AWS WAF（ネットワーク観点）

#### レート制限ルール
```
用途: DDoS対策、API保護
集約単位:
- IP
- Forwarded-IP（X-Forwarded-For）
- Custom key

例:
Limit: 2000 requests per 5 minutes per IP
Action: Block for 10 minutes
```

#### Geo Match
```
国コードベースのブロック/許可
例:
Block: CN, RU, KP
Allow: JP, US, EU countries
```

#### 試験頻出ポイント
- ✅ **統合先**: CloudFront、ALB、API Gateway、AppSync
- ✅ **Web ACL**: ルールの集合、デフォルトアクション
- ✅ **カウントモード**: テストに有用（アクションなし）
- ✅ **WCU（Web ACL Capacity Units）**: 最大5,000 WCU

---

### AWS Shield

#### Shield Standard（無料）
```
保護対象: すべてのAWSカスタマー
レイヤー: L3/L4
自動保護: はい
```

#### Shield Advanced（$3,000/月）
```
保護対象: CloudFront、Route 53、ELB、EIP、Global Accelerator
レイヤー: L3/L4/L7
特徴:
- DRT（DDoS Response Team）サポート
- コスト保護（攻撃時の追加料金を補償）
- リアルタイム攻撃通知
- WAFルール自動適用
```

#### 試験頻出ポイント
- ✅ **Shield Advanced必須要件**: WAF有効化が推奨
- ✅ **SLA**: 99.99%（Shield Advanced）
- ✅ **検出時間**: 数秒〜数分

---

## ⚡ 頻出試験パターン

### パターン1: Transit Gateway vs VPC Peering
```
Q: 100個のVPCを接続する最適な方法は？
A: Transit Gateway
理由: VPC Peeringは n(n-1)/2 = 4,950接続が必要（管理困難）

Q: 2つのVPCを低レイテンシーで接続するには？
A: VPC Peering
理由: Transit Gatewayより低レイテンシー、料金も安い
```

### パターン2: Direct Connect vs VPN
```
Q: 安定した高帯域接続が必要な場合は？
A: Direct Connect
理由: 専用線、低レイテンシー、最大100Gbps

Q: すぐに接続が必要、初期費用を抑えたい場合は？
A: VPN
理由: インターネット経由、数分で開通、初期費用なし
```

### パターン3: Route 53 ルーティングポリシー選択
```
Q: 災害対策でセカンダリリージョンにフェイルオーバーするには？
A: Failover ルーティング

Q: 複数リージョンで最も近いエンドポイントに誘導するには？
A: Geolocation または Geoproximity

Q: Blue/Greenデプロイで段階的に切り替えるには？
A: Weighted ルーティング
```

### パターン4: PrivateLink vs VPC Peering
```
Q: 数百のアカウントにサービスを公開するには？
A: PrivateLink
理由: スケーラブル、個別のPeering不要

Q: 2つのVPC間でフルアクセスが必要な場合は？
A: VPC Peering
理由: すべてのリソースにアクセス可能
```

---

## 🎯 試験直前チェックリスト

### Transit Gateway
- [ ] ルートテーブルとアタッチメントの関係
- [ ] アソシエーション vs プロパゲーション
- [ ] Appliance Mode用途
- [ ] マルチキャスト設定

### Direct Connect
- [ ] VIFの3種類（Private、Public、Transit）
- [ ] Direct Connect Gateway役割
- [ ] BGP設定（AS-PATH、Community）
- [ ] 冗長性設計（2x2）

### Route 53
- [ ] 7つのルーティングポリシー
- [ ] Resolver（Inbound/Outbound）
- [ ] DNSSEC設定
- [ ] ヘルスチェック設定

### VPN
- [ ] Site-to-Site VPN（2トンネル）
- [ ] Client VPN認証方式
- [ ] VPN CloudHub
- [ ] Accelerated VPN

### PrivateLink
- [ ] NLB + VPCエンドポイントサービス
- [ ] クロスアカウント共有
- [ ] エンドポイントポリシー
- [ ] プライベートDNS

### VPCフローログ
- [ ] ACCEPT/REJECTの判定方法
- [ ] セキュリティグループ vs NACL判別
- [ ] CloudWatch Logs Insightsクエリ
- [ ] 3つの配信先

### Network Firewall
- [ ] ステートレス vs ステートフル
- [ ] Suricataルール構文
- [ ] ドメインリスト
- [ ] TLS検査

---

## 💡 試験当日のTips

### 時間配分
- **170分 ÷ 65問 = 約2.6分/問**
- 見直し時間を考慮すると **2分/問** が目安

### 問題の読み方
1. **ネットワーク構成図を描く**: 複雑なシナリオは図示
2. **要件を明確化**: 「最も低コスト」「最低レイテンシー」等
3. **除外条件**: 「〜を使用せずに」に注意
4. **数値チェック**: CIDR、ASN、ポート番号の整合性

### 迷ったら
- BGPルーティングはAS-PATH短い方が優先
- レイテンシー重視 → VPC Peering、Direct Connect
- スケーラビリティ重視 → Transit Gateway、PrivateLink
- コスト重視 → VPN、VPC Peering

---

## 📚 重要サービス優先順位

### 超重要（必ず深く理解）
1. Transit Gateway（ルーティング設計）
2. Direct Connect（VIF、BGP）
3. Route 53（ルーティングポリシー、Resolver）
4. VPN（Site-to-Site、Client VPN）
5. VPCフローログ（トラブルシューティング）

### 重要（確実に理解）
6. PrivateLink（エンドポイントサービス）
7. Network Firewall（Suricataルール）
8. Global Accelerator（Anycast）
9. NLB（クロスゾーン、Proxy Protocol）
10. VPC IPAM

### 理解必須（基本は押さえる）
11. CloudFront（Lambda@Edge）
12. WAF（レート制限）
13. Shield（Standard/Advanced）
14. Reachability Analyzer
15. CloudWatch（ネットワークメトリクス）

---

**次のステップ**: [詳細ガイド](guide.md) で各トピックを深く学習

**最終更新**: 2024年1月
