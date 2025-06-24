# Native Messaging 故障排除指南

當出現「⚠️ 本地轉錄失敗，使用模擬模式...」錯誤時，請按照以下步驟診斷和修復。

## 🚨 常見錯誤和解決方案

### 1. 擴展 ID 不匹配

**現象**: Chrome 擴展無法連接到 Native Host

**原因**: `host_manifest.json` 中的擴展 ID 與實際擴展 ID 不符

**解決方案**:
```bash
# 自動檢測並更新擴展 ID
./detect_extension_id.sh

# 或手動更新（從 chrome://extensions/ 複製 ID）
./update_extension_id.sh [你的擴展ID]
```

### 2. Native Host 未安裝

**現象**: Chrome 無法找到 Native Host

**原因**: Native Host 沒有正確註冊到 Chrome

**解決方案**:
```bash
# 重新安裝 Native Host
./install.sh
```

### 3. 音訊目錄未配置

**現象**: 腳本執行失敗，提示目錄錯誤

**原因**: `get_audio_text.sh` 中的 `AUDIO_DIR` 仍為佔位符

**解決方案**:
```bash
# 配置音訊目錄
./configure_audio_dir.sh
```

### 4. 系統依賴缺失

**現象**: 依賴檢查失敗

**原因**: 缺少 yt-dlp、ffmpeg 或 whisper

**解決方案**:
```bash
# 安裝依賴
brew install yt-dlp ffmpeg
pip3 install openai-whisper
```

### 5. 檔案權限問題

**現象**: Python 腳本或主腳本無法執行

**原因**: 檔案沒有執行權限

**解決方案**:
```bash
# 設置權限
chmod +x get_audio_text_host.py
chmod +x ../../get_audio_text.sh
```

## 🔍 診斷工具

### 快速診斷
```bash
# 執行完整測試
./test_native_host.sh
```

### 手動檢查步驟

#### 1. 檢查擴展狀態
1. 前往 `chrome://extensions/`
2. 確認 Get Audio Text 擴展已啟用
3. 複製擴展 ID（開啟開發者模式後可見）

#### 2. 檢查 Native Host 註冊
```bash
# macOS
ls -la "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/"

# Linux
ls -la "$HOME/.config/google-chrome/NativeMessagingHosts/"
```

應該看到 `com.get_audio_text.host.json` 檔案。

#### 3. 檢查檔案內容
```bash
# 檢查 manifest 內容
cat native-host/host_manifest.json

# 檢查已安裝的 manifest
cat "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.get_audio_text.host.json"
```

#### 4. 測試 Python 腳本
```bash
# 測試依賴檢查
echo '{"action":"check_dependencies"}' | python3 get_audio_text_host.py
```

#### 5. 檢查 Chrome 控制台
1. 在擴展頁面點擊「檢查視圖」→「service worker」
2. 或在網頁上按 F12 打開開發者工具
3. 查看 Console 中的錯誤訊息

## 📊 錯誤代碼對照表

| 錯誤訊息 | 可能原因 | 解決方案 |
|---------|---------|---------|
| `Native Messaging 不可用` | Chrome 版本過舊或權限問題 | 更新 Chrome，檢查 manifest 權限 |
| `Native Messaging 超時` | Python 腳本卡住或路徑錯誤 | 檢查腳本路徑和執行權限 |
| `系統依賴檢查失敗` | 缺少 yt-dlp/ffmpeg/whisper | 安裝對應工具 |
| `找不到腳本` | 主腳本路徑錯誤 | 檢查 get_audio_text.sh 位置 |
| `無法識別當前頁面的影片` | 網站不支援或頁面載入問題 | 重新整理頁面，確認支援網站 |

## 🔧 進階調試

### 啟用詳細日誌
編輯 `get_audio_text_host.py`，在開頭添加：
```python
import logging
logging.basicConfig(
    filename=os.path.expanduser('~/get_audio_text_debug.log'),
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
```

### 檢查日誌檔案
```bash
# 查看 Native Host 日誌
tail -f ~/get_audio_text_host.log

# 查看詳細調試日誌（如果啟用）
tail -f ~/get_audio_text_debug.log
```

### Chrome 擴展調試
1. 前往 `chrome://extensions/`
2. 點擊 Get Audio Text 的「詳細資料」
3. 點擊「檢查視圖」→「service worker」
4. 在 Console 中執行：
```javascript
chrome.runtime.sendNativeMessage(
  'com.get_audio_text.host',
  {action: 'check_dependencies'},
  response => console.log(response)
);
```

## 🛠️ 重置和重新安裝

### 完全重置
```bash
# 1. 移除已安裝的 Native Host
rm -f "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.get_audio_text.host.json"

# 2. 重新檢測擴展 ID
./detect_extension_id.sh

# 3. 配置音訊目錄
./configure_audio_dir.sh

# 4. 重新安裝
./install.sh

# 5. 測試安裝
./test_native_host.sh
```

### 驗證安裝
1. 重新載入 Chrome 擴展
2. 前往 YouTube 測試頁面
3. 點擊轉錄按鈕
4. 觀察是否出現「檢查系統依賴...」而非直接進入模擬模式

## 📞 尋求協助

如果仍然無法解決問題，請提供以下資訊：

1. **系統資訊**:
   - 作業系統版本
   - Chrome 版本
   - Python 版本

2. **錯誤日誌**:
   ```bash
   # 收集所有相關日誌
   ./test_native_host.sh > debug_report.txt 2>&1
   ```

3. **配置資訊**:
   ```bash
   # 檢查當前配置
   echo "=== Host Manifest ===" >> debug_report.txt
   cat host_manifest.json >> debug_report.txt
   echo "=== Installed Manifest ===" >> debug_report.txt
   cat "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.get_audio_text.host.json" >> debug_report.txt 2>/dev/null || echo "Not installed" >> debug_report.txt
   ```

4. **Chrome 控制台錯誤**: 截圖或複製完整錯誤訊息

將 `debug_report.txt` 和相關錯誤資訊一起提供，有助於快速診斷問題。