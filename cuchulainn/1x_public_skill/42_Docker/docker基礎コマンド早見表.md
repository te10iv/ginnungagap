# docker基礎コマンド早見表

- レベル感
  - バックエンドエンジニアが開発環境作るのに、必要なレベル
    - docker compose使う
      - 構成例
        - rails, web-server, mysql
        <!-- - Laravel, web-server, mysql
        - Django, web-server, mysql -->

## まずはこれだけ覚えよう！！
- 確認コマンド


コンテナ・イメージの確認コマンド
目的	コマンド	説明
コンテナ一覧（起動中）	docker ps	いま動いているコンテナを見る
コンテナ一覧（全て）	docker ps -a	停止中も含めて一覧表示
イメージ一覧	docker images	ローカルにある Docker イメージ
ログ確認	docker logs <container>	アプリのエラーなどを確認
コンテナ内に入る	docker exec -it <container> bash



▶ 起動・停止・再起動
操作	コマンド
起動	docker compose up -d
停止	docker compose down
再起動	docker compose restart
個別コンテナ起動	docker compose up -d rails


クリーンアップ（トラブル時に使用）
目的	コマンド
ボリューム削除	docker volume prune
使っていないイメージ削除	docker image prune
すべて掃除（注意）	docker system prune -a


## 構築手順


※ この構成は「M1 Mac で Rails 学習」にも対応。
Step1: ディレクトリ構成
myapp/
  ├─ docker-compose.yml
  ├─ backend/   （Rails）
  ├─ nginx/
  │    └─ default.conf
  └─ db/        （MySQL）


Step2: docker-compose.yml（最小構成例）

```yaml
version: "3.9"
services:
  rails:
    build: ./backend
    volumes:
      - ./backend:/app
    ports:
      - "3000:3000"
    depends_on:
      - db

  web:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
      - ./backend:/app
    depends_on:
      - rails

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: myapp_development
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:


```


Step3: Rails プロジェクトを作成
docker compose run --rm rails rails new . --force --database=mysql


Step4: database.yml 修正（MySQL）

```yaml
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: 5
  username: root
  password: password
  host: db


```


Step5: DB作成
docker compose run --rm rails rails db:create

Step6: 起動！
docker compose up -d


Step6: 動作確認
→ ブラウザで
**http://localhost:3000**（Rails）
**http://localhost**（Nginx経由）



## 運用手順

🎈 Rails 運用

作業	コマンド

サーバ起動	docker compose up -d rails
コンソール起動	docker compose exec rails rails c
マイグレーション	docker compose exec rails rails db:migrate
bundle install	docker compose exec rails bundle install

🌐 Nginx（web）運用
作業	コマンド
設定変更後に再読み込み	docker compose restart web
ログ確認	docker logs web

🛢 MySQL（db）運用
作業	コマンド
MySQL に入る	docker compose exec db mysql -u root -ppassword
再起動	docker compose restart db
データ削除したい	ボリュームを削除 (docker volume rm <name>)

📌 最小限で覚えるべき Docker 思考法（超重要）
docker はアプリを“箱（コンテナ）”に入れて動かす技術
docker-compose は、“複数の箱をまとめて起動する”ツール
Rails / MySQL / Nginx = バラバラの箱
→ docker-compose.yml でそれを繋げるだけ


👍 必要十分・実務レベルのまとめ
この表と構築例を覚えておけば、
バックエンドエンジニアとして普通の開発環境は全部作れるレベル。
Dockerfile や最適化は後回しでOK。
まずは「動く開発環境」が作れれば十分。
