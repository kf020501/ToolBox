# 移動元と移動先のパスを指定
$sourceFile = "C:\path\to\src_filepath"
$destinationFile = "C:\path\to\tge_filepath"

# Measure-Commandでファイル移動の時間を測定
$executionTime = Measure-Command {
    Move-Item -Path $sourceFile -Destination $destinationFile
}

# 結果を表示
Write-Host "ファイル移動にかかった時間: $($executionTime.TotalSeconds) 秒"
