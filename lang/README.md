# 多語言支援說明

## 概述

本工具支援多語言介面，目前支援：
- 繁體中文（台灣）- `zh_TW`
- 英文（美國）- `en_US`

## 使用方法

### 自動語言偵測
系統會自動偵測您的語言偏好，順序如下：
1. 用戶設定檔 (`~/.get_audio_text_i18n`)
2. 系統環境變數 (`LANG`, `LC_ALL`, `LC_MESSAGES`)
3. macOS 系統設定
4. 預設為繁體中文

### 手動切換語言

#### 方法 1：設定檔
```bash
# 切換到英文
echo 'PREFERRED_LANG="en_US"' > ~/.get_audio_text_i18n

# 切換到繁體中文
echo 'PREFERRED_LANG="zh_TW"' > ~/.get_audio_text_i18n
```

#### 方法 2：互動式選擇
```bash
# 載入 i18n 模組並開啟互動選擇
source lang/i18n.sh
init_i18n
interactive_language_selection
```

### 程式設計介面

#### 載入翻譯系統
```bash
source "path/to/lang/i18n.sh"
init_i18n
```

#### 使用翻譯函數
```bash
# 基本用法
echo "$(t MSG_WELCOME)"

# 帶預設值的用法
echo "$(t MSG_UNKNOWN_KEY "預設文字")"
```

#### 獲取語言資訊
```bash
# 取得目前語言
current_lang=$(get_current_language)

# 列出支援的語言
list_supported_languages

# 獲取語言顯示名稱
display_name=$(get_language_display_name "zh_TW")
```

## 語言檔案結構

### 檔案位置
```
lang/
├── i18n.sh          # 核心翻譯引擎
├── zh_TW.sh         # 繁體中文翻譯
├── en_US.sh         # 英文翻譯
├── README.md        # 說明文件
└── messages_mapping.md  # 訊息對照表
```

### 訊息分類
- `MSG_WELCOME` - 歡迎訊息
- `MSG_STATUS_*` - 狀態指示符
- `MSG_CONFIG_*` - 設定相關
- `MSG_ERROR_*` - 錯誤訊息
- `MSG_USAGE_*` - 使用說明
- `MSG_PARAM_*` - 參數說明
- `MSG_PROMPT_*` - 互動提示

## 新增語言支援

### 1. 建立語言檔案
```bash
cp lang/zh_TW.sh lang/新語言代碼.sh
# 編輯檔案，翻譯所有 MSG_* 變數
```

### 2. 更新支援清單
在 `lang/i18n.sh` 中更新 `SUPPORTED_LANGS` 陣列：
```bash
SUPPORTED_LANGS=("zh_TW" "en_US" "新語言代碼")
```

### 3. 新增顯示名稱
在 `get_language_display_name()` 函數中新增案例：
```bash
新語言代碼)
    echo "語言顯示名稱"
    ;;
```

## 測試

執行多語言功能測試：
```bash
./test_i18n.sh
```

## 注意事項

1. **編碼**：所有語言檔案應使用 UTF-8 編碼
2. **變數命名**：所有翻譯訊息變數必須以 `MSG_` 開頭
3. **特殊字符**：保持 emoji 和特殊符號在翻譯中的一致性
4. **格式化**：翻譯中可包含 bash 顏色代碼和格式化字符
5. **動態內容**：使用變數插值處理動態內容（如路徑、檔名等）

## 故障排除

### 常見問題

**Q: 翻譯沒有生效？**
A: 檢查語言檔案是否存在，確認 `init_i18n` 是否成功執行

**Q: 部分文字沒有翻譯？**
A: 檢查是否使用了 `t()` 函數，確認翻譯 key 是否正確

**Q: 語言設定不持久？**
A: 確認設定檔 `~/.get_audio_text_i18n` 的權限和內容

### 除錯模式
```bash
source lang/i18n.sh
init_i18n
debug_i18n  # 顯示除錯資訊
```