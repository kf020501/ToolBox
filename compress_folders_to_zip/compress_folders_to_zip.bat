@echo off

SET BasePath=%~dp0
SET ScriptPath=%BasePath%compress_folders_to_zip.py
SET Args=

:loop
IF "%~1"=="" GOTO runScript
SET Args=%Args% "%~1"
SHIFT
GOTO loop

:runScript
python "%ScriptPath%" %Args%

PAUSE
