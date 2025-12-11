# 制御構文 演習

## 1. 要点まとめ

- 条件分岐（if文）の実践
- 繰り返し処理（for文、while文）の実践
- breakとcontinueの使い分け
- ネストした制御構文の理解
- 実用的な問題解決

## 2. 詳細解説

この演習では、制御構文（if文、for文、while文、break、continue）を総合的に使って問題を解決します。条件分岐と繰り返し処理を組み合わせることで、より複雑な処理を実現できます。

各問題は、実際のプログラミングでよくあるパターンを基にしています。段階的に難易度が上がるように設計されているので、順番に解いていくことで理解が深まります。

## 3. サンプルコード

```python
# 演習問題の例
# 問題: 1から100までの偶数の合計
total = 0
for i in range(1, 101):
    if i % 2 == 0:
        total += i
print(total)
```

## 4. 注意点・落とし穴

- 条件式の書き方に注意（`==`と`=`を混同しない）
- インデントを正しく使う
- 無限ループに注意（while文で）
- カウンタ変数の更新を忘れない

## 5. 演習問題

### 問題1: 成績判定プログラム
ユーザーに点数を入力させ、以下の基準で判定するプログラムを作成してください：
- 90点以上: "優秀"
- 80点以上: "良好"
- 70点以上: "普通"
- 60点以上: "可"
- 60点未満: "不可"

### 問題2: 1から100までの合計
`for`文を使って、1から100までの数値の合計を計算してください。

### 問題3: 素数判定
ユーザーに数値を入力させ、その数値が素数かどうかを判定するプログラムを作成してください。
（素数は1と自分自身以外で割り切れない数）

### 問題4: 九九の表
ネストした`for`文を使って、九九の表を表示してください。

### 問題5: パスワード入力
ユーザーにパスワードを入力させ、"password123"と一致するまで入力を繰り返すプログラムを作成してください。最大5回まで試行できるようにしてください。

## 6. 解答例

```python
# 問題1: 成績判定
score = int(input("点数を入力してください: "))
if score >= 90:
    print("優秀")
elif score >= 80:
    print("良好")
elif score >= 70:
    print("普通")
elif score >= 60:
    print("可")
else:
    print("不可")

# 問題2: 1から100までの合計
total = 0
for i in range(1, 101):
    total += i
print(f"合計: {total}")

# 問題3: 素数判定
num = int(input("数値を入力してください: "))
is_prime = True
if num < 2:
    is_prime = False
else:
    for i in range(2, num):
        if num % i == 0:
            is_prime = False
            break

if is_prime:
    print(f"{num}は素数です")
else:
    print(f"{num}は素数ではありません")

# 問題4: 九九の表
for i in range(1, 10):
    for j in range(1, 10):
        print(f"{i} × {j} = {i * j}", end="  ")
    print()  # 改行

# 問題5: パスワード入力
correct_password = "password123"
attempts = 0
max_attempts = 5

while attempts < max_attempts:
    password = input("パスワードを入力してください: ")
    if password == correct_password:
        print("ログイン成功！")
        break
    else:
        attempts += 1
        remaining = max_attempts - attempts
        if remaining > 0:
            print(f"パスワードが間違っています。あと{remaining}回試行できます。")
        else:
            print("ログインに失敗しました。")
```
