#!/bin/bash

# 測試 Native Host 連接和功能

set -e

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🧪 Native Host 功能測試${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_SCRIPT="$CURRENT_DIR/get_audio_text_host.py"
HOST_MANIFEST="$CURRENT_DIR/host_manifest.json"

# 測試 1: 檢查檔案存在
echo -e "${YELLOW}📁 檢查必要檔案...${NC}"

check_file() {
    local file="$1"
    local desc="$2"
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✅ $desc: $(basename "$file")${NC}"
        return 0
    else
        echo -e "${RED}❌ $desc: $(basename "$file") 不存在${NC}"
        return 1
    fi
}

FILES_OK=true
check_file "$HOST_SCRIPT" "Python 橋接程序" || FILES_OK=false
check_file "$HOST_MANIFEST" "Host manifest" || FILES_OK=false

if [[ "$FILES_OK" != "true" ]]; then
    echo -e "${RED}❌ 必要檔案缺失，請先執行 install.sh${NC}"
    exit 1
fi

# 測試 2: 檢查權限
echo
echo -e "${YELLOW}🔐 檢查檔案權限...${NC}"

if [[ -x "$HOST_SCRIPT" ]]; then
    echo -e "${GREEN}✅ Python 腳本有執行權限${NC}"
else
    echo -e "${RED}❌ Python 腳本沒有執行權限${NC}"
    echo -e "${BLUE}💡 修復: chmod +x $HOST_SCRIPT${NC}"
    exit 1
fi

# 測試 3: 檢查 Python 環境
echo
echo -e "${YELLOW}🐍 檢查 Python 環境...${NC}"

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✅ Python 環境: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}❌ 找不到 python3${NC}"
    exit 1
fi

# 測試 4: 檢查 Native Host 註冊
echo
echo -e "${YELLOW}📋 檢查 Native Host 註冊...${NC}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    NATIVE_MSG_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    NATIVE_MSG_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
else
    echo -e "${RED}❌ 不支援的作業系統: $OSTYPE${NC}"
    exit 1
fi

INSTALLED_MANIFEST="$NATIVE_MSG_DIR/com.get_audio_text.host.json"

if [[ -f "$INSTALLED_MANIFEST" ]]; then
    echo -e "${GREEN}✅ Native Host 已註冊${NC}"
    echo -e "   位置: $INSTALLED_MANIFEST"
    
    # 檢查路徑是否正確
    INSTALLED_PATH=$(grep '"path"' "$INSTALLED_MANIFEST" | sed 's/.*"path": *"\([^"]*\)".*/\1/')
    if [[ "$INSTALLED_PATH" == "$HOST_SCRIPT" ]]; then
        echo -e "${GREEN}✅ 路徑配置正確${NC}"
    else
        echo -e "${RED}❌ 路徑配置錯誤${NC}"
        echo -e "   設定路徑: $INSTALLED_PATH"
        echo -e "   實際路徑: $HOST_SCRIPT"
        echo -e "${BLUE}💡 修復: 重新執行 install.sh${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Native Host 未註冊${NC}"
    echo -e "${BLUE}💡 修復: 執行 install.sh${NC}"
    exit 1
fi

# 測試 5: 測試 Python 腳本基本功能
echo
echo -e "${YELLOW}🔧 測試 Python 腳本...${NC}"

# 測試依賴檢查
echo -e "${BLUE}   測試依賴檢查...${NC}"
TEST_INPUT='{"action":"check_dependencies"}'

PYTHON_TEST_RESULT=$(echo "$TEST_INPUT" | python3 "$HOST_SCRIPT" 2>&1)
PYTHON_EXIT_CODE=$?

