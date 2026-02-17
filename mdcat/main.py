#!/usr/bin/env python3
import json
import sys
from pathlib import Path

# 設定ファイルが存在しない場合に作成する初期拡張子
DEFAULT_EXTENSIONS = [".txt"]
# 設定ファイルが存在しない場合に作成するコードフェンス
DEFAULT_CODE_FENCE = "```"
# 対象ディレクトリ直下に置く設定ファイル名
SETTINGS_FILENAME = "settings.json"


def prompt_directory() -> Path:
    # 引数が無い場合は対話式でディレクトリを受け取る
    while True:
        raw = input("対象ディレクトリを入力してください: ").strip()
        if raw:
            return Path(raw)


def load_settings(target_dir: Path) -> tuple[list[str], str]:
    # 設定ファイルを読み込み、無ければ作成する
    settings_path = target_dir / SETTINGS_FILENAME
    if not settings_path.exists():
        settings = {
            "extensions": DEFAULT_EXTENSIONS,
            "code_fence": DEFAULT_CODE_FENCE,
        }
        settings_path.write_text(
            json.dumps(settings, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        return DEFAULT_EXTENSIONS, DEFAULT_CODE_FENCE

    try:
        # JSONを読み込み、拡張子の配列がある場合はそれを使う
        data = json.loads(settings_path.read_text(encoding="utf-8"))
        exts = data.get("extensions", [])
        code_fence = data.get("code_fence", DEFAULT_CODE_FENCE)
        if not isinstance(code_fence, str) or not code_fence:
            code_fence = DEFAULT_CODE_FENCE
        if isinstance(exts, list) and all(isinstance(x, str) for x in exts) and exts:
            return exts, code_fence
    except (json.JSONDecodeError, OSError):
        # 破損している/読めない場合はデフォルトへフォールバック
        pass

    return DEFAULT_EXTENSIONS, DEFAULT_CODE_FENCE


def iter_target_files(target_dir: Path, extensions: list[str]) -> list[Path]:
    # 拡張子指定にドットが無い場合でも一致できるように正規化
    ext_set = {e if e.startswith(".") else f".{e}" for e in extensions}
    # 再帰的にファイルを探索し、拡張子が一致するものだけ集める
    files = [p for p in target_dir.rglob("*") if p.is_file() and p.suffix in ext_set]
    # 表示順はパスの辞書順で固定
    return sorted(files, key=lambda p: p.as_posix())


def code_fence_lang(path: Path) -> str:
    # Markdownコードフェンスの言語名は拡張子から決定する
    if path.suffix:
        return path.suffix.lstrip(".")
    return ""


def print_file(path: Path, base_dir: Path, code_fence: str) -> None:
    # ヘッダはベースディレクトリからの相対パスで表示
    rel_path = path.relative_to(base_dir).as_posix()
    # コードフェンスの言語名は拡張子から算出
    lang = code_fence_lang(path)
    print(f"\n## {rel_path}\n")
    print(f"{code_fence}{lang}")
    try:
        # 読み取り失敗時でも処理を止めないため errors=replace
        content = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        content = ""
    # ファイルの中身をそのまま出力
    if content:
        print(content, end="" if content.endswith("\n") else "\n")
    print(code_fence)


def main() -> int:
    # 第一引数に対象ディレクトリがある場合はそれを使う
    if len(sys.argv) >= 2:
        target_dir = Path(sys.argv[1])
    else:
        # 引数が無ければ対話式入力
        target_dir = prompt_directory()

    # ディレクトリの存在チェック
    if not target_dir.exists() or not target_dir.is_dir():
        print("対象ディレクトリが存在しません。", file=sys.stderr)
        return 1

    # 設定ファイルを読み込み
    extensions, code_fence = load_settings(target_dir)
    # 対象拡張子に一致するファイル一覧を取得
    files = iter_target_files(target_dir, extensions)

    # 出力の先頭にディレクトリ名を出す
    print(f"# {target_dir.name}")
    for path in files:
        # 各ファイルをMarkdown形式で出力
        print_file(path, target_dir, code_fence)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
