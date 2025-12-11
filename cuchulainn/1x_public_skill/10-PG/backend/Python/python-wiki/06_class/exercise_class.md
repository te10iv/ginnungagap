# クラス編 演習

## 1. 要点まとめ

- クラスの定義とインスタンス化
- 継承の活用
- 特殊メソッドの実装
- 実用的なクラス設計

## 2. 詳細解説

この演習では、クラス、継承、特殊メソッドなどの知識を総合的に使って問題を解決します。オブジェクト指向プログラミングの実践的な使い方を学びます。

## 3. サンプルコード

```python
# 演習問題の例
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        raise NotImplementedError

class Dog(Animal):
    def speak(self):
        return f"{self.name}がワンワン"
```

## 4. 注意点・落とし穴

- `self`を忘れない
- 継承の階層を深くしすぎない
- 特殊メソッドの命名規則を守る

## 5. 演習問題

### 問題1: 基本的なクラス
`BankAccount`クラスを定義し、以下の機能を実装してください：
- 初期残高を設定できる
- `deposit(amount)`メソッドで預金できる
- `withdraw(amount)`メソッドで引き出せる（残高不足の場合はエラーメッセージ）
- `get_balance()`メソッドで残高を取得できる

### 問題2: 継承
`Animal`クラスを親クラスとして定義し、`Dog`クラスと`Cat`クラスを子クラスとして定義してください。それぞれに`speak()`メソッドを実装してください。

### 問題3: 特殊メソッド
`Fraction`クラス（分数）を定義し、以下の特殊メソッドを実装してください：
- `__str__`: 分数を「分子/分母」形式で表示
- `__add__`: 分数の足し算
- `__eq__`: 分数の等価性判定

## 6. 解答例

```python
# 問題1: BankAccountクラス
class BankAccount:
    def __init__(self, initial_balance=0):
        self.balance = initial_balance
    
    def deposit(self, amount):
        if amount > 0:
            self.balance += amount
            return self.balance
        else:
            return "預金額は正の数である必要があります"
    
    def withdraw(self, amount):
        if amount > 0:
            if amount <= self.balance:
                self.balance -= amount
                return self.balance
            else:
                return "残高不足です"
        else:
            return "引き出し額は正の数である必要があります"
    
    def get_balance(self):
        return self.balance

account = BankAccount(1000)
account.deposit(500)
print(account.get_balance())  # 1500
account.withdraw(200)
print(account.get_balance())  # 1300

# 問題2: 継承
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        raise NotImplementedError("サブクラスで実装してください")

class Dog(Animal):
    def speak(self):
        return f"{self.name}がワンワンと吠えました"

class Cat(Animal):
    def speak(self):
        return f"{self.name}がニャーと鳴きました"

dog = Dog("ポチ")
print(dog.speak())  # "ポチがワンワンと吠えました"

cat = Cat("タマ")
print(cat.speak())  # "タマがニャーと鳴きました"

# 問題3: 特殊メソッド
class Fraction:
    def __init__(self, numerator, denominator):
        if denominator == 0:
            raise ValueError("分母は0にできません")
        self.numerator = numerator
        self.denominator = denominator
    
    def __str__(self):
        return f"{self.numerator}/{self.denominator}"
    
    def __add__(self, other):
        if isinstance(other, Fraction):
            new_num = self.numerator * other.denominator + other.numerator * self.denominator
            new_den = self.denominator * other.denominator
            return Fraction(new_num, new_den)
        return NotImplemented
    
    def __eq__(self, other):
        if isinstance(other, Fraction):
            return self.numerator * other.denominator == other.numerator * self.denominator
        return False

f1 = Fraction(1, 2)
f2 = Fraction(1, 4)
f3 = f1 + f2
print(f3)  # "6/8"
print(f1 == Fraction(2, 4))  # True
```
