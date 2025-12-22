# Cursor メモ

Cursorの使い方
- 2025/12/20時点

## 無料とproの違い

- 無料版
  - 回数/速度/モデル選択などに制限がある（上限に達すると待ち or 使えない）
  - まずは「日常の編集 + 小さめの相談」が回るか試す
- pro
  - 月20ドル
  - 制限が緩く、より高性能なモデル/機能が使えることが多い（上限/対象はプランで変わる）

## proプラン以上は課金されない方法

- 目的: 上限超えの従量課金（overage / usage-based / top-up）を発生させない
- 手順（だいたい）:
  - Settings（⌘,）→ Plan / Billing（請求）系
  - **Usage-based / Overage / Top-up** を **OFF**
  - 可能なら **Spending limit（上限）** を **0** か **Hard limit** に設定


## 履歴の仕様と使い方

- 目安: プロジェクト単位で履歴が残るが、保持/同期は設定・バージョン・ログイン状態で変わる
- 運用:
  - 重要な結論はこのメモに1行で転記（いつ/何を/どうした）
  - 再現したい相談は、対象ファイルを `@path` で明示してから聞く


## 現在の請求額の確認方法

- アプリ内:
  - Settings（⌘,）→ Plan / Billing（請求）→ 現在のプラン・当月の利用状況（Usage）・上限（Limit）を確認
- Web（確実）:
  - Cursorのアカウント画面 → Billing（請求）/ Invoices（請求書）で **今月の請求見込み** と **過去の請求** を確認
- 見るポイント:
  - **次回請求日** / **当月の見込み金額** / **追加課金（overage / top-up）の有無**



▼請求画面（ブラウザ）
https://cursor.com/ja/dashboard?tab=billing
今は従量課金の設定項目は設定画面にはないらしい（？）
→
xクレジット
◎一定の利用枠（高速リクエスト500回相当）
が
なくなったらusage limit課金画面（50/100/200ドル　or Custom）が表示されたら、Set　SpendLimitを押せば、
追加課金されず、どのモデル（Composer1）を選んでも、低速になる。


【確認１】
- ブラウザログイン＞Spending
- On-Demand Usageがオフになっていること！！！
  - On-Demand Usage
    - Allow users on your team to go beyond included usage limits. On-demand usage is billed in arrears.


