# LUMA — Lyko's Universal Media Adapter

```
  ██╗     ██╗   ██╗███╗   ███╗ █████╗
  ██║     ██║   ██║████╗ ████║██╔══██╗
  ██║     ██║   ██║██╔████╔██║███████║
  ██║     ██║   ██║██║╚██╔╝██║██╔══██║
  ███████╗╚██████╔╝██║ ╚═╝ ██║██║  ██║
  ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝
         Lyko's Universal Media Adapter
```

A fancy, fully-featured terminal media converter for Windows.

---

## Requirements

- **Python 3.8+** — https://www.python.org (check "Add to PATH" on install)
- **ffmpeg** — https://ffmpeg.org/download.html (or let `install.bat` try to grab it for you)

---

## Quick Start

1. Double-click **`install.bat`** — this checks Python, installs packages, and tries to install ffmpeg.
2. After setup, double-click **`run_luma.bat`** to launch LUMA anytime.

---

## Features

| Mode | What it does |
|------|-------------|
| ▶ Video Converter | Convert between mp4, mkv, avi, mov, webm, flv, wmv, gif, etc. |
| ♫ Audio Converter | Convert between mp3, wav, flac, aac, ogg, opus, m4a, etc. |
| 🖼 Image Converter | Convert between jpg, png, webp, bmp, tiff, ico, gif, etc. |
| ⚡ Batch Convert  | Convert an entire folder of files at once |

---

## Supported Formats

**Video:** mp4, mkv, avi, mov, webm, flv, wmv, m4v, ts, gif  
**Audio:** mp3, wav, flac, aac, ogg, m4a, wma, opus, aiff  
**Image:** jpg, jpeg, png, bmp, webp, tiff, ico, gif  

---

## Notes

- Output files are saved next to the original with `_luma` appended to the name.
- You can drag & drop file paths into the terminal window when prompted.
- For images, ffmpeg handles conversion — no extra tools needed.

---

*Built by Lyko. Powered by ffmpeg.*
