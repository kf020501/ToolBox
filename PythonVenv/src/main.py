"""
メインエントリーポイント
このファイルをカスタマイズしてアプリケーションを作成してください
"""

import sys
from pathlib import Path


def main():
    """メイン関数"""
    print("=" * 50)
    print("  Pythonアプリケーション")
    print("=" * 50)
    print()

    # コマンドライン引数の表示
    if len(sys.argv) > 1:
        print(f"コマンドライン引数: {sys.argv[1:]}")
        print()

    # 現在のディレクトリ情報
    print(f"実行ディレクトリ: {Path.cwd()}")
    print(f"Pythonバージョン: {sys.version}")
    print()

    # ここにアプリケーションのロジックを追加
    print("Hello, Python venv!")
    print()
    print("このファイル (src/main.py) を編集して、")
    print("あなたのアプリケーションを作成してください。")
    print()

    return 0


if __name__ == "__main__":
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n\n中断されました")
        sys.exit(130)
    except Exception as e:
        print(f"\nエラーが発生しました: {e}", file=sys.stderr)
        sys.exit(1)
