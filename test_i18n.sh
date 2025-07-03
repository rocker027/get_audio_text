#!/bin/bash

# 多語言功能測試腳本
echo "🧪 多語言功能測試開始..."
echo "================================"

# 測試腳本目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 測試中文
echo ""
echo "📝 測試繁體中文..."
echo 'PREFERRED_LANG="zh_TW"' > ~/.get_audio_text_i18n
source "$SCRIPT_DIR/lang/i18n.sh"
init_i18n
echo "語言: $(get_current_language)"
echo "標題: $(t MSG_APP_TITLE)"
echo "歡迎訊息: $(t MSG_WELCOME)"
echo "設定完成: $(t MSG_SETUP_COMPLETE)"

# 測試英文
echo ""
echo "📝 測試英文..."
echo 'PREFERRED_LANG="en_US"' > ~/.get_audio_text_i18n
source "$SCRIPT_DIR/lang/i18n.sh"
init_i18n
echo "Language: $(get_current_language)"
echo "Title: $(t MSG_APP_TITLE)"
echo "Welcome: $(t MSG_WELCOME)"
echo "Setup Complete: $(t MSG_SETUP_COMPLETE)"

# 測試實際腳本執行
echo ""
echo "📝 測試實際腳本執行..."
echo ""
echo "--- 中文版本 ---"
echo 'PREFERRED_LANG="zh_TW"' > ~/.get_audio_text_i18n
timeout 3 "$SCRIPT_DIR/get_audio_text.sh" --help 2>/dev/null | head -3

echo ""
echo "--- 英文版本 ---"
echo 'PREFERRED_LANG="en_US"' > ~/.get_audio_text_i18n
timeout 3 "$SCRIPT_DIR/get_audio_text.sh" --help 2>/dev/null | head -3

echo ""
echo "✅ 多語言功能測試完成！"