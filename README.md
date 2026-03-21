<p align="center">
  <img src="src/Luma.png" alt="LUMA" width="560"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.1-ffb000?style=flat-square&labelColor=0a0a06&color=ffb000"/>
  <img src="https://img.shields.io/badge/platform-Windows-ffb000?style=flat-square&labelColor=0a0a06&color=ffb000"/>
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
| [Python](https://www.python.org/downloads/) | 3.8+ | check **"Add Python to PATH"** during install |
| [Node.js](https://nodejs.org) | LTS | required for the GUI only |
| ffmpeg | any | installer handles this automatically |

<br>

## getting started

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

## if ffmpeg fails to auto-install

open PowerShell as admin and run:
```powershell
winget install Gyan.FFmpeg
```
then re-run `install.bat`.

<br>

## project structure

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

<br>

## notes

- drag and drop files straight into the GUI or terminal window — no need to type paths
- if a conversion fails, ffmpeg's error output is printed so you can see exactly what went wrong
- the `_luma` suffix on outputs means you can re-run conversions without overwriting anything

<br>

---

<p align="center">built by <a href="https://github.com/itslyko">lyko</a></p>
