# break_continue

## 1. 要点まとめ

- `break`でループを完全に終了する
- `continue`で現在の繰り返しをスキップして次の繰り返しに進む
- `break`と`continue`は`for`文と`while`文の両方で使用できる
- ネストしたループでは、`break`は最も内側のループのみを終了する
- `break`や`continue`は条件分岐（`if`文）と組み合わせて使うことが多い

## 2. 詳細解説

`break`と`continue`は、ループの制御を行うための文です。

`break`文は、ループを完全に終了します。`break`が実行されると、そのループのブロックから抜け出し、ループの後の処理に進みます。`break`は`for`文と`while`文の両方で使用できます。

`continue`文は、現在の繰り返しをスキップして、次の繰り返しに進みます。`continue`が実行されると、ループのブロックの残りの処理がスキップされ、次の繰り返しが開始されます。`continue`も`for`文と`while`文の両方で使用できます。

ネストしたループ（ループの中にループがある）では、`break`は最も内側のループのみを終了します。外側のループを終了したい場合は、フラグ変数を使うか、例外処理を使う方法があります。

`break`や`continue`は、通常`if`文と組み合わせて使用します。特定の条件が満たされたときにループを制御するために使います。

## 3. サンプルコード

```python
# breakの例
for i in range(10):
    if i == 5:
        break  # iが5になったらループを終了
    print(i)  # 0, 1, 2, 3, 4まで表示

# continueの例
for i in range(10):
    if i % 2 == 0:  # 偶数なら
        continue  # 次の繰り返しにスキップ
    print(i)  # 奇数だけ表示（1, 3, 5, 7, 9）

# while文でのbreak
count = 0
while True:
    count += 1
    if count > 5:
        break
    print(count)

# while文でのcontinue
count = 0
while count < 10:
    count += 1
    if count % 3 == 0:  # 3の倍数なら
        continue
    print(count)  # 3の倍数以外を表示

# ネストしたループでのbreak
for i in range(3):
    for j in range(3):
        if j == 1:
            break  # 内側のループのみ終了
        print(f"({i}, {j})")

# フラグ変数で外側のループも制御
found = False
for i in range(5):
    for j in range(5):
        if i * j == 6:
            found = True
            break
    if found:
        break
print(f"見つかった: i={i}, j={j}")
```

## 4. 注意点・落とし穴

- **breakとcontinueの違い**: `break`はループを完全に終了し、`continue`は次の繰り返しに進みます。混同しやすいので注意しましょう
- **ネストしたループ**: `break`は最も内側のループのみを終了します。外側のループも終了したい場合は、フラグ変数を使いましょう
- **while文でのcontinue**: `while`文で`continue`を使う場合、カウンタ変数の更新を`continue`の前に置かないと、無限ループになる可能性があります
- **else節との関係**: `break`でループが終了した場合、`else`節は実行されません
- **過度な使用**: `break`や`continue`を多用すると、コードの可読性が低下する可能性があります。適度に使いましょう

## 5. 演習問題

1. `for`文と`break`を使って、1から10までの数値のうち、5に達したらループを終了するプログラムを作成してください
2. `for`文と`continue`を使って、1から20までの数値のうち、3の倍数だけをスキップして表示するプログラムを作成してください
3. `while`文と`break`を使って、ユーザーが"stop"と入力するまで入力を繰り返すプログラムを作成してください
4. ネストした`for`文と`break`を使って、2つの数値の組み合わせで、積が10になる最初の組み合わせを見つけるプログラムを作成してください

## 6. 解答例

```python
# 1. breakで5で終了
for i in range(1, 11):
    if i == 5:
        break
    print(i)  # 1, 2, 3, 4まで表示

# 2. continueで3の倍数をスキップ
for i in range(1, 21):
    if i % 3 == 0:
        continue
    print(i)  # 3の倍数以外を表示

# 3. "stop"まで入力を繰り返す
while True:
    user_input = input("文字列を入力してください（終了: stop）: ")
    if user_input == "stop":
        break
    print(f"入力: {user_input}")

# 4. 積が10になる組み合わせを探す
found = False
for i in range(1, 11):
    for j in range(1, 11):
        if i * j == 10:
            print(f"見つかりました: {i} × {j} = 10")
            found = True
            break
    if found:
        break
```