if [[ $PYTHON_EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✅ Python 腳本可正常執行${NC}"
    
    # 解析回應
    if echo "$PYTHON_TEST_RESULT" | grep -q '"success"'; then
        if echo "$PYTHON_TEST_RESULT" | grep -q '"success": *true'; then
            echo -e "${GREEN}✅ 系統依賴檢查通過${NC}"
        else
            echo -e "${YELLOW}⚠️  系統依賴檢查失敗（這可能是正常的）${NC}"
            ERROR_MSG=$(echo "$PYTHON_TEST_RESULT" | grep '"message"' | sed 's/.*"message": *"\([^"]*\)".*/\1/')
            if [[ -n "$ERROR_MSG" ]]; then
                echo -e "   原因: $ERROR_MSG"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  Python 腳本回應格式異常${NC}"
        echo -e "   回應: $PYTHON_TEST_RESULT"
    fi
else
    echo -e "${RED}❌ Python 腳本執行失敗${NC}"
    echo -e "   錯誤: $PYTHON_TEST_RESULT"
    exit 1
fi

# 測試 6: 檢查主腳本
echo
echo -e "${YELLOW}📜 檢查主腳本...${NC}"

MAIN_SCRIPT="$CURRENT_DIR/../../get_audio_text.sh"

if [[ -f "$MAIN_SCRIPT" ]]; then
    echo -e "${GREEN}✅ 主腳本存在: $(basename "$MAIN_SCRIPT")${NC}"
    
    if [[ -x "$MAIN_SCRIPT" ]]; then
        echo -e "${GREEN}✅ 主腳本有執行權限${NC}"
    else
        echo -e "${YELLOW}⚠️  主腳本沒有執行權限${NC}"
        echo -e "${BLUE}💡 修復: chmod +x $MAIN_SCRIPT${NC}"
    fi
    
    # 檢查音訊目錄配置
    AUDIO_DIR=$(grep '^AUDIO_DIR=' "$MAIN_SCRIPT" | cut -d'"' -f2)
    if [[ "$AUDIO_DIR" == "abs_path_to_audio_dir" ]]; then
        echo -e "${RED}❌ 音訊目錄未配置（仍為佔位符）${NC}"
        echo -e "${BLUE}💡 修復: ./configure_audio_dir.sh${NC}"
    elif [[ -d "$AUDIO_DIR" ]]; then
        echo -e "${GREEN}✅ 音訊目錄已配置且存在: $AUDIO_DIR${NC}"
    else
        echo -e "${YELLOW}⚠️  音訊目錄已配置但不存在: $AUDIO_DIR${NC}"
        echo -e "${BLUE}💡 修復: mkdir -p \"$AUDIO_DIR\"${NC}"
    fi
else
    echo -e "${RED}❌ 找不到主腳本: $MAIN_SCRIPT${NC}"
    exit 1
fi

# 測試 7: 檢查系統工具
echo
echo -e "${YELLOW}🛠️  檢查系統工具...${NC}"

check_tool() {
    local tool="$1"
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✅ $tool 已安裝${NC}"
        return 0
    else
        echo -e "${RED}❌ $tool 未安裝${NC}"
        return 1
    fi
}

TOOLS_OK=true
check_tool "yt-dlp" || TOOLS_OK=false
check_tool "ffmpeg" || TOOLS_OK=false
check_tool "whisper" || TOOLS_OK=false

if [[ "$TOOLS_OK" != "true" ]]; then
    echo -e "${YELLOW}⚠️  部分工具未安裝${NC}"
    echo -e "${BLUE}💡 安裝指令:${NC}"
    echo -e "   brew install yt-dlp ffmpeg"
    echo -e "   pip3 install openai-whisper"
fi

# 測試總結
echo
echo -e "${BLUE}📊 測試總結${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [[ "$FILES_OK" == "true" && $PYTHON_EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}🎉 Native Host 基本功能測試通過！${NC}"
    echo
    echo -e "${BLUE}🔄 下一步：在 Chrome 中測試${NC}"
    echo -e "   1. 前往 chrome://extensions/"
    echo -e "   2. 重新載入 Get Audio Text 擴展"
    echo -e "   3. 前往 YouTube 等支援網站"
    echo -e "   4. 點擊轉錄按鈕測試"
    echo
    echo -e "${BLUE}🐛 如果仍然失敗，請檢查：${NC}"
    echo -e "   • Chrome 開發者工具的 Console 錯誤"
    echo -e "   • 日誌檔案: ~/get_audio_text_host.log"
    echo -e "   • 擴展 ID 是否正確"
else
    echo -e "${RED}❌ Native Host 測試失敗${NC}"
    echo -e "${BLUE}💡 請根據上述錯誤信息進行修復${NC}"
fi