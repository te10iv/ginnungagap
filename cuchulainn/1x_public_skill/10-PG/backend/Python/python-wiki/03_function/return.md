# 戻り値

## 1. 要点まとめ

- `return`文で関数から値を返す
- `return`がない場合、関数は`None`を返す
- `return`が実行されると、関数の実行は終了する
- 複数の値を返す場合はタプルとして返す
- 早期リターンで条件分岐を簡潔にできる
- 戻り値の型は動的に決定される

## 2. 詳細解説

`return`文は、関数から値を返すために使用します。`return 値`の形式で記述し、関数の呼び出し元に値を返します。

`return`文がない場合、関数は`None`を返します。明示的に`return None`と書くこともできますが、通常は省略します。

`return`文が実行されると、関数の実行は即座に終了します。`return`の後の処理は実行されません。この特性を利用して、早期リターン（early return）というパターンで、条件分岐を簡潔に書くことができます。

複数の値を返したい場合は、カンマで区切って返すと、タプルとして返されます。受け取る側では、複数の変数に代入することで展開できます。

戻り値の型は動的に決定されます。同じ関数が異なる型の値を返すことも可能ですが、コードの可読性を考えると避けるべきです。

## 3. サンプルコード

```python
# 基本的なreturn
def add(a, b):
    return a + b

result = add(3, 5)
print(result)  # 8

# returnがない場合（Noneを返す）
def greet(name):
    print(f"こんにちは、{name}さん")
    # returnがないのでNoneを返す

result = greet("太郎")
print(result)  # None

# 複数の値を返す（タプル）
def get_name_and_age():
    name = "太郎"
    age = 25
    return name, age  # タプルとして返される

name, age = get_name_and_age()
print(f"{name}は{age}歳です")

# 早期リターン
def check_positive(num):
    if num <= 0:
        return False  # 早期リターン
    return True  # 正の数の場合のみ実行される

# 条件に応じて異なる値を返す
def get_grade(score):
    if score >= 90:
        return "A"
    elif score >= 80:
        return "B"
    elif score >= 70:
        return "C"
    else:
        return "D"

grade = get_grade(85)
print(grade)  # "B"

# returnで関数を終了
def process_data(data):
    if not data:
        return  # データが空なら何もせず終了
    # データ処理
    print("データを処理します")
    return "処理完了"

result = process_data([])  # 何も表示されず、Noneが返る
result = process_data([1, 2, 3])  # "データを処理します"が表示され、"処理完了"が返る
```

## 4. 注意点・落とし穴

- **returnの位置**: `return`が実行されると、その後の処理は実行されません
- **Noneの返却**: `return`がない場合、関数は`None`を返します。戻り値を使う場合は注意が必要です
- **複数のreturn**: 1つの関数に複数の`return`文を書くことができますが、可読性を考慮しましょう
- **型の一貫性**: 同じ関数が異なる型の値を返すと、呼び出し側で混乱する可能性があります
- **タプルの展開**: 複数の値を返す場合、受け取る側で適切に展開する必要があります

## 5. 演習問題

1. 2つの数値を受け取り、その差を返す関数`subtract(a, b)`を作成してください
2. 数値を受け取り、それが偶数かどうかを真偽値で返す関数`is_even(num)`を作成してください
3. 名前と年齢を受け取り、それらをタプルとして返す関数`get_person_info(name, age)`を作成してください
4. 早期リターンを使って、数値が負の数の場合に`None`を返す関数`process_positive(num)`を作成してください

## 6. 解答例

```python
# 1. 差を返す関数
def subtract(a, b):
    return a - b

result = subtract(10, 3)
print(result)  # 7

# 2. 偶数判定
def is_even(num):
    return num % 2 == 0

print(is_even(4))  # True
print(is_even(5))  # False

# 3. タプルを返す関数
def get_person_info(name, age):
    return name, age

name, age = get_person_info("太郎", 25)
print(f"{name}は{age}歳です")

# 4. 早期リターン
def process_positive(num):
    if num < 0:
        return None  # 早期リターン
    return num * 2  # 正の数の場合のみ実行

result = process_positive(-5)
print(result)  # None
result = process_positive(10)
print(result)  # 20
```
