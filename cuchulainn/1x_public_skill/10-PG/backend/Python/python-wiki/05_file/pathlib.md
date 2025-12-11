# pathlib

## 1. 要点まとめ

- `pathlib`はモダンなファイルパス操作のライブラリ
- `Path`クラスでパスを表現する
- パスの結合は`/`演算子で行える
- ファイルの存在確認は`exists()`メソッド
- ファイルの読み書きも`Path`オブジェクトから直接できる
- クロスプラットフォーム対応（Windows/Mac/Linux）

## 2. 詳細解説

`pathlib`は、Python 3.4で導入された、ファイルパスを扱うためのモジュールです。従来の`os.path`よりも直感的で使いやすいAPIを提供します。

`Path`クラスを使ってパスを表現します。`Path("ファイル名")`や`Path("ディレクトリ/ファイル名")`のように使用します。

パスの結合は、`/`演算子で行えます。`Path("dir") / "file.txt"`のように、直感的にパスを結合できます。

ファイルの存在確認は`exists()`メソッドで行えます。`Path("file.txt").exists()`のように使用します。

`Path`オブジェクトから直接ファイルの読み書きができます。`read_text()`で読み込み、`write_text()`で書き込みができます。

`pathlib`はクロスプラットフォーム対応なので、Windows、Mac、Linuxで同じコードが動作します。

## 3. サンプルコード

```python
from pathlib import Path

# Pathオブジェクトの作成
file_path = Path("example.txt")
dir_path = Path("data")

# パスの結合
full_path = Path("data") / "example.txt"
print(full_path)  # data/example.txt

# ファイルの存在確認
if file_path.exists():
    print("ファイルが存在します")

# ファイルの読み込み
content = file_path.read_text(encoding="utf-8")
print(content)

# ファイルの書き込み
file_path.write_text("Hello, World!", encoding="utf-8")

# ディレクトリの作成
new_dir = Path("new_directory")
new_dir.mkdir(exist_ok=True)  # exist_ok=Trueで既存でもエラーにならない

# ファイル名や拡張子の取得
file_path = Path("data/example.txt")
print(file_path.name)  # example.txt
print(file_path.stem)  # example
print(file_path.suffix)  # .txt
print(file_path.parent)  # data

# ディレクトリ内のファイル一覧
dir_path = Path(".")
for file in dir_path.iterdir():
    print(file)
```

## 4. 注意点・落とし穴

- **文字コード**: `read_text()`や`write_text()`では`encoding`パラメータを指定できます
- **ディレクトリの作成**: `mkdir()`でディレクトリを作成できますが、親ディレクトリが存在しない場合は`parents=True`が必要です
- **パスの正規化**: `Path`オブジェクトは自動的にパスを正規化します（`..`や`.`を適切に処理）
- **文字列への変換**: `str()`で文字列に変換できますが、通常は自動的に変換されます

## 5. 演習問題

1. `Path`オブジェクトを使って、ファイル`"data/example.txt"`のパスを作成してください
2. ファイルが存在するか確認し、存在する場合は内容を読み込んで表示してください
3. `Path`オブジェクトを使って、新しいディレクトリ`"output"`を作成し、その中に`"result.txt"`というファイルを作成して"完了"と書き込んでください

## 6. 解答例

```python
from pathlib import Path

# 1. パスの作成
file_path = Path("data") / "example.txt"
print(file_path)

# 2. 存在確認と読み込み
if file_path.exists():
    content = file_path.read_text(encoding="utf-8")
    print(content)
else:
    print("ファイルが見つかりません")

# 3. ディレクトリとファイルの作成
output_dir = Path("output")
output_dir.mkdir(exist_ok=True)

result_file = output_dir / "result.txt"
result_file.write_text("完了", encoding="utf-8")
```
