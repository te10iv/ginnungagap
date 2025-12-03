**GitHub Pages（無料）で作る

MkDocs Material 個人Wiki構築手順書（Freeプラン版）**

※この手順書は GitHub Free プラン限定
Private リポジトリでは Pages が使えないため
Wiki 用リポジトリは Public を使用します。

0. 目的と完成イメージ

無料で以下を実現する：

Markdown で書ける技術Wiki

GitHub Pages で公開され、どこでも閲覧可能（ログイン不要）

MkDocs Material による高品質デザイン

ソース（Markdown）は Git によって管理

手元の PC から更新し、push だけで自動デプロイ

最終URL例：

https://<yourname>.github.io/<repo-name>/

1. リポジトリ作成（Public）

GitHub に新規リポジトリを作成する：

Repository name: ginnungagap（好みでOK）

Visibility: Public

Add README: 任意

作成後、ローカルへクローン：

git clone https://github.com/<yourname>/ginnungagap.git
cd ginnungagap

2. Wiki用ディレクトリの作成

例えば以下のようなフォルダを Wiki のルートにする：

mkdir -p cuchulainn
echo "# My Secret Wiki\nここは個人用Wikiのトップページです。" > cuchulainn/index.md


構成はこうなる：

ginnungagap/
├── cuchulainn/
│   └── index.md
└── ...

3. MkDocs 設定ファイル（mkdocs.yml）を作成

リポジトリ直下に mkdocs.yml を作成：

site_name: My Secret Wiki
docs_dir: cuchulainn

theme:
  name: material

4. GitHub Actions（Pagesデプロイ用）設定

GitHub Pages を “GitHub Actions モード” で動かすため
以下のファイルを作る。

mkdir -p .github/workflows


.github/workflows/gh-pages.yml を作成し、内容を以下にする：

name: Deploy MkDocs site to GitHub Pages

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.x"

      - name: Install MkDocs + Material
        run: |
          pip install mkdocs-material

      - name: Build MkDocs site
        run: |
          mkdocs build --site-dir ./_site

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./_site

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4

5. GitHub Pages の設定（重要）

GitHub のリポジトリを開き：

Settings → Pages

Build and Deployment
　Source: GitHub Actions を選択

（＝自動デプロイ方式）

6. push → 自動デプロイ

ローカルで：

git add .
git commit -m "Initial MkDocs setup"
git push


→ GitHub Actions が自動実行
→ ビルド成功すれば GitHub Pages に公開される

7. 公開URLを確認

Settings → Pages に以下のような表示が出る：

Your site is published at:
https://<yourname>.github.io/ginnungagap/


ブラウザでアクセスし、
cuchulainn/index.md の内容が表示されれば成功。

8. 新しいページを追加する方法

例：AWS 用ディレクトリを作る

mkdir -p cuchulainn/aws
echo "# Test aws memo\n中身は空です。" > cuchulainn/aws/test-aws-memo.md


push すれば自動で反映：

git add .
git commit -m "Add AWS memo"
git push


アクセス例：

https://<yourname>.github.io/ginnungagap/aws/test-aws-memo/

9. 非公開情報の取り扱いルール（重要）

GitHub Pages は Public リポジトリでしか使えない（Free プラン）。

したがって：

個人情報

企業情報

守秘義務の内容

ログの実データ

などは 絶対にリポジトリに置かないこと。

代わりに：

Obsidian + Dropbox（ローカル専用）

GitHub Private リポジトリ（Wikiとは分離）

で安全に管理する。

10. カスタムドメイン（必要なら）

github.io が会社でブロックされている場合は：

独自ドメイン取得（100円〜）

Cloudflare に無料登録

GitHub Pages にカスタムドメイン設定

これにより、
ブロック回避できる確率が高くなります。

（例）

https://my-secret-wiki.xyz/

まとめ
作業	内容
リポジトリ作成	Public、好きな名前
MkDocs導入	mkdocs.yml + docs_dir
GitHub Actions	自動デプロイ設定
Pages設定	Source: GitHub Actions
Push	自動デプロイされる
読み方	https://<user>.github.io/<repo>/