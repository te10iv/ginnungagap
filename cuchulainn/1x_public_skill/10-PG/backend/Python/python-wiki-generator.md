# Python 基礎 Wiki 自動生成プロンプト（Cursor用）

以下のルールに従って、Python学習WikiのディレクトリとMarkdownファイルを自動生成してください。

---

# 0. 目的
私は Python の基礎を学ぶための「個人Wiki（Markdownベース）」を作りたい。
そのため、以下の **ディレクトリ構造＋中身のテンプレファイル** を自動生成したい。

作成後、各ページの本文も Cursor に自動埋めさせて育てていきたい。

---

# 1. ディレクトリ構造（自動生成対象）

以下をカレントディレクトリに作成してください。

python-wiki/
├── 01_basic/
│ ├── overview.md
│ ├── syntax.md
│ ├── datatype.md
│ ├── variable.md
│ ├── operator.md
│ ├── input_output.md
│ └── exercise_basic.md
├── 02_controlflow/
│ ├── overview.md
│ ├── if.md
│ ├── for.md
│ ├── while.md
│ ├── break_continue.md
│ └── exercise_controlflow.md
├── 03_function/
│ ├── overview.md
│ ├── define.md
│ ├── args_kwargs.md
│ ├── return.md
│ ├── scope.md
│ └── exercise_function.md
├── 04_module/
│ ├── overview.md
│ ├── import.md
│ ├── standard_library.md
│ └── exercise_module.md
├── 05_file/
│ ├── open.md
│ ├── read_write.md
│ ├── pathlib.md
│ └── exercise_file.md
├── 06_class/
│ ├── overview.md
│ ├── class.md
│ ├── inheritance.md
│ ├── dunder_method.md
│ └── exercise_class.md
├── 07_advanced/
│ ├── list_comprehension.md
│ ├── generator.md
│ ├── decorator.md
│ └── exception.md
└── README.md


---

# 2. 各 Markdown のテンプレ（自動生成内容）

すべてのページで以下テンプレを使用して生成してください。

{{TITLE}}
1. 要点まとめ

箇条書きで3〜7つほどまとめる

2. 詳細解説

（論理的に5〜15行で解説。必要に応じて図解や例も。）

3. サンプルコード
# サンプルコードを書く

4. 注意点・落とし穴

よくある間違い

初学者がつまずくポイント

5. 演習問題

問題文を書く

問題文を書く

6. 解答例
# 解答例


---

# 3. 生成ルール

- 足りないページやフォルダがあれば、あなたの判断で自動追加して良い
- 内容は「初学者が基礎を体系的に理解できる」ことを最優先
- 難易度は「初学者〜中級者手前」
- Markdown はシンプル構成でOK
- 見出し・箇条書き・コードブロックを必ず使う
- 日本語で書く

---

# 4. 最終出力

- まず **ディレクトリ構造を作成**
- 次に **すべての md ファイルをテンプレに従って自動生成**
- 最後に「Wiki 作成完了」と表示

---

# 5. 続きの運用方法（Cursorに指示する用）

私が以下のように指示したら、Wikiを育てる作業を続けてください。

例）  
- 「list_comprehension.md の内容を詳しくして」  
- 「関数の戻り値について図解を追加して」  
- 「02_controlflow をStep1〜Step5で難易度分けして」  
- 「章立てをPython実践編まで拡張して」  

その際は、
- 過去のmdを読み込み
- 重複しないように
- 別ページも更新が必要なら提案

という方針で作業してください。

---

# 以上の内容に従って、Wikiを自動生成してください。

