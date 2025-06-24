// popup.js
const MODEL_URL = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin";
const WORKER_URL = "https://unpkg.com/whisper-wasm@0.6.1/dist/whisper-wasm.js";
const MODEL_KEY = "whisper_model_bin";
const WORKER_KEY = "whisper_worker_js";
const INSTALLED_KEY = "whisper_model_installed";

// IndexedDB 工具
function idbSet(key, value) {
  return new Promise((resolve, reject) => {
    const open = indexedDB.open('keyval-store', 1);
    open.onupgradeneeded = () => open.result.createObjectStore('keyval');
    open.onsuccess = () => {
      const db = open.result;
      const tx = db.transaction('keyval', 'readwrite');
      tx.objectStore('keyval').put(value, key);
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    };
    open.onerror = () => reject(open.error);
  });
}
function idbGet(key) {
  return new Promise((resolve, reject) => {
    const open = indexedDB.open('keyval-store', 1);
    open.onupgradeneeded = () => open.result.createObjectStore('keyval');
    open.onsuccess = () => {
      const db = open.result;
      const tx = db.transaction('keyval', 'readonly');
      const req = tx.objectStore('keyval').get(key);
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    };
    open.onerror = () => reject(open.error);
  });
}

async function checkModelInstalled() {
  return await idbGet(INSTALLED_KEY);
}

async function setModelInstalled(val) {
  await idbSet(INSTALLED_KEY, val);
}

async function downloadModelViaBackground(url) {
  return new Promise((resolve, reject) => {
    chrome.runtime.sendMessage({ type: 'downloadModel', url }, (response) => {
      if (response && response.success) {
        resolve(response.buffer);
      } else {
        reject(new Error(response ? response.error : 'Unknown error'));
      }
    });
  });
}

document.addEventListener('DOMContentLoaded', async () => {
  const statusDiv = document.getElementById('status');
  const statusText = document.getElementById('status-text');
  const modelInstallDiv = document.getElementById('model-install');
  const installBtn = document.getElementById('install-model-btn');
  const installProgress = document.getElementById('install-progress');

  // 檢查模型安裝狀態
  const installed = await checkModelInstalled();
  if (!installed) {
    modelInstallDiv.style.display = 'block';
    statusText.textContent = '❗ 尚未安裝 Whisper 模型，請先下載安裝';
    statusDiv.className = 'status not-supported';
  } else {
    modelInstallDiv.style.display = 'none';
  }

  installBtn.onclick = async () => {
    installBtn.disabled = true;
    installProgress.textContent = '下載中...';
    try {
      // 用 background 下載模型
      const modelBuf = await downloadModelViaBackground(MODEL_URL);
      await idbSet(MODEL_KEY, modelBuf);
      // 用 background 下載 worker 檔
      const workerTextBuf = await downloadModelViaBackground(WORKER_URL);
      const workerText = new TextDecoder().decode(workerTextBuf);
      await idbSet(WORKER_KEY, workerText);
      // 標記已安裝
      await setModelInstalled(true);
      installProgress.textContent = '安裝完成！';
      setTimeout(()=>{
        modelInstallDiv.style.display = 'none';
        statusText.textContent = '✅ Whisper 模型已安裝，可開始使用';
        statusDiv.className = 'status supported';
      }, 1200);
    } catch(e) {
      installProgress.textContent = '下載失敗：' + e.message;
      installBtn.disabled = false;
    }
  };

  try {
    // 獲取當前標籤頁
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    
    if (tab && tab.url) {
      const supportedSites = [
        'youtube.com',
        'instagram.com',
        'tiktok.com'
      ];
      
      const isSupported = supportedSites.some(site => tab.url.includes(site));
      
      if (isSupported) {
        statusDiv.className = 'status supported';
        statusText.textContent = '✅ 此網站支援音訊轉錄';
      } else {
        statusDiv.className = 'status not-supported';
        statusText.textContent = '❌ 此網站不支援';
      }
    }
  } catch (error) {
    statusDiv.className = 'status not-supported';
    statusText.textContent = '❌ 無法檢查網站狀態';
  }
});