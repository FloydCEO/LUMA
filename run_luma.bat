@echo off
title LUMA -- Lyko's Universal Media Adapter
chcp 65001 >nul 2>&1

:: Add the LUMA folder itself to PATH so ffmpeg.exe works if placed here
set "PATH=%~dp0;%PATH%"

python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo   [ERROR] Python not found.
    echo   Run install.bat first, or download Python from:
    echo   https://www.python.org/downloads
    echo   Make sure to check "Add Python to PATH" during install.
    echo.
    pause
    exit /b 1
)

python "%~dp0luma.py"

:: BUG FIX #10: Only pause on error (non-zero exit), not on clean Goodbye exit.
:: Previously the window always froze after LUMA said "Goodbye!" which was confusing.
if errorlevel 1 (
    echo.
    echo   [!] LUMA exited with an error. Press any key to close.
    pause >nul
)
