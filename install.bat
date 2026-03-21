@echo off
setlocal EnableDelayedExpansion
title LUMA Installer

set "LUMA_DIR=%~dp0"
set "ERRORS=0"
set "FFMPEG_MANUAL=0"

call :print_logo
call :check_admin

echo.
echo   ============================================================
echo     STARTING DEPENDENCY INSTALLATION
echo   ============================================================
echo.
echo   LUMA needs 3 things:  Python  pip packages  ffmpeg
echo.
echo   ------------------------------------------------------------
echo.

call :step_python
call :step_pip
call :step_colorama
call :step_requests
call :step_ffmpeg

echo.
echo   ------------------------------------------------------------
call :finish
endlocal
exit /b 0


:print_logo
cls
echo.
echo    ============================================
echo    ##                                        ##
echo    ##        L   U   M   A                   ##
echo    ##                                        ##
echo    ##    Lyko's Universal Media Adapter      ##
echo    ##           Installer  v2.0              ##
echo    ##                                        ##
echo    ============================================
echo.
goto :eof


:ok
echo   [  OK  ]  %~1
goto :eof

:warn
echo   [ WARN ]  %~1
goto :eof

:fail
echo   [ FAIL ]  %~1
set /a ERRORS+=1
goto :eof

:info
echo   [  ..  ]  %~1
goto :eof

:step_banner
echo.
echo   +----------------------------------------------------------+
echo   ^|  STEP %~1 / 5  --  %~2
echo   +----------------------------------------------------------+
echo.
goto :eof


:check_admin
net session >nul 2>&1
if errorlevel 1 (
    echo.
    echo   +============================================================+
    echo   ^|                                                            ^|
    echo   ^|    ERROR: Not running as Administrator                     ^|
    echo   ^|                                                            ^|
    echo   ^|    Close this, right-click install.bat,                    ^|
    echo   ^|    and choose "Run as administrator"                       ^|
    echo   ^|                                                            ^|
    echo   +============================================================+
    echo.
    pause
    exit /b 1
)
call :ok "Running as Administrator"
goto :eof


:step_python
call :step_banner "1" "Python 3.8+"
python --version >nul 2>&1
if errorlevel 1 (
    call :fail "Python not found in PATH"
    echo.
    echo   Python is REQUIRED. LUMA cannot run without it.
    echo.
    echo   1. Go to https://www.python.org/downloads
    echo   2. Download Python 3.8 or newer
    echo   3. IMPORTANT: check "Add Python to PATH" during install
    echo   4. Re-run this file after installing.
    echo.
    pause
    exit /b 1
)
for /f "tokens=*" %%v in ('python --version 2^>^&1') do set PYVER=%%v
call :ok "Found: !PYVER!"
for /f "tokens=2 delims= " %%v in ('python --version 2^>^&1') do set PYVER_NUM=%%v
set PY_MAJOR=!PYVER_NUM:~0,1!
for /f "tokens=2 delims=." %%m in ("!PYVER_NUM!") do set PY_MINOR=%%m
if !PY_MAJOR! LSS 3 (
    call :warn "Python 2 detected -- LUMA requires Python 3.8+"
    pause
    exit /b 1
)
if !PY_MAJOR! EQU 3 if !PY_MINOR! LSS 8 (
    call :warn "Python 3.!PY_MINOR! is old -- recommend upgrading to 3.8+"
)
goto :eof


:step_pip
call :step_banner "2" "pip  (package manager)"
python -m pip --version >nul 2>&1
if errorlevel 1 (
    call :warn "pip not found -- bootstrapping..."
    python -m ensurepip --upgrade >nul 2>&1
    python -m pip --version >nul 2>&1
    if errorlevel 1 (
        call :fail "Could not install pip automatically"
        call :info "Try manually:  python -m ensurepip --upgrade"
        goto :eof
    )
    call :ok "pip bootstrapped successfully"
) else (
    for /f "tokens=*" %%v in ('python -m pip --version 2^>^&1') do set PIPVER=%%v
    call :ok "Found: !PIPVER!"
)
call :info "Upgrading pip..."
python -m pip install --upgrade pip --quiet --no-warn-script-location >nul 2>&1
call :ok "pip is up to date"
goto :eof


:step_colorama
call :step_banner "3" "colorama  (terminal colors)"
pip show colorama >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=2" %%v in ('pip show colorama 2^>nul ^| findstr /i "^Version"') do set VER=%%v
    call :ok "Already installed  (v!VER!)"
    goto :eof
)
call :info "Installing colorama..."
pip install colorama --quiet --no-warn-script-location
if errorlevel 1 (
    call :fail "colorama install failed -- try:  pip install colorama"
) else (
    call :ok "colorama installed successfully"
)
goto :eof


