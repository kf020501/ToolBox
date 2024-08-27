# コマンドライン引数の処理
param (
    [string]$ScriptDir,
    [string]$LogDir
)

# 引数が不足しているか確認
if (-not $ScriptDir -or -not $LogDir) {
    Write-Host "Error: 必要な引数が不足しています。"
    Write-Host ""
    Write-Host "使用方法: .\Execute-AllScripts.ps1 -ScriptDir <スクリプトのパス> -LogDir <ログ保存先のパス>"
    Write-Host ""
    Write-Host "パラメータ:"
    Write-Host "  -ScriptDir: 実行する .ps1 ファイルが含まれているディレクトリのパスを指定します。"
    Write-Host "  -LogDir   : ログを保存するディレクトリのパスを指定します。"
    Write-Host ""
    throw "ScriptDir と LogDir の両方のパラメータを指定してください。"
}

# ScriptDirの存在確認とエラーハンドリング
if (-not (Test-Path -Path $ScriptDir -PathType Container)) {
    throw "Error: 指定された ScriptDir は存在しません: $ScriptDir"
}

# グローバルスコープで変数を定義
$global:ScriptDir = $ScriptDir
$global:LogDir = $LogDir

# ログディレクトリが存在しない場合は作成
if (-not (Test-Path -Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir
}

# タイムスタンプを生成 (YYYY-MM-DD_hhmmss形式)
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

# 指定したディレクトリ配下のすべての.ps1ファイルを取得
$ps1Files = Get-ChildItem -Path $ScriptDir -Recurse -Filter "*.ps1"

# 各.ps1ファイルを実行し、ログを出力
foreach ($file in $ps1Files) {
    # ログファイル名を生成
    $logFileName = "${timestamp}_$($file.BaseName).log"
    $logFilePath = Join-Path -Path $LogDir -ChildPath $logFileName

    Write-Host "実行中: $($file.FullName) のログを $logFilePath に出力中"
    
    try {
        # スクリプトの実行結果をログファイルにリダイレクト
        & $file.FullName *>> $logFilePath
    } catch {
        Write-Host "Error: $($file.FullName) の実行中にエラーが発生しました: $_"
        # エラーメッセージもログファイルに追加
        "Error: $_" *>> $logFilePath
    }
}
