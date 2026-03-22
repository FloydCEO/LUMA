const { contextBridge, ipcRenderer } = require('electron');
const nodePath = require('path');
const nodeFs   = require('fs');

contextBridge.exposeInMainWorld('electronAPI', {
  checkFfmpeg:    () => ipcRenderer.invoke('check-ffmpeg'),
  runFfmpeg:      (args) => ipcRenderer.invoke('run-ffmpeg', args),
  batchConvert:   (opts) => ipcRenderer.invoke('batch-convert', opts),
  saveFile:       (src) => ipcRenderer.invoke('save-file', src),
  splashDone:     () => ipcRenderer.send('splash-done'),
  dragWindow:     (dx, dy) => ipcRenderer.send('drag-window', dx, dy),
  minimizeWindow: () => ipcRenderer.send('minimize-window'),
  closeWindow:    () => ipcRenderer.send('close-window'),
  openFile:       (filters) => ipcRenderer.invoke('open-file', filters),
  openFolder:     () => ipcRenderer.invoke('open-folder'),
  onClosingSound: (cb) => ipcRenderer.on('play-closing-sound', cb),
  soundURL: (name) => {
    const p = nodePath.join(__dirname, name);
    return nodeFs.existsSync(p) ? 'file:///' + p.replace(/\\/g, '/') : null;
  },
});
