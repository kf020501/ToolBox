function Write-Log($msg){
    Write-Host $msg
}

#
# Excelの準備
#

# オブジェクトの作成（Excelの起動）
$excel = New-Object -ComObject Excel.Application

# Excelを表示？警告メッセージを表示？
$excel.Visible = $false
$excel.DisplayAlerts = $true

# 新しいExcelワークブックを開く
$book = $excel.Workbooks.Add()

#
# 各イベントログの処理
#

foreach($logPath in $Args){

    # イベントログの内容を抽出
    Write-Log "$logPath の内容を取得します"
    $events = (Get-WinEvent -Path $logPath | Select-Object -Property TimeCreated,LogName,Level,Id,ProviderName,Message)

    # イベントが空の場合、次のlogPathに進む
    if($events -eq $null -or $events.Count -eq 0) {
        continue
    }

    Write-Log "Excelに書き込みます"

    # ファイル名をシート名として使用
    $sheetName = [System.IO.Path]::GetFileName($logPath)
    $sheet = $book.Worksheets.Add()
    $sheet.Name = $sheetName

    # 最初のイベントからすべてのプロパティ名を取得
    $propertyNames = $events[0].PSObject.Properties.Name

    # 列ヘッダーを書き込み
    $col = 1
    foreach ($name in $propertyNames) {
        $sheet.Cells.Item(1, $col) = $name
        $col++
    }

    # 抽出した内容をシートに書き込み
    $row = 2 # 2行目から開始
    foreach ($event in $events) {
        $col = 1
        foreach ($name in $propertyNames) {
            $sheet.Cells.Item($row, $col) = $event.$name
            $col++
        }
        $row++
    }

    # シートの列を自動サイズ調整
    $sheet.UsedRange.EntireColumn.AutoFit()
}

#
# Excelの保存
#

# イベントログと同じディレクトリにExcelを保存
# ファイル名の形式 "WinEventLog_YYYYMMDD"
$savePath = (Split-Path -Path $logPath -Parent) + "\WinEventLog_" + (Get-Date -Format "yyyyMMdd") + ".xlsx"
$book.SaveAs($savePath)
$excel.Quit()
