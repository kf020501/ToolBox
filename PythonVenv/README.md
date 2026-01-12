# Python仮想環境プロジェクト

Pythonの仮想環境（venv）を使用した開発環境テンプレートです。

## ディレクトリ構成

```
PythonVenv/
├── src/
│   └── main.py          # メインプログラム
├── venv/                # 仮想環境（自動生成、gitignore対象）
├── requirements.txt     # 依存パッケージリスト
├── setup.ps1            # セットアップスクリプト（Windows用）
├── run.ps1              # 実行スクリプト（Windows用）
├── setup.sh             # セットアップスクリプト（Linux/Mac用）
├── run.sh               # 実行スクリプト（Linux/Mac用）
├── .gitignore          # Git除外設定
└── README.md           # このファイル
```

## 使い方

### Windows

**初回セットアップ**
```powershell
.\setup.ps1
```

**アプリケーション実行**
```powershell
.\run.ps1 [引数...]
```

**手動で仮想環境を操作**
```powershell
# 仮想環境に入る
.\venv\Scripts\Activate.ps1

# 仮想環境を終了
deactivate
```

**PowerShell実行ポリシーエラーが出る場合**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Linux / Mac

**初回セットアップ**
```bash
./setup.sh
```

**アプリケーション実行**
```bash
./run.sh [引数...]
```

**手動で仮想環境を操作**
```bash
# 仮想環境に入る
source venv/bin/activate

# 仮想環境を終了
deactivate
```

## パッケージの追加

**方法1: 手動でインストール**
```bash
# 仮想環境に入る
source venv/bin/activate  # Linux/Mac
.\venv\Scripts\Activate.ps1  # Windows

# パッケージをインストール
pip install パッケージ名

# requirements.txt を更新
pip freeze > requirements.txt
```

**方法2: requirements.txt を編集**
`requirements.txt` を直接編集してから、セットアップスクリプトを再実行。

## トラブルシューティング

**仮想環境を再作成したい**
セットアップスクリプトを再実行すると、既存の仮想環境を削除して再作成するか確認されます。

**Python が見つからない**
Pythonがインストールされ、PATHが通っているか確認してください。
```bash
python --version   # Windows
python3 --version  # Linux/Mac
```

## ライセンス

このテンプレートは自由に使用・改変できます。
