# cursolとは
- 概要
  - あああ



# セキュリティ 🔐 安全な使い方のまとめ
項目	推奨設定
- Data Sharing	Privacy Mode
- 利用モデルをプレミアムモードのもの（	GPT-4o / Claude / Gemini）のみに固定
  - cursor-small は無料モデルにするとCursolに情報が渡る

※ これでも「AIチャットを使う限り、プロンプト自体はモデル提供者に送信される」
→ これは ChatGPT や Claude と同じ仕組み


## 【参考】　以下の設定は開いているファイルのみ自動補完などしてくれるので、OFFにしなくても良い認識
<!-- - Background Agent（あれば）	OFF -->
- Agent Autocomplete	OFF
<!-- - Inline Suggestions	OFF -->
- Suggestions While Commenting OFF



Privacy Mode とは？（重要）
Privacy Mode にすると：
あなたのコードや文章を Cursor が学習に使わない
あなたの編集履歴・プロンプトも送信されない
外部モデル（GPT, Claude など）に渡るのも必要最低限のみ
Cursor 側に永続保存されない
⇒ 社内業務や顧客案件でも使いやすくなる設定です。
📌 次に絶対に確認すべき設定（超重要）


▽ ① Data Sharing を OFF（＝ Privacy Mode）
→ これが一番重要。

▽ ② モデル選択は「cursor-small」を避ける
cursor-small は無料モデルだが、
内部処理が Cursor 側で走りやすい。
プレミアムモデル（GPT-4o / Claude）を使うほうが安全
→ これらはモデル提供会社にしか送信されない。


# 🔧 必ず見るべき設定場所一覧

① Settings → Privacy（あなたの画像のところ）
「Share Data」→ Privacy Mode にする

② Settings → Advanced
Background Agent → OFF
（バックグラウンドでコード解析しない → データ送信量減る）

③ Settings → Features
AI Autocomplete → OFF
（自動補完は内部処理が多い）

④ Settings → Editor
Inline Suggestions → OFF
（AI が裏で解析する量が減る）


