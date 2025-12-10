# ログ設定
$logDir = Join-Path $env:USERPROFILE ".logs"
$logFileName = "YouTubeControl-{0}.log" -f (Get-Date -Format "yyyyMMdd")
$logPath = Join-Path $logDir $logFileName

if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [$Level] $Message" | Out-File -FilePath $logPath -Encoding UTF8 -Append
}

# 管理者権限チェック
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    $msg = "このスクリプトは管理者権限で実行してください。"
    Write-Host $msg -ForegroundColor Red
    Write-Log $msg "ERROR"
    exit 1
}

# 設定ファイルの読み込み
$scriptDir = $PSScriptRoot
$configPath = Join-Path $scriptDir "Config.json"

if (-not (Test-Path $configPath)) {
    $msg = "設定ファイルが見つかりません: $configPath"
    Write-Host $msg -ForegroundColor Red
    Write-Log $msg "ERROR"
    exit 1
}

$config = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

$hostsPath = $config.hostsPath
$hostsBackup = $config.hostsBackup
$markerStart = $config.markerStart
$markerEnd = $config.markerEnd
$blockDomains = $config.blockDomains
$allowMinutes = $config.allowMinutes

Write-Log "Block-YouTube.ps1 started. hosts: $hostsPath"

# 1) バックアップファイルの存在確認
if (-not (Test-Path $hostsBackup)) {
    $msg = "バックアップファイルが見つかりません。既に YouTube はブロックされています。"
    Write-Host $msg -ForegroundColor Yellow
    Write-Log $msg "WARN"
    exit 0
}

# 2) 一時的な hosts ファイルを削除（存在する場合）
if (Test-Path $hostsPath) {
    try {
        Remove-Item -Path $hostsPath -Force -ErrorAction Stop
        Write-Log "一時的な hosts ファイルを削除しました。"
    } catch {
        $msg = "hosts ファイルの削除に失敗しました: $_"
        Write-Host $msg -ForegroundColor Red
        Write-Log $msg "ERROR"
        exit 1
    }
}

# 3) バックアップファイルを元に戻す（hosts.bak → hosts にリネーム）
try {
    Rename-Item -Path $hostsBackup -NewName "hosts" -ErrorAction Stop
    Write-Log "hosts.bak を hosts にリネームしました（元に戻しました）。"
} catch {
    $msg = "hosts.bak のリネームに失敗しました: $_"
    Write-Host $msg -ForegroundColor Red
    Write-Log $msg "ERROR"
    exit 1
}

# 4) DNSキャッシュをクリア（即時反映したい場合）
ipconfig /flushdns | Out-Null
Write-Log "DNS キャッシュをフラッシュしました。"

Write-Host "YouTube を再ブロックしました。"
Write-Log "YouTube ブロックを再適用しました。"
