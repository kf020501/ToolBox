@echo off
REM このバッチファイルは、ドラッグアンドドロップされたすべてのファイルパスを収集し、一度にPowerShellスクリプトに渡します。

SET BasePath=%~dp0
SET PowerShellScriptPath=%BasePath%CompressFolders.ps1
SET Args=

:loop
IF "%~1"=="" GOTO runScript
SET Args=%Args% "%~1"
SHIFT
GOTO loop

:runScript
PowerShell -File "%PowerShellScriptPath%" %Args%

PAUSE
