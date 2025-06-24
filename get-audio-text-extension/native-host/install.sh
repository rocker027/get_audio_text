#!/bin/bash

# Get Audio Text Native Host 安裝腳本

set -e

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔧 Get Audio Text Native Host 安裝程序${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 獲取當前目錄
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_MANIFEST="$CURRENT_DIR/host_manifest.json"
HOST_SCRIPT="$CURRENT_DIR/get_audio_text_host.py"

echo -e "${BLUE}📁 當前目錄: $CURRENT_DIR${NC}"

# 檢查必要檔案
echo -e "${YELLOW}🔍 檢查必要檔案...${NC}"

if [[ ! -f "$HOST_MANIFEST" ]]; then
    echo -e "${RED}❌ 找不到 host_manifest.json${NC}"
    exit 1
fi

if [[ ! -f "$HOST_SCRIPT" ]]; then
    echo -e "${RED}❌ 找不到 get_audio_text_host.py${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 檔案檢查完成${NC}"

# 檢查 Python
echo -e "${YELLOW}🐍 檢查 Python 環境...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ 找不到 python3，請先安裝 Python 3${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}✅ Python 版本: $PYTHON_VERSION${NC}"

# 確保 Python 腳本有執行權限
chmod +x "$HOST_SCRIPT"
echo -e "${GREEN}✅ 設置 Python 腳本執行權限${NC}"

# 檢查 get_audio_text.sh 腳本
MAIN_SCRIPT="$CURRENT_DIR/../../get_audio_text.sh"
echo -e "${YELLOW}🔍 檢查主腳本: $MAIN_SCRIPT${NC}"

if [[ ! -f "$MAIN_SCRIPT" ]]; then
    echo -e "${RED}❌ 找不到 get_audio_text.sh 腳本${NC}"
    echo -e "${YELLOW}   請確認腳本位於: $MAIN_SCRIPT${NC}"
    exit 1
fi

if [[ ! -x "$MAIN_SCRIPT" ]]; then
    echo -e "${YELLOW}⚠️  主腳本沒有執行權限，正在設置...${NC}"
    chmod +x "$MAIN_SCRIPT"
fi

echo -e "${GREEN}✅ 主腳本檢查完成${NC}"

# 檢查依賴工具
echo -e "${YELLOW}🔧 檢查依賴工具...${NC}"

check_tool() {
    local tool=$1
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✅ $tool 已安裝${NC}"
        return 0
    else
        echo -e "${RED}❌ $tool 未安裝${NC}"
        return 1
    fi
}

MISSING_TOOLS=()

if ! check_tool "yt-dlp"; then
    MISSING_TOOLS+=("yt-dlp")
fi

if ! check_tool "ffmpeg"; then
    MISSING_TOOLS+=("ffmpeg")
fi

if ! check_tool "whisper"; then
    MISSING_TOOLS+=("whisper")
fi

if [[ ${#MISSING_TOOLS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  發現缺少的工具: ${MISSING_TOOLS[*]}${NC}"
    echo -e "${BLUE}💡 請使用以下命令安裝:${NC}"
    echo -e "${BLUE}   brew install yt-dlp ffmpeg${NC}"
    echo -e "${BLUE}   pip3 install openai-whisper${NC}"
    echo
    read -p "是否繼續安裝 Native Host？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}安裝已取消${NC}"
        exit 0
    fi
fi

# 確定 Chrome Native Messaging 目錄
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    NATIVE_MSG_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    NATIVE_MSG_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
else
    echo -e "${RED}❌ 不支援的作業系統: $OSTYPE${NC}"
    exit 1
fi

echo -e "${BLUE}📂 Native Messaging 目錄: $NATIVE_MSG_DIR${NC}"

# 建立目錄
mkdir -p "$NATIVE_MSG_DIR"

# 更新 manifest 中的路徑
echo -e "${YELLOW}📝 更新 manifest 路徑...${NC}"
TEMP_MANIFEST=$(mktemp)
sed "s|\"path\": \".*\"|\"path\": \"$HOST_SCRIPT\"|" "$HOST_MANIFEST" > "$TEMP_MANIFEST"

# 複製 manifest 到 Chrome 目錄
cp "$TEMP_MANIFEST" "$NATIVE_MSG_DIR/com.get_audio_text.host.json"
rm "$TEMP_MANIFEST"

echo -e "${GREEN}✅ Native Host manifest 已安裝${NC}"

# 檢查並自動更新 Chrome 擴展 ID
echo -e "${YELLOW}🔍 檢查 Chrome 擴展 ID...${NC}"

CURRENT_EXTENSION_ID=$(grep -o 'chrome-extension://[^/]*' "$HOST_MANIFEST" | sed 's|chrome-extension://||' | sed 's|/$||')

if [[ -n "$CURRENT_EXTENSION_ID" ]]; then
    echo -e "${BLUE}📋 當前設定的擴展 ID: $CURRENT_EXTENSION_ID${NC}"
    
    # 嘗試自動檢測正確的擴展 ID
    echo -e "${YELLOW}🤖 嘗試自動檢測擴展 ID...${NC}"
    
    if [[ -f "$CURRENT_DIR/detect_extension_id.sh" ]]; then
        # 運行檢測腳本（但不自動更新，只檢測）
        DETECTED_ID=""
        
        # Chrome 擴展目錄路徑
        if [[ "$OSTYPE" == "darwin"* ]]; then
            CHROME_EXTENSIONS_DIR="$HOME/Library/Application Support/Google/Chrome/Default/Extensions"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            CHROME_EXTENSIONS_DIR="$HOME/.config/google-chrome/Default/Extensions"
        fi
        
        if [[ -d "$CHROME_EXTENSIONS_DIR" ]]; then
            # 尋找包含 "Get Audio Text" 的 manifest.json
            for ext_dir in "$CHROME_EXTENSIONS_DIR"/*; do
                if [[ -d "$ext_dir" ]]; then
                    ext_id=$(basename "$ext_dir")
                    latest_version=$(ls "$ext_dir" 2>/dev/null | grep -E '^[0-9]+\.' | sort -V | tail -1)
                    
                    if [[ -n "$latest_version" ]]; then
                        manifest_path="$ext_dir/$latest_version/manifest.json"
                        
                        if [[ -f "$manifest_path" ]] && grep -q '"Get Audio Text"' "$manifest_path" 2>/dev/null; then
                            DETECTED_ID="$ext_id"
                            break
                        fi
                    fi
                fi
            done
        fi
        
        if [[ -n "$DETECTED_ID" ]]; then
            if [[ "$DETECTED_ID" != "$CURRENT_EXTENSION_ID" ]]; then
                echo -e "${YELLOW}🔍 檢測到不同的擴展 ID: $DETECTED_ID${NC}"
                echo -e "${YELLOW}是否要更新到檢測到的 ID？(y/N): ${NC}"
                read -n 1 -r
                echo
                
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    # 更新擴展 ID
                    sed "s|chrome-extension://[^/]*/|chrome-extension://$DETECTED_ID/|g" "$HOST_MANIFEST" > "$HOST_MANIFEST.tmp"
                    mv "$HOST_MANIFEST.tmp" "$HOST_MANIFEST"
                    echo -e "${GREEN}✅ 擴展 ID 已更新為: $DETECTED_ID${NC}"
                    CURRENT_EXTENSION_ID="$DETECTED_ID"
                fi
            else
                echo -e "${GREEN}✅ 擴展 ID 配置正確${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  無法自動檢測擴展 ID${NC}"
            echo -e "${BLUE}💡 如果安裝後無法連接，請手動執行:${NC}"
            echo -e "   ./detect_extension_id.sh"
        fi
    fi
    
    echo -e "${BLUE}📋 最終擴展 ID: $CURRENT_EXTENSION_ID${NC}"
else
    echo -e "${RED}❌ host_manifest.json 中沒有找到擴展 ID${NC}"
    exit 1
fi

# 測試安裝
echo -e "${YELLOW}🧪 測試 Native Host 安裝...${NC}"

if python3 -c "
import json
import sys
try:
    # 簡單測試
    manifest_path = '$NATIVE_MSG_DIR/com.get_audio_text.host.json'
    with open(manifest_path, 'r') as f:
        manifest = json.load(f)
    print('✅ Manifest 讀取成功')
    print(f'   Host: {manifest[\"name\"]}')
    print(f'   Path: {manifest[\"path\"]}')
    sys.exit(0)
except Exception as e:
    print(f'❌ 測試失敗: {e}')
    sys.exit(1)
"; then
    echo -e "${GREEN}✅ Native Host 安裝測試通過${NC}"
else
    echo -e "${RED}❌ Native Host 安裝測試失敗${NC}"
    exit 1
fi

echo
echo -e "${GREEN}🎉 Native Host 安裝完成！${NC}"
echo
echo -e "${BLUE}📋 後續步驟:${NC}"
echo -e "1. 在 Chrome 中前往 chrome://extensions/"
echo -e "2. 重新載入 Get Audio Text 擴展"
echo -e "3. 前往支援的網站測試轉錄功能"
echo
echo -e "${BLUE}📁 檔案位置:${NC}"
echo -e "   Native Host: $NATIVE_MSG_DIR/com.get_audio_text.host.json"
echo -e "   Python 腳本: $HOST_SCRIPT"
echo -e "   主腳本: $MAIN_SCRIPT"
echo
echo -e "${YELLOW}💡 提示: 如遇問題，請檢查日誌檔案: ~/get_audio_text_host.log${NC}"