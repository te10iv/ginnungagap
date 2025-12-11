# for

## 1. 要点まとめ

- `for`文でシーケンス（リスト、文字列、タプルなど）の各要素に対して処理を繰り返す
- `range()`関数で数値の範囲を生成できる
- `enumerate()`でインデックスと値を同時に取得できる
- `zip()`で複数のシーケンスを同時に処理できる
- ネストした`for`文で多重ループが可能
- `else`節でループが正常終了した場合の処理を記述できる

## 2. 詳細解説

`for`文は、シーケンス（リスト、文字列、タプル、辞書など）の各要素に対して処理を繰り返すための構文です。`for 変数 in シーケンス:`の形式で記述し、シーケンスの各要素が順番に変数に代入されて、ブロック内の処理が実行されます。

`range()`関数は、数値の範囲を生成するために使用します。`range(5)`は0から4までの数値を生成し、`range(1, 6)`は1から5までの数値を生成します。`range(0, 10, 2)`のように第3引数でステップを指定することもできます。

`enumerate()`関数を使うと、インデックス（位置）と値を同時に取得できます。`for i, value in enumerate(list):`の形式で使用します。

`zip()`関数を使うと、複数のシーケンスを同時に処理できます。`for x, y in zip(list1, list2):`の形式で、対応する要素を同時に取得できます。

`for`文にも`else`節を付けることができます。`else`節は、ループが`break`で中断されずに正常終了した場合に実行されます。

## 3. サンプルコード

```python
# リストの各要素を処理
fruits = ["りんご", "バナナ", "オレンジ"]
for fruit in fruits:
    print(fruit)

# range()を使った繰り返し
for i in range(5):
    print(i)  # 0, 1, 2, 3, 4

for i in range(1, 6):
    print(i)  # 1, 2, 3, 4, 5

for i in range(0, 10, 2):
    print(i)  # 0, 2, 4, 6, 8

# 文字列の各文字を処理
text = "Python"
for char in text:
    print(char)

# enumerate()でインデックスと値を取得
fruits = ["りんご", "バナナ", "オレンジ"]
for index, fruit in enumerate(fruits):
    print(f"{index}: {fruit}")

# zip()で複数のシーケンスを同時に処理
names = ["太郎", "花子", "次郎"]
ages = [25, 30, 20]
for name, age in zip(names, ages):
    print(f"{name}は{age}歳です")

# ネストしたfor文
for i in range(3):
    for j in range(3):
        print(f"({i}, {j})")

# for-else文
numbers = [1, 2, 3, 4, 5]
for num in numbers:
    if num > 10:
        print("10より大きい数値が見つかりました")
        break
else:
    print("10より大きい数値は見つかりませんでした")
```

## 4. 注意点・落とし穴

- **ループ変数のスコープ**: `for`文のループ変数は、ループの外でもアクセスできます。最後に代入された値が残ります
- **シーケンスの変更**: ループ中にシーケンス（リストなど）を変更すると、予期しない動作を引き起こす可能性があります
- **range()の範囲**: `range(5)`は0から4まで（5は含まれない）です。終点は含まれないことに注意しましょう
- **空のシーケンス**: 空のシーケンスに対して`for`文を実行すると、ブロック内の処理は一度も実行されません
- **辞書のループ**: 辞書を直接ループすると、キーのみが取得されます。値やキーと値のペアが必要な場合は`.values()`や`.items()`を使います

## 5. 演習問題

1. `range()`を使って、1から10までの数値を表示してください
2. リスト`[1, 2, 3, 4, 5]`の各要素を2倍した値を表示してください
3. 文字列`"Python"`の各文字を1文字ずつ表示してください
4. `enumerate()`を使って、リスト`["りんご", "バナナ", "オレンジ"]`のインデックスと値を表示してください
5. ネストした`for`文を使って、九九の表（1の段から9の段まで）を表示してください

## 6. 解答例

```python
# 1. 1から10まで
for i in range(1, 11):
    print(i)

# 2. リストの各要素を2倍
numbers = [1, 2, 3, 4, 5]
for num in numbers:
    print(num * 2)

# 3. 文字列の各文字
text = "Python"
for char in text:
    print(char)

# 4. enumerate()の使用
fruits = ["りんご", "バナナ", "オレンジ"]
for index, fruit in enumerate(fruits):
    print(f"{index}: {fruit}")

# 5. 九九の表
for i in range(1, 10):
    for j in range(1, 10):
        print(f"{i} × {j} = {i * j}", end="  ")
    print()  # 改行
```
