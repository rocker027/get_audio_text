# ⚠️ 重要免責聲明

**在使用本工具前，請務必仔細閱讀並理解以下條款。**

本專案 (`get_audio_text`) 是一個為個人學習、研究和教育目的而設計的技術工具。其核心功能是自動化處理音訊和影片檔案，包括下載、轉錄和內容分析。

1.  **合法性與版權**：本工具的設計初衷並非用於侵犯版權。使用者應對其所有行為負全部法律責任。您只能將本工具用於：
    *   您擁有完整版權的內容（例如，您自己創作的影片或錄音）。
    *   已進入公共領域 (Public Domain) 的內容。
    *   您已獲得版權持有人明確授權的內容。
    *   在您所在地區法律允許的「合理使用 (Fair Use)」或「公平處理 (Fair Dealing)」範疇內，例如用於個人備份、學術研究、新聞報導或評論。

2.  **遵守平台政策**：從網路平台（如 YouTube, Instagram, TikTok 等）下載內容可能違反其服務條款 (Terms of Service)。在從任何平台下載內容之前，您有責任閱讀並遵守該平台的相關政策。

3.  **無擔保**：本專案按「原樣」提供，不附帶任何明示或暗示的擔保。開發者不保證工具的穩定性、可靠性或適用於任何特定目的。

4.  **責任限制**：對於因使用或無法使用本工具而導致的任何直接或間接損害（包括但不限於資料遺失、商業利潤損失或任何法律糾紛），專案開發者概不負責。

**繼續使用本工具，即表示您已同意並接受上述所有條款，並承諾將合法、合規地使用本工具。如果您不同意這些條款，請立即停止使用並刪除本專案的所有相關檔案。**

---

# Get Audio Text 🎵→📝

