# データ型

## 1. 要点まとめ

- Pythonには数値型（int, float, complex）、文字列型（str）、真偽値型（bool）などの基本型がある
- コレクション型としてリスト（list）、タプル（tuple）、辞書（dict）、集合（set）がある
- 動的型付けのため、変数の型は実行時に決定される
- `type()`関数で型を確認できる
- 型変換は`int()`, `str()`, `float()`などの関数で行う

## 2. 詳細解説

Pythonのデータ型は大きく分けて、基本型とコレクション型に分類されます。

基本型には、整数（int）、浮動小数点数（float）、複素数（complex）、文字列（str）、真偽値（bool）、None型があります。整数は任意の精度を持ち、浮動小数点数はIEEE 754の倍精度を使用します。

コレクション型には、順序付きのリスト（list）、変更不可のタプル（tuple）、キーと値のペアを格納する辞書（dict）、重複のない要素の集合（set）があります。

Pythonは動的型付け言語のため、変数を宣言する際に型を指定する必要はありません。変数に値を代入すると、その値の型が変数の型となります。`type()`関数を使うことで、変数の型を確認できます。

型変換が必要な場合は、`int()`, `str()`, `float()`, `bool()`などの組み込み関数を使用します。ただし、変換できない値の場合は`ValueError`が発生します。

## 3. サンプルコード

```python
# 基本型
age = 25  # int型
height = 175.5  # float型
name = "山田太郎"  # str型
is_student = True  # bool型
nothing = None  # None型

# 型の確認
print(type(age))  # <class 'int'>
print(type(height))  # <class 'float'>
print(type(name))  # <class 'str'>

# コレクション型
numbers = [1, 2, 3, 4, 5]  # list型
coordinates = (10, 20)  # tuple型
person = {"name": "太郎", "age": 25}  # dict型
unique_numbers = {1, 2, 3, 4, 5}  # set型

# 型変換
num_str = "123"
num_int = int(num_str)  # 文字列を整数に変換
num_float = float(num_str)  # 文字列を浮動小数点数に変換
str_num = str(123)  # 数値を文字列に変換
bool_val = bool(1)  # 真偽値に変換（1はTrue）

# 型チェック
if isinstance(age, int):
    print("ageは整数型です")
```

## 4. 注意点・落とし穴

- **整数除算**: Python 3では`/`は常に浮動小数点数を返します。整数除算は`//`を使います
- **文字列と数値の連結**: 文字列と数値を`+`で連結しようとすると`TypeError`になります。`str()`で変換するか、f-stringを使いましょう
- **リストとタプルの違い**: リストは変更可能（mutable）、タプルは変更不可（immutable）です
- **辞書のキー**: 辞書のキーは変更不可な型（文字列、数値、タプルなど）のみ使用できます
- **Noneの比較**: `None`との比較は`==`ではなく`is None`を使うのが推奨されます

## 5. 演習問題

1. 変数`x`に文字列`"100"`を代入し、それを整数に変換して2倍した値を表示してください
2. リスト`[1, 2, 3]`とタプル`(4, 5, 6)`を作成し、それぞれの型を確認してください
3. 辞書を使って、名前と年齢を格納し、値を表示してください

## 6. 解答例

```python
# 1. 文字列を整数に変換
x = "100"
x_int = int(x)
result = x_int * 2
print(result)  # 200

# 2. リストとタプルの型確認
my_list = [1, 2, 3]
my_tuple = (4, 5, 6)
print(type(my_list))  # <class 'list'>
print(type(my_tuple))  # <class 'tuple'>

# 3. 辞書の使用
person = {
    "name": "山田太郎",
    "age": 25
}
print(f"名前: {person['name']}, 年齢: {person['age']}")
```
