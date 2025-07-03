# 文字訊息對照表

## 已提取的訊息分類

### 1. 主要操作訊息
- `MSG_WELCOME` - "歡迎使用音訊轉錄工具！"
- `MSG_PROCESSING_COMPLETE` - "一條龍處理完成！"
- `MSG_SETUP_COMPLETE` - "設定完成！"

### 2. 設定和配置
- `MSG_FIRST_SETUP` - "首次使用需要設定下載目錄"
- `MSG_CONFIG_LOAD` - "載入現有設定"
- `MSG_CONFIG_NOT_FOUND` - "未找到設定檔，進入初次設定..."
- `MSG_CONFIG_SAVED` - "設定已儲存至"

### 3. 檔案和目錄處理
- `MSG_FILE_EXISTS` - "檔案存在性檢查通過"
- `MSG_FILE_NOT_EXIST` - "檔案不存在"
- `MSG_DIRECTORY_NOT_EXIST` - "目錄不存在"
- `MSG_DIRECTORY_CREATED` - "目錄建立成功"

### 4. 平台偵測
- `MSG_PLATFORM_YOUTUBE` - "YouTube"
- `MSG_PLATFORM_INSTAGRAM` - "Instagram"
- `MSG_PLATFORM_TIKTOK` - "TikTok"
- `MSG_PLATFORM_OTHER` - "其他平台"

### 5. 處理流程
- `MSG_DOWNLOAD_STEP` - "步驟 1/2: 下載音訊..."
- `MSG_TRANSCRIBE_STEP` - "步驟 2/2: 開始轉錄..."
- `MSG_PROCESS_VIDEO` - "影片 → 音訊提取 → Whisper 轉錄 → AI 分析"
- `MSG_PROCESS_AUDIO` - "音訊 → Whisper 轉錄 → AI 分析"
- `MSG_PROCESS_TRANSCRIPT` - "逐字稿 → AI 分析"

### 6. 轉錄和 AI 分析
- `MSG_TRANSCRIBE_COMPLETE` - "轉錄完成！"
- `MSG_AI_ANALYSIS_START` - "開始 AI 分析..."
- `MSG_GEMINI_SUMMARY_START` - "開始使用 Gemini 生成總結..."
- `MSG_WHISPER_MODEL_NOT_EXIST` - "Whisper 模型不存在"

### 7. 錯誤和警告
- `MSG_ERROR_POSSIBLE_REASONS` - "可能原因:"
- `MSG_ERROR_SUGGESTIONS` - "建議:"
- `MSG_ERROR_URL_FORMAT` - "URL 格式錯誤"
- `MSG_ERROR_NETWORK` - "網路連線問題"

### 8. 使用說明
- `MSG_USAGE_TITLE` - "使用方法:"
- `MSG_USAGE_SOURCES` - "支援來源:"
- `MSG_USAGE_PARAMETERS` - "參數說明:"
- `MSG_USAGE_EXAMPLES` - "範例:"

### 9. 互動提示
- `MSG_PROMPT_PATH` - "📁 路徑: "
- `MSG_PROMPT_CREATE_DIR` - "是否建立此目錄？ (Y/n): "
- `MSG_PROMPT_OPEN_TRANSCRIPT` - "要開啟逐字稿資料夾嗎？ (y/N): "

### 10. 狀態指示
- `MSG_STATUS_SUCCESS` - "✅"
- `MSG_STATUS_ERROR` - "❌"
- `MSG_STATUS_WARNING` - "⚠️"
- `MSG_STATUS_INFO` - "ℹ️"

## 訊息覆蓋率分析

✅ **已完成**：
- 主要功能訊息 (100%)
- 錯誤處理訊息 (100%)
- 使用說明訊息 (100%)
- 互動提示訊息 (100%)
- 狀態指示訊息 (100%)

## 特殊處理項目

### 動態文字處理
- 檔案路徑：使用變數插值
- 時間戳：保持動態生成
- 模型名稱：使用 `$WHISPER_MODEL_NAME` 變數

### 保留項目
- 彩色輸出代碼 (如 `${RED}`, `${GREEN}`)
- 特殊符號 (如 emoji)
- 格式化字符 (如 `\n`, `\t`)

### 多語言考量
- 支援不同語言的文字方向
- 保持一致的術語翻譯
- 考慮文化差異的表達方式