<#
.SYNOPSIS
  Windows10/11 に WSL2 + Ubuntu-24.04 を冪等的に自動セットアップ

.DESCRIPTION
  ・管理者権限チェック（インライン）
  ・WSL と VirtualMachinePlatform のみ関数化して有効化
  ・WSL 既定バージョン v2 設定（インライン）
  ・Ubuntu-24.04 が未インストールならのみインストール（直接実行＆$LASTEXITCODE チェック方式）
#>

# 固定ディストリビューション
$distro = "Ubuntu-24.04"
$RebootNeeded = $false

# 管理者権限チェック（インライン）
$current = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($current)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "管理者権限で実行してください。"
    exit 1
}

Write-Host "=== 冪等的 WSL2 + $distro セットアップ ===" -ForegroundColor Cyan

# 機能有効化用の小関数
function Enable-FeatureIfNeeded {
    param([string]$Name)
    $f = Get-WindowsOptionalFeature -Online -FeatureName $Name
    if ($f.State -ne "Enabled") {
        Write-Host "→ 有効化: $Name"
        Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName $Name | Out-Null
        $global:RebootNeeded = $true
    }
    else {
        Write-Host "スキップ: $Name は既に有効です。"
    }
}

# 1) WSL と仮想プラットフォーム機能の有効化
Enable-FeatureIfNeeded -Name "Microsoft-Windows-Subsystem-Linux"
Enable-FeatureIfNeeded -Name "VirtualMachinePlatform"

# 機能有効化後、再起動を要求
if ($RebootNeeded) {
    Write-Host "`n※ 再起動が必要です: 管理者権限で Restart-Computer を実行してください。" -ForegroundColor Yellow
    exit 0
}

# 2) 既定の WSL を v2 に設定
[int]$currentVer = 0
try {
    $status = wsl --status --quiet 2>&1
    if ($status -match "Default Version:\s*(\d+)") { $currentVer = [int]$Matches[1] }
} catch { }
if ($currentVer -eq 2) {
    Write-Host "スキップ: 既定の WSL バージョンは v2 です。"
} else {
    Write-Host "→ 既定の WSL を v2 に設定"
    wsl --set-default-version 2
}

# 3) Ubuntu-24.04 のインストール状況チェック＆インストール
$installedList = @()
try {
    $installedList = wsl --list --quiet 2>$null
} catch {
    Write-Warning "WSL のリスト取得に失敗しました: $($_.Exception.Message)"
}

if ($installedList -split "`r?`n" -contains $distro) {
    Write-Host "スキップ: '$distro' は既にインストール済みです。"
} else {
    Write-Host "→ インストール試行: wsl --install -d $distro"
    & wsl --install -d $distro
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "wsl --install 非対応または失敗: 手動で以下を実行してください：
  wsl --set-default-version 2
  wsl --install -d $distro"
        exit 0
    }
}

Write-Host "`n完了" -ForegroundColor Green
