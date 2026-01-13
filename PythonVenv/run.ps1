# Python仮想環境実行スクリプト
# 使い方: .\run.ps1 [引数...]

# エラー時に停止
$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Pythonアプリケーション実行" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# 仮想環境の存在確認
if (-not (Test-Path ".venv")) {
    Write-Host "✗ 仮想環境が見つかりません" -ForegroundColor Red
    Write-Host ""
    Write-Host "最初にセットアップを実行してください:" -ForegroundColor Yellow
    Write-Host "  .\setup.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}

# main.pyの存在確認
if (-not (Test-Path "src\main.py")) {
    Write-Host "✗ src\main.py が見つかりません" -ForegroundColor Red
    Write-Host ""
    Write-Host "src\main.py を作成してください" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# 仮想環境をアクティベート
Write-Host "仮想環境をアクティベートしています..." -ForegroundColor Yellow
try {
    & ".\.venv\Scripts\Activate.ps1"
    Write-Host "✓ 仮想環境がアクティベートされました" -ForegroundColor Green
} catch {
    Write-Host "✗ 仮想環境のアクティベートに失敗しました" -ForegroundColor Red
    Write-Host ""
    Write-Host "PowerShellの実行ポリシーを確認してください:" -ForegroundColor Yellow
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Pythonスクリプトを実行
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  アプリケーション実行中..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

try {
    # コマンドライン引数を全て渡す
    if ($args.Count -gt 0) {
        python src\main.py @args
    } else {
        python src\main.py
    }
    $exitCode = $LASTEXITCODE
} catch {
    Write-Host ""
    Write-Host "✗ アプリケーションの実行中にエラーが発生しました" -ForegroundColor Red
    Write-Host "  エラー: $_" -ForegroundColor Red
    exit 1
}

# 実行結果の表示
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
if ($exitCode -eq 0) {
    Write-Host "  実行が完了しました (終了コード: $exitCode)" -ForegroundColor Green
} else {
    Write-Host "  実行が完了しました (終了コード: $exitCode)" -ForegroundColor Yellow
}
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# 仮想環境を終了
deactivate

exit $exitCode
