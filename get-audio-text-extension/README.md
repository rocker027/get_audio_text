# Get Audio Text Chrome Extension

音訊轉錄 Chrome 擴展 - 支援 YouTube、Instagram、TikTok 等平台的一鍵音訊提取與轉錄功能。

## 🚀 功能特色

- **一鍵轉錄**：在支援的網站上一鍵提取音訊並轉錄成文字
- **多平台支援**：YouTube、Instagram、TikTok
- **即時進度**：顯示處理進度和狀態
- **自動下載**：轉錄完成後自動下載文字檔案
- **美觀介面**：現代化的浮動按鈕和通知系統

## 📦 安裝方式

### 開發者模式安裝

1. **開啟 Chrome 擴充功能頁面**
   ```
   chrome://extensions/
   ```

2. **啟用開發者模式**
   - 點擊右上角的「開發者模式」切換開關

3. **載入擴充功能**
   - 點擊「載入未封裝項目」
   - 選擇 `get-audio-text-extension` 資料夾
   - 點擊「選擇資料夾」

4. **完成安裝**
   - 擴充功能會出現在列表中
   - 瀏覽器工具列會顯示擴充功能圖示

## 🎯 使用方法

1. **前往支援的網站**：
   - YouTube: https://youtube.com
   - Instagram: https://instagram.com
   - TikTok: https://tiktok.com

2. **開始轉錄**：
   - 在影片頁面會看到右上角的「🎵 轉錄」按鈕
   - 點擊按鈕開始音訊轉錄處理
   - 等待進度條完成

3. **下載結果**：
   - 處理完成後會自動下載轉錄文字檔
   - 檔案名稱包含影片標題和日期

## 📋 檔案結構

```
get-audio-text-extension/
├── manifest.json          # 擴展配置檔案
├── content.js            # 網頁注入腳本
├── content.css           # 樣式檔案
├── background.js         # 後台服務工作程序
├── popup.html           # 彈出視窗 HTML
├── popup.js             # 彈出視窗邏輯
├── icons/               # 圖示資料夾
│   ├── icon.svg         # SVG 圖示原檔
│   └── README.md        # 圖示說明
└── README.md            # 說明文件
```

## ⚙️ 技術實現

### 核心功能

1. **內容腳本注入** (`content.js`)
   - 檢測支援的網站
   - 動態創建轉錄按鈕
   - 處理用戶交互
   - 模擬音訊轉錄流程

2. **樣式設計** (`content.css`)
   - 美觀的按鈕設計
   - 動畫效果
   - 進度條樣式
   - 通知系統

3. **後台服務** (`background.js`)
   - 擴展生命週期管理
   - 檔案下載處理
   - 跨腳本通信

4. **彈出介面** (`popup.html` + `popup.js`)
   - 網站支援狀態檢查
   - 使用說明顯示
   - 擴展狀態監控

### 支援檢測

擴展會自動檢測以下網站：
- `youtube.com/watch` - YouTube 影片頁面
- `instagram.com/p/` - Instagram 貼文
- `instagram.com/reel/` - Instagram Reels  
- `tiktok.com/@*/video/` - TikTok 影片頁面

### 音訊處理模擬

目前版本提供完整的 UI 流程模擬：
1. 影片資訊分析
2. 音訊檔案提取
3. 格式轉換處理
4. 語音辨識轉錄
5. 文字檔案生成
6. 自動下載完成

## 🔧 開發說明

### 擴展權限

- `activeTab`: 存取當前活動分頁
- `storage`: 本地儲存設定
- `downloads`: 檔案下載功能

### 主機權限

- `https://www.youtube.com/*`
- `https://www.instagram.com/*`
- `https://www.tiktok.com/*`

### 自定義設定

可以在 `content.js` 中修改以下配置：

```javascript
const CONFIG = {
  buttonText: '🎵 轉錄',           // 按鈕文字
  buttonId: 'gat-transcribe-btn',  // 按鈕 ID
  // 更多配置選項...
};
```

## 🛠️ 故障排除

### 常見問題

1. **按鈕不顯示**
   - 確認在支援的網站上
   - 重新整理頁面
   - 檢查擴展是否正確安裝

2. **無法下載檔案**
   - 檢查瀏覽器下載設定
   - 確認擴展有下載權限
   - 查看開發者工具的錯誤訊息

3. **擴展無法載入**
   - 檢查 `manifest.json` 語法
   - 確認所有檔案都存在
   - 查看 Chrome 擴展頁面的錯誤

### 調試方法

1. **開發者工具**
   ```
   F12 → Console → 查看錯誤訊息
   ```

2. **擴展調試**
   ```
   chrome://extensions/ → 詳細資料 → 檢查視圖
   ```

## 🔄 更新擴展

修改程式碼後：

1. 前往 `chrome://extensions/`
2. 找到 Get Audio Text 擴展
3. 點擊「重新載入」按鈕
4. 重新整理正在使用的網頁

## 📚 後續開發

### 實際音訊處理整合

要實現真正的音訊轉錄功能，需要：

1. **整合 yt-dlp**：
   - 使用 Native Messaging 與本地腳本通信
   - 或建立 Web API 服務

2. **語音辨識 API**：
   - OpenAI Whisper API
   - Google Speech-to-Text
   - Azure Cognitive Services

3. **後端服務**：
   - 音訊檔案處理服務器
   - 轉錄任務佇列管理
   - 結果儲存和檢索

### 功能擴展

- 支援更多影片平台
- 批次處理功能
- 轉錄結果編輯
- 多語言支援
- 雲端同步功能

## 📝 授權

此專案基於原有的 `get_audio_text.sh` 腳本開發，遵循相同的使用條款。

## 🤝 貢獻

歡迎提交問題報告和功能建議。如需修改代碼，請確保：

1. 遵循現有的程式碼風格
2. 測試所有功能正常運作
3. 更新相關文檔說明

---

**注意**: 此為示範版本，提供完整的 UI 交互體驗。實際的音訊提取和轉錄功能需要額外的後端服務支援。