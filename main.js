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
    },
    icon: path.join(__dirname, 'src', 'favicon.ico'),
  });

  mainWindow.loadFile('src/luma_gui.html');

  mainWindow.once('ready-to-show', () => {
    // Wait for splash to finish (3.6s) then swap
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

// IPC: splash done early (user clicked/pressed key)
ipcMain.on('splash-done', () => {
  if (splashWindow && !splashWindow.isDestroyed()) splashWindow.close();
  if (mainWindow) mainWindow.show();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// ── DRAG WINDOW ───────────────────────────────────────────
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
  if (win) win.close();
});

// ── FFMPEG CHECK ──────────────────────────────────────────
ipcMain.handle('check-ffmpeg', async () => {
  return new Promise((resolve) => {
    exec('ffmpeg -version', (err, stdout) => {
      if (err) {
        // Try next to luma.py
        const local = path.join(__dirname, 'ffmpeg.exe');
        if (fs.existsSync(local)) {
          resolve('local');
        } else {
          resolve(null);
        }
      } else {
        const match = stdout.match(/ffmpeg version ([^\s]+)/);
        resolve(match ? match[1] : 'OK');
      }
    });
  });
});

// ── RUN FFMPEG ────────────────────────────────────────────
ipcMain.handle('run-ffmpeg', async (event, args) => {
  return new Promise((resolve) => {
    // Make sure PATH includes ffmpeg local copy if present
    const env = { ...process.env };
    const localDir = __dirname;
    env.PATH = localDir + path.delimiter + (env.PATH || '');

    const proc = spawn(args[0], args.slice(1), { env });
    let stderr = '';

    proc.stderr.on('data', d => { stderr += d.toString(); });
    proc.on('close', code => {
      resolve({ success: code === 0, stderr });
    });
    proc.on('error', err => {
      resolve({ success: false, stderr: err.message });
    });
  });
});

// ── SAVE FILE (copy to user-chosen location) ──────────────
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
ipcMain.handle('batch-convert', async (event, { folder, inExt, outExt }) => {
  const files = fs.readdirSync(folder).filter(f => f.toLowerCase().endsWith('.' + inExt));
  const results = [];

  for (const file of files) {
    const inputPath = path.join(folder, file);
    const stem = path.basename(file, path.extname(file));
    const outputPath = path.join(folder, stem + '_luma.' + outExt);

    const result = await new Promise((resolve) => {
      const env = { ...process.env, PATH: __dirname + path.delimiter + process.env.PATH };
      const proc = spawn('ffmpeg', ['-i', inputPath, '-y', outputPath], { env });
      let stderr = '';
      proc.stderr.on('data', d => { stderr += d.toString(); });
      proc.on('close', code => resolve({ name: file, success: code === 0, stderr }));
      proc.on('error', err => resolve({ name: file, success: false, stderr: err.message }));
    });
    results.push(result);
  }

  return { files: results };
});
