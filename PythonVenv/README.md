# Python仮想環境プロジェクト

このプロジェクトはPythonの仮想環境（venv）を使用した開発環境テンプレートです。

## ディレクトリ構成

```
PythonVenv/
├── src/
│   └── main.py          # メインプログラム
├── venv/                # 仮想環境（自動生成、gitignore対象）
├── requirements.txt     # 依存パッケージリスト
├── setup.ps1            # セットアップスクリプト
├── run.ps1              # 実行スクリプト
├── .gitignore          # Git除外設定
└── README.md           # このファイル
```

## 使い方

### 1. 初回セットアップ

PowerShellで以下を実行：

```powershell
.\setup.ps1
```

このスクリプトは以下を実行します：
- Python仮想環境の作成
- pipの最新版へのアップグレード
- `requirements.txt` からパッケージのインストール

### 2. アプリケーションの実行

```powershell
.\run.ps1
```

コマンドライン引数を渡す場合：

```powershell
.\run.ps1 arg1 arg2 arg3
```

### 3. 手動で仮想環境を操作

仮想環境に入る：

```powershell
.\venv\Scripts\Activate.ps1
```

仮想環境を終了：

```powershell
deactivate
```

## PowerShell実行ポリシーについて

スクリプトの実行時にエラーが出る場合、PowerShellの実行ポリシーを変更する必要があります：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## パッケージの追加

新しいパッケージを追加する場合：

1. 仮想環境に入る
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```

2. パッケージをインストール
   ```powershell
   pip install パッケージ名
   ```

3. `requirements.txt` を更新
   ```powershell
   pip freeze > requirements.txt
   ```

または、`requirements.txt` を直接編集してから：

```powershell
.\setup.ps1
```

## 開発のヒント

- `src/main.py` を編集してアプリケーションを開発
- 必要に応じて `src/` 配下にモジュールを追加
- テストコードは `tests/` ディレクトリに配置することを推奨

## トラブルシューティング

### スクリプトが実行できない

PowerShellの実行ポリシーを確認してください：

```powershell
Get-ExecutionPolicy
```

`Restricted` の場合は、上記の「PowerShell実行ポリシーについて」を参照してください。

### 仮想環境を再作成したい

```powershell
.\setup.ps1
```

を実行すると、既存の仮想環境を削除して再作成するか確認されます。

### Python が見つからない

Pythonがインストールされているか、PATHが通っているか確認してください：

```powershell
python --version
```

## ライセンス

このテンプレートは自由に使用・改変できます。
