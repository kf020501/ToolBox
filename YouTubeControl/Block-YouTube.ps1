# 管理者権限で実行すること
$hostsPath    = "$env:SystemRoot\System32\drivers\etc\hosts"
$markerStart  = "# === YouTube BLOCK START ==="
$markerEnd    = "# === YouTube BLOCK END ==="

# hosts を丸ごと読み込み
$content = Get-Content $hostsPath -Raw -ErrorAction Stop

# 既存のブロックセクションを削除（多重追加防止）
if ($content -match [regex]::Escape($markerStart)) {
    $pattern = "$([regex]::Escape($markerStart)).*?$([regex]::Escape($markerEnd))`r?`n?"
    $content = [regex]::Replace($content, $pattern, "", "Singleline")
}

# 追加するブロックセクション
$blockSection = @"
$markerStart
127.0.0.1 youtube.com
127.0.0.1 www.youtube.com
$markerEnd
"@

# 末尾に改行がなければ追加
if (-not $content.TrimEnd().EndsWith("`n")) {
    $content += "`r`n"
}

$content += $blockSection

# hosts を上書き保存（デフォルトは ANSI/ASCII なので Encoding は合わせる）
Set-Content -Path $hostsPath -Value $content -Encoding ASCII

# DNSキャッシュをクリア（即時反映したい場合）
ipconfig /flushdns | Out-Null
