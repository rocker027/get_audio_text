#!/bin/bash

# 檢測 Get Audio Text Chrome 擴展 ID

set -e

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔍 檢測 Chrome 擴展 ID${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Chrome 擴展目錄路徑
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CHROME_EXTENSIONS_DIR="$HOME/Library/Application Support/Google/Chrome/Default/Extensions"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    CHROME_EXTENSIONS_DIR="$HOME/.config/google-chrome/Default/Extensions"
else
    echo -e "${RED}❌ 不支援的作業系統: $OSTYPE${NC}"
    exit 1
fi

echo -e "${BLUE}📂 Chrome 擴展目錄: $CHROME_EXTENSIONS_DIR${NC}"

if [[ ! -d "$CHROME_EXTENSIONS_DIR" ]]; then
    echo -e "${RED}❌ Chrome 擴展目錄不存在${NC}"
    echo -e "${YELLOW}💡 請確認：${NC}"
    echo -e "   1. Chrome 已安裝並至少開啟過一次"
    echo -e "   2. Get Audio Text 擴展已載入"
    exit 1
fi

# 尋找可能的擴展 ID
echo -e "${YELLOW}🔍 搜尋 Get Audio Text 擴展...${NC}"

FOUND_IDS=()

# 搜尋包含 "Get Audio Text" 的 manifest.json
for ext_dir in "$CHROME_EXTENSIONS_DIR"/*; do
    if [[ -d "$ext_dir" ]]; then
        ext_id=$(basename "$ext_dir")
        
        # 檢查最新版本目錄
        latest_version=$(ls "$ext_dir" | grep -E '^[0-9]+\.' | sort -V | tail -1)
        
        if [[ -n "$latest_version" ]]; then
            manifest_path="$ext_dir/$latest_version/manifest.json"
            
            if [[ -f "$manifest_path" ]]; then
                # 檢查是否為我們的擴展
                if grep -q '"Get Audio Text"' "$manifest_path" 2>/dev/null; then
                    echo -e "${GREEN}✅ 找到擴展: $ext_id${NC}"
                    
                    # 提取詳細信息
                    name=$(grep '"name"' "$manifest_path" | sed 's/.*"name".*: *"\([^"]*\)".*/\1/')
                    version=$(grep '"version"' "$manifest_path" | sed 's/.*"version".*: *"\([^"]*\)".*/\1/')
                    
                    echo -e "   名稱: $name"
                    echo -e "   版本: $version"
                    echo -e "   路徑: $manifest_path"
                    
                    FOUND_IDS+=("$ext_id")
                fi
            fi
        fi
    fi
done

if [[ ${#FOUND_IDS[@]} -eq 0 ]]; then
    echo -e "${RED}❌ 找不到 Get Audio Text 擴展${NC}"
    echo
    echo -e "${YELLOW}💡 請確認：${NC}"
    echo -e "   1. 擴展已載入到 Chrome"
    echo -e "   2. 前往 chrome://extensions/ 檢查擴展狀態"
    echo -e "   3. 手動複製擴展 ID：在擴展卡片上會顯示 ID"
    echo
    echo -e "${BLUE}📋 手動步驟：${NC}"
    echo -e "   1. 前往 chrome://extensions/"
    echo -e "   2. 開啟右上角的「開發者模式」"
    echo -e "   3. 找到 Get Audio Text 擴展"
    echo -e "   4. 複製 ID（通常在擴展名稱下方）"
    echo -e "   5. 執行: ./update_extension_id.sh [複製的ID]"
    exit 1
elif [[ ${#FOUND_IDS[@]} -eq 1 ]]; then
    EXTENSION_ID="${FOUND_IDS[0]}"
    echo
    echo -e "${GREEN}🎉 自動檢測到擴展 ID: $EXTENSION_ID${NC}"
    
    # 自動更新 host_manifest.json
    echo -e "${YELLOW}📝 更新 host_manifest.json...${NC}"
    
    CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    HOST_MANIFEST="$CURRENT_DIR/host_manifest.json"
    
    if [[ -f "$HOST_MANIFEST" ]]; then
        # 備份原檔案
        cp "$HOST_MANIFEST" "$HOST_MANIFEST.backup"
        
        # 更新擴展 ID
        sed "s|chrome-extension://[^/]*/|chrome-extension://$EXTENSION_ID/|g" "$HOST_MANIFEST.backup" > "$HOST_MANIFEST"
        
        echo -e "${GREEN}✅ host_manifest.json 已更新${NC}"
        echo -e "   舊 ID: $(grep 'chrome-extension://' "$HOST_MANIFEST.backup" | sed 's/.*chrome-extension:\/\/\([^/]*\)\/.*/\1/')"
        echo -e "   新 ID: $EXTENSION_ID"
        
        # 顯示更新後的內容
        echo
        echo -e "${BLUE}📄 更新後的 host_manifest.json:${NC}"
        cat "$HOST_MANIFEST"
        
    else
        echo -e "${RED}❌ 找不到 host_manifest.json${NC}"
        exit 1
    fi
    
else
    echo -e "${YELLOW}⚠️  發現多個可能的擴展 ID:${NC}"
    for i in "${!FOUND_IDS[@]}"; do
        echo -e "   $((i+1)). ${FOUND_IDS[$i]}"
    done
    echo
    echo -e "${BLUE}請手動選擇正確的 ID 並執行:${NC}"
    echo -e "   ./update_extension_id.sh [選擇的ID]"
fi

echo
echo -e "${BLUE}🔄 下一步：重新安裝 Native Host${NC}"
echo -e "   ./install.sh"