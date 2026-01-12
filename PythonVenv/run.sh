#!/bin/bash
# Python仮想環境実行スクリプト
# 使い方: ./run.sh [引数...]

# エラー時に停止
set -e

echo "=================================================="
echo "  Pythonアプリケーション実行"
echo "=================================================="
echo ""

# 仮想環境の存在確認
if [ ! -d "venv" ]; then
    echo "仮想環境が見つかりません"
    echo ""
    echo "最初にセットアップを実行してください:"
    echo "  ./setup.sh"
    echo ""
    exit 1
fi

# main.pyの存在確認
if [ ! -f "src/main.py" ]; then
    echo "src/main.py が見つかりません"
    echo ""
    echo "src/main.py を作成してください"
    echo ""
    exit 1
fi

# 仮想環境をアクティベート
echo "仮想環境をアクティベートしています..."
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    echo "仮想環境がアクティベートされました"
else
    echo "仮想環境のアクティベートに失敗しました"
    echo ""
    exit 1
fi

# Pythonスクリプトを実行
echo ""
echo "=================================================="
echo "  アプリケーション実行中..."
echo "=================================================="
echo ""

# コマンドライン引数を全て渡す
set +e  # エラーで停止しないように一時的に変更
python src/main.py "$@"
EXIT_CODE=$?
set -e

# 実行結果の表示
echo ""
echo "=================================================="
echo "  実行が完了しました (終了コード: ${EXIT_CODE})"
echo "=================================================="
echo ""

# 仮想環境を終了
deactivate

exit $EXIT_CODE
