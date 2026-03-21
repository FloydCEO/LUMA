const { contextBridge, ipcRenderer } = require('electron');
const path = require('path');
const fs   = require('fs');

// Resolve a sound file path relative to this preload's directory (src/)
function soundPath(name) {
  return path.join(__dirname, name);
}

contextBridge.exposeInMainWorld('electronAPI', {
  checkFfmpeg:    () => ipcRenderer.invoke('check-ffmpeg'),
  runFfmpeg:      (args) => ipcRenderer.invoke('run-ffmpeg', args),
  batchConvert:   (opts) => ipcRenderer.invoke('batch-convert', opts),
  saveFile:       (src) => ipcRenderer.invoke('save-file', src),
  splashDone:     () => ipcRenderer.send('splash-done'),
  dragWindow:     (dx, dy) => ipcRenderer.send('drag-window', dx, dy),
  minimizeWindow: () => ipcRenderer.send('minimize-window'),
  closeWindow:    () => ipcRenderer.send('close-window'),

  // ── SOUNDS ──────────────────────────────────────────────────────
  // Returns a file:// URL the renderer can feed to new Audio()
  soundURL: (name) => {
    const p = soundPath(name);
    return fs.existsSync(p) ? 'file://' + p.replace(/\\/g, '/') : null;
  },

  // Called by main process just before the window is destroyed
  onClosingSound: (cb) => ipcRenderer.on('play-closing-sound', cb),
});
