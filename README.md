<p align="center">
  <img src="Luma.png" alt="LUMA" width="600"/>
</p>

<h1 align="center">LUMA</h1>
<p align="center"><em>Lyko's Universal Media Adapter</em></p>

---

a terminal media converter i made because i was tired of going to some sketchy website every time i needed to convert a file. it runs locally, it's fast, and it doesn't upload your stuff anywhere. powered by ffmpeg under the hood.

## what it does

- convert video files between basically any format (mp4, mkv, mov, avi, webm, flv, wmv, gif...)
- convert audio files (mp3, flac, wav, ogg, opus, aac, m4a, wma, aiff...)
- convert images (jpg, png, webp, bmp, tiff, ico, gif...)
- batch convert a whole folder at once

## requirements

- **Python 3.8+** — grab it from [python.org](https://www.python.org/downloads/). during install, make sure you check **"Add Python to PATH"** or nothing will work
- **ffmpeg** — the installer will try to grab this for you automatically

## getting started

1. double-click `install.bat` — it'll check your python, install the dependencies, and try to sort out ffmpeg
2. once that's done, just run `run_luma.bat` whenever you want to use it

if ffmpeg auto-install fails (happens sometimes), open powershell as admin and run:
```
winget install Gyan.FFmpeg
```
then run `install.bat` again.

## output files

converted files get saved in the same folder as the original with `_luma` added to the name, so your originals are never touched. you can also type a custom output path when it asks.

## notes

- you can drag and drop file paths into the terminal window when it asks for a file — you don't have to type the whole thing
- for image conversion, ffmpeg handles everything, no extra tools needed
- if something fails, the error output from ffmpeg will print so you can actually see what went wrong

---

*built by lyko — [github](https://github.com/itslyko)*
