import os
import sys
import subprocess
import shutil
from pathlib import Path

# ─────────────────────────────────────────────
#  ANSI COLOR SETUP  (colorama keeps Windows happy)
# ─────────────────────────────────────────────
try:
    import colorama
    colorama.init()          # ← BUG FIX #5: without this, colors print as garbage on Windows
except ImportError:
    pass                     # colorama missing — colors still work on modern Windows 10+ terminals

# ─────────────────────────────────────────────
#  ANSI COLOR CODES
# ─────────────────────────────────────────────
R   = "\033[0m"       # Reset
CY  = "\033[96m"      # Cyan
YL  = "\033[93m"      # Yellow
GR  = "\033[92m"      # Green
RD  = "\033[91m"      # Red
BL  = "\033[94m"      # Blue
MG  = "\033[95m"      # Magenta
DIM = "\033[2m"       # Dim
BLD = "\033[1m"       # Bold
WH  = "\033[97m"      # White


# ─────────────────────────────────────────────
#  ASCII ART
# ─────────────────────────────────────────────

LUMA_LOGO = f"""
{CY}{BLD}
  ██╗     ██╗   ██╗███╗   ███╗ █████╗
  ██║     ██║   ██║████╗ ████║██╔══██╗
  ██║     ██║   ██║██╔████╔██║███████║
  ██║     ██║   ██║██║╚██╔╝██║██╔══██║
  ███████╗╚██████╔╝██║ ╚═╝ ██║██║  ██║
  ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝
{R}{DIM}          Lyko's Universal Media Adapter{R}
"""

DIVIDER = f"{CY}  {'─' * 50}{R}"

VIDEO_ART = f"""
{YL}  ┌─────────────────────────────────────┐
  │  ┌──────────────────────────────────┐ │
  │  │                                  │ │
  │  │    ▶▶  MP4  MKV  AVI  MOV  ▶▶   │ │
  │  │                                  │ │
  │  └──────────────────────────────────┘ │
  │         [ ] =================== [ ]   │
  └─────────────────────────────────────┘{R}"""

AUDIO_ART = f"""
{MG}  ┌─────────────────────────────────────┐
  │                                     │
  │    ♪  MP3  FLAC  WAV  OGG  OPUS  ♪  │
  │                                     │
  │    ▁▂▃▅▆█▇▆▅▃▂▁▂▃▅▆█▇▆▅▃▂▁▂▃▅▆█   │
  │                                     │
  └─────────────────────────────────────┘{R}"""

IMAGE_ART = f"""
{GR}  ┌─────────────────────────────────────┐
  │                                     │
  │    JPG  PNG  WEBP  BMP  TIFF  ICO   │
  │                                     │
  │    ░░░▒▒▒███  ▄▄▄▄  ░░░▒▒▒███▓▓▓   │
  │         ╲  ▔▔▔▔▔▔  ╱              │
  └─────────────────────────────────────┘{R}"""

CONVERT_ART = f"""
{BL}  ┌─────────────────────────────────────┐
  │                                     │
  │    [ INPUT ]  ══{CY}► LUMA ►{BL}══  [ OUT ]  │
  │                                     │
  │      any format  →  any format      │
  │                                     │
  └─────────────────────────────────────┘{R}"""


# ─────────────────────────────────────────────
#  SUPPORTED FORMATS
# ─────────────────────────────────────────────

VIDEO_FORMATS  = ["mp4", "mkv", "avi", "mov", "webm", "flv", "wmv", "m4v", "ts", "gif"]
AUDIO_FORMATS  = ["mp3", "wav", "flac", "aac", "ogg", "m4a", "wma", "opus", "aiff"]
IMAGE_FORMATS  = ["jpg", "jpeg", "png", "bmp", "webp", "tiff", "ico", "gif"]


def clear():
    os.system("cls" if os.name == "nt" else "clear")


def print_header():
    clear()
    print(LUMA_LOGO)
    print(DIVIDER)
    print()


