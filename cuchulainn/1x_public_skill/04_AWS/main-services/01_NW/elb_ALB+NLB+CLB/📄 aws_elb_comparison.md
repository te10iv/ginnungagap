# AWS ELB（ALB / NLB / CLB）比較 & 選定ガイド

本ドキュメントは AWS のロードバランサ 3 種類  
**ALB / NLB / CLB** の比較と、  
「どんな要件ならどれを選ぶべきか？」をまとめたものです。

---

# 1. ELB 3 種類の比較表

| 項目 | **ALB** | **NLB** | **CLB**（旧） |
|------|---------|---------|----------------|
| レイヤー | L7 (HTTP/HTTPS) | L4 (TCP/UDP/TLS) | L4/L7（中途半端） |
| 主用途 | Webアプリ（API、SPA、マイクロサービス） | 高速ネットワーク、固定IPが必要な通信 | レガシー互換 |
| プロトコル | HTTP/HTTPS/WebSocket | TCP/UDP/TLS | HTTP/HTTPS/TCP |
| パス/ホストベースルーティング | ○ | × | △（非推奨） |
| 固定 IP | × | ○（静的IP または Elastic IP） | × |
| パフォーマンス | 高 | **最高（ロードバランサで唯一100万RPS級）** | 低い |
| 可観測性 | 充実（ターゲットレベル詳細） | 普通 | 限定的 |
| ヘルスチェック | HTTP/HTTPS | TCP/HTTP/HTTPS | TCP/HTTP |
| Lambda を後段に置く | **○** | × | × |
| HTTP/2 | ○ | × | × |
| gRPC | ○ | × | × |
| 新規構築での推奨度 | **最優先** | 用途次第で最優先 | **非推奨**（移行対象） |

---

# 2. どんな要件なら ALB を選ぶ？

## ✅ ALB を選ぶべきケース
- Web アプリ / REST API / GraphQL API
- HTTP/HTTPS の処理を行うアプリケーション
- マイクロサービス構成（Path-based / Host-based routing 必須）
- SPA バックエンド（Next.js / Rails / Laravel / Django など）
- WebSocket を扱いたい
- Lambda のバックエンドとして使いたい
- ECS（Fargate/EC2）サービスでリスナーが 80/443 の場合

## 💡 ALB が向いている理由
- L7 レベルでのルーティングが可能（パス・ホスト）
- 1つの ALB で複数サービスを捌ける
- Web アプリの構成に最適化されている
- CloudWatch や AccessLog など可観測性が高い

---

# 3. どんな要件なら NLB を選ぶ？

## ✅ NLB を選ぶべきケース
- **超高速**（数十万〜100万 RPS 級）処理が必要
- **固定IP**（静的 IP / Elastic IP）が必要
- TCP/UDP ベースのサービス（ゲームサーバ、MQTT、独自プロトコル）
- TLS のオフロードをしたい（例：証明書管理を NLB に集約）
- VPC 内のプライベート通信に使いたい（Private NLB）
- AWS PrivateLink と組み合わせる場合
- 高負荷のデータプレーン処理で ALB が耐えられない場合

## 💡 NLB が向いている理由
- L4 ベースのため極めて高速・低遅延
- 静的 IP が割り当て可能（WAF との組み合わせ不要）
- UDP に対応している唯一のロードバランサ

---

# 4. どんな要件なら CLB（Classic Load Balancer）？

## ⚠️ 原則非推奨。使う場面は限られる。

### CLB を使う場面は？
- 「昔の環境がすでに CLB を使っており、移行できない」
- 「アプリが ALB/NLB の制限に引っかかっている特殊ケース」

### それ以外は？
👉 **新規構築では選んではいけないロードバランサ**

理由：
- 機能が古い
- CloudWatch メトリクスが粗い
- ヘルスチェックが弱い
- ALB/NLB の完全下位互換ではないが総じて劣る

---

# 5. 最終選定ガイド（フローチャート）


【ロードバランサ選定フローチャート】

1. プロトコルは？  
     ├─ HTTP / HTTPS → ALB  
     └─ TCP / UDP     → NLB  

2. 固定IPは必要？  
     ├─ YES → NLB  
     └─ NO  → 次へ  

3. パス or ホストベースのルーティング必要？  
     ├─ YES → ALB  
     └─ NO  → 次へ  

4. WebSocket / gRPC を使いたい？  
     ├─ YES → ALB  
     └─ NO  → NLB or ALB  

5. 超高トラフィック（数十万RPS級）が必要？  
     ├─ YES → NLB  
     └─ NO  → ALB  


---

# 6. まとめ（1行で説明するなら）

- **ALB** → Webアプリ向け、HTTP/HTTPS、ルーティングが強い  
- **NLB** → ネットワーク向け、超高速、固定IP、TCP/UDP  
- **CLB** → レガシー（新規は使わない）

---

# 7. 追加資料（必要なら作成可能）

- ALB / NLB / CLB のアーキテクチャ図  
- 各ロードバランサの CloudFormation / Terraform テンプレ  
- ALB → NLB 移行ガイド  
- ECS + ALB の設計ベストプラクティス  

必要であれば言ってください！