:step_requests
call :step_banner "4" "requests  (optional)"
pip show requests >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=2" %%v in ('pip show requests 2^>nul ^| findstr /i "^Version"') do set VER=%%v
    call :ok "Already installed  (v!VER!)"
    goto :eof
)
call :info "Installing requests..."
pip install requests --quiet --no-warn-script-location
if errorlevel 1 (
    call :warn "requests failed (optional -- LUMA still works without it)"
) else (
    call :ok "requests installed successfully"
)
goto :eof


:step_ffmpeg
call :step_banner "5" "ffmpeg  (media engine -- REQUIRED)"
ffmpeg -version >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=3" %%v in ('ffmpeg -version 2^>^&1 ^| findstr /i "ffmpeg version"') do set FFVER=%%v
    call :ok "Already installed  (version !FFVER!)"
    goto :eof
)
if exist "%LUMA_DIR%ffmpeg.exe" (
    call :ok "Found ffmpeg.exe in LUMA folder -- using it"
    set "PATH=%LUMA_DIR%;%PATH%"
    goto :eof
)
call :warn "ffmpeg not found -- trying auto-install methods..."
echo.

echo   [ 1/3 ]  Trying winget...
winget --version >nul 2>&1
if errorlevel 1 (
    call :info "winget not available -- skipping"
    goto :try_choco
)
winget install --id Gyan.FFmpeg -e --silent --accept-source-agreements --accept-package-agreements
timeout /t 2 /nobreak >nul
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYS_PATH=%%b"
for /f "skip=2 tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USR_PATH=%%b"
set "PATH=!SYS_PATH!;!USR_PATH!;%LUMA_DIR%"
ffmpeg -version >nul 2>&1
if not errorlevel 1 (
    call :ok "ffmpeg installed via winget!"
    goto :eof
)
call :warn "winget ran but ffmpeg not in PATH yet -- may need a restart"
echo.

:try_choco
echo   [ 2/3 ]  Trying Chocolatey...
where choco >nul 2>&1
if errorlevel 1 (
    call :info "Chocolatey not installed -- skipping"
    goto :try_scoop
)
choco install ffmpeg -y --no-progress
ffmpeg -version >nul 2>&1
if not errorlevel 1 (
    call :ok "ffmpeg installed via Chocolatey!"
    goto :eof
)
call :warn "Chocolatey method failed"
echo.

:try_scoop
echo   [ 3/3 ]  Trying Scoop...
where scoop >nul 2>&1
if errorlevel 1 (
    call :info "Scoop not installed -- all auto-methods exhausted"
    goto :ffmpeg_manual
)
scoop install ffmpeg
ffmpeg -version >nul 2>&1
if not errorlevel 1 (
    call :ok "ffmpeg installed via Scoop!"
    goto :eof
)
call :warn "Scoop method failed"

:ffmpeg_manual
set FFMPEG_MANUAL=1
set /a ERRORS+=1
echo.
echo   All 3 auto-install methods failed.
echo   To fix this manually, open PowerShell as Admin and run:
echo.
echo       winget install Gyan.FFmpeg
echo.
echo   Or download ffmpeg.exe from https://ffmpeg.org/download.html
echo   and place it in your LUMA folder, then re-run this installer.
echo.
goto :eof


:finish
echo.
if !ERRORS! EQU 0 (
    color 0A
    echo   +============================================================+
    echo   ^|                                                            ^|
    echo   ^|    ALL STEPS PASSED  --  LUMA is ready to run!            ^|
    echo   ^|                                                            ^|
    echo   +============================================================+
    echo.
    echo   Launching LUMA in 3 seconds...
    timeout /t 3 /nobreak >nul
    python "%LUMA_DIR%luma.py"
) else (
    color 0E
    echo   +============================================================+
    echo   ^|                                                            ^|
    echo   ^|    SETUP FINISHED WITH ISSUES -- see above for details     ^|
    echo   ^|                                                            ^|
    echo   +============================================================+
    echo.
    if !FFMPEG_MANUAL! EQU 1 (
        echo   ffmpeg must be installed manually.
        echo   See instructions above, then run run_luma.bat to launch.
    ) else (
        echo   Review warnings above and re-run if needed.
        echo   Most warnings are non-critical -- try run_luma.bat anyway.
    )
    echo.
    pause
)
goto :eof