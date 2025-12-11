# while

## 1. 要点まとめ

- `while`文で条件が`True`の間、処理を繰り返す
- 条件が`False`になるとループが終了する
- 無限ループに注意（条件が常に`True`にならないように）
- `break`でループを中断、`continue`で次の繰り返しにスキップ
- `else`節でループが正常終了した場合の処理を記述できる
- カウンタ変数の更新を忘れないようにする

## 2. 詳細解説

`while`文は、条件が`True`の間、処理を繰り返すための構文です。`while 条件式:`の形式で記述し、条件式が`True`の間、ブロック内の処理が繰り返し実行されます。

条件式が`False`になると、ループは終了します。条件式が最初から`False`の場合、ブロック内の処理は一度も実行されません。

`while`文を使用する際は、無限ループに注意が必要です。条件式が常に`True`のままになると、ループが終了せず、プログラムが停止しなくなります。カウンタ変数を更新するなど、条件が`False`になるように設計する必要があります。

`break`文を使うと、ループを途中で中断できます。`continue`文を使うと、現在の繰り返しをスキップして次の繰り返しに進みます。

`while`文にも`else`節を付けることができます。`else`節は、ループが`break`で中断されずに正常終了した場合に実行されます。

## 3. サンプルコード

```python
# 基本的なwhile文
count = 0
while count < 5:
    print(count)
    count += 1  # カウンタを更新（重要！）

# カウントダウン
count = 10
while count > 0:
    print(count)
    count -= 1
print("発射！")

# breakでループを中断
count = 0
while True:  # 無限ループ
    print(count)
    count += 1
    if count >= 5:
        break  # ループを終了

# continueで次の繰り返しにスキップ
count = 0
while count < 10:
    count += 1
    if count % 2 == 0:  # 偶数なら
        continue  # 次の繰り返しにスキップ
    print(count)  # 奇数だけ表示

# while-else文
count = 0
while count < 5:
    print(count)
    count += 1
else:
    print("ループが正常終了しました")

# ユーザー入力を使ったループ
while True:
    user_input = input("終了するには 'quit' と入力してください: ")
    if user_input == "quit":
        break
    print(f"入力された値: {user_input}")
```

## 4. 注意点・落とし穴

- **無限ループ**: 条件式が常に`True`のままになると、無限ループになります。カウンタ変数の更新を忘れないようにしましょう
- **カウンタの初期化**: カウンタ変数をループの外で初期化する必要があります
- **条件式の更新**: ループ内で条件式に使う変数を更新しないと、無限ループになる可能性があります
- **breakとcontinueの違い**: `break`はループを完全に終了し、`continue`は次の繰り返しに進みます
- **while True**: `while True:`は無限ループを作る際によく使われますが、必ず`break`で終了条件を設けましょう

## 5. 演習問題

1. `while`文を使って、1から10までの数値を表示してください
2. ユーザーに数値を入力させ、その数値が0になるまで1を引き続けるプログラムを作成してください
3. `while`文と`break`を使って、ユーザーが"end"と入力するまで入力を繰り返すプログラムを作成してください
4. `while`文を使って、1から100までの偶数の合計を計算してください

## 6. 解答例

```python
# 1. 1から10まで
count = 1
while count <= 10:
    print(count)
    count += 1

# 2. 0になるまで1を引く
num = int(input("数値を入力してください: "))
while num > 0:
    print(num)
    num -= 1
print("終了")

# 3. "end"まで入力を繰り返す
while True:
    user_input = input("文字列を入力してください（終了: end）: ")
    if user_input == "end":
        break
    print(f"入力: {user_input}")

# 4. 偶数の合計
total = 0
num = 2
while num <= 100:
    total += num
    num += 2
print(f"1から100までの偶数の合計: {total}")
```