def check_ffmpeg():
    # 1) Already in PATH?
    if shutil.which("ffmpeg") is not None:
        return

    # 2) ffmpeg.exe sitting next to luma.py?
    script_dir = Path(__file__).parent.resolve()
    local_ffmpeg = script_dir / "ffmpeg.exe"
    if local_ffmpeg.exists():
        os.environ["PATH"] = str(script_dir) + os.pathsep + os.environ.get("PATH", "")
        return

    # 3) Give up with a helpful message
    clear()
    print(LUMA_LOGO)
    print(DIVIDER)
    print(f"""
  {RD}{BLD}ffmpeg is not installed.{R}
  LUMA needs ffmpeg to convert media files.

  {WH}HOW TO FIX:{R}

  {YL}Option A{R} — Run the installer (recommended):
    Double-click  {BLD}install.bat{R}  in the LUMA folder.
    It will try to install ffmpeg automatically.

  {YL}Option B{R} — One command (open PowerShell as Admin):
    {CY}winget install Gyan.FFmpeg{R}
    Then restart this program.

  {YL}Option C{R} — Manual download:
    1. Go to  {CY}https://ffmpeg.org/download.html{R}
    2. Windows → gyan.dev → release builds
    3. Download  ffmpeg-release-essentials.zip
    4. Open the zip, go into /bin
    5. Copy  {BLD}ffmpeg.exe{R}  into your LUMA folder
    6. Restart this program.

  {DIM}LUMA folder: {script_dir}{R}
""")
    print(DIVIDER)
    input(f"\n  Press Enter to exit...")
    sys.exit(1)


def prompt_input(label, color=CY):
    return input(f"  {color}{BLD}{label}{R} ").strip()


def pick_option(options, prompt_text):
    for i, opt in enumerate(options, 1):
        print(f"  {DIM}[{R}{WH}{BLD}{i}{R}{DIM}]{R}  {opt}")
    print()
    while True:
        choice = prompt_input(prompt_text)
        if choice.isdigit() and 1 <= int(choice) <= len(options):
            return options[int(choice) - 1]
        print(f"  {RD}Invalid choice, try again.{R}")


def browse_file(extension_filter=None):
    print(f"\n  {DIM}Enter the full path to your file{R}")
    print(f"  {DIM}(you can drag & drop the file into this window){R}\n")
    path = prompt_input("File path ›", YL).strip('"').strip("'")
    if not os.path.isfile(path):
        print(f"\n  {RD}File not found:{R} {path}")
        return None
    if extension_filter:
        ext = Path(path).suffix.lstrip(".").lower()
        if ext not in extension_filter:
            print(f"\n  {RD}Unexpected file type: .{ext}{R}")
            print(f"  {DIM}Expected one of: {', '.join(extension_filter)}{R}")
            return None
    return path


def get_output_path(input_path, new_ext):
    p = Path(input_path)
    default = p.parent / f"{p.stem}_luma.{new_ext}"
    print(f"\n  {DIM}Output will be saved to:{R}")
    print(f"  {GR}{default}{R}\n")
    custom = prompt_input("Press Enter to confirm, or type a new path ›", DIM)
    if custom:
        return custom.strip('"').strip("'")
    return str(default)


def run_ffmpeg(args):
    """
    Run an ffmpeg command. Streams output live so the user can see progress.
    Returns True on success, False on failure. On failure, prints stderr.
    """
    print(f"\n  {CY}Running conversion...{R}\n")
    # Display the command with quoted args so paths with spaces are obvious
    display = " ".join(f'"{a}"' if " " in a else a for a in args)
    print(f"  {DIM}{display}{R}\n")
    print(DIVIDER)

    # BUG FIX #3 / #4: capture stderr separately so we can show it on failure,
    # but let stdout stream live so the user sees ffmpeg progress.
    result = subprocess.run(args, stderr=subprocess.PIPE)
    if result.returncode != 0:
        print(f"\n  {RD}ffmpeg error output:{R}")
        try:
            print("  " + result.stderr.decode("utf-8", errors="replace").replace("\n", "\n  "))
        except Exception:
            pass
    return result.returncode == 0


