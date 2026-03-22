const { app, BrowserWindow, ipcMain, dialog, shell } = require('electron');
const path = require('path');
const { spawn, exec } = require('child_process');
const fs = require('fs');

let mainWindow;
let splashWindow;

function createSplash() {
  splashWindow = new BrowserWindow({
    width: 600,
    height: 400,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    skipTaskbar: true,
    resizable: false,
    center: true,
    backgroundColor: '#00000000',
    webPreferences: {
      preload: path.join(__dirname, 'src', 'splash_preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
    icon: path.join(__dirname, 'src', 'favicon.ico'),
  });
  splashWindow.loadFile('src/splash.html');
}

function createMainWindow() {
  mainWindow = new BrowserWindow({
    width: 960,
    height: 680,
    minWidth: 720,
    minHeight: 500,
    frame: false,
    transparent: false,
    backgroundColor: '#0a0a06',
    center: true,
    show: false,
    webPreferences: {
      preload: path.join(__dirname, 'src', 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false,
      autoplayPolicy: 'no-user-gesture-required',
    },
    icon: path.join(__dirname, 'src', 'favicon.ico'),
  });
  mainWindow.loadFile('src/luma_gui.html');
  mainWindow.webContents.openDevTools();
  mainWindow.once('ready-to-show', () => {
    setTimeout(() => {
      if (splashWindow && !splashWindow.isDestroyed()) splashWindow.close();
      mainWindow.show();
    }, 3600);
  });
}

app.whenReady().then(() => {
  createSplash();
  createMainWindow();
});

ipcMain.on('splash-done', () => {
  if (splashWindow && !splashWindow.isDestroyed()) splashWindow.close();
  if (mainWindow) mainWindow.show();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// ── DRAG / MINIMIZE / CLOSE ───────────────────────────────
ipcMain.on('drag-window', (event, dx, dy) => {
  const win = BrowserWindow.fromWebContents(event.sender);
  if (!win) return;
  const [x, y] = win.getPosition();
  win.setPosition(x + Math.round(dx), y + Math.round(dy));
});

ipcMain.on('minimize-window', (event) => {
  const win = BrowserWindow.fromWebContents(event.sender);
  if (win) win.minimize();
});

ipcMain.on('close-window', (event) => {
  const win = BrowserWindow.fromWebContents(event.sender);
  if (!win) return;
  win.webContents.send('play-closing-sound');
  setTimeout(() => { if (!win.isDestroyed()) win.close(); }, 900);
});

// ── OPEN FILE / FOLDER DIALOGS ────────────────────────────
ipcMain.handle('open-file', async (event, filters) => {
  const { canceled, filePaths } = await dialog.showOpenDialog(mainWindow, {
    properties: ['openFile'],
    filters: filters || [{ name: 'All Files', extensions: ['*'] }],
  });
  return canceled ? null : filePaths[0];
});

ipcMain.handle('open-folder', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory'],
  });
  return canceled ? null : filePaths[0];
});

// ── FFMPEG CHECK ──────────────────────────────────────────
ipcMain.handle('check-ffmpeg', async () => {
  return new Promise((resolve) => {
    exec('ffmpeg -version', (err, stdout) => {
      if (err) {
        const local = path.join(__dirname, 'ffmpeg.exe');
        resolve(fs.existsSync(local) ? 'local' : null);
      } else {
        const match = stdout.match(/ffmpeg version ([^\s]+)/);
        resolve(match ? match[1] : 'OK');
      }
    });
  });
});

// ── RESOLVE FFMPEG PATH ───────────────────────────────────
function firstLine(str) {
  var n = str.indexOf('\n');
  var r = str.indexOf('\r');
  var end = str.length;
  if (n >= 0 && n < end) end = n;
  if (r >= 0 && r < end) end = r;
  return str.slice(0, end).trim();
}

function resolveFfmpeg() {
  const { execSync } = require('child_process');
  try {
    const cmd = process.platform === 'win32' ? 'where ffmpeg' : 'which ffmpeg';
    const r = firstLine(execSync(cmd, { encoding: 'utf8', env: process.env }));
    if (r && fs.existsSync(r)) return r;
  } catch(e) {}

  const local = path.join(__dirname, process.platform === 'win32' ? 'ffmpeg.exe' : 'ffmpeg');
  if (fs.existsSync(local)) return local;

  if (process.platform === 'win32') {
    const candidates = [
      'C:\\ffmpeg\\bin\\ffmpeg.exe',
      path.join(process.env.APPDATA || '', '..', 'Local', 'Microsoft', 'WinGet', 'Links', 'ffmpeg.exe'),
      path.join(process.env.ProgramFiles || 'C:\\Program Files', 'ffmpeg', 'bin', 'ffmpeg.exe'),
      path.join(process.env.USERPROFILE || '', 'scoop', 'shims', 'ffmpeg.exe'),
      'C:\\ProgramData\\chocolatey\\bin\\ffmpeg.exe',
    ];
    for (const c of candidates) {
      try { if (fs.existsSync(c)) return c; } catch(e) {}
    }
    const wpkg = path.join(process.env.LOCALAPPDATA || '', 'Microsoft', 'WinGet', 'Packages');
    if (fs.existsSync(wpkg)) {
      try {
        const r = firstLine(execSync('dir /s /b "' + wpkg + '\\ffmpeg.exe" 2>nul', { encoding: 'utf8', shell: true }));
        if (r && fs.existsSync(r)) return r;
      } catch(e) {}
    }
  }
  return process.platform === 'win32' ? 'ffmpeg.exe' : 'ffmpeg';
}

let _ffmpegBin = null;

// ── RUN FFMPEG ────────────────────────────────────────────
ipcMain.handle('run-ffmpeg', async (event, args) => {
  return new Promise((resolve) => {
    if (!_ffmpegBin) _ffmpegBin = resolveFfmpeg();
    const env = { ...process.env };
    env.PATH = path.dirname(_ffmpegBin) + path.delimiter + __dirname + path.delimiter + (env.PATH || '');
    const proc = spawn(_ffmpegBin, args.slice(1), { env });
    let stderr = '';
    proc.stderr.on('data', d => { stderr += d.toString(); });
    proc.on('close', code => { resolve({ success: code === 0, stderr }); });
    proc.on('error', err => { resolve({ success: false, stderr: err.message }); });
  });
});

// ── SAVE FILE ─────────────────────────────────────────────
ipcMain.handle('save-file', async (event, sourcePath) => {
  const ext = path.extname(sourcePath).slice(1);
  const defaultName = path.basename(sourcePath);
  const { filePath, canceled } = await dialog.showSaveDialog(mainWindow, {
    title: 'Save converted file',
    defaultPath: path.join(app.getPath('downloads'), defaultName),
    filters: [{ name: ext.toUpperCase(), extensions: [ext] }, { name: 'All Files', extensions: ['*'] }],
  });
  if (canceled || !filePath) return null;
  fs.copyFileSync(sourcePath, filePath);
  shell.showItemInFolder(filePath);
  return filePath;
});

// ── BATCH CONVERT ─────────────────────────────────────────
ipcMain.handle('batch-convert', async (event, { folder, inExt, outExt }) => {
  const files = fs.readdirSync(folder).filter(f => f.toLowerCase().endsWith('.' + inExt));
  const results = [];
  for (const file of files) {
    const inputPath = path.join(folder, file);
    const stem = path.basename(file, path.extname(file));
    const outputPath = path.join(folder, stem + '_luma.' + outExt);
    const result = await new Promise((resolve) => {
      if (!_ffmpegBin) _ffmpegBin = resolveFfmpeg();
      const env = { ...process.env };
      env.PATH = path.dirname(_ffmpegBin) + path.delimiter + __dirname + path.delimiter + (env.PATH || '');
      const proc = spawn(_ffmpegBin, ['-i', inputPath, '-y', outputPath], { env });
      let stderr = '';
      proc.stderr.on('data', d => { stderr += d.toString(); });
      proc.on('close', code => resolve({ name: file, success: code === 0, stderr }));
      proc.on('error', err => resolve({ name: file, success: false, stderr: err.message }));
    });
    results.push(result);
  }
  return { files: results };
});