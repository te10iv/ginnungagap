# AWS Advanced Networking Specialty - 模擬問題集

試験形式に近い問題で実力チェック

---

## 📋 使い方

- **問題数**: 20問（実際の試験は65問）
- **目標時間**: 50分（実際の試験は170分）
- **合格ライン**: 14問以上正解（70%）
- **形式**: 単一選択・複数選択（複数選択は明記）

---

## 問題1: Transit Gateway ルーティング設計

貴社は100個のVPCを管理しており、以下の要件があります：
- 本番環境VPC（50個）と開発環境VPC（50個）を完全に分離
- 各環境内では全VPCが相互通信可能
- 共有サービスVPC（1個）には両環境からアクセス可能

最も適切なTransit Gateway設計はどれですか？

A. 1つのTransit Gatewayと1つのルートテーブルで全VPCを接続し、セキュリティグループで制御する

B. 2つのTransit Gateway（本番用、開発用）を作成し、共有サービスVPCは両方に接続する

C. 1つのTransit Gatewayと3つのルートテーブル（本番用、開発用、共有サービス用）を作成し、プロパゲーションで制御する

D. VPC Peeringを使用して各VPCを直接接続する

<details>
<summary>正解と解説</summary>

**正解: C**

**解説**:

**Cが正解の理由**:
1. **コスト効率**: 1つのTransit Gatewayで管理（Transit Gateway料金削減）
2. **セグメンテーション**: ルートテーブルで環境を論理的に分離
3. **柔軟性**: プロパゲーションで動的にルート管理

**設計詳細**:
```yaml
Transit Gateway: tgw-main

本番環境ルートテーブル:
  アソシエーション: 本番VPC 1-50
  プロパゲーション: 本番VPC 1-50, 共有サービスVPC

開発環境ルートテーブル:
  アソシエーション: 開発VPC 1-50
  プロパゲーション: 開発VPC 1-50, 共有サービスVPC

共有サービスルートテーブル:
  アソシエーション: 共有サービスVPC
  プロパゲーション: 本番VPC 1-50, 開発VPC 1-50

結果:
- 本番 ↔ 本番: ✅
- 開発 ↔ 開発: ✅
- 本番 ↔ 共有: ✅
- 開発 ↔ 共有: ✅
- 本番 ↔ 開発: ❌（分離）
```

**Aが不正解の理由**:
- セキュリティグループはVPC内のリソース制御用
- VPC間の分離には不適切

**Bが不正解の理由**:
- コストが2倍（Transit Gateway 2つ）
- 共有サービスVPCの二重管理が複雑

**Dが不正解の理由**:
- 100個のVPC → 約5,000のピアリング接続が必要
- 管理困難、スケールしない

**関連キーワード**: Transit Gateway, ルートテーブル, プロパゲーション, セグメンテーション

</details>

---

## 問題2: Direct Connect 冗長性設計

貴社はオンプレミスデータセンターとAWSを接続する高可用性Direct Connect構成を設計しています。99.99%のSLAを満たす必要があります。

どの構成が最も適切ですか？

A. 1つのDirect Connectロケーションに2つの接続を配置する

B. 2つのDirect Connectロケーションにそれぞれ1つの接続を配置する

C. 2つのDirect Connectロケーションにそれぞれ2つの接続を配置する（計4接続）

D. 1つのDirect Connect接続と1つのVPNバックアップを使用する

<details>
<summary>正解と解説</summary>

**正解: C**

**解説**:

**Cが正解の理由**:
- **99.99% SLA達成**: AWSが保証する最高SLA
- **完全冗長性**: 
  - 2つの異なるロケーション → ロケーション障害に対応
  - 各ロケーションで2接続 → 単一接続障害に対応
  - 異なるエッジルーター → デバイス障害に対応

**構成図**:
```
オンプレミス
├─ ルーター1
│  ├→ DX Location A - Connection 1 (10Gbps)
│  └→ DX Location A - Connection 2 (10Gbps)
└─ ルーター2
   ├→ DX Location B - Connection 1 (10Gbps)
   └→ DX Location B - Connection 2 (10Gbps)

合計: 4 × 10Gbps = 40Gbps（冗長構成）
```

