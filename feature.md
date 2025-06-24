新需求

支援chrome extension版本

# Chrome 擴充套件安裝指南

## 🛠️ 開發者模式安裝（手動安裝）

### 步驟 1：準備檔案

1. **建立專案資料夾**
```bash
mkdir get-audio-text-extension
cd get-audio-text-extension
```

2. **建立必要檔案**

建立以下檔案結構：
```
get-audio-text-extension/
├── manifest.json
├── content.js
├── popup.html
├── popup.js
├── background.js
├── content.css
└── icons/
    ├── icon-16.png
    ├── icon-48.png
    └── icon-128.png
```

### 步驟 2：建立 manifest.json

```json
{
  "name": "Get Audio Text",
  "version": "1.0.0",
  "manifest_version": 3,
  "description": "純前端一鍵下載影片音訊並轉錄成文字",
  
  "permissions": [
    "activeTab",
    "storage",
    "downloads"
  ],
  
  "host_permissions": [
    "https://www.youtube.com/*",
    "https://www.instagram.com/*",
    "https://www.tiktok.com/*"
  ],
  
  "background": {
    "service_worker": "background.js"
  },
  
  "content_scripts": [
    {
      "matches": [
        "https://www.youtube.com/*",
        "https://www.instagram.com/*",
        "https://www.tiktok.com/*"
      ],
      "js": ["content.js"],
      "css": ["content.css"]
    }
  ],
  
  "action": {
    "default_popup": "popup.html",
    "default_title": "Get Audio Text"
  },
  
  "icons": {
    "16": "icons/icon-16.png",
    "48": "icons/icon-48.png",
    "128": "icons/icon-128.png"
  }
}
```

### 步驟 3：建立 content.css

```css
/* content.css */
.gat-button {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 500;
}

.gat-notification {
  font-size: 14px;
  border-radius: 8px;
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes slideOut {
  from {
    transform: translateX(0);
    opacity: 1;
  }
  to {
    transform: translateX(100%);
    opacity: 0;
  }
}

.spinner {
  border: 3px solid rgba(255,255,255,0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

#progress-bar {
  width: 300px;
  height: 6px;
  background: rgba(255,255,255,0.3);
  border-radius: 3px;
  margin-top: 15px;
  overflow: hidden;
}

#progress-fill {
  height: 100%;
  background: #4CAF50;
  transition: width 0.3s ease;
}
```

### 步驟 4：建立 background.js

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  console.log('Get Audio Text 擴充套件已安裝');
});

// 監聽來自 content script 的消息
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'downloadFile') {
    chrome.downloads.download({
      url: request.url,
      filename: request.filename,
      saveAs: true
    }).then(() => {
      sendResponse({ success: true });
    }).catch((error) => {
      sendResponse({ success: false, error: error.message });
    });
    return true; // 保持消息通道開放
  }
});
```

### 步驟 5：建立 popup.html 和 popup.js

**popup.html:**
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body {
      width: 300px;
      padding: 20px;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    
    h1 {
      margin: 0 0 15px 0;
      font-size: 18px;
      color: #333;
    }
    
    .status {
      padding: 10px;
      border-radius: 5px;
      margin-bottom: 15px;
    }
    
    .supported {
      background: #e8f5e8;
      color: #2e7d32;
    }
    
    .not-supported {
      background: #ffebee;
      color: #c62828;
    }
    
    .instructions {
      font-size: 14px;
      color: #666;
      line-height: 1.4;
    }
  </style>
</head>
<body>
  <h1>🎵 Get Audio Text</h1>
  <div id="status" class="status">
    <div id="status-text">檢查中...</div>
  </div>
  <div class="instructions">
    <p><strong>支援的網站：</strong></p>
    <ul>
      <li>YouTube</li>
      <li>Instagram</li>
      <li>TikTok</li>
    </ul>
    <p>在支援的網站上，點擊右上角的「轉錄」按鈕即可開始。</p>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

**popup.js:**
```javascript
// popup.js
document.addEventListener('DOMContentLoaded', async () => {
  const statusDiv = document.getElementById('status');
  const statusText = document.getElementById('status-text');
  
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
```

### 步驟 6：建立圖示

你需要建立三個尺寸的圖示檔案：
- `icons/icon-16.png` (16x16 pixels)
- `icons/icon-48.png` (48x48 pixels)  
- `icons/icon-128.png` (128x128 pixels)

可以使用線上圖示產生器或設計軟體建立，建議使用麥克風相關的圖示。

### 步驟 7：安裝到 Chrome

1. **開啟 Chrome 擴充功能頁面**
   - 在 Chrome 網址列輸入：`chrome://extensions/`
   - 或透過選單：更多工具 → 擴充功能

2. **啟用開發者模式**
   - 在頁面右上角開啟「開發者模式」切換按鈕

3. **載入擴充功能**
   - 點擊「載入未封裝項目」
   - 選擇你建立的 `get-audio-text-extension` 資料夾
   - 點擊「選擇資料夾」

4. **驗證安裝**
   - 擴充功能應該出現在列表中
   - 瀏覽器工具列會出現擴充功能圖示

## 🚀 使用方式

1. **前往支援的網站**
   - YouTube: https://www.youtube.com
   - Instagram: https://www.instagram.com  
   - TikTok: https://www.tiktok.com

2. **開始轉錄**
   - 在影片頁面會看到右上角的「轉錄」浮動按鈕
   - 點擊按鈕開始音訊提取和轉錄
   - 等待處理完成後下載逐字稿

## 🔧 故障排除

### 問題：擴充功能無法載入

**解決方案：**
1. 檢查所有檔案是否都在正確位置
2. 確認 `manifest.json` 語法正確
3. 查看 Chrome 擴充功能頁面的錯誤訊息

### 問題：在網站上看不到按鈕

**解決方案：**
1. 重新整理頁面
2. 檢查是否在支援的網站上
3. 在開發者工具的 Console 查看錯誤訊息

### 問題：轉錄功能不工作

**解決方案：**
1. 確認瀏覽器支援 Web Speech API
2. 檢查麥克風權限設定
3. 嘗試在無痕模式下使用

## 📦 打包發布（可選）

如果想要分享給其他人：

1. **壓縮資料夾**
```bash
zip -r get-audio-text-extension.zip get-audio-text-extension/
```

2. **分享安裝說明**
   - 提供 zip 檔案
   - 附上這份安裝指南

## 🔄 更新擴充功能

修改程式碼後：
1. 在 `chrome://extensions/` 頁面
2. 點擊擴充功能的「重新載入」按鈕
3. 重新整理使用中的網頁

這樣就完成了 Chrome 擴充套件的完整安裝流程！