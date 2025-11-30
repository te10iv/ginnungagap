# dockerの状態遷移と、メモリ容量との関係、削除手順


📘 Docker 状態遷移 × メモリ × 削除手順まとめメモ（保存版）
1. Docker コンテナの状態遷移（最重要）
Docker コンテナは大きく 4 つの状態を行き来する。
          docker run
   ┌────────────────────┐
   │                    ▼
Created → Running → Paused
   ▲        ↓           │
   │        ↓           │ docker unpause
   │        ↓           ▼
   └────── Exited (Stopped)
2. 各状態の意味と「メモリ」「容量」への影響
状態	意味	メモリRAM	ディスク容量	prune で削除？
Created	作成されたが未起動	使わない	少し使う	❌
Running	実行中	使う（最大）	ディスクは使う	❌
Paused	実行が一時停止	メモリを保持（解放されない）	ディスクは同じ	❌
Exited / Stopped	完全停止	メモリ解放	イメージ＋差分が残る	✔ prune対象
Deleted	完全削除	0	0	—
3. 状態ごとのイメージ図（記憶しやすさ重視）
✔ Running（動作中）
CPU → 動作中
メモリ → 大量に使う
prune → 削除されない
✔ Paused（一時停止）
CPU → 止まってる
メモリ → 保持したまま
prune → 削除されない
≫ 例えるなら「一時停止中のゲーム」
≫ メモリ上に全部残っているので容量は食う
✔ Exited（完全停止）
CPU → 動かない
メモリ → 完全に解放
prune → 削除対象
≫ 例えるなら「アプリを閉じた状態」
≫ ただしディスク上に“コンテナの差分”は残る
4. 状態を切り替えるコマンドまとめ
操作	コマンド	状態遷移
起動	docker start <id>	Exited → Running
一時停止	docker pause <id>	Running → Paused
再開	docker unpause <id>	Paused → Running
停止	docker stop <id>	Running/Paused → Exited
完全削除	docker rm <id>	Exited → Deleted
5. 容量（ディスク）を消費するもの一覧
何？	説明	大容量になりやすい？
イメージ	・docker pullやdocker buildで生成
・重い（数百MB〜数GB）	⭐最強に重い
コンテナの差分レイヤー	コンテナごとの変更分	△
ボリューム	DB やログデータ	⭐重い（数GB行く）
キャッシュ（ビルドキャッシュ等）	build の中間データ	△
6. メモリとの関係まとめ（ここだけ覚えればOK）
状態	メモリ	典型的な容量状況
Running	使う（増える）	アプリが動く分だけRAMを食う
Paused	使い続ける（解放されない）	止まっててもRAMを占有
Exited	解放される	RAMは0になる。ディスクだけ残る
Deleted	0	ディスク完全0
7. 削除（クリーンアップ）手順まとめ（安全版 → 容量爆増版）
🟩（安全）停止コンテナを削除
docker container prune
Exited のみ削除
データは残る
容量は少し戻る（数百MB〜）
🟨（中級）使わないイメージを削除（大量に戻る）
docker image prune -a
タグなし or 使用されてないイメージ削除
数GB〜数十GB 空く
🟧（中級）使わないボリュームを削除
docker volume prune
使用中のDBは消えない
古いMySQL/Postgresのデータが飛ぶ
🟥（最強）すべて削除（DB含む）
docker system prune -a --volumes
※ 絶対に本番では使わない。学習環境専用。
すべての未使用
コンテナ
イメージ
ネットワーク
ボリューム（DB含む）
を削除
数十GBレベルで空くこともある
8. 推奨クリーンアップ手順（あなた向け）
あなたの環境では：
① 停止コンテナだけ消す（やった）
docker container prune
② 不要なイメージ削除（今が容量回復ポイント）
docker image prune -a
③ 不要ボリューム削除（必要なら）
docker volume prune
→ これだけで Mac の容量はほぼ最適化 される！
9. 保存用まとめ（超要約）
[Running]
  ↑ docker unpause
[Paused] ← docker pause
  ↓ docker stop   →  RAM解放
[Exited]
  ↓ docker rm     →  完全削除（ディスク解放）
[Deleted]
容量に効くのは：
①イメージ ②ボリューム ③停止コンテナ