# ─────────────────────────────────────────────
#  BUG FIX #1 & #2: codec-aware video args
#  The original code blindly applied -preset and -crf to every format.
#  Those flags are H.264/H.265-only — everything else needs different args.
# ─────────────────────────────────────────────

def _video_args(input_file, fmt, preset, crf):
    """Return a complete list of ffmpeg arguments for video conversion."""

    if fmt == "gif":
        # GIF: palette-based two-pass for best quality
        return [
            "ffmpeg", "-i", input_file,
            "-vf", "fps=15,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse",
            "-loop", "0",
            "-y", f"{Path(input_file).parent / (Path(input_file).stem + '_luma.gif')}"
        ]

    if fmt in ("mp4", "m4v"):
        return [
            "ffmpeg", "-i", input_file,
            "-c:v", "libx264", "-preset", preset, "-crf", crf,
            "-c:a", "aac", "-b:a", "192k",
            "-movflags", "+faststart",
            "-y"
        ]

    if fmt == "mkv":
        return [
            "ffmpeg", "-i", input_file,
            "-c:v", "libx264", "-preset", preset, "-crf", crf,
            "-c:a", "copy",
            "-y"
        ]

    if fmt == "webm":
        # VP9 + Opus — the native webm codecs
        crf_vp9 = {"fast": "40", "medium": "33", "slow": "28"}.get(preset, "33")
        return [
            "ffmpeg", "-i", input_file,
            "-c:v", "libvpx-vp9", "-crf", crf_vp9, "-b:v", "0",
            "-c:a", "libopus", "-b:a", "128k",
            "-y"
        ]

    if fmt == "avi":
        return [
            "ffmpeg", "-i", input_file,
            "-c:v", "mpeg4", "-q:v", "6",
            "-c:a", "mp3", "-q:a", "4",
            "-y"
        ]

    if fmt == "mov":
        return [
            "ffmpeg", "-i", input_file,
            "-c:v", "libx264", "-preset", preset, "-crf", crf,
            "-c:a", "aac", "-b:a", "192k",
            "-y"
        ]

    if fmt == "flv":
        return [
            "ffmpeg", "-i", input_file,
            "-c:v", "libx264", "-preset", preset, "-crf", crf,
            "-c:a", "aac", "-b:a", "128k",
            "-ar", "44100",
            "-y"
        ]

    if fmt == "wmv":
        return [
            "ffmpeg", "-i", input_file,
            "-c:v", "wmv2", "-b:v", "2000k",
            "-c:a", "wmav2", "-b:a", "192k",
            "-y"
        ]

    if fmt == "ts":
        return [
            "ffmpeg", "-i", input_file,
            "-c:v", "libx264", "-preset", preset, "-crf", crf,
            "-c:a", "aac", "-b:a", "192k",
            "-f", "mpegts",
            "-y"
        ]

    # Fallback — let ffmpeg decide (shouldn't normally reach here)
    return ["ffmpeg", "-i", input_file, "-y"]


def convert_video():
    print_header()
    print(VIDEO_ART)
    print(f"  {YL}{BLD}VIDEO CONVERTER{R}\n")
    print(DIVIDER)

    input_file = browse_file(VIDEO_FORMATS)
    if not input_file:
        pause_return()
        return

    print(f"\n  {WH}Choose output format:{R}\n")
    fmt = pick_option(VIDEO_FORMATS, "Format number ›")

    output_file = get_output_path(input_file, fmt)

    # GIF skips the quality menu (palette-based, no preset/crf)
    if fmt == "gif":
        args = [
            "ffmpeg", "-i", input_file,
            "-vf", "fps=15,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse",
            "-loop", "0",
            "-y", output_file
        ]
    else:
        print(f"\n  {WH}Choose quality preset:{R}\n")
        presets = ["Fast (lower quality)", "Balanced", "High Quality (slow)"]
        preset_map = {"Fast (lower quality)": "fast", "Balanced": "medium", "High Quality (slow)": "slow"}
        crf_map   = {"Fast (lower quality)": "28",   "Balanced": "23",     "High Quality (slow)": "18"}
        preset_choice = pick_option(presets, "Preset number ›")
        preset = preset_map[preset_choice]
        crf    = crf_map[preset_choice]

        # BUG FIX #1 & #2: use codec-aware args, then append output path
        args = _video_args(input_file, fmt, preset, crf) + [output_file]

    success = run_ffmpeg(args)
    finish_message(success, output_file)


