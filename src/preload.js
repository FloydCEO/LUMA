const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  checkFfmpeg:    () => ipcRenderer.invoke('check-ffmpeg'),
  runFfmpeg:      (args) => ipcRenderer.invoke('run-ffmpeg', args),
  batchConvert:   (opts) => ipcRenderer.invoke('batch-convert', opts),
  saveFile:       (src) => ipcRenderer.invoke('save-file', src),
  splashDone:     () => ipcRenderer.send('splash-done'),
  dragWindow:     (dx, dy) => ipcRenderer.send('drag-window', dx, dy),
  minimizeWindow: () => ipcRenderer.send('minimize-window'),
  closeWindow:    () => ipcRenderer.send('close-window'),
});
