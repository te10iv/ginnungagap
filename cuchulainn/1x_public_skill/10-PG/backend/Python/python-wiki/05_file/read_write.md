# ファイルの読み書き

## 1. 要点まとめ

- `read()`でファイル全体を読み込む
- `readline()`で1行ずつ読み込む
- `readlines()`で全行をリストとして読み込む
- `write()`で文字列を書き込む
- `writelines()`でリストの内容を書き込む
- ファイルポインタの位置に注意する

## 2. 詳細解説

ファイルの読み込みには、いくつかの方法があります。

`read()`メソッドは、ファイル全体を文字列として読み込みます。引数で読み込むバイト数を指定することもできます。

`readline()`メソッドは、1行ずつ読み込みます。改行文字（`\n`）も含まれます。ファイルの末尾に達すると空文字列を返します。

`readlines()`メソッドは、ファイルの全行をリストとして読み込みます。各行がリストの要素になります。

ファイルへの書き込みには、`write()`メソッドを使います。文字列を書き込みますが、自動的に改行は追加されません。改行が必要な場合は、明示的に`\n`を追加する必要があります。

`writelines()`メソッドは、文字列のリストを書き込みます。各要素の間に自動的に改行は追加されないので、必要に応じて`\n`を含める必要があります。

ファイルにはファイルポインタ（現在の読み書き位置）があり、読み書きを行うと自動的に進みます。`seek()`メソッドで位置を変更できます。

## 3. サンプルコード

```python
# read()で全体を読み込む
with open("example.txt", "r", encoding="utf-8") as file:
    content = file.read()
    print(content)

# readline()で1行ずつ読み込む
with open("example.txt", "r", encoding="utf-8") as file:
    line = file.readline()
    while line:
        print(line, end="")  # end=""で改行を抑制
        line = file.readline()

# readlines()で全行をリストとして読み込む
with open("example.txt", "r", encoding="utf-8") as file:
    lines = file.readlines()
    for line in lines:
        print(line, end="")

# ファイルを直接イテレート（推奨）
with open("example.txt", "r", encoding="utf-8") as file:
    for line in file:
        print(line, end="")

# write()で書き込む
with open("output.txt", "w", encoding="utf-8") as file:
    file.write("1行目\n")
    file.write("2行目\n")

# writelines()でリストを書き込む
lines = ["1行目\n", "2行目\n", "3行目\n"]
with open("output.txt", "w", encoding="utf-8") as file:
    file.writelines(lines)
```

## 4. 注意点・落とし穴

- **メモリ使用量**: `read()`で大きなファイルを読み込むと、メモリを大量に消費します。大きなファイルは1行ずつ処理しましょう
- **改行文字**: `readline()`は改行文字も含みます。`strip()`で削除する場合が多いです
- **ファイルポインタ**: 一度読み込んだ後、再度読み込むには`seek(0)`で先頭に戻す必要があります
- **エンコーディング**: 日本語を含むファイルは`encoding='utf-8'`を指定しましょう
- **書き込みモード**: `'w'`モードは既存のファイルを上書きします。追記したい場合は`'a'`モードを使いましょう

## 5. 演習問題

1. ファイル`"data.txt"`の内容を1行ずつ読み込み、各行の先頭に行番号を付けて表示してください
2. リスト`["りんご", "バナナ", "オレンジ"]`の各要素を1行ずつファイル`"fruits.txt"`に書き込んでください
3. ファイル`"input.txt"`の内容を読み込み、大文字に変換して`"output.txt"`に書き込んでください

## 6. 解答例

```python
# 1. 行番号を付けて表示
with open("data.txt", "r", encoding="utf-8") as file:
    for line_num, line in enumerate(file, 1):
        print(f"{line_num}: {line}", end="")

# 2. リストをファイルに書き込む
fruits = ["りんご", "バナナ", "オレンジ"]
with open("fruits.txt", "w", encoding="utf-8") as file:
    for fruit in fruits:
        file.write(fruit + "\n")

# 3. 大文字に変換して書き込む
with open("input.txt", "r", encoding="utf-8") as input_file:
    content = input_file.read()
    upper_content = content.upper()

with open("output.txt", "w", encoding="utf-8") as output_file:
    output_file.write(upper_content)
```
