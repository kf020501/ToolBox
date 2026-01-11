# Python仮想環境セットアップスクリプト
# 使い方: .\setup.ps1

# エラー時に停止
$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Python仮想環境セットアップ" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Python3の存在確認
Write-Host "[1/4] Pythonのバージョンを確認しています..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  ✓ $pythonVersion が見つかりました" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Pythonが見つかりません。Pythonをインストールしてください。" -ForegroundColor Red
    exit 1
}

# 既存のvenv削除確認
if (Test-Path "venv") {
    Write-Host ""
    Write-Host "[2/4] 既存の仮想環境が見つかりました" -ForegroundColor Yellow
    $response = Read-Host "  既存の仮想環境を削除して再作成しますか? (y/N)"
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Host "  既存の仮想環境を削除しています..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force venv
        Write-Host "  ✓ 削除完了" -ForegroundColor Green
    } else {
        Write-Host "  既存の仮想環境を使用します" -ForegroundColor Green
        $skipVenvCreation = $true
    }
} else {
    Write-Host ""
    Write-Host "[2/4] 仮想環境を作成しています..." -ForegroundColor Yellow
}

# 仮想環境の作成
if (-not $skipVenvCreation) {
    try {
        python -m venv venv
        Write-Host "  ✓ 仮想環境の作成が完了しました" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ 仮想環境の作成に失敗しました" -ForegroundColor Red
        Write-Host "  エラー: $_" -ForegroundColor Red
        exit 1
    }
}

# 仮想環境のアクティベート
Write-Host ""
Write-Host "[3/4] 仮想環境をアクティベートしています..." -ForegroundColor Yellow
try {
    & ".\venv\Scripts\Activate.ps1"
    Write-Host "  ✓ 仮想環境がアクティベートされました" -ForegroundColor Green
} catch {
    Write-Host "  ✗ 仮想環境のアクティベートに失敗しました" -ForegroundColor Red
    Write-Host "  PowerShellの実行ポリシーを確認してください:" -ForegroundColor Yellow
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    exit 1
}

# pipのアップグレード
Write-Host "  pipを最新版にアップグレードしています..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet
Write-Host "  ✓ pipのアップグレードが完了しました" -ForegroundColor Green

# requirements.txtからパッケージをインストール
Write-Host ""
Write-Host "[4/4] 依存パッケージをインストールしています..." -ForegroundColor Yellow
if (Test-Path "requirements.txt") {
    try {
        pip install -r requirements.txt
        Write-Host "  ✓ 依存パッケージのインストールが完了しました" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ パッケージのインストールに失敗しました" -ForegroundColor Red
        Write-Host "  エラー: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ! requirements.txtが見つかりません" -ForegroundColor Yellow
    Write-Host "  必要に応じて requirements.txt を作成してください" -ForegroundColor Yellow
}

# 完了メッセージ
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  セットアップが完了しました！" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "次のステップ:" -ForegroundColor Cyan
Write-Host "  1. アプリケーションを実行: .\run.ps1" -ForegroundColor White
Write-Host "  2. 手動で仮想環境に入る: .\venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "  3. 仮想環境を終了: deactivate" -ForegroundColor White
Write-Host ""
