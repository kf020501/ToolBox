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

# このスクリプトが存在するフォルダを基準に Block-YouTube.ps1 を探す
$blockScriptPath = Join-Path $scriptDir "Block-YouTube.ps1"

Write-Log "Allow-YouTube.ps1 started. hosts: $hostsPath"

# 1) hosts ファイルの存在確認
if (-not (Test-Path $hostsPath)) {
    $msg = "hosts が見つかりません: $hostsPath"
    Write-Host $msg -ForegroundColor Red
    Write-Log $msg "ERROR"
    exit 1
}

# 2) バックアップファイルが既に存在する場合は警告
if (Test-Path $hostsBackup) {
    $msg = "既に YouTube ブロックは解除されています。（バックアップファイルが存在します）"
    Write-Host $msg -ForegroundColor Yellow
    Write-Log $msg "WARN"
    exit 0
}

# 3) 元ファイルを hosts.bak にリネーム（バックアップ）
try {
    Rename-Item -Path $hostsPath -NewName "hosts.bak" -ErrorAction Stop
    Write-Log "hosts を hosts.bak にリネームしました（バックアップ）。"
} catch {
    $msg = "hosts のリネームに失敗しました: $_"
    Write-Host $msg -ForegroundColor Red
    Write-Log $msg "ERROR"
    exit 1
}

# 4) バックアップファイルからブロックセクションを削除した内容を新しい hosts として配置
$content = Get-Content $hostsBackup -Raw -ErrorAction Stop

$startIndex = $content.IndexOf($markerStart, [System.StringComparison]::Ordinal)
$endIndex   = -1
if ($startIndex -ge 0) {
    $endIndex = $content.IndexOf($markerEnd, $startIndex, [System.StringComparison]::Ordinal)
}

if ($startIndex -ge 0 -and $endIndex -ge 0) {
    $endIndex += $markerEnd.Length

    # マーカー直後の連続した改行も削除
    while ($endIndex -lt $content.Length -and ($content[$endIndex] -eq "`n" -or $content[$endIndex] -eq "`r")) {
        $endIndex++
    }

    $newContent = $content.Remove($startIndex, $endIndex - $startIndex)

    if ([string]::IsNullOrWhiteSpace($newContent)) {
        $msg = "除去後の hosts 内容が空のため書き込みを中止しました。"
        Write-Host $msg -ForegroundColor Yellow
        Write-Log $msg "ERROR"
        # バックアップを元に戻す
        Rename-Item -Path $hostsBackup -NewName "hosts" -ErrorAction SilentlyContinue
        exit 1
    }

    Set-Content -Path $hostsPath -Value $newContent -Encoding ASCII

    ipconfig /flushdns | Out-Null

    Write-Host "YouTube ブロックを解除しました。"
    Write-Log "YouTube ブロックセクションを削除した hosts を配置しました。"
} else {
    # ブロックセクションがない場合は、そのままコピー
    Copy-Item -Path $hostsBackup -Destination $hostsPath -Force
    ipconfig /flushdns | Out-Null

    $msg = "ブロックセクションが見つかりませんでした。元のファイルをそのまま配置しました。"
    Write-Host $msg
    Write-Log $msg "WARN"
}

# 2) 指定時間後に再ブロックするタスクを登録
$minutes = $allowMinutes
$triggerTime = (Get-Date).AddMinutes($minutes)
$timeStr = $triggerTime.ToString("HH:mm")
$dateStr = $triggerTime.ToString("yyyy/MM/dd")

$taskName = "ReBlockYouTube"

# 同名タスク削除
schtasks /Delete /TN $taskName /F 2>$null | Out-Null

# ▼ スクリプトのある場所の Block-YouTube.ps1 を実行
$taskCmd = "powershell.exe -ExecutionPolicy Bypass -File `"$blockScriptPath`""

$createResult = schtasks /Create `
    /SC ONCE `
    /TN $taskName `
    /TR $taskCmd `
    /ST $timeStr `
    /SD $dateStr `
    /RL HIGHEST `
    /F 2>&1

if ($LASTEXITCODE -ne 0) {
    $msg = "タスク登録に失敗しました: $createResult"
    Write-Host $msg -ForegroundColor Red
    Write-Log $msg "ERROR"
    exit 1
}

Write-Host "YouTube は $minutes 分だけ解放されます。"
Write-Host "$($triggerTime.ToString("yyyy/MM/dd HH:mm")) に自動で再ブロックされます。"
Write-Log "タスク $taskName を登録しました。実行予定: $($triggerTime.ToString("yyyy/MM/dd HH:mm"))"
