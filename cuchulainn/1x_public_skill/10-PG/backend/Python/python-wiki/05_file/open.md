# ファイルの開閉

## 1. 要点まとめ

- `open()`関数でファイルを開く
- ファイルモード（`'r'`, `'w'`, `'a'`など）を指定する
- `with`文を使うと自動的にファイルを閉じる
- ファイルを開いたら必ず閉じる（リソースの解放）
- ファイルが存在しない場合のエラーハンドリングが必要

## 2. 詳細解説

ファイルを操作するには、まず`open()`関数でファイルを開く必要があります。`open(ファイルパス, モード)`の形式で使用します。

ファイルモードは、ファイルをどのように扱うかを指定します。主なモードは以下の通りです：
- `'r'`: 読み込みモード（デフォルト）
- `'w'`: 書き込みモード（既存のファイルは上書き）
- `'a'`: 追記モード（既存のファイルの末尾に追加）
- `'x'`: 排他的作成モード（ファイルが存在する場合はエラー）
- `'b'`: バイナリモード（`'rb'`, `'wb'`など）

ファイルを開いたら、必ず`close()`メソッドで閉じる必要があります。ファイルを閉じないと、リソースが解放されず、メモリリークの原因になる可能性があります。

`with`文を使うと、ファイルを自動的に閉じてくれます。`with open(...) as f:`の形式で使用し、ブロックを抜けると自動的にファイルが閉じられます。この方法が推奨されます。

## 3. サンプルコード

```python
# 基本的なファイルの開閉
file = open("example.txt", "r")
content = file.read()
file.close()

# with文を使った方法（推奨）
with open("example.txt", "r") as file:
    content = file.read()
# ブロックを抜けると自動的に閉じられる

# 書き込みモード
with open("output.txt", "w") as file:
    file.write("Hello, World!")

# 追記モード
with open("log.txt", "a") as file:
    file.write("新しいログ\n")

# バイナリモード
with open("image.jpg", "rb") as file:
    data = file.read()
```

## 4. 注意点・落とし穴

- **ファイルの閉じ忘れ**: ファイルを開いたら必ず閉じましょう。`with`文を使うと自動的に閉じられます
- **ファイルが存在しない場合**: 読み込みモードで存在しないファイルを開こうとすると`FileNotFoundError`が発生します
- **書き込みモードの注意**: `'w'`モードは既存のファイルを上書きします。データが失われる可能性があるので注意しましょう
- **エンコーディング**: テキストファイルを扱う場合、`encoding`パラメータで文字コードを指定できます（例: `encoding='utf-8'`）
- **パスの指定**: 相対パスと絶対パスの違いを理解しましょう

## 5. 演習問題

1. `with`文を使って、ファイル`"hello.txt"`を読み込みモードで開き、内容を表示してください
2. `with`文を使って、ファイル`"output.txt"`に"Pythonを学んでいます"と書き込んでください
3. ファイルが存在しない場合のエラーハンドリングを追加してください

## 6. 解答例

```python
# 1. ファイルの読み込み
try:
    with open("hello.txt", "r", encoding="utf-8") as file:
        content = file.read()
        print(content)
except FileNotFoundError:
    print("ファイルが見つかりません")

# 2. ファイルの書き込み
with open("output.txt", "w", encoding="utf-8") as file:
    file.write("Pythonを学んでいます")

# 3. エラーハンドリング付き
try:
    with open("example.txt", "r", encoding="utf-8") as file:
        content = file.read()
        print(content)
except FileNotFoundError:
    print("ファイルが見つかりません")
except PermissionError:
    print("ファイルへのアクセス権限がありません")
except Exception as e:
    print(f"エラーが発生しました: {e}")
```
