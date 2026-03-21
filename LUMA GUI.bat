@echo off
setlocal EnableDelayedExpansion
title LUMA
cd /d "%~dp0"
chcp 65001 >nul 2>&1
cls
color 06
python "%~dp0src\luma_logo.py"
echo   ----------------------------------------------------
echo.
echo     --  Initializing...
timeout /t 1 /nobreak >nul
echo     --  Loading GUI engine...
timeout /t 1 /nobreak >nul
echo     --  Launching...
echo.
echo   ----------------------------------------------------
echo.
npx electron . 2>nul
if errorlevel 1 (
    color 0C
    echo.
    echo     [!]  LUMA exited with an error.
    echo          Make sure install.bat was run first.
    echo.
    pause >nul
)
