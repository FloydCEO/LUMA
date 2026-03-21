@echo off
setlocal EnableDelayedExpansion
title LUMA Installer

set "LUMA_DIR=%~dp0"
set "ERRORS=0"
set "FFMPEG_MANUAL=0"
set "NODE_MANUAL=0"

call :print_logo
call :check_admin

echo.
echo   ============================================================
echo     STARTING DEPENDENCY INSTALLATION
echo   ============================================================
echo.
echo   LUMA needs:  Python  pip packages  ffmpeg  Node.js  Electron
echo.
echo   ------------------------------------------------------------
echo.

call :step_python
call :step_pip
call :step_colorama
call :step_requests
call :step_ffmpeg
call :step_nodejs
call :step_electron

echo.
echo   ------------------------------------------------------------
call :finish
endlocal
exit /b 0


:print_logo
cls
chcp 65001 >nul 2>&1
color 06
python "%LUMA_DIR%src\luma_logo.py" 2>nul
if errorlevel 1 (
    echo.
    echo    ============================================
    echo      L  U  M  A  --  Lyko's Universal Media Adapter
    echo      Installer v3.0
    echo    ============================================
    echo.
)
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
echo   ^|  STEP %~1 / 7  --  %~2
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


:step_nodejs
call :step_banner "6" "Node.js  (required for GUI)"
node --version >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=*" %%v in ('node --version 2^>^&1') do set NODEVER=%%v
    call :ok "Already installed  (!NODEVER!)"
    goto :eof
)
call :warn "Node.js not found -- trying auto-install..."
echo.

echo   [ 1/2 ]  Trying winget...
winget --version >nul 2>&1
if errorlevel 1 (
    call :info "winget not available -- skipping"
    goto :node_choco
)
winget install --id OpenJS.NodeJS.LTS -e --silent --accept-source-agreements --accept-package-agreements
timeout /t 3 /nobreak >nul
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYS_PATH=%%b"
for /f "skip=2 tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USR_PATH=%%b"
set "PATH=!SYS_PATH!;!USR_PATH!;%LUMA_DIR%"
node --version >nul 2>&1
if not errorlevel 1 (
    call :ok "Node.js installed via winget!"
    goto :eof
)
call :warn "winget ran but Node not in PATH yet -- may need a restart"
echo.

:node_choco
echo   [ 2/2 ]  Trying Chocolatey...
where choco >nul 2>&1
if errorlevel 1 (
    call :info "Chocolatey not installed -- skipping"
    goto :node_manual
)
choco install nodejs-lts -y --no-progress
node --version >nul 2>&1
if not errorlevel 1 (
    call :ok "Node.js installed via Chocolatey!"
    goto :eof
)
call :warn "Chocolatey method failed"

:node_manual
set NODE_MANUAL=1
set /a ERRORS+=1
echo.
echo   Could not auto-install Node.js.
echo   To fix this manually:
echo.
echo     1. Go to https://nodejs.org
echo     2. Download the LTS installer and run it
echo     3. Re-run this installer after.
echo.
echo   The terminal version of LUMA (luma.py) still works without Node.
echo.
goto :eof


:step_electron
call :step_banner "7" "Electron  (GUI framework)"
node --version >nul 2>&1
if errorlevel 1 (
    call :warn "Skipping Electron -- Node.js not available"
    goto :eof
)

if exist "%LUMA_DIR%node_modules\electron" (
    call :ok "Electron already installed"
    goto :eof
)

if not exist "%LUMA_DIR%package.json" (
    call :warn "package.json not found in LUMA folder -- skipping Electron"
    call :info "Make sure package.json is in the same folder as this installer"
    goto :eof
)

call :info "Installing Electron (this may take a minute)..."
cd /d "%LUMA_DIR%"
npm install --save-dev electron --quiet 2>nul
if errorlevel 1 (
    call :fail "Electron install failed -- try running:  npm install --save-dev electron"
    call :info "Run from the LUMA folder in a terminal window"
) else (
    call :ok "Electron installed successfully"
)
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
    call :make_shortcut
    echo   Launching LUMA GUI in 3 seconds...
    timeout /t 3 /nobreak >nul
    cd /d "%LUMA_DIR%"
    npx electron .
) else (
    color 0E
    echo   +============================================================+
    echo   ^|                                                            ^|
    echo   ^|    SETUP FINISHED WITH ISSUES -- see above for details     ^|
    echo   ^|                                                            ^|
    echo   +============================================================+
    echo.
    if !FFMPEG_MANUAL! EQU 1 (
        echo   ffmpeg must be installed manually -- see instructions above.
    )
    if !NODE_MANUAL! EQU 1 (
        echo   Node.js must be installed manually -- see instructions above.
        echo   Without it the GUI won't run, but luma.py still works.
    )
    echo.
    echo   Once fixed, run LUMA GUI.bat for the GUI
    echo   or run_luma.bat for the terminal version.
    echo.
    pause
)
goto :eof


:make_shortcut
call :info "Creating desktop shortcut..."
set "SC_TARGET=cmd.exe"
set "SC_ARGS=/c \"%LUMA_DIR%LUMA GUI.bat\""
set "SC_ICON=%LUMA_DIR%src\favicon.ico"
set "SC_DEST=%USERPROFILE%\Desktop\LUMA.lnk"
powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut($env:SC_DEST); $sc.TargetPath = 'cmd.exe'; $sc.Arguments = '/c \"' + $env:LUMA_DIR + 'LUMA GUI.bat\"'; $sc.WorkingDirectory = $env:LUMA_DIR; $sc.Description = 'LUMA - Lyko''s Universal Media Adapter'; $sc.WindowStyle = 7; if (Test-Path $env:SC_ICON) { $sc.IconLocation = $env:SC_ICON }; $sc.Save()" >nul 2>&1
if exist "%SC_DEST%" (
    call :ok "Desktop shortcut created"
) else (
    call :warn "Could not create shortcut -- you can make one manually"
)
goto :eof
) else (
    call :warn "Could not create shortcut -- you can make one manually"
)
goto :eof
