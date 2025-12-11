# import

## 1. 要点まとめ

- `import モジュール名`でモジュール全体をインポート
- `from モジュール名 import 要素名`で特定の要素だけをインポート
- `import モジュール名 as 別名`でエイリアスを付ける
- `from ... import *`は避ける（名前空間の汚染）
- モジュールの検索パスは`sys.path`で確認できる
- 自作モジュールもインポートできる

## 2. 詳細解説

`import`文は、モジュールを読み込むために使用します。基本的な形式は`import モジュール名`で、モジュール全体を読み込みます。読み込んだモジュールの要素にアクセスするには、`モジュール名.要素名`の形式を使います。

特定の要素だけを読み込みたい場合は、`from モジュール名 import 要素名`の形式を使います。この場合、モジュール名を付けずに直接要素名でアクセスできます。

モジュール名が長い場合や、名前の衝突を避けたい場合は、`import モジュール名 as 別名`の形式でエイリアス（別名）を付けることができます。

`from ... import *`は、モジュール内のすべての要素をインポートしますが、名前空間が汚染されるため、通常は避けるべきです。

自作のモジュールもインポートできます。同じディレクトリにある`.py`ファイルは、そのままインポートできます。

## 3. サンプルコード

```python
# 基本的なインポート
import math
print(math.sqrt(16))  # 4.0
print(math.pi)  # 3.14159...

# 特定の要素だけをインポート
from math import sqrt, pi
print(sqrt(16))  # モジュール名不要
print(pi)

# エイリアスを付ける
import datetime as dt
now = dt.datetime.now()
print(now)

# 複数のモジュールをインポート
import math, random, os

# 階層的なインポート（パッケージ）
from collections import Counter
counter = Counter([1, 2, 2, 3, 3, 3])
print(counter)

# 自作モジュールのインポート（同じディレクトリにある場合）
# my_module.py というファイルがある場合
# import my_module
# my_module.my_function()
```

## 4. 注意点・落とし穴

- **名前の衝突**: インポートした要素名と既存の変数名が衝突しないように注意しましょう
- **`from ... import *`の使用**: 名前空間が汚染されるため、通常は避けるべきです
- **循環インポート**: モジュール同士が互いにインポートし合うと、循環インポートエラーが発生する可能性があります
- **モジュールの検索パス**: モジュールが見つからない場合は、`sys.path`で検索パスを確認できます
- **相対インポート**: パッケージ内では相対インポート（`.`を使う）も可能ですが、通常は絶対インポートが推奨されます

## 5. 演習問題

1. `math`モジュールをインポートし、`sqrt`関数を使って16の平方根を計算してください
2. `datetime`モジュールに`dt`というエイリアスを付けてインポートし、現在の日時を表示してください
3. `random`モジュールから`randint`関数だけをインポートし、1から100までの乱数を生成してください

## 6. 解答例

```python
# 1. mathモジュールのインポート
import math
result = math.sqrt(16)
print(result)  # 4.0

# 2. datetimeモジュールにエイリアス
import datetime as dt
now = dt.datetime.now()
print(now)

# 3. randomモジュールから特定の関数だけ
from random import randint
number = randint(1, 100)
print(number)
```