**BGP設定**:
```
プライマリパス（Location A）:
- AS-PATH: 65000

セカンダリパス（Location B）:
- AS-PATH: 65000 65000 65000（Prepending）

結果: Location A優先、障害時にLocation B自動切り替え
```

**Aが不正解の理由**:
- 単一ロケーション → ロケーション障害で全断
- 99.9% SLA（99.99%未達）

**Bが不正解の理由**:
- 各ロケーション単一接続 → 接続障害で50%ダウン
- 99.9% SLA

**Dが不正解の理由**:
- VPNは最大1.25Gbps/トンネル → 帯域不足の可能性
- フェイルオーバー時のパフォーマンス低下

**関連キーワード**: Direct Connect, 冗長性, SLA, 高可用性

</details>

---

## 問題3: Route 53 ルーティングポリシー選択

グローバルWebアプリケーションで以下の要件があります：
- 米国ユーザーは米国リージョンに誘導
- 日本ユーザーは日本リージョンに誘導
- 各リージョンで障害発生時は別リージョンにフェイルオーバー

どのRoute 53設定が最適ですか？

A. Geolocation ルーティングポリシー

B. Latency ルーティングポリシー

C. Geolocation + Failover の組み合わせ（ネストポリシー）

D. Multi-value Answer ルーティングポリシー

<details>
<summary>正解と解説</summary>

**正解: C**

**解説**:

**Cが正解の理由**:
地理的位置による振り分け + 障害時のフェイルオーバーを両立

**設定例**:
```yaml
# レベル1: Geolocation（地域判定）
レコードセット1:
  Name: www.example.com
  Type: A
  SetID: US-Geolocation
  Geolocation: 
    CountryCode: US
  AliasTarget: us-failover-alias

レコードセット2:
  Name: www.example.com
  Type: A
  SetID: JP-Geolocation
  Geolocation:
    CountryCode: JP
  AliasTarget: jp-failover-alias

# レベル2: Failover（各地域内で冗長性）
# 米国フェイルオーバー
us-failover-alias:
  Primary: us-east-1 (ヘルスチェック付き)
  Secondary: us-west-2

# 日本フェイルオーバー
jp-failover-alias:
  Primary: ap-northeast-1 (ヘルスチェック付き)
  Secondary: ap-southeast-1

動作:
1. 米国ユーザー → us-east-1（正常）
2. us-east-1障害 → us-west-2に自動切替
3. 日本ユーザー → ap-northeast-1（正常）
4. ap-northeast-1障害 → ap-southeast-1に自動切替
```

**Aが不正解の理由**:
- フェイルオーバー機能なし
- 障害時の対応不可

**Bが不正解の理由**:
- 地理的な制御ができない
- レイテンシーベースのため、予期しないリージョンに誘導される可能性

**Dが不正解の理由**:
- 地理的制御なし
- ランダム選択のため要件を満たさない

**関連キーワード**: Route 53, Geolocation, Failover, ヘルスチェック

</details>

---

## 問題4: BGP AS-PATH Prepending

オンプレミスネットワークには2つのDirect Connect接続（プライマリとセカンダリ）があります。通常時はプライマリを使用し、障害時のみセカンダリを使用したい。

どのBGP設定が適切ですか？（複数選択）

A. プライマリ接続でAS-PATHをそのまま広告する  
B. セカンダリ接続でAS-PATH Prependingを使用する  
C. BGP Local Preferenceをセカンダリで高く設定する  
D. BGP MEDをプライマリで低く設定する  
E. プライマリのBGP Weight値を高く設定する

<details>
<summary>正解と解説</summary>

**正解: A, B**

**解説**:

**A, Bが正解の理由**:
AS-PATH Prependingは標準的な経路制御手法

