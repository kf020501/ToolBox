@echo off
REM 日付をYYYYMMDD形式で取得
set YYYYMMDD=%DATE:/=%

REM 引数がある場合、フォルダ名に引数を追加
if "%~1"=="" (
    mkdir %YYYYMMDD%
) else (
    mkdir %YYYYMMDD%_%~1%
)
