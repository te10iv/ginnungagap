# NAT Gateway 概要

## 1. サービスの役割

## 2. 主なユースケース

## 3. 他サービスとの関係

## 4. 料金のざっくりイメージ

## 5. 初心者がまず覚えるべきポイント

- natgwは割高

- NAT Gateway は 「AZごとのリソース」なので、冗長性を持たせたいなら最低２つは必要
    - 例　private-subnet-1aにだけnatgw作って、 private-subnet-1cのルーティングテーブルのDGWを1aのnatgwにしても、ダメ。


