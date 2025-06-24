# Native Messaging Host 設置指南

本目錄包含了 Chrome 擴展與本地 `get_audio_text.sh` 腳本整合所需的 Native Messaging Host。

## 🏗️ 架構說明

```
Chrome Extension → Native Messaging → Python Bridge → get_audio_text.sh → yt-dlp/Whisper
```

### 檔案說明

- `get_audio_text_host.py`: Python 橋接程序，處理 Chrome 與本地腳本的通信
- `host_manifest.json`: Native Host 配置檔案
- `install.sh`: 自動安裝腳本
- `README.md`: 本說明檔案

## 🚀 快速安裝

### 1. 確認前置條件

確保已安裝必要工具：
```bash
# 檢查工具是否已安裝
yt-dlp --version
ffmpeg -version
whisper --help

# 如果沒有安裝，請執行：
brew install yt-dlp ffmpeg
pip3 install openai-whisper
```

### 2. 配置主腳本

確認 `get_audio_text.sh` 中的音訊目錄路徑已正確設置：
```bash
# 編輯主腳本
nano ../../get_audio_text.sh

# 將 AUDIO_DIR 設置為絕對路徑
AUDIO_DIR="/Users/yourusername/Downloads/AudioCapture"
```

### 3. 執行安裝

```bash
cd native-host
./install.sh
```

安裝腳本會：
- 檢查所有依賴
- 設置正確的檔案權限
- 將 Native Host 註冊到 Chrome
- 執行安裝測試

### 4. 重新載入擴展

1. 前往 `chrome://extensions/`
2. 找到 Get Audio Text 擴展
3. 點擊「重新載入」按鈕

## 🔧 手動安裝（進階）

如果自動安裝失敗，可以手動執行以下步驟：

### 1. 註冊 Native Host

```bash
# 建立 Chrome Native Messaging 目錄
mkdir -p "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"

# 複製並更新 manifest
cp host_manifest.json "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.get_audio_text.host.json"

# 編輯 manifest 中的路徑
nano "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.get_audio_text.host.json"
```

### 2. 更新路徑

在 manifest 中將 `path` 更新為實際路徑：
```json
{
  "name": "com.get_audio_text.host",
  "description": "Get Audio Text Native Host",
  "path": "/Users/rocker/Documents/get_audio_text/get-audio-text-extension/native-host/get_audio_text_host.py",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://你的擴展ID/"
  ]
}
```

### 3. 設置權限

```bash
chmod +x get_audio_text_host.py
chmod +x ../../get_audio_text.sh
```

## 🧪 測試安裝

### 測試 Native Host

```bash
# 測試 Python 橋接程序
echo '{"action":"check_dependencies"}' | python3 get_audio_text_host.py
```

### 測試完整流程

1. 前往 YouTube 頁面
2. 點擊擴展的轉錄按鈕
3. 觀察是否顯示「檢查系統依賴...」
4. 檢查是否能正常下載和轉錄

## 🐛 故障排除

### 常見錯誤

#### 1. "Native Messaging 不可用"
- 檢查 manifest.json 中是否有 `"nativeMessaging"` 權限
- 確認 Native Host 已正確安裝

#### 2. "系統依賴檢查失敗"
- 檢查 yt-dlp, ffmpeg, whisper 是否已安裝
- 確認 get_audio_text.sh 有執行權限

#### 3. "找不到腳本"
- 檢查 host_manifest.json 中的路徑是否正確
- 確認 get_audio_text_host.py 存在且可執行

#### 4. 擴展 ID 不匹配
- 在 Chrome 擴展頁面複製實際的擴展 ID
- 更新 host_manifest.json 中的 allowed_origins

### 日誌檢查

查看錯誤日誌：
```bash
tail -f ~/get_audio_text_host.log
```

查看 Chrome 控制台：
- 在擴展頁面點擊「檢查視圖」
- 查看 Console 中的錯誤信息

## 📁 目錄結構

```
native-host/
├── get_audio_text_host.py    # Python 橋接程序
├── host_manifest.json        # Native Host 配置
├── install.sh               # 安裝腳本
└── README.md                # 本說明檔案

../../get_audio_text.sh      # 主要音訊處理腳本
```

## 🔧 自訂配置

### 修改超時時間

在 `get_audio_text_host.py` 中修改：
```python
TIMEOUT = 300  # 5分鐘超時
```

### 調整音訊目錄

在 `../../get_audio_text.sh` 中修改：
```bash
AUDIO_DIR="/path/to/your/audio/directory"
```

### 添加更多平台支援

1. 修改 content.js 中的支援網站列表
2. 更新 manifest.json 中的 host_permissions

## 📞 支援

如果遇到問題：

1. 檢查所有依賴是否正確安裝
2. 確認檔案路徑和權限設置
3. 查看錯誤日誌檔案
4. 重新執行安裝腳本

更多技術細節請參考：
- [Chrome Native Messaging 文檔](https://developer.chrome.com/docs/apps/nativeMessaging/)
- [get_audio_text.sh 使用說明](../../README.md)