**設定例（Cisco）**:
```cisco
! プライマリ接続（AS-PATHそのまま）
route-map SET-PRIMARY permit 10
 ! 何もしない（AS-PATHは最短）
 exit

! セカンダリ接続（AS-PATH Prepending）
route-map SET-SECONDARY permit 10
 set as-path prepend 65000 65000 65000
 exit

router bgp 65000
 neighbor 169.254.1.1 route-map SET-PRIMARY out     ! プライマリ
 neighbor 169.254.2.1 route-map SET-SECONDARY out  ! セカンダリ
 exit

結果:
プライマリ: AS-PATH = 65000
セカンダリ: AS-PATH = 65000 65000 65000 65000

AWS側の選択: プライマリ（AS-PATH短い方が優先）
```

**動作**:
```
通常時:
オンプレミス → AWS トラフィック
  ↓ プライマリDX（AS-PATH短い）✅

AWS → オンプレミス トラフィック
  ↓ プライマリDX（AS-PATH短い）✅

プライマリ障害時:
両方向とも自動的にセカンダリDXに切り替え
```

**Cが不正解の理由**:
- Local Preferenceは**受信側（AWS側）**で設定
- 顧客側では設定不可
- （AWS側ではVPN=200、DX=100がデフォルト）

**Dが不正解の理由**:
- MED（Multi-Exit Discriminator）は同一AS間でのみ有効
- Direct Connect（異なるAS間）では効果なし

**Eが不正解の理由**:
- Weight値はCisco独自の属性
- ローカルルーター内でのみ有効
- AWS側に伝播しない

**BGP属性の優先順位（復習）**:
```
1. Weight（Ciscoのみ、ローカル）
2. Local Preference（AS内）
3. AS-PATH（短い方が優先）← 今回使用
4. Origin
5. MED（同一AS間）
```

**関連キーワード**: BGP, AS-PATH Prepending, 経路制御, Direct Connect

</details>

---

## 問題5: VPN ECMP設計

オンプレミスとTransit Gateway間でVPN接続を使用しています。単一VPN接続（2トンネル）の帯域制限（2.5Gbps）を超える必要があります。

どの設計が最適ですか？

A. 1つのVPN接続のトンネル数を4つに増やす

B. 同じCustomer Gatewayで複数のVPN接続を作成し、ECMPを有効化する

C. Direct Connectに切り替える

D. Accelerated VPNを使用する

<details>
<summary>正解と解説</summary>

**正解: B**

**解説**:

**Bが正解の理由**:
ECMP（Equal-Cost Multi-Path）で複数VPN接続を負荷分散

**設計**:
```
制約:
- 1 VPN接続 = 2トンネル
- 1トンネル = 最大1.25Gbps
- 1 VPN接続 = 最大2.5Gbps

必要帯域: 5Gbps以上

解決策:
VPN接続1（CGW-1）: トンネル1 + トンネル2 = 2.5Gbps
VPN接続2（CGW-1）: トンネル1 + トンネル2 = 2.5Gbps
合計: 5Gbps

構成:
aws ec2 create-vpn-connection \
  --type ipsec.1 \
  --customer-gateway-id cgw-xxxxx \
  --transit-gateway-id tgw-xxxxx

aws ec2 create-vpn-connection \
  --type ipsec.1 \
  --customer-gateway-id cgw-xxxxx \  # 同じCGW
  --transit-gateway-id tgw-xxxxx

Transit Gateway設定:
- VPN ECMP Support: Enabled（デフォルト）

BGP設定（Cisco）:
router bgp 65000
 address-family ipv4
  maximum-paths 4  # ECMP有効化
  neighbor 169.254.1.1 activate  # VPN1-Tunnel1
  neighbor 169.254.1.5 activate  # VPN1-Tunnel2
  neighbor 169.254.2.1 activate  # VPN2-Tunnel1
  neighbor 169.254.2.5 activate  # VPN2-Tunnel2
 exit-address-family
```

