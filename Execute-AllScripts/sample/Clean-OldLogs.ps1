# 指定された LogDir の存在を確認
if (-not (Test-Path -Path $global:LogDir -PathType Container)) {
    throw "エラー: 指定された LogDir は存在しません: $global:LogDir"
}

# 1週間以上前に作成された .log ファイルを削除
$logFiles = Get-ChildItem -Path $global:LogDir -Filter "*.log"

foreach ($logFile in $logFiles) {
    $fileAge = (Get-Date) - $logFile.CreationTime
    if ($fileAge.TotalDays -ge 7) {
        try {
            Remove-Item -Path $logFile.FullName -Force
            Write-Host "削除しました: $($logFile.FullName)"
        } catch {
            Write-Host "エラー: $($logFile.FullName) の削除中にエラーが発生しました: $_"
        }
    }
}
