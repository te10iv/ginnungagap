# 標準ライブラリ

## 1. 要点まとめ

- 標準ライブラリはPythonに標準で含まれるモジュール群
- `math`: 数学関数（sqrt, sin, cos, piなど）
- `datetime`: 日時処理（日付、時刻の操作）
- `random`: 乱数生成（randint, choice, shuffleなど）
- `os`: OS機能（ファイル操作、環境変数など）
- `json`: JSON処理（JSONの読み書き）
- `sys`: システム関連（コマンドライン引数、終了など）

## 2. 詳細解説

Pythonの標準ライブラリは、よく使われる機能を提供するモジュール群です。これらはPythonをインストールすると自動的に利用可能になります。

`math`モジュールは、数学関数を提供します。`sqrt`（平方根）、`sin`（正弦）、`cos`（余弦）、`pi`（円周率）などが含まれます。

`datetime`モジュールは、日時を扱うための機能を提供します。日付や時刻の作成、計算、フォーマットなどができます。

`random`モジュールは、乱数を生成する機能を提供します。`randint`（範囲内の整数乱数）、`choice`（リストからランダムに選択）、`shuffle`（リストをシャッフル）などが含まれます。

`os`モジュールは、OS（オペレーティングシステム）の機能にアクセスします。ファイル操作、環境変数の取得、ディレクトリ操作などができます。

`json`モジュールは、JSON形式のデータを扱います。JSON文字列とPythonオブジェクトの相互変換ができます。

`sys`モジュールは、システム関連の機能を提供します。コマンドライン引数の取得、プログラムの終了、Pythonのバージョン情報などが含まれます。

## 3. サンプルコード

```python
# mathモジュール
import math
print(math.sqrt(16))  # 4.0
print(math.pi)  # 3.14159...
print(math.sin(math.pi / 2))  # 1.0

# datetimeモジュール
import datetime
now = datetime.datetime.now()
print(now)  # 現在の日時
print(now.strftime("%Y-%m-%d %H:%M:%S"))  # フォーマット

# randomモジュール
import random
print(random.randint(1, 10))  # 1から10までの乱数
print(random.choice(["りんご", "バナナ", "オレンジ"]))  # ランダムに選択

# osモジュール
import os
print(os.getcwd())  # 現在のディレクトリ
print(os.listdir("."))  # ディレクトリ内のファイル一覧

# jsonモジュール
import json
data = {"name": "太郎", "age": 25}
json_str = json.dumps(data)  # PythonオブジェクトをJSON文字列に
print(json_str)
data2 = json.loads(json_str)  # JSON文字列をPythonオブジェクトに
print(data2)

# sysモジュール
import sys
print(sys.version)  # Pythonのバージョン
print(sys.argv)  # コマンドライン引数
```

## 4. 注意点・落とし穴

- **モジュールのインポート**: 使用する前に必ず`import`する必要があります
- **関数名の確認**: モジュールによって関数名が異なるので、公式ドキュメントを参照しましょう
- **バージョンによる違い**: Pythonのバージョンによって、利用可能な機能が異なる場合があります
- **パフォーマンス**: 標準ライブラリは最適化されているため、自作の実装より高速な場合が多いです

## 5. 演習問題

1. `math`モジュールを使って、半径5の円の面積を計算してください（面積 = π × r²）
2. `datetime`モジュールを使って、現在の日時を「YYYY-MM-DD HH:MM:SS」形式で表示してください
3. `random`モジュールを使って、1から6までのサイコロの目を10回表示してください
4. `json`モジュールを使って、辞書をJSON文字列に変換し、それを再度辞書に戻してください

## 6. 解答例

```python
# 1. 円の面積
import math
radius = 5
area = math.pi * radius ** 2
print(f"面積: {area}")

# 2. 日時の表示
import datetime
now = datetime.datetime.now()
formatted = now.strftime("%Y-%m-%d %H:%M:%S")
print(formatted)

# 3. サイコロ
import random
for _ in range(10):
    dice = random.randint(1, 6)
    print(dice)

# 4. JSONの変換
import json
data = {"name": "太郎", "age": 25, "city": "東京"}
json_str = json.dumps(data, ensure_ascii=False)
print(json_str)
data2 = json.loads(json_str)
print(data2)
```
