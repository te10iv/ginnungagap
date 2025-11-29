# copilot-test.txtファイルを読み込む

# ① 必要なモジュールをインポート

import os
import re
import json
# import boto3


with open('copilot-test.txt', 'r') as file:
    data = file.read()
    # data = file.readline()
    # data = file.readlines()
print(data)


# 閏年を判別する関数
def is_leap_year(year):
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0) == 0



