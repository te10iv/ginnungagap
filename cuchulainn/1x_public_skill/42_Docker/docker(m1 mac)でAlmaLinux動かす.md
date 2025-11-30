# docker(m1 mac)でAlmaLinux動かす

## 前提
- docker(m1 mac)
  - 

## やること
- 

② Docker Desktop を用意（もう入ってたら飛ばしてOK）
Docker Desktop for Mac をインストール
すでに入っていればそのまま使ってOK。

▼いちおう確認　（M1　macならデフォルト）
起動して、メニューの Settings → General あたりで
Use Virtualization framework（Apple系の仮想化）
が有効ならそのままで大丈夫。


# 1) イメージを取得（pull）
docker pull almalinux:9

▼ログ
9: Pulling from library/almalinux
855c1b9e7f00: Pull complete 
Digest: sha256:9c869fd1056a929a1a6c6811a991b5dcb7a1ccfb8e8c44165d9719192826d4ac
Status: Downloaded newer image for almalinux:9
docker.io/library/almalinux:9


# 2) とりあえず一時的に入ってみる例　（--rm により、抜けた瞬間にコンテナは完全に消える。）
docker run --rm -it almalinux:9 bash


