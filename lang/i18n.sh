#!/bin/bash

# 國際化 (i18n) 核心模組
# Internationalization Core Module

# 設定檔路徑
I18N_CONFIG_FILE="$HOME/.get_audio_text_i18n"
LANG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 預設語言設定
DEFAULT_LANG="zh_TW"
CURRENT_LANG=""

# 支援的語言清單
SUPPORTED_LANGS=("zh_TW" "en_US")

# 偵測系統語言
detect_system_language() {
    local system_lang=""
    
    # 嘗試從多個來源獲取語言設定
    if [ -n "$LANG" ]; then
        # 從 LANG 環境變數
        system_lang=$(echo "$LANG" | cut -d'.' -f1)
    elif [ -n "$LC_ALL" ]; then
        # 從 LC_ALL 環境變數
        system_lang=$(echo "$LC_ALL" | cut -d'.' -f1)
    elif [ -n "$LC_MESSAGES" ]; then
        # 從 LC_MESSAGES 環境變數
        system_lang=$(echo "$LC_MESSAGES" | cut -d'.' -f1)
    elif command -v locale >/dev/null 2>&1; then
        # 使用 locale 命令
        system_lang=$(locale | grep "LANG=" | cut -d'=' -f2 | cut -d'.' -f1)
    elif command -v defaults >/dev/null 2>&1; then
        # macOS 特定方法
        system_lang=$(defaults read -g AppleLocale 2>/dev/null || echo "")
    fi
    
    # 移除引號
    system_lang="${system_lang//\"/}"
    
    # 語言代碼轉換
    case "$system_lang" in
        zh_TW|zh-TW|zh_Hant|zh-Hant)
            echo "zh_TW"
            ;;
        zh_CN|zh-CN|zh_Hans|zh-Hans|zh)
            echo "zh_TW"  # 目前使用繁體中文作為中文預設
            ;;
        en_US|en-US|en)
            echo "en_US"
            ;;
        *)
            echo "$DEFAULT_LANG"
            ;;
    esac
}

# 檢查語言是否支援
is_language_supported() {
    local lang="$1"
    local supported_lang
    
    for supported_lang in "${SUPPORTED_LANGS[@]}"; do
        if [ "$lang" = "$supported_lang" ]; then
            return 0
        fi
    done
    return 1
}

# 載入語言設定
load_language_config() {
    if [ -f "$I18N_CONFIG_FILE" ]; then
        source "$I18N_CONFIG_FILE"
        if [ -n "$PREFERRED_LANG" ] && is_language_supported "$PREFERRED_LANG"; then
            echo "$PREFERRED_LANG"
            return 0
        fi
    fi
    
    # 如果沒有設定檔或設定無效，使用系統語言
    detect_system_language
}

# 儲存語言偏好設定
save_language_preference() {
    local lang="$1"
    
    if is_language_supported "$lang"; then
        echo "# get_audio_text 語言偏好設定" > "$I18N_CONFIG_FILE"
        echo "PREFERRED_LANG=\"$lang\"" >> "$I18N_CONFIG_FILE"
        return 0
    else
        return 1
    fi
}

# 載入指定語言檔案
load_language() {
    local lang="$1"
    local lang_file="$LANG_DIR/${lang}.sh"
    
    if [ -f "$lang_file" ]; then
        source "$lang_file"
        CURRENT_LANG="$lang"
        return 0
    else
        return 1
    fi
}

# 初始化多語言支援
init_i18n() {
    local preferred_lang
    
    # 載入語言設定
    preferred_lang=$(load_language_config)
    
    # 嘗試載入偏好語言
    if load_language "$preferred_lang"; then
        return 0
    fi
    
    # 回退到預設語言
    if [ "$preferred_lang" != "$DEFAULT_LANG" ]; then
        if load_language "$DEFAULT_LANG"; then
            return 0
        fi
    fi
    
    # 如果都失敗，嘗試載入任何可用的語言
    local lang
    for lang in "${SUPPORTED_LANGS[@]}"; do
        if load_language "$lang"; then
            return 0
        fi
    done
    
    # 完全失敗
    echo "錯誤: 無法載入任何語言檔案" >&2
    return 1
}

# 獲取目前語言
get_current_language() {
    echo "$CURRENT_LANG"
}

# 列出所有支援的語言
list_supported_languages() {
    printf '%s\n' "${SUPPORTED_LANGS[@]}"
}

# 切換語言
switch_language() {
    local new_lang="$1"
    
    if is_language_supported "$new_lang"; then
        if load_language "$new_lang"; then
            save_language_preference "$new_lang"
            return 0
        fi
    fi
    return 1
}

# 獲取語言顯示名稱
get_language_display_name() {
    local lang="$1"
    
    case "$lang" in
        zh_TW)
            echo "繁體中文 (台灣)"
            ;;
        en_US)
            echo "English (US)"
            ;;
        *)
            echo "$lang"
            ;;
    esac
}

# 翻譯函數（主要介面）
t() {
    local key="$1"
    local default_value="$2"
    local value
    
    # 獲取變數值
    value=$(eval echo "\$$key" 2>/dev/null)
    
    # 如果找不到翻譯，使用預設值或key
    if [ -z "$value" ]; then
        if [ -n "$default_value" ]; then
            echo "$default_value"
        else
            echo "$key"
        fi
    else
        echo "$value"
    fi
}

# 語言選擇互動模式
interactive_language_selection() {
    echo "$(t MSG_SEPARATOR)"
    echo "🌍 語言選擇 / Language Selection"
    echo "$(t MSG_SEPARATOR)"
    echo ""
    
    echo "目前語言 / Current Language: $(get_language_display_name "$CURRENT_LANG")"
    echo ""
    echo "可用語言 / Available Languages:"
    
    local i=1
    local lang
    for lang in "${SUPPORTED_LANGS[@]}"; do
        echo "$i. $(get_language_display_name "$lang")"
        i=$((i + 1))
    done
    
    echo ""
    echo "請選擇語言 / Please select language (1-${#SUPPORTED_LANGS[@]}): "
    read -r selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#SUPPORTED_LANGS[@]}" ]; then
        local selected_lang="${SUPPORTED_LANGS[$((selection - 1))]}"
        if switch_language "$selected_lang"; then
            echo ""
            echo "✅ 語言已切換至: $(get_language_display_name "$selected_lang")"
            echo "✅ Language switched to: $(get_language_display_name "$selected_lang")"
            return 0
        else
            echo ""
            echo "❌ 語言切換失敗 / Language switch failed"
            return 1
        fi
    else
        echo ""
        echo "❌ 無效的選擇 / Invalid selection"
        return 1
    fi
}

# 除錯函數：顯示載入的語言資訊
debug_i18n() {
    echo "=== i18n Debug Information ==="
    echo "Current Language: $CURRENT_LANG"
    echo "Default Language: $DEFAULT_LANG"
    echo "System Language: $(detect_system_language)"
    echo "Config File: $I18N_CONFIG_FILE"
    echo "Language Directory: $LANG_DIR"
    echo "Supported Languages: ${SUPPORTED_LANGS[*]}"
    echo ""
    echo "Sample translations:"
    echo "  MSG_WELCOME: $(t MSG_WELCOME)"
    echo "  MSG_SETUP_COMPLETE: $(t MSG_SETUP_COMPLETE)"
    echo "============================="
}

# 如果直接執行此腳本，顯示除錯資訊
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    init_i18n
    debug_i18n
fi