# vscode ショートカットキー（mac/win）

## 備忘録

現在の行で修正している単語を、他の行にある同じ単語も同時に修正する方法が複数あります。用途別に整理して説明します。

1. 同じ単語を順に選択して同時編集（最もよく使う方法）
手順　修正したい単語にカーソルを置く
Ctrl + D（Windows / Linux）
Cmd + D（macOS） を押す
同じ単語が次々に選択され、複数カーソルになる
そのまま入力すると、すべて同時に編集される

特徴　今見えている範囲から順に選択　一部だけ修正したい場合に向いている

2. ファイル内の同じ単語をすべて同時に編集
手順　単語を選択（またはカーソルを置く）

Ctrl + Shift + L（Windows / Linux）
Cmd + Shift + L（macOS）

特徴
ファイル内の同一単語を一括で複数カーソル化
変数名などをまとめて変更する場合に便利

3. マウス操作で複数カーソルを作る
手順　Alt + クリック（Windows / Linux）
Option + クリック（macOS）

特徴
任意の位置にカーソルを追加可能
単語が完全一致していなくても対応できる


## よく使う

| 操作 | Mac | Windows |
|------|-----|---------|
| コマンドパレット | `Cmd + Shift + P` | `Ctrl + Shift + P` |
| ファイル検索 | `Cmd + P` | `Ctrl + P` |
| シンボル検索 | `Cmd + Shift + O` | `Ctrl + Shift + O` |
| クイックオープン（ファイル内検索） | `Cmd + P` → `@` | `Ctrl + P` → `@` |
| 検索・置換 | `Cmd + F` / `Cmd + Option + F` | `Ctrl + F` / `Ctrl + H` |
| 全ファイル検索 | `Cmd + Shift + F` | `Ctrl + Shift + F` |
| 行を削除 | `Cmd + Shift + K` | `Ctrl + Shift + K` |
| 行をコピー | `Cmd + Shift + D` | `Shift + Alt + Down` |
| 行を移動 | `Option + ↑/↓` | `Alt + ↑/↓` |
| 複数カーソル | `Cmd + Option + ↑/↓` | `Ctrl + Alt + ↑/↓` |
| 同じ単語を選択 | `Cmd + D` | `Ctrl + D` |
| 元に戻す/やり直し | `Cmd + Z` / `Cmd + Shift + Z` | `Ctrl + Z` / `Ctrl + Y` |
| 保存 | `Cmd + S` | `Ctrl + S` |
| すべて保存 | `Cmd + Option + S` | `Ctrl + K S` |

## 割と使う

| 操作 | Mac | Windows |
|------|-----|---------|
| ターミナル表示/非表示 | `Ctrl + @` | `Ctrl + @` |
| サイドバー表示/非表示 | `Cmd + B` | `Ctrl + B` |
| エクスプローラー表示 | `Cmd + Shift + E` | `Ctrl + Shift + E` |
| 検索パネル表示 | `Cmd + Shift + F` | `Ctrl + Shift + F` |
| Git表示 | `Ctrl + Shift + G` | `Ctrl + Shift + G` |
| 拡張機能表示 | `Cmd + Shift + X` | `Ctrl + Shift + X` |
| 設定を開く | `Cmd + ,` | `Ctrl + ,` |
| キーバインド設定 | `Cmd + K Cmd + S` | `Ctrl + K Ctrl + S` |
| フォーマット | `Shift + Option + F` | `Shift + Alt + F` |
| 定義へ移動 | `F12` | `F12` |
| 参照を検索 | `Shift + F12` | `Shift + F12` |
| 戻る/進む | `Ctrl + -` / `Ctrl + Shift + -` | `Alt + ←` / `Alt + →` |
| ファイルを閉じる | `Cmd + W` | `Ctrl + W` |
| エディタを分割 | `Cmd + \` | `Ctrl + \` |
| タブを切り替え | `Cmd + 1/2/3` | `Ctrl + 1/2/3` |
| コメントアウト | `Cmd + /` | `Ctrl + /` |
| ブロックコメント | `Shift + Option + A` | `Shift + Alt + A` |

## 必須で覚えるべき操作

### 1. コマンドパレット（最重要）
- **Mac**: `Cmd + Shift + P`
- **Windows**: `Ctrl + Shift + P`
- あらゆる操作を検索して実行できる。覚えれば操作を探す手間が減る

### 2. ファイル検索
- **Mac**: `Cmd + P`
- **Windows**: `Ctrl + P`
- ファイル名を入力して素早く開く

### 3. 複数カーソル編集
- **Mac**: `Cmd + Option + ↑/↓` または `Cmd + D`（同じ単語を順次選択）
- **Windows**: `Ctrl + Alt + ↑/↓` または `Ctrl + D`
- 同じ編集を複数箇所で一括実行

### 4. 定義へ移動・参照検索
- **定義へ移動**: `F12`
- **参照を検索**: `Shift + F12`
- コードの理解とリファクタリングに必須

### 5. ファイル比較
**方法1（コマンドパレット）**
1. アクティブファイルを開く
2. コマンドパレット（`Cmd/Ctrl + Shift + P`）を開く
3. 「File: Compare Active File With…」を選択

**方法2（右クリック）**
1. エクスプローラーで比較したい一方のファイルを右クリック
2. 「比較対象の選択（Select for Compare）」をクリック
3. もう一方のファイルを右クリック
4. 「選択項目と比較（Compare with Selected）」を選択

### 6. 検索・置換
- **検索**: `Cmd/Ctrl + F`
- **置換**: `Cmd + Option + F`（Mac） / `Ctrl + H`（Windows）
- **全ファイル検索**: `Cmd/Ctrl + Shift + F`
- 正規表現や大文字小文字の区別も設定可能

### 7. 行操作
- **行を削除**: `Cmd/Ctrl + Shift + K`
- **行をコピー**: `Cmd + Shift + D`（Mac） / `Shift + Alt + Down`（Windows）
- **行を移動**: `Option + ↑/↓`（Mac） / `Alt + ↑/↓`（Windows）

### 8. フォーマット
- **Mac**: `Shift + Option + F`
- **Windows**: `Shift + Alt + F`
- コード整形を自動実行

### 9. ターミナル操作
- **表示/非表示**: `Ctrl + @`（Mac/Windows共通）
- **新規ターミナル**: `Ctrl + Shift + @`（Mac） / `Ctrl + Shift + ` `（Windows）

### 10. エディタ分割
- **Mac**: `Cmd + \`
- **Windows**: `Ctrl + \`
- 複数ファイルを同時に表示

### 11. 戻る/進む（ナビゲーション）
- **Mac**: `Ctrl + -` / `Ctrl + Shift + -`
- **Windows**: `Alt + ←` / `Alt + →`
- コードジャンプ後に元の位置に戻る

### 12. 設定のカスタマイズ
- **設定を開く**: `Cmd/Ctrl + ,`
- **キーバインド設定**: `Cmd + K Cmd + S`（Mac） / `Ctrl + K Ctrl + S`（Windows）
- ショートカットを自分好みに変更可能

## 補足

### ショートカットの覚え方
- `Cmd/Ctrl + P` = **P**roject（ファイル検索）
- `Cmd/Ctrl + Shift + P` = **P**alette（コマンドパレット）
- `Cmd/Ctrl + D` = **D**uplicate（同じ単語を選択）
- `F12` = Go to definition（定義へ移動）

### よく使うコマンドパレットコマンド
- `>reload` - ウィンドウをリロード
- `>format` - フォーマット
- `>change language` - 言語モードを変更
- `>toggle word wrap` - 折り返し表示の切り替え
