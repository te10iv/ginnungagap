# ファイル操作 演習

## 1. 要点まとめ

- ファイルの読み書き
- エラーハンドリング
- pathlibの使用
- 実用的なファイル処理

## 2. 詳細解説

この演習では、ファイル操作に関する知識を総合的に使って問題を解決します。ファイルの読み書き、エラーハンドリング、`pathlib`の使用など、実用的なファイル処理を学びます。

## 3. サンプルコード

```python
# 演習問題の例
from pathlib import Path

file_path = Path("data.txt")
if file_path.exists():
    content = file_path.read_text(encoding="utf-8")
    print(content)
```

## 4. 注意点・落とし穴

- ファイルを開いたら必ず閉じる（`with`文を使う）
- エラーハンドリングを忘れない
- 文字コード（`encoding`）を指定する

## 5. 演習問題

### 問題1: ファイルの読み込みと表示
ファイル`"input.txt"`の内容を読み込み、各行の先頭に行番号を付けて表示してください。

### 問題2: ファイルへの書き込み
リスト`["Python", "Java", "JavaScript", "Go"]`の各要素を1行ずつファイル`"languages.txt"`に書き込んでください。

### 問題3: ファイルのコピー
ファイル`"source.txt"`の内容を読み込み、`"destination.txt"`にコピーしてください。

### 問題4: ファイルの行数カウント
ファイル`"data.txt"`の行数をカウントして表示してください。

### 問題5: pathlibを使ったファイル操作
`pathlib`を使って、以下の処理を行ってください：
1. ディレクトリ`"output"`を作成
2. その中に`"result.txt"`を作成
3. "処理完了"と書き込む

## 6. 解答例

```python
# 問題1: 行番号を付けて表示
try:
    with open("input.txt", "r", encoding="utf-8") as file:
        for line_num, line in enumerate(file, 1):
            print(f"{line_num}: {line}", end="")
except FileNotFoundError:
    print("ファイルが見つかりません")

# 問題2: リストをファイルに書き込む
languages = ["Python", "Java", "JavaScript", "Go"]
with open("languages.txt", "w", encoding="utf-8") as file:
    for lang in languages:
        file.write(lang + "\n")

# 問題3: ファイルのコピー
try:
    with open("source.txt", "r", encoding="utf-8") as source:
        content = source.read()
    
    with open("destination.txt", "w", encoding="utf-8") as dest:
        dest.write(content)
    print("コピーが完了しました")
except FileNotFoundError:
    print("ファイルが見つかりません")

# 問題4: 行数のカウント
try:
    with open("data.txt", "r", encoding="utf-8") as file:
        line_count = sum(1 for line in file)
    print(f"行数: {line_count}")
except FileNotFoundError:
    print("ファイルが見つかりません")

# 問題5: pathlibを使った操作
from pathlib import Path

output_dir = Path("output")
output_dir.mkdir(exist_ok=True)

result_file = output_dir / "result.txt"
result_file.write_text("処理完了", encoding="utf-8")
print("処理が完了しました")
```