**動作**:
```
AWS → オンプレミス (5Gbpsトラフィック):
- 25% → VPN1-Tunnel1 (1.25Gbps)
- 25% → VPN1-Tunnel2 (1.25Gbps)
- 25% → VPN2-Tunnel1 (1.25Gbps)
- 25% → VPN2-Tunnel2 (1.25Gbps)

合計: 5Gbps
```

**Aが不正解の理由**:
- 1 VPN接続は常に2トンネル固定
- トンネル数を変更不可

**Cが不正解の理由**:
- Direct Connectは有効な選択肢だが「最適」ではない
- 理由:
  - プロビジョニング時間が長い（1-2週間）
  - コストが高い
  - 質問は「帯域拡張」が焦点

**Dが不正解の理由**:
- Accelerated VPNは**レイテンシー削減**が目的
- 帯域制限は変わらない（1.25Gbps/トンネル）

**関連キーワード**: VPN, ECMP, Transit Gateway, 帯域拡張

</details>

---

## 問題6: Route 53 Resolver設計

ハイブリッドクラウド環境で以下の要件があります：
- オンプレミスからVPC内のプライベートホストゾーン（internal.example.com）を解決したい
- VPCからオンプレミスのドメイン（corp.example.com）を解決したい

必要な設定を**すべて**選択してください。（複数選択）

A. Route 53 Resolver Inbound Endpoint を作成する  
B. Route 53 Resolver Outbound Endpoint を作成する  
C. Resolver Rule（FORWARD）を作成し、corp.example.comをオンプレミスDNSに転送する  
D. オンプレミスDNSサーバーをInbound EndpointのIPアドレスに転送する設定を追加する  
E. VPCのDHCPオプションセットを変更する

<details>
<summary>正解と解説</summary>

**正解: A, B, C, D**

**解説**:

**必要な設定**:

**1. Inbound Endpoint（オンプレ → VPC）**:
```yaml
用途: オンプレミスからVPCのDNSクエリ解決

作成:
aws route53resolver create-resolver-endpoint \
  --direction INBOUND \
  --security-group-ids sg-xxxxx \
  --ip-addresses \
    SubnetId=subnet-1,Ip=10.0.1.10 \
    SubnetId=subnet-2,Ip=10.0.2.10

結果:
- Inbound Endpoint IP: 10.0.1.10, 10.0.2.10
```

**2. Outbound Endpoint（VPC → オンプレ）**:
```yaml
用途: VPCからオンプレミスのDNSクエリ転送

作成:
aws route53resolver create-resolver-endpoint \
  --direction OUTBOUND \
  --security-group-ids sg-xxxxx \
  --ip-addresses SubnetId=subnet-3 SubnetId=subnet-4
```

**3. Resolver Rule（C）**:
```yaml
用途: corp.example.com ドメインをオンプレミスDNSに転送

作成:
aws route53resolver create-resolver-rule \
  --rule-type FORWARD \
  --domain-name corp.example.com \
  --target-ips Ip=10.20.0.53,Port=53 \  # オンプレDNS
  --resolver-endpoint-id rslvr-out-xxxxx

VPCに関連付け:
aws route53resolver associate-resolver-rule \
  --resolver-rule-id rslvr-rr-xxxxx \
  --vpc-id vpc-xxxxx
```

**4. オンプレミスDNS設定（D）**:
```bind
# /etc/named.conf または /etc/bind/named.conf

zone "internal.example.com" {
    type forward;
    forward only;
    forwarders {
        10.0.1.10;  # Inbound Endpoint IP 1
        10.0.2.10;  # Inbound Endpoint IP 2
    };
};

zone "compute.internal" {  # VPCのデフォルトドメイン
    type forward;
    forward only;
    forwarders {
        10.0.1.10;
        10.0.2.10;
    };
};
```

**クエリフロー**:
```
オンプレ → VPC:
オンプレアプリ
  ↓ (クエリ: db.internal.example.com)
オンプレDNS
  ↓ (転送)
Inbound Endpoint (10.0.1.10)
  ↓
Route 53 Private Hosted Zone
  ↓ (応答: 10.0.10.100)

VPC → オンプレ:
VPC内EC2
  ↓ (クエリ: server.corp.example.com)
Route 53 Resolver
  ↓ (Resolver Ruleにマッチ)
Outbound Endpoint
  ↓ (転送)
オンプレDNS (10.20.0.53)
  ↓ (応答)
```

