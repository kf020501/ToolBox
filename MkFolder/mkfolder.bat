@echo off
REM ���t��YYYYMMDD�`���Ŏ擾
set YYYYMMDD=%DATE:/=%

REM ����������ꍇ�A�t�H���_���Ɉ�����ǉ�
if "%~1"=="" (
    mkdir %YYYYMMDD%
) else (
    mkdir %YYYYMMDD%_%~1%
)
