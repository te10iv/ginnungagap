# ECS マネージドコンソール構築手順  

## 参考資料（WEB、動画）

- **よさげ**
    - [[AWS ECS] FargateとELBを使ってWebサイトを公開する - Qiita](https://qiita.com/K5K/items/2bab270b8fad24505303)

- **10分！**
    - [Amazon ECS入門 〜公式のDockerイメージを使って10分で構築してみる〜 | DevelopersIO](https://dev.classmethod.jp/articles/amazon-ecs-entrance-1/)

- **どう？**
    - [AWS入門 - ECS・Fargate 使ってみる](https://zenn.dev/umatoma/articles/5862ee6cc1e7c4)

- **2時間かかる。WordPress構築**

## 【参考】タスクのARNはwildcard指定できるのか？

**結論**: `"wildcard": "arn:aws:ecs:ap-northeast-1:941766628229:task/pf2-ecs-cluster1/＊"` という書き方は出来そう

- タスク１のARN: `arn:aws:ecs:ap-northeast-1:941766628229:task/pf2-ecs-cluster1/5ff29ff13fb84873a735e893a282396f`
- タスク２のARN: `arn:aws:ecs:ap-northeast-1:941766628229:task/pf2-ecs-cluster1/87f4e5e463b245f7a4ba4aa30d8b8c09`

## 構築手順（ECS on Fargate）

### 前提

- VPC、サブネットが作ってあること

### 1. クラスターを作成

- 先にタスク定義を作成しても良い
- 名前をつけるぐらいである
    - あまりクラスターに設定項目はない（サービスのほうが設定項目が多い）
- クラスターを作成した時点でCloudFormationのスタック（クラスター）も作成される

### 2. タスク定義を作成

- on EC2 か on Fargateを選択。ここではon Fargateを選んでみる

#### タスクサイズ

- テスト用WEBサーバくらいなら、0.25vCPU、メモリ0.5GBでもOK

#### ロールについて

- **タスクロール** ★他のAWSアカウントと連携する際の権限？★
    - 説明では、「タスク IAM ロールは、タスクのコンテナが AWS のサービスへの API リクエストを行うことを許可します。[IAM コンソール](https://ap-northeast-1.console.aws.amazon.com/iam/home?region=ap-northeast-1#roles) からタスク IAM ロールを作成できます。」とあるが、、
        - タスクロールは他のAWS（アカウント？）と連携する際に設定するもの、らしい(今回は連携させないため、なしでOK)
    - デフォルトは空欄
        - とりあえずecsTaskExecutionRoleにしたほうが良いのかな？？？？？？？？？

- **タスク実行ロール** ★要するに、ECRからイメージをプルするときに使うロールっぽい★
    - ※タスク実行ロールはECSコンテナエージェントが利用するIAMロールである。(**要するに、ECRからイメージをプルするときに使う**)
    - デフォルトのecstasckExecutionRole。そのまま使ってみる。

#### コンテナ

- 名前。お好きに。
- イメージURI
    - ECR Public GalleryでApacheコンテナイメージを検索し、最新のImage URLをメモした値を入力
    - httpd(apache)の例 ★httpd:latestなどと入力しても動きません★
        - `public.ecr.aws/docker/library/httpd:alpine3.19`
    - nginxなら
        - `nginx:latest(?)`
    - wordpressなら
        - `wordpress:latest`

### 3. サービスを作成

- サービス作成を選択

#### コンピューティングオプションを選択

1. キャパシティープロバイダを選んだ場合
    - ※1 つ以上のキャパシティープロバイダーにタスクを分散する起動戦略を指定します
    - っっっx

2. 起動タイプを選択した場合
    - ※キャパシティープロバイダー戦略を使用せずに、タスクを直接起動します。
    - xxx

#### デプロイ設定

- アプリケーションタイプは①サービス か ②タスク かを選択
    - **サービス**
        - WEBアプリとかならこちらを選択
    - **タスク**
        - バッチなど、実行してすぐ終了するもの

#### 確認事項

- 出来上がるまで数分かかる
- これで、もうコンテナが使えるようになる
- 起動中のサービス画面で、パブリックIPが割り振られている
- ブラウザでWEBページが見れることを確認できた！
    - `http://x.x.x.x`

### 4. タスクの作成

- 作成（なんだか、サービスと似たような内容を選べる）
- ２台作成してみた

## 自作のコンテナイメージを使いたい場合

### 1. リポジトリを作成

- リポジトリ作成を選択
- 公開するつもりがないなら、プライベートで良い
- （

