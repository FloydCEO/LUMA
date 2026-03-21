@echo off
title LUMA -- Lyko's Universal Media Adapter
chcp 65001 >nul 2>&1
set "PATH=%~dp0;%PATH%"
cls
color 06
python "%~dp0src\luma_logo.py"
echo   ----------------------------------------------------
echo.
python "%~dp0src\luma.py"
if errorlevel 1 (
    echo.
    echo   [!] LUMA exited with an error. Press any key to close.
    pause >nul
)
