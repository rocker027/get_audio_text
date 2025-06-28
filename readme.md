# Get Audio Text 🎵→📝

一個強大的一條龍自動化工具，可以從 YouTube、Instagram 等平台下載音訊並自動轉錄成文字逐字稿。

## ✨ 功能特色

- 🚀 **一條龍自動化**：從 URL 到逐字稿，一個指令搞定
- 🌐 **多平台支援**：YouTube、Instagram、TikTok、Facebook 等
- 🎯 **智能檔名處理**：避免特殊字元問題，自動使用原始標題命名
- 🗂️ **自動清理**：轉錄完成後自動刪除音訊檔案，節省空間
- 📄 **多格式輸出**：支援 TXT、SRT、VTT 格式
- 🎛️ **靈活選項**：可選擇保留音訊、跳過轉錄等

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

## 📦 安裝

1. **下載腳本**

```bash
# 建立工具目錄
mkdir -p ~/get_audio_text
cd ~/get_audio_text

# 下載腳本
curl -o get_audio_text.sh https://your-repo-url/get_audio_text.sh

# 賦予執行權限
chmod +x get_audio_text.sh
```

2. **設定路徑**

```bash
# 修改腳本中的路徑設定
sed -i 's|abs_path_to_audio_dir|/Users/$USER/Downloads/CaptureAudio|g' get_audio_text.sh
```

3. **建立全域指令（可選）**

```bash
# 建立符號連結，可在任何地方使用
sudo ln -s ~/get_audio_text.sh /usr/local/bin/get_audio_text
```

## 🚀 使用方法

### 基本使用

```bash
# 下載音訊 + 自動轉錄（預設行為）
./get_audio_text.sh "https://www.youtube.com/watch?v=VIDEO_ID"

# 使用全域指令
get_audio_text "https://www.instagram.com/p/POST_ID/"
```

### 使用本地檔案

```bash
# 轉錄本地影片檔案
./get_audio_text.sh "/path/to/local_video.mp4"

# 假設影片位於當前目錄
./get_audio_text.sh "local_video.mp4"
```

### 進階選項

```bash
# 僅下載音訊，不轉錄
./get_audio_text.sh "URL" --no-transcribe

# 轉錄完成後保留音訊檔案
./get_audio_text.sh "URL" --keep-audio

# 完成後詢問是否開啟資料夾
./get_audio_text.sh "URL" --open-folder

# 組合使用
./get_audio_text.sh "URL" --keep-audio --open-folder
```

## 📁 檔案結構

```
📂 CaptureAudio/
├── 📂 Transcripts/           # 逐字稿輸出目錄
│   ├── 影片標題.txt         # 純文字逐字稿
│   ├── 影片標題.srt         # 字幕格式（時間軸）
│   └── 影片標題.vtt         # 網頁字幕格式
└── 影片標題.mp3             # 音訊檔案（使用 --keep-audio 時保留）
```

## 💡 使用範例

### YouTube 影片轉錄

```bash
get_audio_text "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

**輸出：**
- `Rick Astley - Never Gonna Give You Up.txt`
- `Rick Astley - Never Gonna Give You Up.srt`
- `Rick Astley - Never Gonna Give You Up.vtt`

### Instagram Reels 轉錄

```bash
get_audio_text "https://www.instagram.com/reel/ABC123/" --keep-audio
```

**輸出：**
- 逐字稿檔案（3種格式）
- 原始音訊檔案（因使用 --keep-audio）

### 批次處理

```bash
# 建立 URL 清單
echo "https://www.youtube.com/watch?v=VIDEO1" > urls.txt
echo "https://www.youtube.com/watch?v=VIDEO2" >> urls.txt

# 批次處理
while read url; do
    get_audio_text "$url"
    sleep 5  # 避免請求過於頻繁
done < urls.txt
```

## ⚙️ 參數說明

| 參數 | 說明 | 範例 |
|------|------|------|
| `--no-transcribe` | 僅下載音訊，跳過轉錄 | `get_audio_text "URL" --no-transcribe` |
| `--keep-audio` | 轉錄完成後保留音訊檔案 | `get_audio_text "URL" --keep-audio` |
| `--open-folder` | 完成後詢問是否開啟資料夾 | `get_audio_text "URL" --open-folder` |

## 🌍 支援平台

| 平台 | 支援狀況 | 說明 |
|------|----------|------|
| ✅ YouTube | 完全支援 | 公開影片 |
| ✅ Instagram | 公開內容 | 公開貼文、Reels |
| ✅ TikTok | 完全支援 | 公開影片 |
| ✅ Facebook | 部分支援 | 公開影片 |
| ✅ Twitter | 部分支援 | 公開影片 |
| ✅ 其他 | 有限支援 | 依 yt-dlp 支援度 |

## 🔧 自訂設定

### 修改輸出路徑

編輯腳本開頭的路徑設定：

```bash
# 修改音訊下載目錄
AUDIO_DIR="/your/custom/path/Audio"

# 逐字稿會自動建立在 $AUDIO_DIR/Transcripts/
```

### 調整 Whisper 模型

在腳本中找到 `--model medium` 並修改：

```bash
# 可選模型大小（速度 vs 準確度）
--model tiny    # 最快，準確度最低
--model small   # 推薦用於中文
--model medium  # 預設，平衡速度和準確度
--model large   # 最慢，準確度最高
```

## 🐛 常見問題

### Q: 提示缺少工具？

**A:** 請確保已安裝所有必要工具：

```bash
# 檢查工具安裝狀況
yt-dlp --version
ffmpeg -version
whisper --help
```

### Q: 找不到下載的檔案？

**A:** 檢查腳本中的路徑設定是否正確，確保目錄存在且有寫入權限。

### Q: Instagram 影片下載失敗？

**A:** 請確認：
- 影片為公開內容
- URL 格式正確
- 網路連線正常

### Q: Whisper 轉錄速度很慢？

**A:** 可以嘗試：
- 使用較小的模型（如 `small`）
- 確保電腦有足夠的記憶體
- 第一次使用會下載模型檔案

## 📄 授權條款

本專案採用 MIT 授權條款。

**注意事項：**
- 請遵守各平台的使用條款
- 僅用於個人學習和研究用途
- 請尊重版權，不要下載未授權內容

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！

### 開發環境設定

```bash
git clone https://github.com/your-username/get-audio-text.git
cd get-audio-text
chmod +x get_audio_text.sh
```

## 📞 支援

如果遇到問題，請：

1. 檢查 [常見問題](#-常見問題) 章節
2. 提交 [GitHub Issue](https://github.com/your-username/get-audio-text/issues)
3. 查看 [yt-dlp 文檔](https://github.com/yt-dlp/yt-dlp) 了解支援的網站

---

**⭐ 如果這個工具對你有幫助，請給個 Star！**
