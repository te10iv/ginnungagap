# AWS Advanced Networking Specialty - トラブルシューティングガイド

よくある問題と解決方法

---

## 📋 目次

1. [Transit Gateway関連](#1-transit-gateway関連)
2. [Direct Connect関連](#2-direct-connect関連)
3. [VPN関連](#3-vpn関連)
4. [Route 53関連](#4-route-53関連)
5. [VPCネットワーク関連](#5-vpcネットワーク関連)

---

## 1. Transit Gateway関連

### 問題1: Transit Gateway経由で通信できない

#### 症状
- VPC A → VPC B への通信が失敗
- Transit Gatewayアタッチメントは正常

#### 原因と解決策

##### ケース1: ルートテーブルアソシエーションが不正
```bash
# 確認
aws ec2 describe-transit-gateway-attachments \
  --filters "Name=transit-gateway-id,Values=tgw-xxxxx"

aws ec2 get-transit-gateway-attachment-propagations \
  --transit-gateway-route-table-id tgw-rtb-xxxxx

# 問題: アタッチメントがルートテーブルに関連付けられていない

# 解決
aws ec2 associate-transit-gateway-route-table \
  --transit-gateway-route-table-id tgw-rtb-xxxxx \
  --transit-gateway-attachment-id tgw-attach-xxxxx
```

##### ケース2: ルートプロパゲーションが無効
```bash
# 確認
aws ec2 get-transit-gateway-route-table-propagations \
  --transit-gateway-route-table-id tgw-rtb-xxxxx

# 問題: プロパゲーションが無効

# 解決
aws ec2 enable-transit-gateway-route-table-propagation \
  --transit-gateway-route-table-id tgw-rtb-xxxxx \
  --transit-gateway-attachment-id tgw-attach-yyyyy
```

##### ケース3: VPCサブネットのルートテーブルにルートがない
```bash
# 確認
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=vpc-xxxxx"

# 問題: VPCルートテーブルに宛先CIDRへのルートがない

# 解決
aws ec2 create-route \
  --route-table-id rtb-xxxxx \
  --destination-cidr-block 10.1.0.0/16 \
  --transit-gateway-id tgw-xxxxx
```

##### ケース4: セキュリティグループまたはNACL
```bash
# セキュリティグループ確認
aws ec2 describe-security-groups --group-ids sg-xxxxx

# NACL確認
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=vpc-xxxxx"

# 解決: 必要なトラフィックを許可
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 443 \
  --source-group sg-yyyyy
```

---

### 問題2: Transit Gateway Peeringが確立できない

#### 症状
- ピアリング接続がPendingのまま
- クロスリージョン通信ができない

#### 原因と解決策

##### ケース1: ピアリングリクエストが承認されていない
```bash
# 確認
aws ec2 describe-transit-gateway-peering-attachments \
  --filters "Name=state,Values=pendingAcceptance"

# 解決: リモートリージョンで承認
aws ec2 accept-transit-gateway-peering-attachment \
  --transit-gateway-attachment-id tgw-attach-xxxxx \
  --region us-west-2
```

##### ケース2: ルートが設定されていない
```bash
# ピアリング用の静的ルート追加
aws ec2 create-transit-gateway-route \
  --transit-gateway-route-table-id tgw-rtb-xxxxx \
  --destination-cidr-block 10.2.0.0/16 \
  --transit-gateway-attachment-id tgw-attach-peering
```

---

### 問題3: Appliance Modeで非対称ルーティング

#### 症状
- ファイアウォールを通過するトラフィックが断続的に失敗
- ステートフルインスペクションが正常に動作しない

#### 原因と解決策

```bash
# 確認: Appliance Modeが有効か
aws ec2 describe-transit-gateway-vpc-attachments \
  --transit-gateway-attachment-ids tgw-attach-xxxxx \
  --query 'TransitGatewayVpcAttachments[0].Options.ApplianceModeSupport'

# 問題: Appliance Modeが無効

# 解決: Appliance Mode有効化
aws ec2 modify-transit-gateway-vpc-attachment \
  --transit-gateway-attachment-id tgw-attach-xxxxx \
  --options ApplianceModeSupport=enable
```

---

## 2. Direct Connect関連

### 問題4: Direct Connect接続が確立できない

#### 症状
- 接続ステータスがDown
- BGPセッションが確立しない

#### デバッグ手順

##### 1. 接続ステータス確認
```bash
# Direct Connect接続状態確認
aws directconnect describe-connections \
  --connection-id dxcon-xxxxx

# VIF状態確認
aws directconnect describe-virtual-interfaces \
  --connection-id dxcon-xxxxx

# 期待される状態: "connectionState": "available"
```

##### 2. BGPステータス確認
```bash
# VIF詳細確認
aws directconnect describe-virtual-interfaces \
  --virtual-interface-id dxvif-xxxxx

# BGP Status確認
{
  "bgpStatus": "up",
  "bgpPeers": [
    {
      "bgpStatus": "up",
      "awsBgpAsn": 64512,
      "customerBgpAsn": 65000
    }
  ]
}
```

#### 原因と解決策

##### ケース1: 物理層の問題
```bash
# 光レベル確認
aws directconnect describe-loa \
  --connection-id dxcon-xxxxx

# CloudWatchメトリクス確認
aws cloudwatch get-metric-statistics \
  --namespace AWS/DX \
  --metric-name ConnectionLightLevelTx \
  --dimensions Name=ConnectionId,Value=dxcon-xxxxx \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Average

# 正常範囲: -2.0 dBm 以上
# 問題: -5.0 dBm 以下 → ケーブル不良の可能性

# 解決: AWSサポートに連絡、物理接続確認
```

##### ケース2: BGP設定不一致
```
チェックポイント:
1. ASN番号の一致
   - AWS側: 64512（デフォルト）
   - 顧客側: BGP ASN（65000-65534）

2. BGP認証キーの一致
   - AWS: 設定したPSK
   - 顧客側ルーター: 同じPSK

3. IPアドレスの一致
   - AWS側: 169.254.x.1/30
   - 顧客側: 169.254.x.2/30

4. VLAN IDの一致
   - VIF VLAN: 例 100
   - 顧客側ルーター: 同じ100
```

##### オンプレミス側BGP設定確認（Cisco）
```cisco
! BGP設定確認
show ip bgp summary
show ip bgp neighbors 169.254.x.1

! 問題: BGP session not established

! デバッグ
debug ip bgp
debug ip bgp events
debug ip bgp updates

! よくある原因:
! 1. BGP ASN不一致
! 2. BGP パスワード不一致
! 3. タイマー設定不一致

! 解決例
router bgp 65000
 neighbor 169.254.x.1 remote-as 64512
 neighbor 169.254.x.1 password <正しいPSK>
 neighbor 169.254.x.1 timers 10 30
 exit
```

---

### 問題5: Direct Connect経由のトラフィックが流れない

#### 症状
- BGPセッションは確立済み
- しかしトラフィックがDirect Connect経由で流れない

#### 原因と解決策

##### ケース1: BGPルート広告がない
```bash
# AWS側で受信しているルート確認
aws ec2 describe-transit-gateway-route-tables \
  --transit-gateway-route-table-ids tgw-rtb-xxxxx

# 顧客側ルーターで広告確認
show ip bgp neighbors 169.254.x.1 advertised-routes

# 問題: ルートが広告されていない

# 解決（Cisco）
router bgp 65000
 address-family ipv4
  network 192.168.0.0 mask 255.255.0.0
  neighbor 169.254.x.1 activate
 exit-address-family
```

##### ケース2: ローカルプリファレンスの問題
```
問題: VPN経路の方がLocal Preferenceが高く、VPNが優先される

AWS側の優先順位:
- VPN: Local Preference 200
- DX: Local Preference 100

解決: AS-PATH Prependingで調整
```

```cisco
! AS-PATH Prependingでパスを短くする
route-map SET-DX-PRIMARY permit 10
 ! DX経由のパスは短いまま（優先）
 exit

route-map SET-VPN-BACKUP permit 10
 set as-path prepend 65000 65000 65000
 exit

router bgp 65000
 address-family ipv4
  neighbor 169.254.1.1 route-map SET-DX-PRIMARY out  ! DX
  neighbor 169.254.2.1 route-map SET-VPN-BACKUP out  ! VPN
 exit-address-family
```

---

### 問題6: Direct Connect MTU問題

#### 症状
- 小さなパケットは通信可能
- 大きなパケット（1500バイト以上）が失敗
- HTTPS接続が確立後にハング

#### 原因と解決策

```bash
# MTU確認
# Direct Connect: 最大9001バイト（Jumbo Frame）
# VPN: 最大1399バイト（IPsecオーバーヘッド）

# テスト
ping -M do -s 8973 <宛先IP>  # Jumbo Frame (9001 - 28)
ping -M do -s 1472 <宛先IP>  # 通常フレーム (1500 - 28)

# 問題: MTU不一致、経路上でフラグメントが発生

# 解決1: TCPのMSS調整（ルーター側）
interface GigabitEthernet0/0
 ip tcp adjust-mss 1460
 exit

# 解決2: Path MTU Discovery有効化
# アプリケーション側でPMTUDを有効化

# 解決3: EC2側でMTU設定
sudo ip link set dev eth0 mtu 9001  # Jumbo Frame
```

---

## 3. VPN関連

### 問題7: VPNトンネルがDownする

#### 症状
- VPNトンネルが断続的にDown
- トンネルが確立してもすぐに切断

#### 原因と解決策

##### ケース1: DPD（Dead Peer Detection）タイムアウト
```bash
# CloudWatchでトンネル状態確認
aws cloudwatch get-metric-statistics \
  --namespace AWS/VPN \
  --metric-name TunnelState \
  --dimensions Name=VpnId,Value=vpn-xxxxx Name=TunnelIpAddress,Value=203.0.113.10 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Maximum

# 問題: DPDタイムアウト設定が短すぎる

# 解決（Cisco）
crypto ikev2 profile AWS-IKE-PROFILE
 dpd 10 3 on-demand  # 10秒間隔、3回失敗で切断
 exit

# 推奨: 10秒間隔、3-5回リトライ
```

##### ケース2: Phase 1/Phase 2パラメータ不一致
```bash
# AWS推奨パラメータ
Phase 1:
- Encryption: AES256, AES128
- Integrity: SHA2-256, SHA2-384, SHA2-512
- DH Group: 14, 15, 16, 17, 18, 19, 20, 21
- Lifetime: 28800秒

Phase 2:
- Encryption: AES256, AES128
- Integrity: SHA2-256, SHA2-384, SHA2-512
- DH Group: 14, 15, 16, 17, 18, 19, 20, 21
- Lifetime: 3600秒

# 顧客側設定確認（Cisco）
show crypto ikev2 proposal
show crypto ipsec transform-set

# 不一致があれば修正
```

##### ケース3: NATトラバーサルの問題
```
問題: 顧客側ルーターがNAT配下にある場合、IPsecが正常に動作しない

解決: NAT-Traversal（NAT-T）有効化
```

```cisco
crypto ikev2 profile AWS-IKE-PROFILE
 match identity remote address 0.0.0.0
 authentication remote pre-share
 authentication local pre-share
 keyring local AWS-KEYRING
 nat-keepalive 20  # NAT-T keepalive
 exit
```

---

### 問題8: VPN帯域が出ない

#### 症状
- VPN接続は確立済み
- スループットが1.25Gbpsに制限される

#### 原因と解決策

##### ECMPで複数VPN集約
```bash
# 問題: 単一VPNトンネルは最大1.25Gbps

# 解決: 複数VPN接続でECMP

# VPN接続1
aws ec2 create-vpn-connection \
  --type ipsec.1 \
  --customer-gateway-id cgw-xxxxx \
  --transit-gateway-id tgw-xxxxx

# VPN接続2（同じCGW）
aws ec2 create-vpn-connection \
  --type ipsec.1 \
  --customer-gateway-id cgw-xxxxx \
  --transit-gateway-id tgw-xxxxx

# 結果: 2 VPN × 2 トンネル = 4トンネル = 最大5Gbps
```

```cisco
! BGPでECMP有効化
router bgp 65000
 address-family ipv4
  maximum-paths 4  # 最大4パス
  neighbor 169.254.1.1 activate  # VPN1-Tunnel1
  neighbor 169.254.1.5 activate  # VPN1-Tunnel2
  neighbor 169.254.2.1 activate  # VPN2-Tunnel1
  neighbor 169.254.2.5 activate  # VPN2-Tunnel2
 exit-address-family
```

---

## 4. Route 53関連

### 問題9: Route 53 Resolverが応答しない

#### 症状
- オンプレミスからVPCのDNSクエリが失敗
- Inbound Endpointに到達できない

#### 原因と解決策

##### ケース1: セキュリティグループ設定
```bash
# 確認
aws ec2 describe-security-groups --group-ids sg-xxxxx

# 問題: DNS（UDP/TCP 53）が許可されていない

# 解決
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 53 \
  --cidr 192.168.0.0/16

aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol udp \
  --port 53 \
  --cidr 192.168.0.0/16
```

##### ケース2: ルーティングの問題
```bash
# オンプレミスからInbound Endpointへのルートがあるか確認
traceroute 10.0.1.10  # Inbound Endpoint IP

# VPC内のルートテーブル確認
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=vpc-xxxxx"

# 解決: 必要なルートを追加
```

---

### 問題10: Outbound Resolver Ruleが動作しない

#### 症状
- VPCからオンプレミスドメインのDNS解決ができない
- Outbound Endpointは正常

#### 原因と解決策

##### ケース1: Resolver Ruleが関連付けられていない
```bash
# 確認
aws route53resolver list-resolver-rule-associations \
  --filters "Name=VPCId,Values=vpc-xxxxx"

# 問題: 該当するRuleがない

# 解決
aws route53resolver associate-resolver-rule \
  --resolver-rule-id rslvr-rr-xxxxx \
  --vpc-id vpc-xxxxx
```

##### ケース2: ドメイン名が一致しない
```bash
# 確認
aws route53resolver get-resolver-rule --resolver-rule-id rslvr-rr-xxxxx

# ルール: corp.example.com
# クエリ: server.corp.example.local  # 一致しない

# 解決: 正しいドメイン名でルール作成
aws route53resolver create-resolver-rule \
  --rule-type FORWARD \
  --domain-name corp.example.local \
  --target-ips Ip=10.20.0.53,Port=53 \
  --resolver-endpoint-id rslvr-out-xxxxx
```

---

### 問題11: DNSSEC検証エラー

#### 症状
- DNSSECを有効化したドメインが解決できない
- SERVFAIL エラー

#### 原因と解決策

##### ケース1: DSレコードが親ゾーンに未登録
```bash
# DS レコード取得
aws route53 get-dnssec --hosted-zone-id Z1234567890ABC

# 問題: 親ゾーン（.comなど）にDSレコードが登録されていない

# 解決: ドメインレジストラでDSレコード登録
# 例: example.com のDSレコードを .com ゾーンに登録
```

##### ケース2: KSKローテーション中
```bash
# DNSSEC ステータス確認
aws route53 get-dnssec --hosted-zone-id Z1234567890ABC

# KeySigningKey のステータスを確認
# Status: ACTION_NEEDED → 手動対応が必要

# 解決: KSKローテーション完了
aws route53 activate-key-signing-key \
  --hosted-zone-id Z1234567890ABC \
  --name my-ksk-name
```

---

## 5. VPCネットワーク関連

### 問題12: VPCフローログでREJECTが大量発生

#### 症状
- VPCフローログで大量のREJECT
- 正常な通信も影響を受けている可能性

#### デバッグ手順

##### 1. CloudWatch Logs Insightsで分析
```sql
-- REJECTの宛先ポート別集計
fields @timestamp, srcaddr, dstaddr, dstport, action
| filter action = "REJECT"
| stats count() by dstport
| sort count desc
| limit 10

-- REJECTの送信元IP別集計
fields @timestamp, srcaddr, dstaddr, action
| filter action = "REJECT"
| stats count() by srcaddr
| sort count desc
| limit 10

-- 特定ポートへのREJECT（SSH）
fields @timestamp, srcaddr, dstaddr, dstport, action
| filter action = "REJECT" and dstport = 22
| stats count() by srcaddr
| sort count desc
```

##### 2. セキュリティグループ vs NACL判定
```
判定方法:
- インバウンドREJECT + アウトバウンドREJECT → NACL
- インバウンドREJECT のみ → セキュリティグループ

理由:
- セキュリティグループ: ステートフル（戻りトラフィック自動許可）
- NACL: ステートレス（明示的に双方向許可必要）
```

#### 原因と解決策

##### ケース1: ポートスキャン攻撃
```bash
# CloudWatch Logs Insightsで確認
fields @timestamp, srcaddr, dstport
| filter action = "REJECT" and srcaddr = "203.0.113.100"
| stats count() by dstport
| sort dstport

# 結果: 1-65535まで順番にスキャン → ポートスキャン

# 解決: NACLでブロック
aws ec2 create-network-acl-entry \
  --network-acl-id acl-xxxxx \
  --rule-number 10 \
  --protocol -1 \
  --rule-action deny \
  --ingress \
  --cidr-block 203.0.113.100/32
```

##### ケース2: 設定ミス（過度に厳しいルール）
```bash
# セキュリティグループ確認
aws ec2 describe-security-groups --group-ids sg-xxxxx

# 問題: 必要なポートが許可されていない

# 解決: 必要なルールを追加
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 443 \
  --source-group sg-alb
```

---

### 問題13: Reachability Analyzerで到達不可

#### 症状
- Reachability Analyzerの結果が「Not Reachable」
- ホップバイホップのパス分析で原因特定が必要

#### デバッグ手順

```bash
# Reachability Analyzer実行
aws ec2 create-network-insights-path \
  --source ec2-instance-id \
  --destination ec2-instance-id \
  --protocol tcp \
  --destination-port 443

aws ec2 start-network-insights-analysis \
  --network-insights-path-id nip-xxxxx

# 結果確認
aws ec2 describe-network-insights-analyses \
  --network-insights-analysis-id nia-xxxxx
```

#### よくある原因

##### 1. セキュリティグループのアウトバウンドルール
```
問題: 送信元セキュリティグループでアウトバウンドが許可されていない

解決:
aws ec2 authorize-security-group-egress \
  --group-id sg-source \
  --protocol tcp \
  --port 443 \
  --destination-group sg-destination
```

##### 2. NACLの戻りトラフィック
```
問題: NACLでエフェメラルポートが許可されていない

解決:
# インバウンド: 宛先サービスポート（例: 443）
# アウトバウンド: エフェメラルポート（1024-65535）

aws ec2 create-network-acl-entry \
  --network-acl-id acl-xxxxx \
  --rule-number 100 \
  --protocol tcp \
  --port-range From=1024,To=65535 \
  --rule-action allow \
  --egress
```

##### 3. ルートテーブルのブラックホールルート
```bash
# 確認
aws ec2 describe-route-tables --route-table-ids rtb-xxxxx

# 問題: ルートのTargetが削除されたリソース（"blackhole"）

# 解決: 正しいルートを追加
aws ec2 create-route \
  --route-table-id rtb-xxxxx \
  --destination-cidr-block 10.1.0.0/16 \
  --transit-gateway-id tgw-xxxxx
```

---

## 🔧 デバッグツールとコマンド

### VPCフローログクエリ集

#### 1. Top Talkers（通信量上位）
```sql
fields @timestamp, srcaddr, dstaddr, bytes
| stats sum(bytes) as totalBytes by srcaddr, dstaddr
| sort totalBytes desc
| limit 10
```

#### 2. 特定ポートへのアクセス
```sql
fields @timestamp, srcaddr, dstaddr, dstport, action
| filter dstport = 22
| stats count() by action, srcaddr
| sort count desc
```

#### 3. 外部への通信（データ流出検知）
```sql
fields @timestamp, srcaddr, dstaddr, dstport, bytes
| filter dstaddr not like "10."
    and dstaddr not like "172.16."
    and dstaddr not like "192.168."
| stats sum(bytes)/1024/1024 as mb by srcaddr, dstaddr
| filter mb > 1000
| sort mb desc
```

### CloudWatch メトリクス確認

#### Direct Connect
```bash
# 接続状態
aws cloudwatch get-metric-statistics \
  --namespace AWS/DX \
  --metric-name ConnectionState \
  --dimensions Name=ConnectionId,Value=dxcon-xxxxx \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Maximum

# 帯域使用率
aws cloudwatch get-metric-statistics \
  --namespace AWS/DX \
  --metric-name ConnectionBpsEgress \
  --dimensions Name=ConnectionId,Value=dxcon-xxxxx \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Average,Maximum
```

#### Transit Gateway
```bash
# パケットドロップ
aws cloudwatch get-metric-statistics \
  --namespace AWS/TransitGateway \
  --metric-name PacketDropCountBlackhole \
  --dimensions Name=TransitGateway,Value=tgw-xxxxx \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Sum
```

---

**troubleshooting.md 完成！実務のネットワークトラブル対応を網羅しました。**
