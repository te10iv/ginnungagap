# Cursor ショートカットキー（mac/win）

## 備忘録

- Markdown プレビューの表示／非表示
  - Cmd + Shift + V
  - Ctrl + Shift + V

- cursol チャットウィンドウ 表示 非表示 ショートカット
  - macOS: Command + L
  - Windows / Linux: Ctrl + L

- コメントアウト
  - Ctrl + /



cursol-sh

## よく使う

| 操作 | Mac | Windows |
|------|-----|---------|
| **AI機能** |
| AIチャットを開く | `Cmd + L` | `Ctrl + L` |
| AI補完を受け入れる | `Tab` | `Tab` |
| AI補完を拒否 | `Esc` | `Esc` |
| インライン編集（選択範囲をAI編集） | `Cmd + K` | `Ctrl + K` |
| コマンドパレット | `Cmd + Shift + P` | `Ctrl + Shift + P` |
| **ファイル操作** |
| ファイル検索 | `Cmd + P` | `Ctrl + P` |
| シンボル検索 | `Cmd + Shift + O` | `Ctrl + Shift + O` |
| 保存 | `Cmd + S` | `Ctrl + S` |
| すべて保存 | `Cmd + Option + S` | `Ctrl + K S` |
| **検索** |
| 検索・置換 | `Cmd + F` / `Cmd + Option + F` | `Ctrl + F` / `Ctrl + H` |
| 全ファイル検索 | `Cmd + Shift + F` | `Ctrl + Shift + F` |
| **編集** |
| 行を削除 | `Cmd + Shift + K` | `Ctrl + Shift + K` |
| 複数カーソル | `Cmd + Option + ↑/↓` | `Ctrl + Alt + ↑/↓` |
| 同じ単語を選択 | `Cmd + D` | `Ctrl + D` |
| 元に戻す/やり直し | `Cmd + Z` / `Cmd + Shift + Z` | `Ctrl + Z` / `Ctrl + Y` |

## 割と使う

| 操作 | Mac | Windows |
|------|-----|---------|
| **AI機能** |
| チャット履歴を表示 | `Cmd + Shift + L` | `Ctrl + Shift + L` |
| コンテキストを追加 | `Cmd + I` | `Ctrl + I` |
| **表示** |
| サイドバー表示/非表示 | `Cmd + B` | `Ctrl + B` |
| ターミナル表示/非表示 | `Ctrl + @` | `Ctrl + @` |
| エクスプローラー表示 | `Cmd + Shift + E` | `Ctrl + Shift + E` |
| **コードナビゲーション** |
| 定義へ移動 | `F12` | `F12` |
| 参照を検索 | `Shift + F12` | `Shift + F12` |
| 戻る/進む | `Ctrl + -` / `Ctrl + Shift + -` | `Alt + ←` / `Alt + →` |
| **編集** |
| 行を移動 | `Option + ↑/↓` | `Alt + ↑/↓` |
| フォーマット | `Shift + Option + F` | `Shift + Alt + F` |
| コメントアウト | `Cmd + /` | `Ctrl + /` |
| **その他** |
| エディタを分割 | `Cmd + \` | `Ctrl + \` |
| 設定を開く | `Cmd + ,` | `Ctrl + ,` |
| ファイルを閉じる | `Cmd + W` | `Ctrl + W` |

## その他（ショートカットキー）

| 操作 | Mac | Windows |
|------|-----|---------|
| **AI機能** |
| コードベース全体を検索（AI） | `Cmd + Shift + A` | `Ctrl + Shift + A` |
| 選択範囲を説明 | `Cmd + Shift + H` | `Ctrl + Shift + H` |
| **Git操作** |
| Git表示 | `Ctrl + Shift + G` | `Ctrl + Shift + G` |
| **拡張機能** |
| 拡張機能表示 | `Cmd + Shift + X` | `Ctrl + Shift + X` |
| **タブ操作** |
| タブを切り替え | `Cmd + 1/2/3` | `Ctrl + 1/2/3` |
| 次のタブ | `Cmd + Option + →` | `Ctrl + PageDown` |
| 前のタブ | `Cmd + Option + ←` | `Ctrl + PageUp` |

## 必須で覚えるべき操作

### 1. AIチャット（最重要）
- **Mac**: `Cmd + L`
- **Windows**: `Ctrl + L`
- コードについて質問・指示ができる。Cursorの核心機能

### 2. インライン編集（AI編集）
- **Mac**: `Cmd + K`
- **Windows**: `Ctrl + K`
- 選択範囲をAIで編集。コードを選択して実行すると、AIが提案を表示

### 3. AI補完の受け入れ/拒否
- **受け入れ**: `Tab`
- **拒否**: `Esc`
- AIが提案したコードを素早く取り入れる

### 4. コンテキスト追加
- **Mac**: `Cmd + I`
- **Windows**: `Ctrl + I`
- チャットに追加のコンテキスト（ファイル、選択範囲など）を追加

### 5. ファイル検索
- **Mac**: `Cmd + P`
- **Windows**: `Ctrl + P`
- VSCodeと同じ。ファイル名で素早く開く

### 6. コマンドパレット
- **Mac**: `Cmd + Shift + P`
- **Windows**: `Ctrl + Shift + P`
- すべての操作を検索して実行

### 7. 複数カーソル編集
- **Mac**: `Cmd + Option + ↑/↓` または `Cmd + D`
- **Windows**: `Ctrl + Alt + ↑/↓` または `Ctrl + D`
- 同じ編集を複数箇所で一括実行

### 8. 定義へ移動・参照検索
- **定義へ移動**: `F12`
- **参照を検索**: `Shift + F12`
- コードの理解に必須

### 9. チャット履歴
- **Mac**: `Cmd + Shift + L`
- **Windows**: `Ctrl + Shift + L`
- 過去のAIチャットを確認

### 10. コードベース全体検索（AI）
- **Mac**: `Cmd + Shift + A`
- **Windows**: `Ctrl + Shift + A`
- AIを使ってコードベース全体から情報を検索

## Cursor特有の機能

### AIチャットの使い方
1. `Cmd/Ctrl + L` でチャットを開く
2. 質問や指示を入力
3. コードを選択して `Cmd/Ctrl + I` でコンテキスト追加も可能

### インライン編集の使い方
1. 編集したいコードを選択
2. `Cmd/Ctrl + K` を押す
3. 編集内容を指示
4. AIが提案を表示、`Tab`で受け入れ

### AI補完の設定
- Settings → Features → Cursor Tab で有効/無効を切り替え
- 自動補完の感度も調整可能

## 補足

### VSCodeとの違い
- CursorはVSCodeベースなので、基本的なショートカットは同じ
- AI機能のショートカット（`Cmd/Ctrl + L`、`Cmd/Ctrl + K`など）が追加されている

### セキュリティ設定（重要）
Cursorを使用する際は、プライバシー設定を確認：
- Settings → Privacy → Share Data を「Privacy Mode」に設定
- プレミアムモデル（GPT-4o / Claude）を使用（cursor-smallは避ける）

### よく使うAIプロンプト例
- 「この関数を説明して」
- 「このコードをリファクタリングして」
- 「バグを修正して」
- 「テストコードを書いて」
- 「この機能を追加して」
