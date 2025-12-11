# 関数編 演習

## 1. 要点まとめ

- 関数の定義と呼び出し
- 引数と戻り値の使い方
- スコープの理解
- 実用的な関数の作成

## 2. 詳細解説

この演習では、関数の定義、引数の受け渡し、戻り値の返却、スコープなど、関数に関する知識を総合的に使って問題を解決します。

関数を使うことで、コードを再利用可能な単位に分割でき、保守性が向上します。実用的な関数を作成することで、関数の使い方を実践的に学びます。

## 3. サンプルコード

```python
# 演習問題の例
def calculate_area(radius):
    return 3.14 * radius * radius

area = calculate_area(5)
print(area)
```

## 4. 注意点・落とし穴

- 引数の数と型を正しく渡す
- 戻り値の型を意識する
- グローバル変数の変更には`global`が必要
- 関数名は意味のある名前にする

## 5. 演習問題

### 問題1: 最大値を返す関数
3つの数値を受け取り、その最大値を返す関数`max_of_three(a, b, c)`を作成してください。

### 問題2: 文字列の反転
文字列を受け取り、それを反転した文字列を返す関数`reverse_string(text)`を作成してください。

### 問題3: 素数判定関数
数値を受け取り、それが素数かどうかを真偽値で返す関数`is_prime(num)`を作成してください。

### 問題4: リストの合計と平均
数値のリストを受け取り、その合計と平均をタプルとして返す関数`sum_and_average(numbers)`を作成してください。

### 問題5: カウンター関数
グローバル変数`counter`を定義し、関数`increment()`と`decrement()`でその値を増減させるプログラムを作成してください。

## 6. 解答例

```python
# 問題1: 最大値を返す
def max_of_three(a, b, c):
    if a >= b and a >= c:
        return a
    elif b >= a and b >= c:
        return b
    else:
        return c

print(max_of_three(10, 25, 15))  # 25

# 問題2: 文字列の反転
def reverse_string(text):
    return text[::-1]

print(reverse_string("Python"))  # "nohtyP"

# 問題3: 素数判定
def is_prime(num):
    if num < 2:
        return False
    for i in range(2, num):
        if num % i == 0:
            return False
    return True

print(is_prime(7))  # True
print(is_prime(10))  # False

# 問題4: 合計と平均
def sum_and_average(numbers):
    total = sum(numbers)
    average = total / len(numbers) if len(numbers) > 0 else 0
    return total, average

total, avg = sum_and_average([1, 2, 3, 4, 5])
print(f"合計: {total}, 平均: {avg}")

# 問題5: カウンター
counter = 0

def increment():
    global counter
    counter += 1

def decrement():
    global counter
    counter -= 1

increment()
increment()
print(counter)  # 2
decrement()
print(counter)  # 1
```
