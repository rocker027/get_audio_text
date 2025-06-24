#!/bin/bash

# 手動更新 Chrome 擴展 ID

set -e

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ $# -ne 1 ]]; then
    echo -e "${RED}❌ 用法: $0 <擴展ID>${NC}"
    echo
    echo -e "${BLUE}📋 如何獲取擴展 ID：${NC}"
    echo -e "   1. 前往 chrome://extensions/"
    echo -e "   2. 開啟右上角的「開發者模式」"
    echo -e "   3. 找到 Get Audio Text 擴展"
    echo -e "   4. 複製 ID（在擴展名稱下方，類似：abcdefghijklmnopqrstuvwxyz123456）"
    echo
    echo -e "${BLUE}📝 範例：${NC}"
    echo -e "   $0 abcdefghijklmnopqrstuvwxyz123456"
    exit 1
fi

EXTENSION_ID="$1"

# 驗證擴展 ID 格式
if [[ ! "$EXTENSION_ID" =~ ^[a-z]{32}$ ]]; then
    echo -e "${RED}❌ 無效的擴展 ID 格式${NC}"
    echo -e "${YELLOW}   擴展 ID 應該是 32 個小寫字母組成${NC}"
    echo -e "${YELLOW}   您提供的 ID: $EXTENSION_ID (長度: ${#EXTENSION_ID})${NC}"
    exit 1
fi

echo -e "${BLUE}🔧 更新擴展 ID 為: $EXTENSION_ID${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_MANIFEST="$CURRENT_DIR/host_manifest.json"

if [[ ! -f "$HOST_MANIFEST" ]]; then
    echo -e "${RED}❌ 找不到 host_manifest.json${NC}"
    exit 1
fi

# 備份原檔案
cp "$HOST_MANIFEST" "$HOST_MANIFEST.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${BLUE}📦 已備份原檔案${NC}"

# 讀取並顯示當前 ID
OLD_ID=$(grep 'chrome-extension://' "$HOST_MANIFEST" | sed 's/.*chrome-extension:\/\/\([^/]*\)\/.*/\1/' | head -1)

if [[ -n "$OLD_ID" ]]; then
    echo -e "${YELLOW}📋 當前擴展 ID: $OLD_ID${NC}"
    
    if [[ "$OLD_ID" == "$EXTENSION_ID" ]]; then
        echo -e "${GREEN}✅ 擴展 ID 已經是正確的，無需更新${NC}"
        exit 0
    fi
fi

# 更新擴展 ID
sed "s|chrome-extension://[^/]*/|chrome-extension://$EXTENSION_ID/|g" "$HOST_MANIFEST" > "$HOST_MANIFEST.tmp"

if [[ $? -eq 0 ]]; then
    mv "$HOST_MANIFEST.tmp" "$HOST_MANIFEST"
    echo -e "${GREEN}✅ host_manifest.json 已更新${NC}"
    echo -e "   舊 ID: $OLD_ID"
    echo -e "   新 ID: $EXTENSION_ID"
else
    echo -e "${RED}❌ 更新失敗${NC}"
    rm -f "$HOST_MANIFEST.tmp"
    exit 1
fi

# 顯示更新後的內容
echo
echo -e "${BLUE}📄 更新後的 host_manifest.json:${NC}"
cat "$HOST_MANIFEST"

echo
echo -e "${GREEN}🎉 擴展 ID 更新完成！${NC}"
echo
echo -e "${BLUE}🔄 下一步：重新安裝 Native Host${NC}"
echo -e "   ./install.sh"