# 例外処理

## 1. 要点まとめ

- 例外はプログラム実行中のエラー
- `try-except`文で例外を捕捉できる
- `else`節で例外が発生しなかった場合の処理を記述
- `finally`節で必ず実行される処理を記述
- 複数の例外を捕捉できる
- 独自の例外クラスを定義できる

## 2. 詳細解説

例外は、プログラムの実行中に発生するエラーです。例外が発生すると、プログラムの実行が中断されます。

`try-except`文を使うと、例外を捕捉して処理を続行できます。`try`ブロックに例外が発生する可能性のあるコードを書き、`except`ブロックに例外が発生した場合の処理を書きます。

`else`節は、例外が発生しなかった場合に実行されます。`try`ブロックが正常に完了した場合に実行されます。

`finally`節は、例外の有無に関わらず、必ず実行されます。リソースのクリーンアップなどに使用します。

複数の例外を捕捉する場合は、複数の`except`節を書くか、`except (例外1, 例外2):`のようにタプルで指定します。

独自の例外クラスを定義することもできます。`Exception`クラスを継承して作成します。

## 3. サンプルコード

```python
# 基本的な例外処理
try:
    result = 10 / 0
except ZeroDivisionError:
    print("ゼロで割ることはできません")

# 複数の例外を捕捉
try:
    num = int(input("数値を入力してください: "))
    result = 10 / num
except ValueError:
    print("数値に変換できません")
except ZeroDivisionError:
    print("ゼロで割ることはできません")

# else節の使用
try:
    file = open("example.txt", "r")
except FileNotFoundError:
    print("ファイルが見つかりません")
else:
    content = file.read()
    print(content)
    file.close()

# finally節の使用
try:
    file = open("example.txt", "r")
    content = file.read()
except FileNotFoundError:
    print("ファイルが見つかりません")
finally:
    print("処理を終了します")
    # ファイルが開かれている場合は閉じる処理など

# 例外情報の取得
try:
    result = 10 / 0
except ZeroDivisionError as e:
    print(f"エラー: {e}")

# すべての例外を捕捉（非推奨）
try:
    # 何らかの処理
    pass
except Exception as e:
    print(f"エラーが発生しました: {e}")

# 独自の例外クラス
class MyCustomError(Exception):
    pass

def check_positive(num):
    if num < 0:
        raise MyCustomError("数値は正である必要があります")
    return num

try:
    check_positive(-5)
except MyCustomError as e:
    print(f"カスタムエラー: {e}")
```

## 4. 注意点・落とし穴

- **例外の捕捉範囲**: 必要最小限の例外だけを捕捉しましょう。すべての例外を捕捉するのは避けます
- **`except Exception`**: すべての例外を捕捉するのは、デバッグを困難にする可能性があります
- **`finally`の使用**: リソースのクリーンアップには`finally`を使いましょう。`with`文を使うとより簡潔に書けます
- **例外の再発生**: `raise`で例外を再発生させることができます
- **例外のチェーン**: `raise ... from ...`で例外をチェーンできます

## 5. 演習問題

1. ユーザーに数値を入力させ、それを2で割った結果を表示するプログラムを作成してください。例外処理を追加してください
2. ファイル`"data.txt"`を読み込むプログラムを作成してください。ファイルが存在しない場合の例外処理を追加してください
3. 独自の例外クラス`NegativeNumberError`を定義し、負の数が渡された場合にこの例外を発生させる関数を作成してください

## 6. 解答例

```python
# 1. 数値の入力と割り算
try:
    num = float(input("数値を入力してください: "))
    result = 2 / num
    print(f"結果: {result}")
except ValueError:
    print("数値に変換できません")
except ZeroDivisionError:
    print("ゼロで割ることはできません")
except Exception as e:
    print(f"予期しないエラー: {e}")

# 2. ファイルの読み込み
try:
    with open("data.txt", "r", encoding="utf-8") as file:
        content = file.read()
        print(content)
except FileNotFoundError:
    print("ファイルが見つかりません")
except PermissionError:
    print("ファイルへのアクセス権限がありません")
except Exception as e:
    print(f"エラーが発生しました: {e}")

# 3. 独自の例外クラス
class NegativeNumberError(Exception):
    def __init__(self, message="数値は正である必要があります"):
        self.message = message
        super().__init__(self.message)

def check_positive(num):
    if num < 0:
        raise NegativeNumberError(f"{num}は負の数です")
    return num

try:
    check_positive(-10)
except NegativeNumberError as e:
    print(f"エラー: {e}")
```
