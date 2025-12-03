# プルリク作成までの流れ

## チートシート

```bash
# ① リポジトリをclone
git clone https://github.com/ユーザー名/リポジトリ名.git
cd リポジトリ名

# ② 最新のmainブランチを取得
git checkout main
git pull origin main

# ③ 作業ブランチを作成・移動
git switch -c feature/my-change

# ④ 変更・ステージング・コミット
git add .
git commit -m "修正内容"

# ⑤ （推奨）push前にmainの最新を取り込む
git pull --rebase origin main

# ⑥ リモートにpush
git push -u origin feature/my-change
```

GitHub上で「Compare & pull request」→ タイトル・説明を書く → 「Create Pull Request」

---

## まとめ（超短縮版）

```bash
git clone URL && cd リポジトリ名
git checkout main && git pull origin main
git switch -c feature/xxx
git add . && git commit -m "message"
git pull --rebase origin main  # 推奨
git push -u origin feature/xxx
```

---

## 補足

### ブランチ名の命名規則
- `feature/機能名` - 新機能追加
- `fix/修正内容` - バグ修正
- `hotfix/緊急修正` - 緊急の修正

### `git pull --rebase` について
- **推奨**: push前に実行すると、mainブランチの最新変更を取り込んで履歴がきれいになる
- **省略可**: チームのルールや個人の好みで省略してもOK
- **代替**: `git merge origin main` でも可（履歴は分岐する）

### `git push -u` について
- `-u` オプション: 次回以降は `git push` だけでOKになる
- 初回のみ `-u` が必要

### 特定ファイルだけをaddする場合
```bash
git add path/to/file1 path/to/file2
```

### コミットメッセージの書き方
- 日本語: `"◯◯を修正"`
- 英語: 命令形で `"Fix bug in login"` または `"Add new feature"`

### 他人のリポジトリにPRする場合（フォーク方式）
1. GitHub上で「Fork」ボタンをクリック
2. 自分のフォークをclone
3. 上記のチートシートと同じ手順
4. push先は自分のフォーク
5. GitHub上で元のリポジトリに対してPRを作成

### よくあるエラーと対処
- **`fatal: refusing to merge unrelated histories`**: `git pull --rebase origin main --allow-unrelated-histories`
- **コンフリクト発生時**: コンフリクトを解決後、`git add .` → `git rebase --continue`