def convert_audio():
    print_header()
    print(AUDIO_ART)
    print(f"  {MG}{BLD}AUDIO CONVERTER{R}\n")
    print(DIVIDER)

    input_file = browse_file(AUDIO_FORMATS + VIDEO_FORMATS)
    if not input_file:
        pause_return()
        return

    print(f"\n  {WH}Choose output format:{R}\n")
    fmt = pick_option(AUDIO_FORMATS, "Format number ›")

    output_file = get_output_path(input_file, fmt)

    # BUG FIX #7 & #8: added missing wma and aiff codec args
    extra = []
    if fmt == "mp3":
        extra = ["-codec:a", "libmp3lame", "-q:a", "2"]
    elif fmt == "flac":
        extra = ["-codec:a", "flac", "-compression_level", "8"]
    elif fmt == "ogg":
        extra = ["-codec:a", "libvorbis", "-q:a", "5"]
    elif fmt == "opus":
        extra = ["-codec:a", "libopus", "-b:a", "128k"]
    elif fmt in ("aac", "m4a"):
        extra = ["-codec:a", "aac", "-b:a", "192k"]
    elif fmt == "wav":
        extra = ["-codec:a", "pcm_s16le"]
    elif fmt == "wma":
        # BUG FIX #7: wma previously had no args and always failed
        extra = ["-codec:a", "wmav2", "-b:a", "192k"]
    elif fmt == "aiff":
        # BUG FIX #8: aiff previously had no args and always failed
        extra = ["-codec:a", "pcm_s16be"]

    # Strip video stream when extracting audio from a video file
    args = ["ffmpeg", "-i", input_file, "-vn"] + extra + ["-y", output_file]
    success = run_ffmpeg(args)
    finish_message(success, output_file)


def convert_image():
    print_header()
    print(IMAGE_ART)
    print(f"  {GR}{BLD}IMAGE CONVERTER{R}\n")
    print(DIVIDER)

    input_file = browse_file(IMAGE_FORMATS)
    if not input_file:
        pause_return()
        return

    print(f"\n  {WH}Choose output format:{R}\n")
    fmt = pick_option(IMAGE_FORMATS, "Format number ›")

    output_file = get_output_path(input_file, fmt)

    # BUG FIX #6: -vframes 1 ensures we grab exactly one frame — critical for
    # animated GIFs or any multi-frame input. Without it ffmpeg errors out
    # or produces a broken multi-image output for static formats like png/jpg.
    args = ["ffmpeg", "-i", input_file, "-vframes", "1", "-y", output_file]
    success = run_ffmpeg(args)
    finish_message(success, output_file)


def batch_convert():
    print_header()
    print(CONVERT_ART)
    print(f"  {BL}{BLD}BATCH CONVERTER{R}\n")
    print(DIVIDER)
    print(f"\n  {DIM}Convert all files of one type in a folder{R}\n")

    folder = prompt_input("Folder path ›", YL).strip('"').strip("'")
    if not os.path.isdir(folder):
        print(f"\n  {RD}Folder not found.{R}")
        pause_return()
        return

    print(f"\n  {WH}Input file extension (e.g. mp4, mp3, png):{R}\n")
    in_ext = prompt_input("Extension ›").lower().lstrip(".")

    print(f"\n  {WH}Output format:{R}\n")
    out_ext = prompt_input("Output format ›").lower().lstrip(".")

    files = list(Path(folder).glob(f"*.{in_ext}"))
    if not files:
        print(f"\n  {RD}No .{in_ext} files found in that folder.{R}")
        pause_return()
        return

    print(f"\n  {GR}Found {len(files)} file(s). Starting batch conversion...{R}\n")
    print(DIVIDER)

    success_count = 0
    for f in files:
        out = f.parent / f"{f.stem}_luma.{out_ext}"
        print(f"\n  {CY}Converting:{R} {f.name}  {DIM}→{R}  {out.name}")
        args = ["ffmpeg", "-i", str(f), "-y", str(out)]
        # BUG FIX #3: capture stderr so we can show WHY something failed
        result = subprocess.run(args, stderr=subprocess.PIPE)
        if result.returncode == 0:
            print(f"  {GR}✓ Done{R}")
            success_count += 1
        else:
            print(f"  {RD}✗ Failed{R}")
            try:
                err = result.stderr.decode("utf-8", errors="replace").strip().splitlines()
                # Show only the last few lines (the actual error, not the whole ffmpeg banner)
                for line in err[-5:]:
                    print(f"    {DIM}{line}{R}")
            except Exception:
                pass

    print(f"\n{DIVIDER}")
    print(f"\n  {GR}{BLD}Batch complete!{R}  {success_count}/{len(files)} files converted.\n")
    pause_return()


