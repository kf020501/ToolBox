<#
.SYNOPSIS
  指定ディレクトリに指定サイズ・指定個数のランダムデータファイルを作成するスクリプト

.DESCRIPTION
  コマンドライン引数（-Dir, -Size, -Num）が指定されていれば、そのままファイル作成を実行します。  
  何も指定されなかった場合は、対話式メニューで作成先ディレクトリ、ファイルサイズ（単位指定可）、作成個数を変更し、  
  メニュー上の「0」を選択したタイミングでファイル作成を開始します。

.NOTES
  ・作成ファイル名は "sample_001", "sample_002", … のようにゼロ埋めされます。  
  ・ファイルは10MB（10*1024*1024バイト）ずつのチャンクで作成し、最後に余り（Sizeの端数）を追加します。
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Dir,
    [Parameter(Mandatory=$false)]
    [long]$Size,
    [Parameter(Mandatory=$false)]
    [int]$Num
)

# 初期値設定（パラメータが指定されなかった場合）
if (-not $PSBoundParameters.ContainsKey("Dir")) {
    $Dir = (Get-Location).Path
}
if (-not $PSBoundParameters.ContainsKey("Size")) {
    $Size = 10 * 1024 * 1024    # 10MB
}
if (-not $PSBoundParameters.ContainsKey("Num")) {
    $Num = 10
}

# ファイル作成処理（メイン処理）
function Make-SampleFiles {
    param(
        [string]$Dir,
        [long]$Size,
        [int]$Num
    )

    # 全体の処理開始時刻（ミリ秒単位）
    $startTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss.fff"
    Write-Host "$startTime 処理開始"

    # ゼロ埋め桁数の取得
    $digitCount = ($Num.ToString()).Length

    # 1回あたりの書き込みサイズ（10MB）
    $chunkSize = 10 * 1024 * 1024
    $cnt = [int]([math]::Floor($Size / $chunkSize))
    $sizeFrac = $Size % $chunkSize

    # ランダムバイト生成用のインスタンス作成
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

    for ($i = 1; $i -le $Num; $i++) {
        $fileName = "sample_" + $i.ToString("D$digitCount")
        $filePath = Join-Path $Dir $fileName

        # ファイル作成（既存ファイルは上書き）
        $fs = [System.IO.File]::Open($filePath, [System.IO.FileMode]::Create)
        $totalWritten = 0

        # チャンク単位で書き込み
        for ($j = 1; $j -le $cnt; $j++) {
            $buffer = New-Object byte[] $chunkSize
            $rng.GetBytes($buffer)
            $fs.Write($buffer, 0, $chunkSize)
            $totalWritten += $chunkSize
            
            Write-Progress -Activity "Writing $fileName" `
                           -Status "$totalWritten / $Size bytes" `
                           -PercentComplete (($totalWritten / $Size) * 100)
        }
        # 残り（端数）の書き込み
        if ($sizeFrac -gt 0) {
            $buffer = New-Object byte[] $sizeFrac
            $rng.GetBytes($buffer)
            $fs.Write($buffer, 0, $sizeFrac)
            $totalWritten += $sizeFrac
            Write-Progress -Activity "Writing $fileName" `
                           -Status "$totalWritten / $Size bytes" `
                           -PercentComplete 100
        }
        $fs.Close()

        # 各ファイル完了時刻（ミリ秒単位）
        $finishTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss.fff"
        Write-Host "$finishTime $fileName 完了: "
    }
}

# 対話式メニュー処理を1関数に隔離
function Show-InteractiveMenu {
    param(
        [string]$InitialDir,
        [long]$InitialSize,
        [int]$InitialNum
    )

    $Dir = $InitialDir
    $Size = $InitialSize
    $Num = $InitialNum

    while ($true) {
        Write-Host "----------------------------------------"
        Write-Host "1) 作成先    : $Dir"
        Write-Host ("2) 作成サイズ: {0:N0}" -f $Size)
        Write-Host "3) 作成個数  : $Num"
        Write-Host ""
        Write-Host "0) ファイル作成"
        Write-Host "q) Quit"
        Write-Host "----------------------------------------"
        $choice = Read-Host "番号を入力してください"

        switch ($choice) {
            "1" {
                $inputDir = Read-Host "作成先ディレクトリのパスを入力してください"
                if ($inputDir) { $Dir = $inputDir }
            }
            "2" {
                $unit = Read-Host "容量単位を入力してください [B/KB/MB/GB/TB]:"
                if ($unit) {
                    $unitList = @{ "B" = 0; "KB" = 1; "MB" = 2; "GB" = 3; "TB" = 4 }
                    if ($unitList.ContainsKey($unit)) {
                        $exp = $unitList[$unit]
                    } else {
                        $exp = 0
                    }
                    $sizeInput = Read-Host "サイズを入力してください (数字)"
                    $sInt = 0
                    if ([int]::TryParse($sizeInput, [ref]$sInt)) {
                        $coe = [math]::Pow(1024, $exp)
                        $Size = [long]($sInt * $coe)
                        Write-Host "$sizeInput x 1024^$exp = $Size"
                    }
                }
            }
            "3" {
                $numInput = Read-Host "作成個数を入力してください"
                $nInt = 0
                if ([int]::TryParse($numInput, [ref]$nInt)) {
                    $Num = $nInt
                }
            }
            "0" {
                Make-SampleFiles -Dir $Dir -Size $Size -Num $Num
                break
            }
            "q" {
                exit
            }
            default {
                Write-Host "対応する数字を入力して下さい"
                Start-Sleep -Milliseconds 100
            }
        }
    }
}

# パラメータが指定されなかった場合は対話式メニューを表示
if ($PSBoundParameters.Count -eq 0) {
    Show-InteractiveMenu -InitialDir $Dir -InitialSize $Size -InitialNum $Num
}
else {
    Make-SampleFiles -Dir $Dir -Size $Size -Num $Num
}
