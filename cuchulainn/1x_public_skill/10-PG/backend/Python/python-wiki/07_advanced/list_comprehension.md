# リスト内包表記

## 1. 要点まとめ

- リスト内包表記はリストを簡潔に作成する構文
- `[式 for 要素 in イテラブル]`の基本形式
- 条件分岐（`if`）を追加できる
- ネストしたリスト内包表記も可能
- 辞書内包表記、集合内包表記もある
- 可読性とパフォーマンスのバランスを考慮する

## 2. 詳細解説

リスト内包表記は、リストを簡潔に作成するための構文です。`for`文と`append()`を使った処理を1行で書けます。

基本的な形式は`[式 for 要素 in イテラブル]`です。イテラブル（リスト、文字列、rangeなど）の各要素に対して式を評価し、その結果をリストに格納します。

条件分岐を追加する場合は、`[式 for 要素 in イテラブル if 条件]`の形式を使います。条件が`True`の要素だけがリストに含まれます。

ネストしたリスト内包表記も可能です。`[式 for 要素1 in イテラブル1 for 要素2 in イテラブル2]`の形式で、2つのループをネストできます。

辞書内包表記は`{キー: 値 for 要素 in イテラブル}`の形式で、集合内包表記は`{式 for 要素 in イテラブル}`の形式で使用できます。

リスト内包表記は簡潔で読みやすいですが、複雑になりすぎると可読性が低下する可能性があります。適度に使いましょう。

## 3. サンプルコード

```python
# 基本的なリスト内包表記
squares = [x ** 2 for x in range(10)]
print(squares)  # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# 条件分岐を含む
evens = [x for x in range(20) if x % 2 == 0]
print(evens)  # [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]

# 文字列の処理
words = ["hello", "world", "python"]
upper_words = [word.upper() for word in words]
print(upper_words)  # ['HELLO', 'WORLD', 'PYTHON']

# ネストしたリスト内包表記
matrix = [[i * j for j in range(3)] for i in range(3)]
print(matrix)  # [[0, 0, 0], [0, 1, 2], [0, 2, 4]]

# 辞書内包表記
squares_dict = {x: x ** 2 for x in range(5)}
print(squares_dict)  # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# 集合内包表記
unique_squares = {x ** 2 for x in range(-5, 6)}
print(unique_squares)  # {0, 1, 4, 9, 16, 25}
```

## 4. 注意点・落とし穴

- **可読性**: リスト内包表記が複雑になりすぎると、可読性が低下します。適度に使いましょう
- **メモリ使用量**: 大きなリストを作成する場合、メモリを大量に消費する可能性があります
- **条件の順序**: `if`は`for`の後に置きます。`if-else`を使う場合は、式の前に置きます
- **ネストの深さ**: ネストが深くなりすぎると、理解が困難になります

## 5. 演習問題

1. 1から20までの数値のうち、3の倍数だけをリスト内包表記で作成してください
2. 文字列のリスト`["apple", "banana", "cherry"]`の各要素を大文字に変換したリストを作成してください
3. 辞書内包表記を使って、1から10までの数値とその2乗を対応付けた辞書を作成してください

## 6. 解答例

```python
# 1. 3の倍数
multiples_of_3 = [x for x in range(1, 21) if x % 3 == 0]
print(multiples_of_3)  # [3, 6, 9, 12, 15, 18]

# 2. 大文字変換
fruits = ["apple", "banana", "cherry"]
upper_fruits = [fruit.upper() for fruit in fruits]
print(upper_fruits)  # ['APPLE', 'BANANA', 'CHERRY']

# 3. 辞書内包表記
squares = {x: x ** 2 for x in range(1, 11)}
print(squares)  # {1: 1, 2: 4, 3: 9, ..., 10: 100}
```
