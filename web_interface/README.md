# 音頻轉錄 Web 界面

這是一個基於 Python CGI 的本地端 Web 界面，提供友善的 UI 來使用 `get_audio_text.sh` 腳本進行音頻轉錄。

## 功能特色

- **多樣化輸入**：支援 URL 輸入或本地檔案上傳
- **拖拉上傳**：直接拖拉檔案到指定區域
- **即時狀態**：顯示處理進度和詳細日誌
- **Markdown 預覽**：美觀的總結內容預覽
- **一鍵複製**：複製 Markdown 內容到剪貼簿
- **響應式設計**：適配各種螢幕尺寸

## 支援格式

### 影片格式
- MP4, AVI, MKV, MOV, WMV, FLV, WEBM, M4V, 3GP, OGV

### 音頻格式  
- MP3, WAV, FLAC, AAC, OGG, M4A, WMA, OPUS

### 逐字稿格式
- TXT, VTT, SRT

### 線上平台
- YouTube
- Instagram（公開內容）
- TikTok
- Facebook
- 其他 yt-dlp 支援的平台

## 安裝與使用

### 1. 確保依賴項已安裝

```bash
# 安裝必要工具
brew install yt-dlp ffmpeg
pip3 install openai-whisper

# 確保 get_audio_text.sh 已正確設定
./get_audio_text.sh --help
```

### 2. 啟動 Web 服務

```bash
cd web_interface
python3 -m http.server 8000 --cgi
```

### 3. 開啟瀏覽器

訪問 `http://localhost:8000` 即可使用 Web 界面。

## 使用說明

### 輸入來源
1. **線上影片**：在 URL 輸入框中貼上影片連結
2. **本地檔案**：點擊「瀏覽檔案」或直接拖拉檔案到上傳區域

### 處理選項
- **Whisper 模型**：選擇轉錄精度（tiny 最快，large 最準確）
- **保留音頻檔案**：轉錄完成後是否保留音頻文件
- **僅下載**：只下載不轉錄
- **跳過 AI 總結**：不產生 Gemini 總結

### 處理流程
1. 填寫輸入來源和選項
2. 點擊「開始處理」
3. 觀察即時處理狀態
4. 查看 Markdown 格式的總結結果
5. 使用複製按鈕將內容複製到剪貼簿

## 技術架構

### 前端
- **HTML5**：語義化結構
- **CSS3**：現代化 UI 設計
- **JavaScript**：互動邏輯和狀態管理
- **marked.js**：Markdown 渲染

### 後端
- **Python CGI**：處理表單提交
- **subprocess**：執行 shell 腳本
- **即時輸出**：串流處理狀態更新

### 檔案結構
```
web_interface/
├── index.html              # 主頁面
├── static/
│   ├── style.css          # 樣式檔案
│   └── script.js          # 前端邏輯
├── cgi-bin/
│   └── process.py         # CGI 處理腳本
├── uploads/               # 上傳檔案暫存
└── README.md              # 說明文件
```

## 注意事項

1. **檔案權限**：確保 CGI 腳本有執行權限
2. **相對路徑**：CGI 腳本會自動定位到正確的 `get_audio_text.sh` 位置
3. **檔案清理**：上傳的檔案會在處理完成後自動清理
4. **瀏覽器支援**：建議使用現代瀏覽器以獲得最佳體驗

## 疑難排解

### 常見問題

**Q: 無法啟動 CGI 服務**  
A: 確保在 `web_interface` 目錄中執行 `python3 -m http.server 8000 --cgi`

**Q: 處理失敗**  
A: 檢查 `get_audio_text.sh` 是否正確設定，以及所有依賴項是否已安裝

**Q: 無法複製內容**  
A: 部分瀏覽器需要 HTTPS 才能使用剪貼簿 API，會自動降級到手動選擇模式

### 日誌查看
處理過程中的詳細日誌會顯示在 Web 界面的狀態區域中，有助於診斷問題。

## 開發與客製化

### 修改 UI 樣式
編輯 `static/style.css` 檔案來自定義界面外觀。

### 擴展功能
- 修改 `static/script.js` 新增前端功能
- 修改 `cgi-bin/process.py` 新增後端處理邏輯

### 新增支援格式
在 `process.py` 中的檔案類型檢查邏輯中添加新的副檔名支援。