def finish_message(success, output_file):
    print()
    print(DIVIDER)
    if success:
        print(f"\n  {GR}{BLD}✓  Conversion complete!{R}")
        print(f"  {DIM}Saved to:{R} {GR}{output_file}{R}\n")
    else:
        print(f"\n  {RD}{BLD}✗  Conversion failed.{R}")
        print(f"  {DIM}Check the error output above for details.{R}\n")
    pause_return()


def pause_return():
    input(f"  {DIM}Press Enter to return to menu...{R}")


def about():
    print_header()
    print(f"""
  {CY}{BLD}LUMA — Lyko's Universal Media Adapter{R}
  {DIM}Version 1.0.1{R}

  {WH}Built by Lyko.{R}
  Powered by {YL}ffmpeg{R} — the industry-standard media toolkit.

  {DIM}Supported conversions:{R}
    {YL}Video :{R}  {', '.join(VIDEO_FORMATS)}
    {MG}Audio :{R}  {', '.join(AUDIO_FORMATS)}
    {GR}Image :{R}  {', '.join(IMAGE_FORMATS)}

  {DIM}For issues or suggestions, check the README.{R}
""")
    pause_return()


def main_menu():
    check_ffmpeg()
    while True:
        print_header()
        print(f"  {WH}{BLD}What would you like to convert?{R}\n")
        print(f"  {DIM}[{R}{WH}{BLD}1{R}{DIM}]{R}  {YL}▶  Video Converter{R}         {DIM}mp4, mkv, avi, mov, webm...{R}")
        print(f"  {DIM}[{R}{WH}{BLD}2{R}{DIM}]{R}  {MG}♫  Audio Converter{R}         {DIM}mp3, wav, flac, ogg, opus...{R}")
        print(f"  {DIM}[{R}{WH}{BLD}3{R}{DIM}]{R}  {GR}🖼  Image Converter{R}         {DIM}jpg, png, webp, bmp, gif...{R}")
        print(f"  {DIM}[{R}{WH}{BLD}4{R}{DIM}]{R}  {BL}⚡  Batch Convert{R}           {DIM}whole folder at once{R}")
        print(f"  {DIM}[{R}{WH}{BLD}5{R}{DIM}]{R}  {DIM}ℹ  About LUMA{R}")
        print(f"  {DIM}[{R}{WH}{BLD}0{R}{DIM}]{R}  {DIM}Exit{R}")
        print()
        print(DIVIDER)
        print()
        choice = prompt_input("Choose an option ›")

        if   choice == "1": convert_video()
        elif choice == "2": convert_audio()
        elif choice == "3": convert_image()
        elif choice == "4": batch_convert()
        elif choice == "5": about()
        elif choice == "0":
            print(f"\n  {CY}Thanks for using LUMA. Goodbye!{R}\n")
            sys.exit(0)
        else:
            print(f"\n  {RD}Invalid option.{R}\n")


if __name__ == "__main__":
    try:
        main_menu()
    except KeyboardInterrupt:
        print(f"\n\n  {DIM}Interrupted. Goodbye.{R}\n")
        sys.exit(0)