**Eが不正解の理由**:
- VPCのDHCPオプションセットはデフォルトで「AmazonProvidedDNS」
- Route 53 Resolverは自動的にこれを使用
- 変更不要

**関連キーワード**: Route 53 Resolver, ハイブリッドDNS, Inbound Endpoint, Outbound Endpoint

</details>

---

## 問題7: VPCエンドポイント vs PrivateLink

以下のシナリオで、最も適切な選択肢はどれですか？

**シナリオ**: 自社の SaaS サービスを100社の顧客AWSアカウントに提供したい。各顧客はVPCからプライベート接続でサービスにアクセスする必要がある。

A. 各顧客とVPC Peeringを設定する

B. AWS PrivateLinkでエンドポイントサービスを公開する

C. Gateway VPCエンドポイントを使用する

D. Transit Gatewayで各顧客VPCを接続する

<details>
<summary>正解と解説</summary>

**正解: B**

**解説**:

**Bが正解の理由**:
AWS PrivateLinkは大規模なSaaS提供に最適

**アーキテクチャ**:
```
サービスプロバイダー側（自社）:
1. Network Load Balancer作成
2. VPCエンドポイントサービス作成
3. サービス名を顧客に共有
   例: com.amazonaws.vpce.us-east-1.vpce-svc-xxxxx

サービスコンシューマー側（各顧客）:
1. Interface VPCエンドポイント作成
2. サービス名を指定
3. 接続リクエスト送信

プロバイダー側で承認:
aws ec2 accept-vpc-endpoint-connections \
  --service-id vpce-svc-xxxxx \
  --vpc-endpoint-ids vpce-customer1 vpce-customer2 ...

結果:
- 100社の顧客が個別にInterface Endpointを作成
- プロバイダーは1つのエンドポイントサービスで管理
- 各顧客のVPCは完全に分離
```

**メリット**:
```
スケーラビリティ:
- 数千の顧客に対応可能
- プロバイダー側の管理が簡単

セキュリティ:
- VPC間の直接接続なし
- 顧客のIPアドレス範囲を知る必要なし

料金:
- 顧客側: $0.01/時間/endpoint + データ処理料
- プロバイダー側: 無料（NLB料金のみ）

プライベートDNS:
- 顧客VPC内でカスタムDNS名を使用可能
```

**Aが不正解の理由**:
- 100社 × VPC Peering = 管理不可能
- IPアドレス範囲の重複問題
- 双方向の設定が必要（非効率）

**Cが不正解の理由**:
- Gateway Endpointは**S3とDynamoDBのみ**
- カスタムサービスには使用不可

**Dが不正解の理由**:
- Transit Gateway接続は「協調的な接続」向け
- SaaS提供には不適切
- 料金が高い（各顧客がTGW料金負担）
- セキュリティリスク（VPC間ルーティング）

**関連キーワード**: PrivateLink, VPCエンドポイントサービス, SaaS, スケーラビリティ

</details>

---

## 問題8: Network Firewall vs Security Group vs NACL

以下のセキュリティ要件を満たす最適な組み合わせを選択してください。（複数選択）

**要件**:
- 特定のドメイン（malware.com）へのアウトバウンド通信をブロックしたい
- SQLインジェクション攻撃のパターンをブロックしたい
- EC2インスタンスへのSSHアクセスを特定のIPアドレスのみ許可したい

A. Security GroupでSSH（ポート22）を特定IPからのみ許可する  
B. NACLで特定ドメインをブロックする  
C. AWS Network Firewallでドメインブロックリストを設定する  
D. AWS Network FirewallでSuricataルールを使用してSQLインジェクションをブロックする  
E. Security GroupでSQLインジェクションをブロックする

