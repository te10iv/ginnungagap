from pathlib import Path
import textwrap

BASE_DIR = Path("python-wiki")

# ディレクトリごとのファイル構成
STRUCTURE = {
    "01_basic": [
        "overview.md",
        "syntax.md",
        "datatype.md",
        "variable.md",
        "operator.md",
        "input_output.md",
        "exercise_basic.md",
    ],
    "02_controlflow": [
        "overview.md",
        "if.md",
        "for.md",
        "while.md",
        "break_continue.md",
        "exercise_controlflow.md",
    ],
    "03_function": [
        "overview.md",
        "define.md",
        "args_kwargs.md",
        "return.md",
        "scope.md",
        "exercise_function.md",
    ],
    "04_module": [
        "overview.md",
        "import.md",
        "standard_library.md",
        "exercise_module.md",
    ],
    "05_file": [
        "open.md",
        "read_write.md",
        "pathlib.md",
        "exercise_file.md",
    ],
    "06_class": [
        "overview.md",
        "class.md",
        "inheritance.md",
        "dunder_method.md",
        "exercise_class.md",
    ],
    "07_advanced": [
        "list_comprehension.md",
        "generator.md",
        "decorator.md",
        "exception.md",
    ],
}

# 各 md ファイルのテンプレ（TITLE だけ差し替える）
PAGE_TEMPLATE = textwrap.dedent("""\
    # {title}

    ## 1. 要点まとめ
    - 

    ## 2. 詳細解説
    （論理的に5〜15行で解説。必要に応じて図解や例も。）

    ## 3. サンプルコード
    ```python
    # サンプルコードを書く
    ```

    ## 4. 注意点・落とし穴
    - よくある間違い
    - 初学者がつまずくポイント

    ## 5. 演習問題
    1. 問題文を書く
    2. 問題文を書く

    ## 6. 解答例
    ```python
    # 解答例
    ```
    """)

README_CONTENT = textwrap.dedent("""\
    # Python 基礎 Wiki

    Python の基礎を学ぶための個人用 Wiki です。

    ## ディレクトリ構成

    - 01_basic: Python の超基本（文法・データ型など）
    - 02_controlflow: if / for / while など制御構文
    - 03_function: 関数・引数・戻り値・スコープ
    - 04_module: import / 標準ライブラリ
    - 05_file: ファイル入出力
    - 06_class: クラス・継承・特殊メソッド
    - 07_advanced: リスト内包表記・ジェネレータ・デコレータ・例外処理

    各 md ファイルは Cursor に読み込ませて中身を育てていきます。
    """)


def filename_to_title(filename: str) -> str:
    """ファイル名からざっくりタイトルを作る."""
    stem = Path(filename).stem  # "input_output" -> "input_output"
    # 特殊ケースを少しだけ日本語化
    special = {
        "overview": "概要",
        "syntax": "基本文法",
        "datatype": "データ型",
        "variable": "変数",
        "operator": "演算子",
        "input_output": "入力と出力",
        "exercise_basic": "基本編 演習",
        "exercise_controlflow": "制御構文 演習",
        "exercise_function": "関数編 演習",
        "exercise_module": "モジュール編 演習",
        "exercise_file": "ファイル操作 演習",
        "exercise_class": "クラス編 演習",
        "standard_library": "標準ライブラリ",
        "class": "クラスの基礎",
        "inheritance": "継承",
        "dunder_method": "特殊メソッド（dunder）",
        "list_comprehension": "リスト内包表記",
        "generator": "ジェネレータ",
        "decorator": "デコレータ",
        "exception": "例外処理",
    }
    if stem in special:
        return special[stem]

    # デフォルトは「単語をスペース区切りにしてタイトルケース」
    return stem.replace("_", " ").title()


def create_python_wiki(base_dir: Path = BASE_DIR) -> None:
    # ベースディレクトリ作成
    base_dir.mkdir(exist_ok=True)

    # README.md 作成
    readme_path = base_dir / "README.md"
    if not readme_path.exists():
        readme_path.write_text(README_CONTENT, encoding="utf-8")
        print(f"created: {readme_path}")
    else:
        print(f"exists : {readme_path}")

    # 各ディレクトリ・ファイル作成
    for subdir, files in STRUCTURE.items():
        dir_path = base_dir / subdir
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"dir    : {dir_path}")

        for filename in files:
            file_path = dir_path / filename
            if file_path.exists():
                print(f"exists : {file_path}")
                continue

            title = filename_to_title(filename)
            content = PAGE_TEMPLATE.format(title=title)
            file_path.write_text(content, encoding="utf-8")
            print(f"created: {file_path}")


if __name__ == "__main__":
    create_python_wiki()
    print("✅ python-wiki ディレクトリと md ファイルの作成が完了しました。")
