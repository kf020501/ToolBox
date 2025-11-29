# 管理者権限チェック
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "このスクリプトは管理者権限で実行してください。" -ForegroundColor Red
    exit 1
}

# 管理者権限で実行すること
$hostsPath    = "$env:SystemRoot\System32\drivers\etc\hosts"
$markerStart  = "# === YouTube BLOCK START ==="
$markerEnd    = "# === YouTube BLOCK END ==="

# このスクリプトが存在するフォルダを基準に Block-YouTube.ps1 を探す
$scriptDir = $PSScriptRoot
$blockScriptPath = Join-Path $scriptDir "Block-YouTube.ps1"

# 1) hosts からブロックセクションだけ削除（＝一時的に解除）
if (Test-Path $hostsPath) {
    $content = Get-Content $hostsPath -Raw -ErrorAction Stop

    if ($content -match [regex]::Escape($markerStart)) {
        $pattern = "$([regex]::Escape($markerStart)).*?$([regex]::Escape($markerEnd))`r?`n?"
        $content = [regex]::Replace($content, $pattern, "", "Singleline")

        Set-Content -Path $hostsPath -Value $content -Encoding ASCII

        ipconfig /flushdns | Out-Null

        Write-Host "YouTube ブロックを解除しました。"
    }
}

# 2) 30分後に再ブロックするタスクを登録
$minutes = 30
$triggerTime = (Get-Date).AddMinutes($minutes)
$timeStr = $triggerTime.ToString("HH:mm")
$dateStr = $triggerTime.ToString("yyyy/MM/dd")

$taskName = "ReBlockYouTube"

# 同名タスク削除
schtasks /Delete /TN $taskName /F 2>$null | Out-Null

# ▼ スクリプトのある場所の Block-YouTube.ps1 を実行
$taskCmd = "powershell.exe -ExecutionPolicy Bypass -File `"$blockScriptPath`""

schtasks /Create `
    /SC ONCE `
    /TN $taskName `
    /TR $taskCmd `
    /ST $timeStr `
    /SD $dateStr `
    /RL HIGHEST `
    /F | Out-Null

Write-Host "YouTube は $minutes 分だけ解放されます。"
Write-Host "$($triggerTime.ToString("yyyy/MM/dd HH:mm")) に自動で再ブロックされます。"