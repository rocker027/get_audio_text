#!/bin/bash

# 一鍵修復 Native Messaging 連接問題

set -e

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔧 Native Messaging 連接修復工具${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "${YELLOW}此工具將自動診斷並修復常見的連接問題${NC}"
echo

# 步驟 1: 檢測並更新擴展 ID
echo -e "${BLUE}步驟 1/4: 檢測擴展 ID${NC}"
if [[ -f "detect_extension_id.sh" ]]; then
    if ./detect_extension_id.sh; then
        echo -e "${GREEN}✅ 擴展 ID 檢測完成${NC}"
    else
        echo -e "${YELLOW}⚠️  自動檢測失敗，請手動處理${NC}"
        echo -e "${BLUE}💡 請前往 chrome://extensions/ 複製擴展 ID，然後執行:${NC}"
        echo -e "   ./update_extension_id.sh [擴展ID]"
        read -p "按 Enter 繼續或 Ctrl+C 退出..."
    fi
else
    echo -e "${RED}❌ 找不到檢測腳本${NC}"
    exit 1
fi

echo

# 步驟 2: 配置音訊目錄
echo -e "${BLUE}步驟 2/4: 配置音訊目錄${NC}"
if [[ -f "configure_audio_dir.sh" ]]; then
    ./configure_audio_dir.sh
    echo -e "${GREEN}✅ 音訊目錄配置完成${NC}"
else
    echo -e "${RED}❌ 找不到配置腳本${NC}"
    exit 1
fi

echo

# 步驟 3: 安裝 Native Host
echo -e "${BLUE}步驟 3/4: 安裝 Native Host${NC}"
if [[ -f "install.sh" ]]; then
    ./install.sh
    echo -e "${GREEN}✅ Native Host 安裝完成${NC}"
else
    echo -e "${RED}❌ 找不到安裝腳本${NC}"
    exit 1
fi

echo

# 步驟 4: 測試連接
echo -e "${BLUE}步驟 4/4: 測試連接${NC}"
if [[ -f "test_native_host.sh" ]]; then
    if ./test_native_host.sh; then
        echo
        echo -e "${GREEN}🎉 修復完成！Native Host 應該可以正常運作了${NC}"
        echo
        echo -e "${BLUE}📋 接下來請執行：${NC}"
        echo -e "   1. 前往 chrome://extensions/"
        echo -e "   2. 重新載入 Get Audio Text 擴展"
        echo -e "   3. 前往 YouTube 等網站測試轉錄功能"
        echo
        echo -e "${YELLOW}💡 如果仍然出現問題，請查看：${NC}"
        echo -e "   • TROUBLESHOOTING.md - 詳細故障排除指南"
        echo -e "   • ~/get_audio_text_host.log - 錯誤日誌"
    else
        echo
        echo -e "${RED}❌ 測試失敗，仍有問題需要解決${NC}"
        echo -e "${BLUE}💡 請查看 TROUBLESHOOTING.md 獲得更多幫助${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ 找不到測試腳本${NC}"
    exit 1
fi

echo
echo -e "${GREEN}🎯 修復程序完成！${NC}"