<details>
<summary>正解と解説</summary>

**正解: A, C, D**

**解説**:

**A: セキュリティグループでSSH制御**:
```yaml
要件: EC2へのSSHアクセスを特定IPのみ許可

設定:
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 22 \
  --cidr 203.0.113.0/24

適している理由:
- セキュリティグループはステートフル
- インスタンスレベルの制御に最適
- シンプルな設定
```

**C: Network Firewallでドメインブロック**:
```yaml
要件: 特定ドメインへのアウトバウンド通信をブロック

設定:
# ドメインリストルールグループ作成
aws network-firewall create-rule-group \
  --rule-group-name block-malicious-domains \
  --type STATEFUL \
  --rule-group '{
    "RulesSource": {
      "RulesSourceList": {
        "TargetTypes": ["HTTP_HOST", "TLS_SNI"],
        "Targets": [".malware.com", ".phishing.com"],
        "GeneratedRulesType": "DENYLIST"
      }
    }
  }'

適している理由:
- ドメイン名ベースのフィルタリング
- HTTPS/TLS SNI検査可能
- セキュリティグループやNACLでは不可能
```

**D: Network FirewallでSQLインジェクション検出**:
```yaml
要件: SQLインジェクション攻撃のブロック

設定（Suricataルール）:
alert tcp any any -> any any (
  msg:"SQL Injection Attempt";
  flow:to_server;
  content:"UNION SELECT";
  nocase;
  sid:1000001;
  rev:1;
)

alert tcp any any -> any any (
  msg:"SQL Injection - OR 1=1";
  flow:to_server;
  content:"OR 1=1";
  nocase;
  sid:1000002;
  rev:1;
)

適している理由:
- ディープパケットインスペクション（DPI）
- パターンマッチングでペイロード検査
- IDS/IPS機能
```

**Bが不正解の理由**:
```
NACLの制約:
- IPアドレスベースのフィルタリングのみ
- ドメイン名はサポートされない
- DNSクエリ結果のIPアドレスは動的に変わるため不適切

例:
malware.com → 198.51.100.10（今日）
malware.com → 198.51.100.11（明日）
→ NACLでは対応不可
```

**Eが不正解の理由**:
```
セキュリティグループの制約:
- L4（ポート、プロトコル）レベルの制御のみ
- ペイロード（L7）の検査不可
- SQLインジェクションは**アプリケーション層（L7）**の攻撃
- セキュリティグループでは検出・ブロック不可

適切な対策:
- AWS WAF（Webアプリケーションの場合）
- Network Firewall（その他のプロトコル）
```

**比較表**:
| 機能 | Security Group | NACL | Network Firewall |
|------|---------------|------|-----------------|
| **レベル** | インスタンス | サブネット | VPC/サブネット |
| **ステート** | ステートフル | ステートレス | ステートフル/レス |
| **制御粒度** | 5-tuple | 5-tuple | DPI（ペイロード検査） |
| **ドメインブロック** | ❌ | ❌ | ✅ |
| **IDS/IPS** | ❌ | ❌ | ✅ |
| **用途** | インスタンス保護 | サブネット境界 | 高度な脅威対策 |

**関連キーワード**: Network Firewall, Security Group, NACL, Suricata, ドメインフィルタリング

</details>

---

## 問題9: Jumbo Frame設定

オンプレミスとAWS間でDirect Connect経由で大量のデータ転送を行っています。転送速度を最適化するためにJumbo Frame（MTU 9001）を使用したい。

必要な設定を**すべて**選択してください。（複数選択）

A. Direct Connect接続でJumbo Frameを有効化する  
B. VPC内のEC2インスタンスのMTUを9001に設定する  
C. オンプレミス側のネットワーク機器でMTU 9001をサポートする  
D. Transit GatewayでJumbo Frameを有効化する  
E. VPCのDHCPオプションセットを変更する

<details>
<summary>正解と解説</summary>

**正解: B, C**

**解説**:

