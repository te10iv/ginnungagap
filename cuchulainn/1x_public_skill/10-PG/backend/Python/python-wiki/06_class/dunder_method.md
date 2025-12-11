# 特殊メソッド（dunder）

## 1. 要点まとめ

- 特殊メソッドは`__`（アンダースコア2つ）で囲まれたメソッド
- `__init__`はインスタンス作成時に呼ばれる
- `__str__`は文字列表現を返す（`print()`や`str()`で使用）
- `__repr__`は開発者向けの文字列表現を返す
- `__len__`は`len()`関数で使用される
- `__eq__`は`==`演算子で使用される

## 2. 詳細解説

特殊メソッド（dunderメソッド、マジックメソッド）は、`__`（アンダースコア2つ）で囲まれたメソッドです。これらは特定の操作や組み込み関数が呼び出された際に自動的に実行されます。

`__init__`は、インスタンスが作成される際に自動的に呼び出される初期化メソッドです。

`__str__`は、オブジェクトの文字列表現を返すメソッドです。`print()`や`str()`で使用されます。ユーザー向けの読みやすい文字列を返すべきです。

`__repr__`は、開発者向けの文字列表現を返すメソッドです。デバッグ時に有用で、可能であれば`eval()`で再現できる文字列を返すべきです。

`__len__`は、`len()`関数が呼び出された際に実行されるメソッドです。オブジェクトの「長さ」を返します。

`__eq__`は、`==`演算子が使用された際に実行されるメソッドです。2つのオブジェクトが等しいかどうかを判定します。

他にも多くの特殊メソッドがあり、演算子のオーバーロードや組み込み関数との統合を可能にします。

## 3. サンプルコード

```python
# 基本的な特殊メソッド
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    
    def __str__(self):
        return f"{self.name} ({self.age}歳)"
    
    def __repr__(self):
        return f"Person('{self.name}', {self.age})"
    
    def __eq__(self, other):
        if isinstance(other, Person):
            return self.name == other.name and self.age == other.age
        return False

person = Person("太郎", 25)
print(person)  # "太郎 (25歳)" - __str__が呼ばれる
print(repr(person))  # "Person('太郎', 25)" - __repr__が呼ばれる

person2 = Person("太郎", 25)
print(person == person2)  # True - __eq__が呼ばれる

# __len__の実装
class MyList:
    def __init__(self, items):
        self.items = items
    
    def __len__(self):
        return len(self.items)

my_list = MyList([1, 2, 3, 4, 5])
print(len(my_list))  # 5 - __len__が呼ばれる

# 演算子のオーバーロード
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __add__(self, other):
        return Point(self.x + other.x, self.y + other.y)
    
    def __str__(self):
        return f"Point({self.x}, {self.y})"

p1 = Point(1, 2)
p2 = Point(3, 4)
p3 = p1 + p2  # __add__が呼ばれる
print(p3)  # "Point(4, 6)"
```

## 4. 注意点・落とし穴

- **`__str__`と`__repr__`の違い**: `__str__`はユーザー向け、`__repr__`は開発者向けです。`__repr__`が定義されていない場合、`__str__`が使われます
- **`__eq__`の実装**: `__eq__`を実装する場合、`__hash__`も実装する必要がある場合があります（辞書のキーとして使う場合）
- **演算子のオーバーロード**: 演算子をオーバーロードする際は、直感的な動作を心がけましょう
- **特殊メソッドの命名**: 特殊メソッドは`__`で囲まれた名前である必要があります

## 5. 演習問題

1. `Book`クラスに`__str__`メソッドを追加し、タイトルと著者名を表示できるようにしてください
2. `Vector`クラスを定義し、`__add__`メソッドでベクトルの足し算ができるようにしてください
3. `Stack`クラスを定義し、`__len__`メソッドでスタックのサイズを取得できるようにしてください

## 6. 解答例

```python
# 1. __str__の実装
class Book:
    def __init__(self, title, author):
        self.title = title
        self.author = author
    
    def __str__(self):
        return f"『{self.title}』 by {self.author}"

book = Book("Python入門", "山田太郎")
print(book)  # "『Python入門』 by 山田太郎"

# 2. __add__の実装
class Vector:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __add__(self, other):
        return Vector(self.x + other.x, self.y + other.y)
    
    def __str__(self):
        return f"Vector({self.x}, {self.y})"

v1 = Vector(1, 2)
v2 = Vector(3, 4)
v3 = v1 + v2
print(v3)  # "Vector(4, 6)"

# 3. __len__の実装
class Stack:
    def __init__(self):
        self.items = []
    
    def push(self, item):
        self.items.append(item)
    
    def pop(self):
        return self.items.pop()
    
    def __len__(self):
        return len(self.items)

stack = Stack()
stack.push(1)
stack.push(2)
stack.push(3)
print(len(stack))  # 3
```
