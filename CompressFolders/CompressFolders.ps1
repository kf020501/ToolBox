$FolderPaths = $Args

# 引数が指定されていない場合のチェック
if (-not $FolderPaths) {
    Write-Host "フォルダパスを指定してください。" -ForegroundColor Yellow
    exit
}

foreach ($FolderPath in $FolderPaths) {
    # フォルダの存在確認
    if ((Test-Path $FolderPath) -and ((Get-Item $FolderPath).PSIsContainer)) {
        # 圧縮先のZIPファイル名を決定
        $ParentPath = Split-Path -Path $FolderPath -Parent
        $FolderName = Split-Path -Path $FolderPath -Leaf
        $ZipPath = Join-Path -Path $ParentPath -ChildPath "$FolderName.zip"

        # フォルダを圧縮
        try {
            Compress-Archive -Path (Join-Path $FolderPath '*') -DestinationPath $ZipPath -Force
            Write-Host "フォルダ '$FolderPath' を '$ZipPath' に圧縮しました。"
        } catch {
            Write-Host "エラー: フォルダ '$FolderPath' を圧縮できませんでした。$($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "フォルダ '$FolderPath' が存在しないか、有効なフォルダではありません。" -ForegroundColor Yellow
    }
}
