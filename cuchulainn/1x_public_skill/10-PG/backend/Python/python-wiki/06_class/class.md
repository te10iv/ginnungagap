# クラスの基礎

## 1. 要点まとめ

- `class`キーワードでクラスを定義する
- `__init__`メソッドでインスタンスを初期化する
- `self`はインスタンス自身を表す
- メソッドはクラス内で定義された関数
- 属性は`self.属性名`で定義・アクセスする
- インスタンスは`クラス名()`で作成する

## 2. 詳細解説

クラスは`class`キーワードを使って定義します。`class クラス名:`の形式で記述し、その後のインデントされたブロックにメソッドや属性を定義します。

`__init__`メソッドは、インスタンスが作成される際に自動的に呼び出される特殊なメソッドです。初期化処理（属性の設定など）を行います。`def __init__(self, 引数1, 引数2, ...):`の形式で定義します。

`self`は、インスタンス自身を表す特殊な引数です。メソッドの第1引数として必ず指定します。`self`を通じて、インスタンスの属性やメソッドにアクセスできます。

属性は、オブジェクトが持つデータです。`self.属性名 = 値`の形式で定義し、`self.属性名`でアクセスします。

メソッドは、クラス内で定義された関数です。メソッドの第1引数は通常`self`です。メソッド内では`self`を通じて、インスタンスの属性や他のメソッドにアクセスできます。

インスタンスは、`クラス名(引数1, 引数2, ...)`のように呼び出すことで作成できます。このとき、`__init__`メソッドが自動的に呼び出されます。

## 3. サンプルコード

```python
# 基本的なクラス定義
class Dog:
    def __init__(self, name, breed):
        self.name = name
        self.breed = breed
        self.age = 0  # デフォルト値
    
    def bark(self):
        print(f"{self.name}がワンワンと吠えました")
    
    def get_info(self):
        return f"{self.name}は{self.breed}で{self.age}歳です"

# インスタンスの作成
dog1 = Dog("ポチ", "柴犬")
dog1.age = 3
dog1.bark()  # "ポチがワンワンと吠えました"
print(dog1.get_info())  # "ポチは柴犬で3歳です"

# 複数のインスタンス
dog2 = Dog("タロ", "ゴールデンレトリバー")
dog2.age = 5
dog2.bark()  # "タロがワンワンと吠えました"

# クラス変数（すべてのインスタンスで共有）
class Counter:
    count = 0  # クラス変数
    
    def __init__(self):
        Counter.count += 1
        self.id = Counter.count
    
    def get_id(self):
        return self.id

c1 = Counter()
c2 = Counter()
print(c1.get_id())  # 1
print(c2.get_id())  # 2
```

## 4. 注意点・落とし穴

- **`self`の省略**: メソッドの第1引数として`self`を必ず指定する必要があります
- **`__init__`の戻り値**: `__init__`メソッドは戻り値を返しません（`None`を返す）
- **属性の初期化**: 属性は`__init__`メソッドで初期化するのが一般的です
- **クラス変数とインスタンス変数**: クラス変数はすべてのインスタンスで共有され、インスタンス変数は各インスタンスごとに独立しています
- **メソッドの呼び出し**: メソッドを呼び出す際は、`self`を渡す必要はありません（自動的に渡されます）

## 5. 演習問題

1. `Rectangle`クラスを定義し、幅（width）と高さ（height）を属性として持たせ、面積を計算するメソッド`area()`を追加してください
2. `Student`クラスを定義し、名前、年齢、科目のリストを属性として持たせ、科目を追加するメソッド`add_subject()`を追加してください
3. `BankAccount`クラスを定義し、残高を属性として持たせ、預金するメソッド`deposit()`と引き出すメソッド`withdraw()`を追加してください

## 6. 解答例

```python
# 1. Rectangleクラス
class Rectangle:
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    def area(self):
        return self.width * self.height

rect = Rectangle(10, 5)
print(f"面積: {rect.area()}")  # 50

# 2. Studentクラス
class Student:
    def __init__(self, name, age):
        self.name = name
        self.age = age
        self.subjects = []
    
    def add_subject(self, subject):
        self.subjects.append(subject)

student = Student("太郎", 20)
student.add_subject("数学")
student.add_subject("英語")
print(student.subjects)  # ['数学', '英語']

# 3. BankAccountクラス
class BankAccount:
    def __init__(self, initial_balance=0):
        self.balance = initial_balance
    
    def deposit(self, amount):
        self.balance += amount
        return self.balance
    
    def withdraw(self, amount):
        if amount <= self.balance:
            self.balance -= amount
            return self.balance
        else:
            return "残高不足"

account = BankAccount(1000)
account.deposit(500)
print(account.balance)  # 1500
account.withdraw(200)
print(account.balance)  # 1300
```
