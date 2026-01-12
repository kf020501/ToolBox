#!/bin/bash
# Python仮想環境セットアップスクリプト
# 使い方: ./setup.sh

# エラー時に停止
set -e

echo "=================================================="
echo "  Python仮想環境セットアップ"
echo "=================================================="
echo ""

# Python3の存在確認
echo "[1/4] Pythonのバージョンを確認しています..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "  ${PYTHON_VERSION} が見つかりました"
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version)
    echo "  ${PYTHON_VERSION} が見つかりました"
    PYTHON_CMD="python"
else
    echo "  Pythonが見つかりません。Pythonをインストールしてください。"
    exit 1
fi

# 既存のvenv削除確認
SKIP_VENV_CREATION=false
if [ -d "venv" ]; then
    echo ""
    echo "[2/4] 既存の仮想環境が見つかりました"
    read -p "  既存の仮想環境を削除して再作成しますか? (y/N): " response
    if [[ "$response" =~ ^[yY]$ ]]; then
        echo "  既存の仮想環境を削除しています..."
        rm -rf venv
        echo "  削除完了"
    else
        echo "  既存の仮想環境を使用します"
        SKIP_VENV_CREATION=true
    fi
else
    echo ""
    echo "[2/4] 仮想環境を作成しています..."
fi

# 仮想環境の作成
if [ "$SKIP_VENV_CREATION" = false ]; then
    if $PYTHON_CMD -m venv venv; then
        echo "  仮想環境の作成が完了しました"
    else
        echo "  仮想環境の作成に失敗しました"
        exit 1
    fi
fi

# 仮想環境のアクティベート
echo ""
echo "[3/4] 仮想環境をアクティベートしています..."
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    echo "  仮想環境がアクティベートされました"
else
    echo "  仮想環境のアクティベートに失敗しました"
    exit 1
fi

# pipのアップグレード
echo "  pipを最新版にアップグレードしています..."
python -m pip install --upgrade pip --quiet
echo "  pipのアップグレードが完了しました"

# requirements.txtからパッケージをインストール
echo ""
echo "[4/4] 依存パッケージをインストールしています..."
if [ -f "requirements.txt" ]; then
    if pip install -r requirements.txt; then
        echo "  依存パッケージのインストールが完了しました"
    else
        echo "  パッケージのインストールに失敗しました"
        exit 1
    fi
else
    echo "  requirements.txtが見つかりません"
    echo "  必要に応じて requirements.txt を作成してください"
fi

# 完了メッセージ
echo ""
echo "=================================================="
echo "  セットアップが完了しました！"
echo "=================================================="
echo ""
echo "次のステップ:"
echo "  1. アプリケーションを実行: ./run.sh"
echo "  2. 手動で仮想環境に入る: source venv/bin/activate"
echo "  3. 仮想環境を終了: deactivate"
echo ""