**Jumbo Frameの基礎**:
```
標準フレーム: MTU 1500バイト
Jumbo Frame: MTU 9001バイト（AWS最大値）

メリット:
- オーバーヘッド削減
- 大容量データ転送の高速化
- CPUオフロード

制約:
- 経路上のすべての機器がJumbo Frameをサポート必要
```

**B: EC2インスタンスMTU設定**:
```bash
# Amazon Linux 2
sudo ip link set dev eth0 mtu 9001

# 永続化（/etc/sysconfig/network-scripts/ifcfg-eth0）
MTU=9001

# 確認
ip link show eth0
ping -M do -s 8973 <宛先IP>  # 9001 - 28 (IP+ICMPヘッダー)

# CloudFormation（UserData）
UserData:
  Fn::Base64: !Sub |
    #!/bin/bash
    ip link set dev eth0 mtu 9001
    echo "MTU=9001" >> /etc/sysconfig/network-scripts/ifcfg-eth0
```

**C: オンプレミス側設定**:
```cisco
! Ciscoルーター
interface GigabitEthernet0/0
 mtu 9001
 exit

! スイッチ
interface range GigabitEthernet1/0/1-48
 mtu 9216  # スイッチは少し大きめに設定（ヘッダー分）
 exit

! 確認
show interfaces GigabitEthernet0/0 | include MTU
```

**Aが不正解の理由**:
- Direct Connectは**デフォルトでJumbo Frameをサポート**
- 追加の有効化設定は不要
- 自動的にMTU 9001まで対応

**Dが不正解の理由**:
- Transit Gatewayも**デフォルトでJumbo Frameをサポート**
- MTU 8500までサポート（若干小さい）
- 追加設定不要

**Eが不正解の理由**:
- DHCPオプションセットはDNS、NTPサーバー等の設定用
- MTU設定には使用しない
- MTUはネットワークインターフェースレベルで設定

**MTU設定の考慮点**:
```
経路チェック:
オンプレミス
  ↓ (MTU 9001)
スイッチ（MTU 9216）
  ↓ (MTU 9001)
ルーター（MTU 9001）
  ↓ (MTU 9001)
Direct Connect
  ↓ (MTU 9001)
AWS
  ↓ (MTU 9001)
EC2インスタンス（MTU 9001）

注意:
- 経路上の**最小MTU**が実効MTU
- 1箇所でもMTU 1500なら全体が1500に制限される
```

**トラブルシューティング**:
```bash
# Path MTU Discovery テスト
tracepath -n <宛先IP>

# Ping テスト（Don't Fragment）
ping -M do -s 8973 <宛先IP>  # Jumbo Frame
ping -M do -s 1472 <宛先IP>  # 標準フレーム

# 失敗する場合:
# - 経路上にMTU 1500の機器がある
# - フラグメント化が発生している
```

**関連キーワード**: Jumbo Frame, MTU, Direct Connect, パフォーマンス最適化

</details>

---

## 問題10: VPCフローログ分析

VPCフローログで以下のエントリを発見しました：

```
2 123456789012 eni-xxxxx 203.0.113.100 10.0.1.50 45678 22 6 10 520 1704096000 1704096001 REJECT OK
```

このエントリから読み取れる情報を**すべて**選択してください。（複数選択）

A. SSHポート（22）への接続試行が拒否された  
B. 送信元IPアドレスは203.0.113.100である  
C. セキュリティグループで拒否された  
D. NACLで拒否された  
E. 10パケット、520バイトが転送された

<details>
<summary>正解と解説</summary>

**正解: A, B, E**

**解説**:

**フローログフォーマット解析**:
```
フィールド順:
version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes start end action log-status

値:
2                    # version
123456789012         # account-id
eni-xxxxx            # interface-id
203.0.113.100        # srcaddr（送信元IP）
10.0.1.50            # dstaddr（宛先IP）
45678                # srcport（送信元ポート）
22                   # dstport（宛先ポート）← SSH
6                    # protocol（6=TCP）
10                   # packets
520                  # bytes
1704096000           # start（タイムスタンプ）
1704096001           # end
REJECT               # action ← 拒否された
OK                   # log-status
```

