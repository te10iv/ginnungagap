# apacheとnginxの違い

## 結論（まずこれだけ）

項目	Nginx	Apache
処理方式	イベント駆動（超高速・省メモリ）	プロセス/スレッド方式（古典的）
高負荷時	圧倒的に強い（大量同時接続OK）	プロセス増えて重くなる
静的ファイル	超高速	そこそこ
動的処理	外部（PHP-FPMなど）に任せる	モジュール内で実行可（mod_phpなど）
設定の柔軟性	シンプル・高速志向	多機能で柔軟
用途	近代的な Web / API サーバに最適	伝統的 Web サービス、互換性が必要な環境
1. アーキテクチャの違い（ここが核心）
■ Nginx：イベント駆動（少ないプロセスでも大量接続を捌ける）

worker プロセスは少数（通常 1〜4）

1つの worker が 大量の接続を非同期で処理

CPU・メモリの使用量が少ない

高負荷でも落ちにくい

📌 API Gateway / CDN / リバースプロキシ用途に強い理由はこれ！

■ Apache：プロセス or スレッド方式（MPM）

Apache は「MPM」という処理方式を選べる：

MPM	特徴
prefork	リクエストごとにプロセス。安定するが重い。mod_php 用。
worker	スレッド方式で軽め。
event	Nginxに近いが、まだ Apache の設計上限界あり。

📌 接続数が増えると子プロセス・スレッドが増え、メモリを食いやすい。

2. 静的コンテンツの速度
種類	Nginx	Apache
HTML/画像/動画 などの静的ファイル	非常に高速	普通

理由：

Nginx は静的ファイルを OS の sendfile 等の仕組みで効率的に返す

Apache はリクエストごとにプロセス/スレッドが必要

📌 静的ファイル配信は Nginx の圧勝。

3. 動的処理（PHP など）
✔ Nginx

自前では実行しない

PHP-FPM や uWSGI など別プロセスに処理を渡す

Nginx → PHP-FPM → PHP実行


→ 責務が分離されていて近代的。

✔ Apache

mod_php で直接 PHP を動かせる（昔の LAMP）

MPM の種類によっては FPM 方式も可能

→ 古いシステムは Apache + mod_php が多い。

4. リバースプロキシ性能
用途	Nginx	Apache
リバースプロキシ (API Gateway, LB 的)	最強	そこそこ

Nginx はイベント駆動なのでリバースプロキシとして世界中で使われてます
（例：CDN、ロードバランサ、Kubernetes ingress-nginx）。

5. 学習・設定のしやすさ
項目	Nginx	Apache
設定ファイル	シンプル	機能多すぎて複雑
互換性	堅牢で近代的	25年以上の歴史、対応モジュール圧倒的
.htaccess	使えない	使える（アプリ側で設定上書き可能）

→ WordPressの共有レンタルサーバが Apache な理由は .htaccess サポートがあるため。

6. どっちを使う？（要件ベースの判断）
◎ Nginx を選ぶべきケース

API サーバ

リバースプロキシ / ロードバランサ

高負荷想定（大規模 Web サイト）

Kubernetes Ingress

静的コンテンツ多い

◎ Apache を選ぶべきケース

レガシー LAMP アプリがある

.htaccess が必要

mod 系の豊富なモジュールを活用したい

業務要件で Apache 前提

7. まとめ（短く覚えるならこれ）

Nginx = 高速・省メモリ・現代的・イベント駆動

Apache = 多機能・歴史長い・プロセスモデル・.htaccess強い

