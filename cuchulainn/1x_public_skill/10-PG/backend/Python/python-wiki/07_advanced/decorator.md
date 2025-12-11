# デコレータ

## 1. 要点まとめ

- デコレータは関数を修飾する機能
- `@デコレータ名`の形式で使用
- 関数を引数として受け取り、新しい関数を返す
- 既存の関数を変更せずに機能を追加できる
- 複数のデコレータを重ねて使える
- デコレータ関数とデコレータクラスがある

## 2. 詳細解説

デコレータは、関数を修飾する機能です。既存の関数を変更せずに、機能を追加できます。

デコレータは、関数を引数として受け取り、新しい関数（または元の関数をラップした関数）を返す関数です。

デコレータを使うには、`@デコレータ名`を関数の定義の前に付けます。これは`関数 = デコレータ(関数)`と同じ意味です。

デコレータの利点は、既存のコードを変更せずに機能を追加できることです。ログ出力、実行時間の計測、認証チェックなど、横断的関心事（cross-cutting concern）を実装する際に便利です。

複数のデコレータを重ねて使うこともできます。下から上に順番に適用されます。

デコレータ関数だけでなく、デコレータクラスも作成できます。`__call__`メソッドを実装することで、クラスをデコレータとして使えます。

## 3. サンプルコード

```python
# 基本的なデコレータ
def my_decorator(func):
    def wrapper():
        print("関数の実行前")
        func()
        print("関数の実行後")
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

say_hello()
# 関数の実行前
# Hello!
# 関数の実行後

# 引数を受け取る関数のデコレータ
def decorator_with_args(func):
    def wrapper(*args, **kwargs):
        print(f"関数 {func.__name__} が呼ばれました")
        return func(*args, **kwargs)
    return wrapper

@decorator_with_args
def add(a, b):
    return a + b

result = add(3, 5)  # "関数 add が呼ばれました"
print(result)  # 8

# 実行時間を計測するデコレータ
import time

def timing_decorator(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} の実行時間: {end - start:.4f}秒")
        return result
    return wrapper

@timing_decorator
def slow_function():
    time.sleep(1)
    return "完了"

slow_function()  # "slow_function の実行時間: 1.0000秒"

# 複数のデコレータ
def decorator1(func):
    def wrapper():
        print("デコレータ1")
        func()
    return wrapper

def decorator2(func):
    def wrapper():
        print("デコレータ2")
        func()
    return wrapper

@decorator1
@decorator2
def say_hi():
    print("Hi!")

say_hi()
# デコレータ1
# デコレータ2
# Hi!
```

## 4. 注意点・落とし穴

- **`functools.wraps`**: デコレータを使うと、元の関数のメタデータ（名前、docstringなど）が失われる可能性があります。`functools.wraps`を使うと保持できます
- **引数の扱い**: デコレータは様々な引数を受け取る関数に対応できるよう、`*args, **kwargs`を使うのが一般的です
- **デコレータの順序**: 複数のデコレータを使う場合、下から上に適用されます

## 5. 演習問題

1. 関数の実行前後にメッセージを表示するデコレータ`log_decorator`を作成してください
2. 関数の実行時間を計測するデコレータ`timer_decorator`を作成してください
3. 関数が呼ばれた回数をカウントするデコレータ`count_calls`を作成してください

## 6. 解答例

```python
# 1. ログデコレータ
def log_decorator(func):
    def wrapper(*args, **kwargs):
        print(f"{func.__name__} を実行します")
        result = func(*args, **kwargs)
        print(f"{func.__name__} の実行が完了しました")
        return result
    return wrapper

@log_decorator
def greet(name):
    print(f"こんにちは、{name}さん")

greet("太郎")

# 2. タイマーデコレータ
import time

def timer_decorator(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"実行時間: {end - start:.4f}秒")
        return result
    return wrapper

@timer_decorator
def calculate():
    total = sum(range(1000000))
    return total

calculate()

# 3. 呼び出し回数カウントデコレータ
def count_calls(func):
    func.call_count = 0
    def wrapper(*args, **kwargs):
        func.call_count += 1
        print(f"{func.__name__} が {func.call_count} 回呼ばれました")
        return func(*args, **kwargs)
    return wrapper

@count_calls
def say_hello():
    print("Hello!")

say_hello()  # "say_hello が 1 回呼ばれました"
say_hello()  # "say_hello が 2 回呼ばれました"
```
