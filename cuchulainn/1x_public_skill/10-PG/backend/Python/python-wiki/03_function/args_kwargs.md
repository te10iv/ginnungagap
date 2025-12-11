# 引数とキーワード引数

## 1. 要点まとめ

- 位置引数は順序通りに渡される
- キーワード引数は引数名を指定して渡せる
- `*args`で可変長の位置引数を受け取れる
- `**kwargs`で可変長のキーワード引数を受け取れる
- デフォルト引数で引数を省略できる
- 引数の順序: 位置引数 → デフォルト引数 → `*args` → `**kwargs`

## 2. 詳細解説

Pythonの関数には、様々な方法で引数を渡すことができます。

位置引数は、関数定義の順序通りに渡される引数です。`func(a, b, c)`のように呼び出すと、`a`、`b`、`c`の順に引数が渡されます。

キーワード引数は、引数名を指定して渡す引数です。`func(a=1, b=2, c=3)`のように呼び出すと、順序に関係なく引数を渡せます。位置引数とキーワード引数を混在させる場合、位置引数を先に書く必要があります。

`*args`を使うと、可変長の位置引数を受け取れます。`args`はタプルとして扱われ、任意の数の引数を渡せます。

`**kwargs`を使うと、可変長のキーワード引数を受け取れます。`kwargs`は辞書として扱われ、任意の数のキーワード引数を渡せます。

デフォルト引数は、引数にデフォルト値を指定することで、呼び出し時に省略できます。デフォルト引数は、デフォルト値のない引数の後に置く必要があります。

## 3. サンプルコード

```python
# 位置引数
def greet(name, age):
    print(f"{name}は{age}歳です")

greet("太郎", 25)  # 位置引数で渡す

# キーワード引数
greet(age=25, name="太郎")  # 順序を変えられる
greet("太郎", age=25)  # 位置引数とキーワード引数の混在

# デフォルト引数
def greet_with_default(name, age=20):
    print(f"{name}は{age}歳です")

greet_with_default("太郎")  # ageは省略可能
greet_with_default("花子", 30)  # ageを指定することも可能

# *args（可変長位置引数）
def sum_all(*args):
    total = 0
    for num in args:
        total += num
    return total

print(sum_all(1, 2, 3))  # 6
print(sum_all(1, 2, 3, 4, 5))  # 15

# **kwargs（可変長キーワード引数）
def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

print_info(name="太郎", age=25, city="東京")

# *argsと**kwargsの組み合わせ
def func(a, b, *args, **kwargs):
    print(f"a={a}, b={b}")
    print(f"args={args}")
    print(f"kwargs={kwargs}")

func(1, 2, 3, 4, 5, x=10, y=20)
# a=1, b=2
# args=(3, 4, 5)
# kwargs={'x': 10, 'y': 20}
```

## 4. 注意点・落とし穴

- **引数の順序**: 位置引数、デフォルト引数、`*args`、`**kwargs`の順序を守る必要があります
- **デフォルト引数の位置**: デフォルト引数は、デフォルト値のない引数の後に置く必要があります
- **キーワード引数の後**: キーワード引数を使った後は、位置引数を使えません
- **`*args`と`**kwargs`の名前**: `args`と`kwargs`は慣習的な名前で、他の名前でも動作しますが、慣習に従うのが推奨されます
- **可変長引数の使用**: `*args`や`**kwargs`を使うと柔軟になりますが、関数の仕様が不明確になる可能性があります

## 5. 演習問題

1. デフォルト引数を使って、挨拶文を表示する関数`greet(name="ゲスト", greeting="こんにちは")`を作成してください
2. `*args`を使って、任意の数の数値の平均を計算する関数`average(*args)`を作成してください
3. `**kwargs`を使って、人物情報を表示する関数`print_person(**kwargs)`を作成してください
4. 位置引数、`*args`、`**kwargs`をすべて使う関数を作成してください

## 6. 解答例

```python
# 1. デフォルト引数
def greet(name="ゲスト", greeting="こんにちは"):
    print(f"{greeting}、{name}さん")

greet()  # "こんにちは、ゲストさん"
greet("太郎")  # "こんにちは、太郎さん"
greet("花子", "おはよう")  # "おはよう、花子さん"

# 2. *argsで平均を計算
def average(*args):
    if len(args) == 0:
        return 0
    return sum(args) / len(args)

print(average(1, 2, 3, 4, 5))  # 3.0
print(average(10, 20, 30))  # 20.0

# 3. **kwargsで人物情報を表示
def print_person(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

print_person(name="太郎", age=25, city="東京")

# 4. すべての引数タイプを使用
def complex_func(a, b, *args, **kwargs):
    print(f"a={a}, b={b}")
    print(f"追加の位置引数: {args}")
    print(f"追加のキーワード引数: {kwargs}")

complex_func(1, 2, 3, 4, 5, x=10, y=20)
```
