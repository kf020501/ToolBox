@echo off

SET BasePath=%~dp0
SET ScriptPath=%BasePath%backup_file.py

python "%ScriptPath%" %*

echo Process completed. The window will close in 20 seconds...
timeout /t 20 /nobreak > nul