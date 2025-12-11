# 継承

## 1. 要点まとめ

- 継承は既存のクラスを拡張して新しいクラスを作る
- 親クラス（基底クラス）の機能を子クラス（派生クラス）が引き継ぐ
- `super()`で親クラスのメソッドを呼び出せる
- メソッドのオーバーライドで親クラスのメソッドを上書きできる
- 多重継承も可能（複数の親クラスから継承）
- 継承を使うことでコードの再利用性が向上する

## 2. 詳細解説

継承は、既存のクラスを拡張して新しいクラスを作る機能です。親クラス（基底クラス、スーパークラス）の機能を子クラス（派生クラス、サブクラス）が引き継ぎます。

継承は`class 子クラス名(親クラス名):`の形式で定義します。子クラスは親クラスのすべての属性とメソッドを継承します。

`super()`関数を使うと、親クラスのメソッドを呼び出せます。`super().メソッド名()`の形式で使用します。これにより、親クラスの機能を拡張できます。

メソッドのオーバーライドは、親クラスのメソッドを子クラスで再定義することです。同じ名前のメソッドを子クラスで定義すると、親クラスのメソッドが上書きされます。

多重継承は、複数の親クラスから継承することです。`class 子クラス名(親クラス1, 親クラス2):`の形式で定義します。ただし、多重継承は複雑になるため、慎重に使用する必要があります。

継承を使うことで、共通の機能を親クラスにまとめ、子クラスで個別の機能を追加できます。これにより、コードの再利用性が向上します。

## 3. サンプルコード

```python
# 基本的な継承
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        print(f"{self.name}が鳴いています")

class Dog(Animal):
    def speak(self):
        print(f"{self.name}がワンワンと吠えました")

class Cat(Animal):
    def speak(self):
        print(f"{self.name}がニャーと鳴きました")

dog = Dog("ポチ")
dog.speak()  # "ポチがワンワンと吠えました"

cat = Cat("タマ")
cat.speak()  # "タマがニャーと鳴きました"

# super()の使用
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

class Student(Person):
    def __init__(self, name, age, student_id):
        super().__init__(name, age)  # 親クラスの__init__を呼び出し
        self.student_id = student_id

student = Student("太郎", 20, "S001")
print(f"{student.name}、{student.age}歳、ID: {student.student_id}")

# 多重継承
class A:
    def method_a(self):
        print("Aのメソッド")

class B:
    def method_b(self):
        print("Bのメソッド")

class C(A, B):
    pass

c = C()
c.method_a()  # "Aのメソッド"
c.method_b()  # "Bのメソッド"
```

## 4. 注意点・落とし穴

- **`super()`の使用**: 親クラスのメソッドを呼び出す場合は`super()`を使いましょう
- **メソッド解決順序（MRO）**: 多重継承では、メソッドの解決順序が重要です。`__mro__`属性で確認できます
- **オーバーライド**: 親クラスのメソッドをオーバーライドする際は、意図的に行いましょう
- **継承の深さ**: 継承が深くなりすぎると、コードが複雑になります。適度な深さを保ちましょう

## 5. 演習問題

1. `Vehicle`クラスを親クラスとして定義し、`Car`クラスと`Bicycle`クラスを子クラスとして定義してください。それぞれに適切な`speak()`メソッド（音を出す）を追加してください
2. `super()`を使って、親クラスの`__init__`を呼び出す子クラスを作成してください
3. `Shape`クラスを親クラスとして定義し、`Rectangle`クラスと`Circle`クラスを子クラスとして定義し、それぞれに`area()`メソッドを実装してください

## 6. 解答例

```python
# 1. Vehicleクラスの継承
class Vehicle:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        print(f"{self.name}が音を出しています")

class Car(Vehicle):
    def speak(self):
        print(f"{self.name}がブーブーと鳴きました")

class Bicycle(Vehicle):
    def speak(self):
        print(f"{self.name}がチリンチリンと鳴きました")

car = Car("プリウス")
car.speak()  # "プリウスがブーブーと鳴きました"

bicycle = Bicycle("ママチャリ")
bicycle.speak()  # "ママチャリがチリンチリンと鳴きました"

# 2. super()の使用
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

class Employee(Person):
    def __init__(self, name, age, employee_id):
        super().__init__(name, age)
        self.employee_id = employee_id

emp = Employee("花子", 30, "E001")
print(f"{emp.name}、{emp.age}歳、ID: {emp.employee_id}")

# 3. Shapeクラスの継承
import math

class Shape:
    def area(self):
        raise NotImplementedError("サブクラスで実装してください")

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    def area(self):
        return self.width * self.height

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius
    
    def area(self):
        return math.pi * self.radius ** 2

rect = Rectangle(10, 5)
print(f"長方形の面積: {rect.area()}")  # 50

circle = Circle(5)
print(f"円の面積: {circle.area()}")  # 約78.54
```
