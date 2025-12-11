# ジェネレータ

## 1. 要点まとめ

- ジェネレータはイテレータを簡単に作成する方法
- `yield`キーワードで値を返す
- メモリ効率が良い（必要な時だけ値を生成）
- ジェネレータ関数とジェネレータ式がある
- `next()`で次の値を取得できる
- 一度消費されたジェネレータは再利用できない

## 2. 詳細解説

ジェネレータは、イテレータを簡単に作成する方法です。通常の関数と似ていますが、`return`の代わりに`yield`キーワードを使います。

ジェネレータ関数は、`yield`を含む関数です。関数を呼び出すと、ジェネレータオブジェクトが返されます。`next()`を呼び出すと、次の`yield`まで実行され、その値を返します。

ジェネレータの利点は、メモリ効率が良いことです。すべての値を一度にメモリに格納するのではなく、必要な時だけ値を生成します。これにより、大きなデータセットを扱う際にメモリを節約できます。

ジェネレータ式は、リスト内包表記に似た構文で、`()`を使います。`(式 for 要素 in イテラブル)`の形式で使用します。

ジェネレータは一度消費されると再利用できません。再度使用するには、新しいジェネレータを作成する必要があります。

## 3. サンプルコード

```python
# 基本的なジェネレータ関数
def count_up_to(max_count):
    count = 1
    while count <= max_count:
        yield count
        count += 1

counter = count_up_to(5)
print(next(counter))  # 1
print(next(counter))  # 2
print(next(counter))  # 3

# for文で使用
for num in count_up_to(5):
    print(num)  # 1, 2, 3, 4, 5

# ジェネレータ式
squares = (x ** 2 for x in range(10))
print(list(squares))  # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# フィボナッチ数列のジェネレータ
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

fib = fibonacci()
for _ in range(10):
    print(next(fib))  # 0, 1, 1, 2, 3, 5, 8, 13, 21, 34

# ジェネレータの利点（メモリ効率）
def large_range(n):
    i = 0
    while i < n:
        yield i
        i += 1

# リストだとメモリを大量に消費するが、ジェネレータは必要時だけ生成
large_gen = large_range(1000000)
print(next(large_gen))  # 0
print(next(large_gen))  # 1
```

## 4. 注意点・落とし穴

- **一度しか使えない**: ジェネレータは一度消費されると再利用できません
- **`yield`と`return`**: ジェネレータ関数では`return`で値を返すことはできません（`return`だけは可能）
- **メモリ効率**: 大きなデータセットを扱う場合、ジェネレータが有効です
- **状態の保持**: ジェネレータは呼び出し間で状態を保持します

## 5. 演習問題

1. 1からnまでの数値を生成するジェネレータ関数`count_to(n)`を作成してください
2. 偶数だけを生成するジェネレータ関数`even_numbers()`を作成してください
3. ジェネレータ式を使って、1から10までの数値の2乗を生成してください

## 6. 解答例

```python
# 1. count_toジェネレータ
def count_to(n):
    i = 1
    while i <= n:
        yield i
        i += 1

for num in count_to(5):
    print(num)  # 1, 2, 3, 4, 5

# 2. 偶数を生成するジェネレータ
def even_numbers():
    num = 0
    while True:
        yield num
        num += 2

evens = even_numbers()
for _ in range(5):
    print(next(evens))  # 0, 2, 4, 6, 8

# 3. ジェネレータ式
squares = (x ** 2 for x in range(1, 11))
print(list(squares))  # [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```
