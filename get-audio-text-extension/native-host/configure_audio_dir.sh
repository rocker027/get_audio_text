#!/bin/bash

# 配置 get_audio_text.sh 音訊目錄

set -e

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📁 配置音訊目錄${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 尋找主腳本
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$CURRENT_DIR/../../get_audio_text.sh"

echo -e "${BLUE}📂 主腳本路徑: $MAIN_SCRIPT${NC}"

if [[ ! -f "$MAIN_SCRIPT" ]]; then
    echo -e "${RED}❌ 找不到主腳本: $MAIN_SCRIPT${NC}"
    exit 1
fi

# 檢查當前配置
CURRENT_AUDIO_DIR=$(grep '^AUDIO_DIR=' "$MAIN_SCRIPT" | cut -d'"' -f2)
echo -e "${YELLOW}📋 當前音訊目錄: $CURRENT_AUDIO_DIR${NC}"

if [[ "$CURRENT_AUDIO_DIR" == "abs_path_to_audio_dir" ]]; then
    echo -e "${RED}⚠️  音訊目錄尚未配置（仍為佔位符）${NC}"
    NEEDS_CONFIG=true
else
    echo -e "${GREEN}✅ 音訊目錄已配置${NC}"
    
    if [[ -d "$CURRENT_AUDIO_DIR" ]]; then
        echo -e "${GREEN}✅ 目錄存在且可存取${NC}"
        NEEDS_CONFIG=false
    else
        echo -e "${YELLOW}⚠️  配置的目錄不存在: $CURRENT_AUDIO_DIR${NC}"
        NEEDS_CONFIG=true
    fi
fi

if [[ "$NEEDS_CONFIG" == "true" ]]; then
    echo
    echo -e "${BLUE}💡 建議的音訊目錄選項：${NC}"
    echo -e "   1. $HOME/Downloads/AudioCapture"
    echo -e "   2. $HOME/Documents/AudioCapture"
    echo -e "   3. $HOME/Desktop/AudioCapture"
    echo -e "   4. 自訂路徑"
    echo
    
    while true; do
        read -p "請選擇選項 (1-4): " choice
        
        case $choice in
            1)
                NEW_AUDIO_DIR="$HOME/Downloads/AudioCapture"
                break
                ;;
            2)
                NEW_AUDIO_DIR="$HOME/Documents/AudioCapture"
                break
                ;;
            3)
                NEW_AUDIO_DIR="$HOME/Desktop/AudioCapture"
                break
                ;;
            4)
                echo
                read -p "請輸入自訂路徑: " NEW_AUDIO_DIR
                
                # 展開波浪號
                NEW_AUDIO_DIR="${NEW_AUDIO_DIR/#\~/$HOME}"
                
                if [[ -z "$NEW_AUDIO_DIR" ]]; then
                    echo -e "${RED}❌ 路徑不能為空${NC}"
                    continue
                fi
                break
                ;;
            *)
                echo -e "${RED}❌ 無效選項，請選擇 1-4${NC}"
                continue
                ;;
        esac
    done
    
    echo
    echo -e "${BLUE}📁 將設置音訊目錄為: $NEW_AUDIO_DIR${NC}"
    
    # 建立目錄
    if [[ ! -d "$NEW_AUDIO_DIR" ]]; then
        echo -e "${YELLOW}📂 建立目錄...${NC}"
        if mkdir -p "$NEW_AUDIO_DIR"; then
            echo -e "${GREEN}✅ 目錄建立成功${NC}"
        else
            echo -e "${RED}❌ 無法建立目錄${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ 目錄已存在${NC}"
    fi
    
    # 備份原檔案
    cp "$MAIN_SCRIPT" "$MAIN_SCRIPT.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${BLUE}📦 已備份原檔案${NC}"
    
    # 更新腳本
    sed "s|^AUDIO_DIR=\".*\"|AUDIO_DIR=\"$NEW_AUDIO_DIR\"|" "$MAIN_SCRIPT" > "$MAIN_SCRIPT.tmp"
    
    if [[ $? -eq 0 ]]; then
        mv "$MAIN_SCRIPT.tmp" "$MAIN_SCRIPT"
        echo -e "${GREEN}✅ 主腳本已更新${NC}"
        
        # 驗證更新
        UPDATED_AUDIO_DIR=$(grep '^AUDIO_DIR=' "$MAIN_SCRIPT" | cut -d'"' -f2)
        echo -e "   音訊目錄: $UPDATED_AUDIO_DIR"
        
        # 建立轉錄子目錄
        mkdir -p "$NEW_AUDIO_DIR/Transcripts"
        echo -e "${GREEN}✅ 轉錄目錄已建立: $NEW_AUDIO_DIR/Transcripts${NC}"
        
    else
        echo -e "${RED}❌ 更新失敗${NC}"
        rm -f "$MAIN_SCRIPT.tmp"
        exit 1
    fi
    
else
    echo -e "${GREEN}✅ 音訊目錄配置正確，無需更新${NC}"
fi

# 檢查腳本權限
if [[ ! -x "$MAIN_SCRIPT" ]]; then
    echo -e "${YELLOW}🔧 設置腳本執行權限...${NC}"
    chmod +x "$MAIN_SCRIPT"
    echo -e "${GREEN}✅ 執行權限已設置${NC}"
fi

# 驗證配置
echo
echo -e "${BLUE}🧪 驗證配置...${NC}"

FINAL_AUDIO_DIR=$(grep '^AUDIO_DIR=' "$MAIN_SCRIPT" | cut -d'"' -f2)

echo -e "   音訊目錄: $FINAL_AUDIO_DIR"
echo -e "   目錄存在: $(if [[ -d "$FINAL_AUDIO_DIR" ]]; then echo "✅ 是"; else echo "❌ 否"; fi)"
echo -e "   可寫入: $(if [[ -w "$FINAL_AUDIO_DIR" ]]; then echo "✅ 是"; else echo "❌ 否"; fi)"
echo -e "   腳本權限: $(if [[ -x "$MAIN_SCRIPT" ]]; then echo "✅ 可執行"; else echo "❌ 無執行權限"; fi)"

echo
echo -e "${GREEN}🎉 音訊目錄配置完成！${NC}"
echo
echo -e "${BLUE}📁 設定摘要：${NC}"
echo -e "   音訊檔案將保存至: $FINAL_AUDIO_DIR"
echo -e "   轉錄檔案將保存至: $FINAL_AUDIO_DIR/Transcripts"
echo
echo -e "${BLUE}🔄 下一步：安裝 Native Host${NC}"
echo -e "   ./install.sh"