<p align="center">
  <img src="src/Luma.png" alt="LUMA" width="560"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.1-ffb000?style=flat-square&labelColor=0a0a06&color=ffb000"/>
  <img src="https://img.shields.io/badge/🪟 Windows-supported-ffb000?style=flat-square&labelColor=0a0a06&color=ffb000"/>
  <img src="https://img.shields.io/badge/🍎 macOS-supported-ffb000?style=flat-square&labelColor=0a0a06&color=ffb000"/>
  <img src="https://img.shields.io/badge/🐧 Linux-supported-ffb000?style=flat-square&labelColor=0a0a06&color=ffb000"/>
  <img src="https://img.shields.io/badge/powered%20by-ffmpeg-ffb000?style=flat-square&labelColor=0a0a06&color=ffb000"/>
  <img src="https://img.shields.io/badge/license-MIT-ffb000?style=flat-square&labelColor=0a0a06&color=ffb000"/>
</p>

<p align="center"><em>Local media conversion. No uploads. No rate limits. No paywalls.</em></p>

---

i made this because i was tired of using sketchy websites every time i needed to convert a file — ones that either watermark your output, cap you at a few conversions a day, or charge you for anything above 360p. LUMA runs entirely on your machine, powered by ffmpeg under the hood. your files never go anywhere.

it comes in two flavors — a GUI built with Electron that looks sick, and a terminal version if you prefer that.

<br>

## features

- **video** — mp4, mkv, avi, mov, webm, flv, wmv, m4v, ts, gif
- **audio** — mp3, wav, flac, ogg, opus, aac, m4a, wma, aiff
- **image** — jpg, png, webp, bmp, tiff, ico, gif
- **batch convert** — entire folders at once
- lossless passthrough where possible — wav → ogg → wav sounds identical
- quality presets for video (fast / balanced / high)
- drag & drop files directly into the GUI
- save dialog lets you pick exactly where the output goes
- originals are never touched — output gets `_luma` appended

<br>

## requirements

| Requirement | Version | Notes |
|---|---|---|
| [Python](https://www.python.org/downloads/) | 3.8+ | check **"Add Python to PATH"** during install (Windows) |
| [Node.js](https://nodejs.org) | LTS | required for the GUI only |
| ffmpeg | any | installer handles this automatically on all platforms |

<br>

## getting started

### 🪟 Windows

**1. run the installer**
```
install.bat  (right-click → Run as administrator)
```
this checks all dependencies, installs anything missing, sets up Electron, creates a desktop shortcut, and launches LUMA automatically when done.

**2. launch anytime after**

| File | What it does |
|---|---|
| `LUMA GUI.bat` | opens the GUI |
| `bash-luma.bat` | opens the terminal version |

<br>

### 🍎 macOS

**1. open Terminal** — press `Cmd + Space`, type `Terminal`, hit Enter

**2. navigate to the LUMA folder**
```bash
cd /path/to/LUMA
```
> tip: type `cd ` then drag the LUMA folder into the Terminal window — it fills the path automatically

**3. run the installer**
```bash
bash install.sh
```
this installs ffmpeg (via Homebrew or MacPorts if available), Node.js, Electron, and all Python dependencies automatically.

> **don't have Homebrew?** the installer will tell you — or you can install it yourself first:
> ```bash
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> ```

**4. launch anytime after**

| File | What it does |
|---|---|
| `bash 'LUMA GUI.sh'` | opens the GUI |
| `bash luma.sh` | opens the terminal version |

<br>

### 🐧 Linux (Universal)

LUMA's Linux installer auto-detects your distro's package manager and handles everything.

**Supported distros:** Ubuntu · Debian · Mint · Fedora · RHEL · CentOS · Arch · Manjaro · openSUSE · Void · Alpine · and anything else with a standard package manager

**1. open a terminal**

**2. navigate to the LUMA folder**
```bash
cd /path/to/LUMA
```

**3. run the installer**
```bash
bash install.sh
```
the installer detects whether you're on `apt`, `dnf`, `pacman`, `zypper`, `xbps`, or `apk` and uses the right commands. if none of those work, it falls back to `snap` or `flatpak`.

**4. launch anytime after**

| File | What it does |
|---|---|
| `bash 'LUMA GUI.sh'` | opens the GUI |
| `bash luma.sh` | opens the terminal version |

<br>

## if ffmpeg fails to auto-install

### 🪟 Windows
open PowerShell as admin and run:
```powershell
winget install Gyan.FFmpeg
```
then re-run `install.bat`.

### 🍎 macOS
```bash
brew install ffmpeg
```
or download a static binary from [evermeet.cx](https://evermeet.cx/ffmpeg/), place it in the LUMA folder, and run `chmod +x ffmpeg`.

### 🐧 Linux
run the command for your distro:
```bash
# Debian / Ubuntu / Mint
sudo apt install ffmpeg

# Fedora / RHEL / CentOS
sudo dnf install ffmpeg

# Arch / Manjaro
sudo pacman -S ffmpeg

# openSUSE
sudo zypper install ffmpeg

# Void Linux
sudo xbps-install ffmpeg

# Alpine
sudo apk add ffmpeg
```
or download a universal static build from [johnvansickle.com/ffmpeg](https://johnvansickle.com/ffmpeg/), place the binary in the LUMA folder, and run `chmod +x ffmpeg`.

<br>

## project structure

### 🪟 Windows
```
LUMA/
├── src/
│   ├── favicon.ico
│   ├── luma.py
│   ├── luma_gui.html
│   ├── luma_logo.py
│   ├── Luma.png
│   ├── preload.js
│   ├── splash.html
│   └── splash_preload.js
├── bash-luma.bat
├── install.bat
├── LUMA GUI.bat
├── main.js
├── package.json
└── README.md
```

### 🍎 macOS  /  🐧 Linux
```
LUMA/
├── src/
│   ├── favicon.ico
│   ├── luma.py
│   ├── luma_gui.html
│   ├── luma_logo.py
│   ├── Luma.png
│   ├── preload.js
│   ├── splash.html
│   └── splash_preload.js
├── install.sh
├── luma.sh
├── LUMA GUI.sh
├── main.js
├── package.json
└── README.md
```

<br>

## notes

- drag and drop files straight into the GUI or terminal window — no need to type paths
- if a conversion fails, ffmpeg's error output is printed so you can see exactly what went wrong
- the `_luma` suffix on outputs means you can re-run conversions without overwriting anything
- on macOS/Linux, make sure scripts are executable: `chmod +x install.sh luma.sh 'LUMA GUI.sh'`

<br>

---

<p align="center">built by <a href="https://github.com/itslyko">lyko</a></p>
