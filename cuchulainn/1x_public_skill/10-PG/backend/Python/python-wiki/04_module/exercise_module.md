# モジュール編 演習

## 1. 要点まとめ

- 標準ライブラリの使い方
- モジュールのインポート方法
- 実用的なモジュールの活用

## 2. 詳細解説

この演習では、Pythonの標準ライブラリを使った実用的なプログラムを作成します。モジュールを適切に使いこなすことで、効率的なプログラミングが可能になります。

## 3. サンプルコード

```python
# 演習問題の例
import math
import random

# 円の面積を計算
radius = random.randint(1, 10)
area = math.pi * radius ** 2
print(f"半径{radius}の円の面積: {area}")
```

## 4. 注意点・落とし穴

- モジュールをインポートするのを忘れない
- 関数名や引数を正しく使う
- 標準ライブラリの存在を知っておく

## 5. 演習問題

### 問題1: 数学計算
`math`モジュールを使って、以下の計算を行ってください：
- 16の平方根
- 30度の正弦値（`math.radians`で度をラジアンに変換）
- 円周率の値

### 問題2: 日時処理
`datetime`モジュールを使って、以下の処理を行ってください：
- 現在の日時を取得
- 今日から7日後の日付を計算
- 日時を「YYYY年MM月DD日」形式で表示

### 問題3: 乱数生成
`random`モジュールを使って、以下の処理を行ってください：
- 1から100までの乱数を10個生成
- リスト`["りんご", "バナナ", "オレンジ", "ぶどう", "いちご"]`からランダムに3つ選択
- リスト`[1, 2, 3, 4, 5]`をシャッフル

### 問題4: JSON処理
`json`モジュールを使って、以下の処理を行ってください：
- 辞書`{"name": "太郎", "age": 25, "city": "東京"}`をJSON文字列に変換
- JSON文字列`'{"name": "花子", "age": 30}'`を辞書に変換

## 6. 解答例

```python
# 問題1: 数学計算
import math

sqrt_16 = math.sqrt(16)
print(f"16の平方根: {sqrt_16}")

sin_30 = math.sin(math.radians(30))
print(f"30度の正弦値: {sin_30}")

print(f"円周率: {math.pi}")

# 問題2: 日時処理
import datetime

now = datetime.datetime.now()
print(f"現在の日時: {now}")

future = now + datetime.timedelta(days=7)
print(f"7日後: {future}")

formatted = now.strftime("%Y年%m月%d日")
print(f"フォーマット: {formatted}")

# 問題3: 乱数生成
import random

random_numbers = [random.randint(1, 100) for _ in range(10)]
print(f"乱数10個: {random_numbers}")

fruits = ["りんご", "バナナ", "オレンジ", "ぶどう", "いちご"]
selected = random.sample(fruits, 3)
print(f"ランダムに3つ選択: {selected}")

numbers = [1, 2, 3, 4, 5]
random.shuffle(numbers)
print(f"シャッフル後: {numbers}")

# 問題4: JSON処理
import json

data = {"name": "太郎", "age": 25, "city": "東京"}
json_str = json.dumps(data, ensure_ascii=False)
print(f"JSON文字列: {json_str}")

json_data = '{"name": "花子", "age": 30}'
data2 = json.loads(json_data)
print(f"辞書: {data2}")
```