**A: SSH接続試行が拒否**:
```
dstport = 22 → SSHポート
action = REJECT → 拒否された

結論: SSH接続試行がブロックされた ✅
```

**B: 送信元IP**:
```
srcaddr = 203.0.113.100 ✅

追加情報:
- パブリックIPアドレス（203.x.x.x）
- 外部からのアクセス試行
```

**E: パケット数とバイト数**:
```
packets = 10
bytes = 520

平均パケットサイズ = 520 / 10 = 52バイト
→ TCP SYNパケット（接続試行）の可能性が高い ✅
```

**Cが不正解の理由**:
```
セキュリティグループ vs NACL判定:

判定方法:
1. 同じ送信元からインバウンドREJECT + アウトバウンドREJECT
   → NACL（ステートレス）

2. インバウンドREJECTのみ
   → セキュリティグループまたはNACL（判別不可）

この問題:
- フローログエントリが1つのみ
- インバウンドREJECTしか見えない
- セキュリティグループかNACLか判別できない ❌
```

**Dが不正解の理由**:
- 上記と同じ理由
- 追加情報（アウトバウンドフローログ）が必要

**完全な判定には**:
```bash
# CloudWatch Logs Insightsクエリ
fields @timestamp, srcaddr, dstaddr, srcport, dstport, action
| filter srcaddr = "203.0.113.100" and dstaddr = "10.0.1.50"
| sort @timestamp desc

期待される結果:

ケース1（セキュリティグループ）:
- インバウンド: 203.0.113.100 → 10.0.1.50:22 REJECT
- アウトバウンド: （レコードなし - ステートフルのため）

ケース2（NACL）:
- インバウンド: 203.0.113.100 → 10.0.1.50:22 REJECT
- アウトバウンド: 10.0.1.50 → 203.0.113.100 REJECT
```

**セキュリティ分析**:
```
このフローログから:
1. 外部IP（203.0.113.100）からSSH接続試行
2. 拒否されている（正常な防御）
3. パケット数10 → 繰り返しの接続試行
4. 可能性: ポートスキャン、ブルートフォース攻撃

推奨アクション:
- NACLでこのIPアドレスをブロック（既に防御されているが念のため）
- GuardDutyでアラート確認
- 他のポートへの攻撃がないか確認
```

**関連キーワード**: VPCフローログ, セキュリティ分析, ACCEPT/REJECT

</details>

---

## 📊 採点と分析

### 得点計算
- 10問中 _____ 問正解
- 正答率: _____ %

### レベル判定
| 正解数 | 正答率 | レベル |
|--------|--------|--------|
| 9-10問 | 90-100% | **合格確実** |
| 7-8問 | 70-80% | **合格ライン** - さらに復習推奨 |
| 5-6問 | 50-60% | **要復習** - 弱点分野を強化 |
| 0-4問 | 0-40% | **基礎から学習** - guide.md精読推奨 |

### 次のステップ

#### 90-100%の場合
- ✅ 実際の試験に挑戦可能
- ✅ Tutorials Dojo模擬試験で最終確認
- ✅ [quick-reference.md](quick-reference.md)で最終復習

#### 70-80%の場合
- 📖 間違えた問題の分野を[guide.md](guide.md)で復習
- 🔄 1週間後に再挑戦
- 📝 [practical-examples.md](practical-examples.md)で実践

#### 50-60%の場合
- 📚 [guide.md](guide.md)を精読
- 🛠️ [practical-examples.md](practical-examples.md)でハンズオン
- 📖 Udemy動画を再視聴

#### 0-40%の場合
- 🎓 ネットワーク基礎（TCP/IP、BGP）を復習
- 📚 AWS Certified Solutions Architect - Associateから復習
- 📖 [quick-reference.md](quick-reference.md)で全体像を把握

---

**次のステップ**: [troubleshooting.md](troubleshooting.md) で実務のトラブル対応を学習
