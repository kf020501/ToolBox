@echo off

SET BasePath=%~dp0
SET PowerShellScriptPath=%BasePath%Allow-YouTube.ps1
SET Args=

:loop
IF "%~1"=="" GOTO runScript
SET Args=%Args% "%~1"
SHIFT
GOTO loop

:runScript
PowerShell -File "%PowerShellScriptPath%" %Args%

echo The window will close in 20 seconds...
timeout /t 20 /nobreak > nul
