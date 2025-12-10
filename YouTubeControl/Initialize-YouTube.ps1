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

Write-Log "Initialize-YouTube.ps1 started. hosts: $hostsPath"

# 1) hosts ファイルの存在確認
if (-not (Test-Path $hostsPath)) {
    $msg = "hosts が見つかりません: $hostsPath"
    Write-Host $msg -ForegroundColor Red
    Write-Log $msg "ERROR"
    exit 1
}

# 2) 既にブロックセクションが存在するかチェック
$content = Get-Content $hostsPath -Raw -ErrorAction Stop

if ($content -match [regex]::Escape($markerStart)) {
    $msg = "既に YouTube ブロックセクションが存在します。初期化は不要です。"
    Write-Host $msg -ForegroundColor Yellow
    Write-Log $msg "WARN"
    exit 0
}

# 3) バックアップファイルが存在する場合は警告
if (Test-Path $hostsBackup) {
    $msg = "バックアップファイルが既に存在します。YouTube ブロックが一時解除されている可能性があります。"
    Write-Host $msg -ForegroundColor Yellow
    Write-Log $msg "WARN"

    Write-Host "続行しますか? (Y/N): " -NoNewline
    $response = Read-Host
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Host "初期化を中止しました。"
        Write-Log "ユーザーにより初期化が中止されました。"
        exit 0
    }
}

# 4) ブロックセクションを作成
$blockLines = @()
$blockLines += $markerStart
foreach ($domain in $blockDomains) {
    $blockLines += "127.0.0.1 $domain"
}
$blockLines += $markerEnd

$blockSection = $blockLines -join "`r`n"

# 5) hosts ファイルの末尾にブロックセクションを追加
if (-not $content.TrimEnd().EndsWith("`n")) {
    $content += "`r`n"
}

$content += $blockSection

# 6) hosts を上書き保存
Set-Content -Path $hostsPath -Value $content -Encoding ASCII
Write-Log "YouTube ブロックセクションを追加し、hosts を更新しました。"

# 7) DNSキャッシュをクリア
ipconfig /flushdns | Out-Null
Write-Log "DNS キャッシュをフラッシュしました。"

Write-Host "YouTube ブロックを初期化しました。" -ForegroundColor Green
Write-Host "YouTube がブロックされています。"
Write-Log "初期化が完了しました。"