![CleanShot 2025-07-02 at 21 57 13@2x](https://github.com/user-attachments/assets/465b17ca-186a-41e2-b77c-a7f39309cd93)

一個強大的音訊轉錄工具，提供命令列和 Web 介面兩種使用方式。它可以從 YouTube、Instagram 等平台下載音訊並自動轉錄成文字逐字稿，並具備 AI 總結功能。

## ✨ 功能特色

### 🖥️ Web 介面
- 🌐 **友善的使用者介面**：直觀的拖放上傳和即時狀態顯示。
- 📊 **即時進度追蹤**：透過詳細日誌可視化處理流程。
- 📋 **Markdown 預覽**：美觀的總結內容顯示和一鍵複製功能。
- 📁 **多種輸入方式**：支援 URL 輸入、檔案上傳和拖放操作。

### 🛠️ 命令列工具
- 🚀 **一站式自動化**：從 URL 到逐字稿，一個指令搞定。
- 🌐 **多平台支援**：YouTube、Instagram、TikTok、Facebook 等。
- 🎯 **智能檔名處理**：自動使用原始標題作為檔名，避免特殊字元問題。
- 🗂️ **自動清理**：轉錄完成後自動刪除音訊檔案，節省空間。

### 🤖 AI 增強功能
- 📄 **多種輸出格式**：支援 TXT、SRT 和 VTT 格式。
- 🧠 **AI 智能總結**：整合 Gemini CLI，自動生成內容總結。
- 🎛️ **靈活選項**：可選擇保留音訊、跳過轉錄、自訂 Whisper 模型等。

## 🛠️ 系統需求

### 必要工具

```bash
# 安裝 yt-dlp（影片下載工具）
brew install yt-dlp

# 安裝 ffmpeg（音訊轉換工具）
brew install ffmpeg

# 安裝 Whisper（語音識別工具）
pip3 install openai-whisper
```

### 系統要求

- macOS / Linux
- Python 3.9+
- 網路連線

### 可選工具

```bash
# 安裝 Gemini CLI（用於 AI 總結功能）
# 依照 Google AI Studio 文件安裝
```

## 📦 安裝與設定

### 1. 下載專案

```bash
# 複製專案
git clone https://github.com/rocker027/get-audio-text.git
cd get-audio-text

# 或下載 ZIP 檔並解壓縮
```

### 2. 設定腳本

腳本首次執行時會引導您完成設定：

```bash
# 賦予執行權限
chmod +x get_audio_text.sh

# 首次執行將進入設定模式
./get_audio_text.sh
```

腳本會要求您設定音訊檔案下載目錄。建議使用預設路徑：
- 預設路徑：`~/Downloads/AudioCapture`
- 逐字稿將儲存在：`~/Downloads/AudioCapture/Transcripts`
- Whisper 模型將快取在：`~/Downloads/AudioCapture/WhisperModel`

### 3. 啟動 Web 介面（可選）

```bash
# 導航到 Web 介面目錄
cd web_interface

# 啟動本地 Web 伺服器
python3 -m http.server 8000 --cgi

# 在瀏覽器中開啟 http://localhost:8000
```

## 🚀 使用方法

### 🖥️ 使用 Web 介面

建議使用 Web 介面以獲得更直觀的體驗：

1.  **啟動 Web 伺服器**
    ```bash
    cd web_interface
    python3 -m http.server 8000 --cgi
    ```

2.  **在瀏覽器中訪問**：`http://localhost:8000`

3.  **使用方式**
    - **URL 輸入**：貼上 YouTube、Instagram 等網址。
    - **檔案上傳**：點擊「瀏覽檔案」或拖放檔案。
    - **即時監控**：查看處理進度和詳細日誌。
    - **結果預覽**：以 Markdown 格式查看總結並一鍵複製。

### 🛠️ 使用命令列

#### 基本使用

```bash
# 下載音訊 + 自動轉錄（預設行為）
./get_audio_text.sh "https://www.youtube.com/watch?v=VIDEO_ID"

# Instagram Reels
./get_audio_text.sh "https://www.instagram.com/reel/POST_ID/"
```

#### 使用本地檔案

```bash
# 轉錄本地影片檔案
./get_audio_text.sh "/path/to/local_video.mp4"

# 轉錄音訊檔案
./get_audio_text.sh "/path/to/audio.mp3"

# 分析逐字稿檔案（直接生成 AI 總結）
./get_audio_text.sh "/path/to/transcript.txt"
```

#### 進階選項

```bash
# 僅下載音訊，不轉錄
./get_audio_text.sh "URL" --no-transcribe

# 轉錄完成後保留音訊檔案
./get_audio_text.sh "URL" --keep-audio

# 跳過 AI 總結
./get_audio_text.sh "URL" --no-summary

# 指定 Whisper 模型（預設為 small）
./get_audio_text.sh "URL" --model base
./get_audio_text.sh "URL" --model medium

# 組合選項
./get_audio_text.sh "URL" --model small --keep-audio --no-summary
```

## 📁 專案結構

```
get-audio-text/
├── 📄 get_audio_text.sh          # 主要轉錄腳本
├── 📄 README.md                 # 專案說明文件（英文）
├── 📄 README.zh-TW.md           # 專案說明文件（繁體中文）
├── 📄 .gitignore                 # Git 忽略設定
└── 📂 web_interface/             # Web 介面
    ├── 📄 index.html             # 主頁面
    ├── 📄 test.html              # CGI 測試頁面
    ├── 📄 README.md              # Web 介面說明文件
    ├── 📂 static/                # 靜態資源
    │   ├── 📄 style.css          # 樣式表
    │   └── 📄 script.js          # 前端邏輯
    ├── 📂 cgi-bin/               # CGI 腳本
    │   ├── 📄 process.py         # 主要處理腳本
    │   ├── 📄 test.py            # 測試腳本
    │   └── 📄 ...                # 其他測試工具
    └── 📂 uploads/               # 暫存檔案上傳
```

### 輸出檔案結構

```
~/Downloads/AudioCapture/         # 預設輸出目錄
├── 📂 Transcripts/               # 逐字稿和總結
│   ├── 影片標題.txt             # 純文字逐字稿
│   ├── 影片標題.srt             # 字幕格式（帶時間戳）
│   ├── 影片標題.vtt             # WebVTT 格式
│   └── 影片標題_summary.txt      # AI 生成的總結
├── 📂 WhisperModel/             # Whisper 模型快取
│   └── [model_name].pt          # 下載的模型檔案
└── 影片標題.mp3                 # 音訊檔案（可選保留）
```

## 💡 使用範例

### 🖥️ Web 介面範例

1.  **處理 YouTube 影片**
    - 在 URL 輸入框中貼上：`https://www.youtube.com/watch?v=dQw4w9WgXcQ`
    - 選擇 Whisper 模型：`small`
    - 點擊「🚀 開始處理」
    - 查看即時進度：下載 → 轉錄 → AI 總結
    - 查看並複製 Markdown 格式的總結。

2.  **處理本地檔案**
    - 將 MP4 檔案拖放到上傳區域。
    - 系統自動偵測檔案類型並進行相應處理。
    - 查看即時狀態和最終結果。

### 🛠️ 命令列範例

#### 轉錄 YouTube 影片

```bash
./get_audio_text.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" --model small
```

**輸出檔案：**
- `Rick Astley - Never Gonna Give You Up.txt`（純文字逐字稿）
- `Rick Astley - Never Gonna Give You Up.srt`（字幕檔）
- `Rick Astley - Never Gonna Give You Up.vtt`（WebVTT 檔）
- `Rick Astley - Never Gonna Give You Up_summary.txt`（AI 總結）

#### 轉錄 Instagram Reel

```bash
./get_audio_text.sh "https://www.instagram.com/reel/ABC123/" --keep-audio
```

**輸出：**
- 完整的逐字稿檔案（3 種格式）
- AI 智能總結
- 原始音訊檔案（因使用 --keep-audio）

#### 處理本地檔案

```bash
# 處理本地影片
./get_audio_text.sh "/path/to/video.mp4"

# 處理音訊檔案
./get_audio_text.sh "/path/to/audio.mp3"

# 分析現有逐字稿
./get_audio_text.sh "/path/to/transcript.vtt"
```

## ⚙️ 參數參考

### 命令列參數

| 參數 | 說明 | 範例 |
|---|---|---|
| `--model [model_name]` | 指定 Whisper 模型 (tiny, base, small, medium, large)。預設：`small` | `./get_audio_text.sh "URL" --model base` |
| `--no-transcribe` | 僅下載音訊，跳過轉錄 | `./get_audio_text.sh "URL" --no-transcribe` |
| `--keep-audio` | 轉錄後保留音訊檔案 | `./get_audio_text.sh "URL" --keep-audio` |
| `--no-summary` | 跳過生成 AI 總結 | `./get_audio_text.sh "URL" --no-summary` |

### Whisper 模型比較

| 模型 | 大小 | 速度 | 準確度 | 建議用途 |
|---|---|---|---|---|
| `tiny` | ~39 MB | 最快 | 較低 | 快速測試 |
| `base` | ~74 MB | 快 | 一般 | 日常使用 |
| `small` | ~244 MB | 中等 | 良好 | **推薦預設** |
| `medium` | ~769 MB | 慢 | 很好 | 高品質需求 |
| `large` | ~1550 MB | 最慢 | 最佳 | 專業用途 |

### Web 介面選項

- **Whisper 模型**：從下拉選單中選擇。
- **保留音訊檔案**：轉錄後是否保留音訊。
- **僅下載，跳過轉錄**：只下載，不轉錄。
- **跳過 AI 總結**：不生成 Gemini 總結。

## 🌍 支援格式與平台

### 📱 支援平台

| 平台 | 支援狀況 | 備註 |
|---|---|---|
| ✅ YouTube | 完全支援 | 公開影片、Shorts |
| ✅ Instagram | 公開內容 | 公開貼文、Reels、Stories |
| ✅ TikTok | 完全支援 | 公開影片 |
| ✅ Facebook | 部分支援 | 公開影片 |
| ✅ Twitter/X | 部分支援 | 公開影片 |
| ✅ 其他 | 有限支援 | 依 yt-dlp 支援度 |

### 📁 支援檔案格式

#### 影片格式
- **完全支援**：MP4, AVI, MKV, MOV, WMV, FLV, WEBM, M4V, 3GP, OGV

#### 音訊格式
- **完全支援**：MP3, WAV, FLAC, AAC, OGG, M4A, WMA, OPUS

#### 逐字稿格式
- **直接分析**：TXT, VTT, SRT（支援直接 AI 總結，無需轉錄）

### 🔄 處理流程

1.  **線上影片** → 下載音訊 → Whisper 轉錄 → AI 總結
2.  **本地影片** → 提取音訊 → Whisper 轉錄 → AI 總結
3.  **本地音訊** → Whisper 轉錄 → AI 總結
4.  **逐字稿檔案** → 直接 AI 總結

## 🔧 進階設定

### 修改輸出路徑

腳本首次執行時會引導您設定，但您也可以手動編輯設定檔：

```bash
# 設定檔位置
~/.get_audio_text_config

# 內容格式
AUDIO_DIR="/your/custom/path/AudioCapture"
TRANSCRIPT_DIR="/your/custom/path/AudioCapture/Transcripts"
WHISPER_MODEL_DIR="/your/custom/path/AudioCapture/WhisperModel"
```

### Web 介面設定

Web 介面會自動使用命令列腳本的設定。無需額外配置。

### Gemini AI 設定

若要使用 AI 總結功能，您需要先設定 Gemini CLI：

```bash
# 安裝 Gemini CLI（請參考 Google AI Studio 文件）
# 設定您的 API 金鑰
export GOOGLE_API_KEY="your-api-key"
```

## 🐛 常見問題與疑難排解

### 安裝問題

**Q: 提示缺少工具？**
```bash
# 檢查工具安裝狀況
yt-dlp --version
ffmpeg -version
whisper --help

# 重新安裝
brew install yt-dlp ffmpeg
pip3 install openai-whisper
```

**Q: Web 介面無法啟動？**
```bash
# 確保您在正確的目錄中
cd web_interface

# 確保使用 --cgi 參數
python3 -m http.server 8000 --cgi

# 檢查瀏覽器訪問 http://localhost:8000
```

### 使用問題

**Q: 找不到下載的檔案？**
- 檢查設定檔：`~/.get_audio_text_config`
- 確保目錄存在且有寫入權限。
- 預設位置：`~/Downloads/AudioCapture/Transcripts/`

**Q: Instagram/TikTok 下載失敗？**
- 確保內容是公開的。
- 檢查 URL 格式是否正確。
- 確保您的網路連線正常。
- 嘗試更新 yt-dlp：`brew upgrade yt-dlp`

**Q: Web 介面卡在「準備中」？**
- 使用 `http://localhost:8000/test.html` 診斷 CGI 環境。
- 檢查 Python 路徑和權限。
- 確保 `get_audio_text.sh` 具有執行權限。

### 效能問題

**Q: Whisper 轉錄速度很慢？**
- 使用較小的模型（`tiny` 或 `base`）。
- 首次使用模型需要下載，這需要時間。
- 確保您有足夠的記憶體和 CPU 資源。

**Q: AI 總結未生成？**
- 檢查是否已安裝 Gemini CLI。
- 確認 API 金鑰設定正確。
- 您可以使用 `--no-summary` 跳過總結功能。

## 🔧 開發與貢獻

### 專案技術棧

- **命令列腳本**：Bash Shell Script
- **Web 前端**：HTML5, CSS3, JavaScript (原生)
- **Web 後端**：Python CGI
- **音訊處理**：yt-dlp, ffmpeg, OpenAI Whisper
- **AI 整合**：Gemini CLI

### 開發環境設定

```bash
# 複製專案
git clone https://github.com/rocker027/get-audio-text.git
cd get-audio-text

# 設定腳本權限
chmod +x get_audio_text.sh

# 測試命令列功能
./get_audio_text.sh

# 測試 Web 介面
cd web_interface
python3 -m http.server 8000 --cgi
```

### 貢獻指南

歡迎提交 Issue 和 Pull Request！

1.  **回報問題**：使用 GitHub Issues。
2.  **功能建議**：詳細描述需求和使用情境。
3.  **程式碼貢獻**：請遵循現有的程式碼風格。

## 🙏 致謝與第三方授權

本專案的實現依賴於以下幾個優秀的開源工具。我們對這些專案的開發者表示衷心的感謝。使用者在使用本工具時，也應遵守這些第三方工具的授權條款。

-   **yt-dlp**
    -   **用途**：從網路平台下載影片和音訊。
    -   **授權**：The Unlicense (Public Domain)
    -   **專案連結**：[https://github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)

-   **FFmpeg**
    -   **用途**：音訊提取與格式轉換。
    -   **授權**：GNU Lesser General Public License (LGPL) version 2.1 or later / GNU General Public License (GPL) version 2 or later。
    -   **專案連結**：[https://ffmpeg.org/](https://ffmpeg.org/)

-   **OpenAI Whisper**
    -   **用途**：語音轉文字辨識。
    -   **授權**：MIT License
    -   **專案連結**：[https://github.com/openai/whisper](https://github.com/openai/whisper)

-   **Google Gemini**
    -   **用途**：AI 內容總結。
    -   **授權**：Apache License 2.0
    -   **專案連結**：[https://ai.google.dev/](https://ai.google.dev/)

---

## 📄 授權與使用條款

### 授權條款

本專案採用 **MIT 授權條款**。您可以自由使用、修改和分發。

### 重要聲明

- ⚖️ **法律合規**：請遵守各平台的使用條款。
- 🎓 **用途限制**：僅用於個人學習、研究和合法用途。
- 📄 **版權尊重**：請尊重版權，不要下載未經授權的內容。
- 🚫 **責任聲明**：使用者須自行承擔使用本工具的風險。

## 📞 支援與回饋

### 取得協助

1.  📖 查看 [常見問題](#-常見問題與疑難排解) 章節。
2.  🐛 提交 [GitHub Issue](https://github.com/rocker027/get-audio-text/issues)。
3.  📚 參考 [yt-dlp 文件](https://github.com/yt-dlp/yt-dlp) 了解平台支援。
4.  🧪 使用 `http://localhost:8000/test.html` 診斷問題。

### 功能亮點

- 🖥️ **雙模式**：命令列 + Web 介面
- 🎯 **智能化**：自動檔案類型偵測
- 🤖 **AI 增強**：Gemini 智能總結
- 📊 **可視化**：即時進度和狀態顯示
- 🔧 **使用者友善**：一鍵安裝和自動設定

---

**⭐ 如果這個工具對您有幫助，請給個 Star 支持我們！**

**🚀 讓音訊轉錄變得更簡單、更智能！**
