# プルリク作成までの流れ

## プルリク作成までの Git コマンド(チートシート的な)

- 前提
	•	既に GitHub 上にリポジトリがある（自分 or 他人の repository）

① リポジトリをローカルに clone

```
git clone https://github.com/ユーザー名/リポジトリ名.git
cd リポジトリ名
```

② 最新の main ブランチを取得（最重要）

```
git checkout main
git pull origin main
```

③ 作業用ブランチを作成して移動

```
git switch -c feature/my-change
```

※ feature/〜、fix/〜 などがよく使われる命名
※ 昔はgit checkout -bを使っていた人も多い。動作は同じ。

④ 変更を行い、ステージングへ追加

```
git add .
```

特定ファイルだけなら：

```
git add path/to/file1
git add path/to/file2
```

⑤ コミットする

```
git commit -m "◯◯を修正"
```

※ 英語だと、修正内容を命令形で書く `git commit -m "modify init.txt"`


⑤ '
（できれば）git pull --rebase origin main


⑥ リモートの自分の作業ブランチへ push

```
git push origin feature/my-change
```

または

```
git push -u origin feature/my-change
```


ここで GitHub 上に自動的に「Compare & pull request」ボタンが表示される！
つまり、ターミナル側はここまでで OK。
あとは GitHub 上で：

1. 「Compare & Pull Request」をクリック
2. タイトル・説明を書く
3. 「Create Pull Request」

で完了！


## 補足1：他人のリポジトリにプルリクしたい場合（フォーク方式）

GitHub で Fork → 自分のアカウントの repo を clone → push は自分の fork に → PR を元 repo に作成。

コマンド自体は同じ：

```
git clone 自分のフォークURL
git switch -c fix/xxx
git add .
git commit -m "fix xxx"
git push -u origin fix/xxx
```


## まとめ（超短い版）

```
git clone URL
git checkout main
git pull
git switch -c feature/xxx
git add .
（できれば）git pull --rebase origin main
git commit -m "message"
git push origin feature/xxx
```


