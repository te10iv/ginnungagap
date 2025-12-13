# AWS Certified Advanced Networking - Specialty サマリー

## 📋 資格概要

**試験コード**: ANS-C01  
**試験時間**: 170分  
**問題数**: 65問  
**合格ライン**: 750点/1000点  
**受験料**: $300 USD  
**有効期限**: 3年間

---

## 🎯 対象者

- **前提知識**: SAA必須、ネットワーク知識（TCP/IP、BGP、VPN等）
- **実務経験**: AWS ネットワーク実務経験2年以上推奨
- **対象者**: ネットワークエンジニア、インフラエンジニア

---

## 📚 試験範囲

| ドメイン | 比重 |
|---------|------|
| **ドメイン1: ネットワーク設計** | 30% |
| **ドメイン2: ネットワーク実装** | 26% |
| **ドメイン3: ネットワーク管理と運用** | 20% |
| **ドメイン4: ネットワークセキュリティ、コンプライアンス** | 24% |

---

## 🛠️ 関連AWSサービス（重要度順）

### 🔴 最重要

#### 1. AWS Transit Gateway

**資格取得のために知るべき知識**:
- ✅ ルートテーブル設計（アソシエーション、プロパゲーション）
- ✅ Transit Gateway Attachments（VPC、VPN、Direct Connect、Peering）
- ✅ マルチキャスト対応
- ✅ ネットワークセグメンテーション
- ✅ Transit Gateway Connect（SD-WAN統合）
- ✅ Flow Logs分析

---

#### 2. AWS Direct Connect

**資格取得のために知るべき知識**:
- ✅ VIF種類（Private、Public、Transit）
- ✅ Direct Connect Gateway
- ✅ LAG（Link Aggregation Group）
- ✅ BGP設定（AS番号、コミュニティタグ）
- ✅ 冗長性設計（デュアルDX、MACSec）
- ✅ SLA、帯域オプション

---

#### 3. Amazon VPC（高度な機能）

**資格取得のために知るべき知識**:
- ✅ VPCピアリング vs Transit Gateway
- ✅ VPCエンドポイント（Gateway、Interface、PrivateLink）
- ✅ NACL vs セキュリティグループ（詳細な違い）
- ✅ VPCフローログ分析（Athena、CloudWatch Logs Insights）
- ✅ IPAM（IP Address Manager）
- ✅ Prefix List

---

#### 4. AWS PrivateLink

**資格取得のために知るべき知識**:
- ✅ VPCエンドポイントサービス作成
- ✅ NLB統合
- ✅ エンドポイントポリシー
- ✅ クロスアカウント共有

---

#### 5. Amazon Route 53

**資格取得のために知るべき知識**:
- ✅ 全ルーティングポリシー詳細
- ✅ Route 53 Resolver（ハイブリッドDNS）
- ✅ DNSSEC
- ✅ トラフィックフロー
- ✅ ヘルスチェック高度な設定

---

#### 6. AWS VPN

**資格取得のために知るべき知識**:
- ✅ Site-to-Site VPN設定
- ✅ Client VPN（リモートアクセス）
- ✅ VPN CloudHub
- ✅ アクセラレーテッドVPN
- ✅ BGP over VPN

---

#### 7. AWS Global Accelerator

**資格取得のために知るべき知識**:
- ✅ CloudFrontとの違い
- ✅ Anycast IPアドレス
- ✅ エンドポイントグループ設定
- ✅ トラフィックダイヤル

---

#### 8. Amazon CloudFront

**資格取得のために知るべき知識**:
- ✅ オリジンフェイルオーバー
- ✅ Lambda@Edge、CloudFront Functions
- ✅ フィールドレベル暗号化
- ✅ オリジンシールド

---

#### 9. AWS Network Firewall

**資格取得のために知るべき知識**:
- ✅ ステートフルルール vs ステートレスルール
- ✅ Suricataルール
- ✅ ファイアウォールポリシー
- ✅ Logging設定

---

#### 10. Elastic Load Balancing

**資格取得のために知るべき知識**:
- ✅ NLB（ネットワークロードバランサー）詳細
- ✅ クロスゾーン負荷分散
- ✅ Proxy Protocol
- ✅ ターゲットグループ設定

---

## 🎓 ハンズオン（標準15時間）

#### ハンズオン1: ハイブリッドネットワーク（5時間）
- [ ] Transit Gateway構築
- [ ] Direct Connect Gatewayシミュレーション
- [ ] Site-to-Site VPN設定
- [ ] BGPルーティング

#### ハンズオン2: マルチリージョン設計（4時間）
- [ ] Transit Gateway Peering
- [ ] Route 53フェイルオーバー
- [ ] Global Accelerator設定

#### ハンズオン3: セキュリティとモニタリング（3時間）
- [ ] Network Firewall設定
- [ ] VPCフローログ分析
- [ ] PrivateLink構築

#### ハンズオン4: 高度なDNS（3時間）
- [ ] Route 53 Resolver設定
- [ ] プライベートホストゾーン統合
- [ ] DNSSEC有効化

---

## 💡 試験対策のポイント

### 頻出トピック
- ✅ Transit Gateway ルーティング設計
- ✅ Direct Connect冗長性設計
- ✅ BGPルーティング（AS-PATH、コミュニティタグ）
- ✅ VPCエンドポイント vs PrivateLink
- ✅ ハイブリッドDNS（Route 53 Resolver）
- ✅ ネットワークセグメンテーション
- ✅ VPCフローログ分析

---

## ⏱️ 学習スケジュール目安

| レベル | 学習時間 | 期間 |
|--------|---------|------|
| **SAA保持・ネットワーク経験あり** | 80-100時間 | 2-3ヶ月 |
| **SAA保持・ネットワーク経験なし** | 120-150時間 | 3-4ヶ月 |

---

**次のステップ**: [詳細学習ガイド](guide.md)
